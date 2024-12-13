/* Copyright (c) 2023 BlackBerry Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import Foundation
import BlackBerryDynamics.AppKinetics

open class Service: NSObject, GDServiceClientDelegate, GDServiceDelegate {
    
    static let sharedInstance = Service()
    fileprivate var service: GDService
    fileprivate var client: GDServiceClient
    
    // Helper static variable with providers array for transfer-file service
    class var serviceProviders: Array<GDServiceProvider> {
        let array = GDiOS.sharedInstance().getServiceProviders(for: Constants.fileTransferGDServiceIdentifier, andVersion: Constants.fileTransferGDServiceVersionIdentifier, andServiceType: .application)
        let path = Bundle.main.path(forResource: "Info", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!)
        let id = dict!["GDApplicationID"] as! String // this application GD Application ID
        
        // remove own id from providers list
        let filtered = array.filter() { $0.identifier != id }
        
        return filtered
    }
    
    fileprivate override init() {
        print(#file, #function)
        
        self.service = GDService()
        self.client = GDServiceClient()
        super.init()
        self.service.delegate = self
        self.client.delegate = self
    }
    
    deinit {
        self.service.delegate = nil
        self.client.delegate = nil
        
        print(#file, #function)
    }
    
    // MARK: Service delegate
    
    public func gdServiceDidReceive(from application: String, forService service: String, withVersion version: String, forMethod method: String, withParams params: Any, withAttachments attachments: [String], forRequestID requestID: String) {
        print(#file, #function)

        // A request for Service has been received. Dispatch it for servicing and return immediately
        // so as not to block the Good run-time. This mechanism may be moved into the Good run-time in the near
        // future.
        DispatchQueue.main.async { () -> Void in
            self.processRequestFor(application, forService: service, withVersion: version, forMethod: method, withParams: params as AnyObject, withAttachments: attachments as [AnyObject], forRequestID: requestID)
        }
    }
    
    //MARK: Service Client delegate
    
    public func gdServiceClientDidReceive(from application: String, withParams params: Any, withAttachments attachments: [String], correspondingToRequestID requestID: String) {
        print(#file, #function)
        // Server could send reply in params. Reply could be as expected or could be an error.
        // Handle reply in view model, which will show an alert.
        // FUTURE: AppKinetics callbacks will be moved to background queue in upcoming releases.
        // Dispatch it to the main thread as an alert will be shown in notification handler.
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.serviceClientDidReceiveFromNotificationIdentifier), object: params)
        }
    }
    
    public func gdServiceClientDidStartSending(to application: String, withFilename filename: String, correspondingToRequestID requestID: String) {
        print(#file, #function)
        // FUTURE: AppKinetics callbacks will be moved to background queue in upcoming releases.
        // Dispatch it to the main thread  as reply will be handled to show an alert.
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.serviceClientDidStartSendingToNotificationIdentifier), object: nil)
        }
    }
    
    public func gdServiceClientDidFinishSending(to application: String, withAttachments attachments: [String], withParams params: Any, correspondingToRequestID requestID: String) {
        print(#file, #function)
        // FUTURE: AppKinetics callbacks will be moved to background queue in upcoming releases.
        // Dispatch it to the main thread  as reply will be handled to show an alert.
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.serviceClientDidFinishSendingToNotificationIdentifier), object: nil)
        }
    }
    
    // MARK: SEND requests
    func sendToWithMethodGreetMe() throws {
        try GDServiceClient.send(to: Constants.servicesServerApplicationGDIdentifier,
            withService: Constants.greetingsGDServiceIdentifier,
            withVersion: Constants.greetingsGDServiceVersionIdentifier,
            withMethod: Constants.greetingsGDServiceMethodIdentifier,
            withParams: nil,
            withAttachments: nil,
            bringServiceToFront: .GDEPreferMeInForeground,
            requestID: nil)
    }
    
    func sendBringToFront() throws {
        try GDServiceClient.bring(toFront: Constants.servicesServerApplicationGDIdentifier, completion: { (success) in
            print("sendBringToFront completed")
        })
    }
    
    func sendToWithMethodGetDateAndTime() throws {
        try GDServiceClient.send(to: Constants.servicesServerApplicationGDIdentifier,
            withService: Constants.dateAndTimeGDServiceIdentifier,
            withVersion: Constants.dateAndTimeGDServiceVersionIdentifier,
            withMethod: Constants.dateAndTimeGDServiceMethodIdentifier,
            withParams: nil,
            withAttachments: nil,
            bringServiceToFront: .GDEPreferMeInForeground,
            requestID: nil)
    }
    
    func sendToWithMethodFileTransfer(_ application: String, withAttachments attachments: Array<String>) throws {
        try GDServiceClient.send(to: application,
            withService: Constants.fileTransferGDServiceIdentifier,
            withVersion: Constants.fileTransferGDServiceVersionIdentifier,
            withMethod: Constants.fileTransferGDServiceMethodIdentifier,
            withParams: nil,
            withAttachments: attachments,
            bringServiceToFront: .GDEPreferPeerInForeground,
            requestID: nil)
    }
    
    // Reply to service could be an error
    func sendErrorTo(_ application: String, withError error: NSError) {
        let requestID : String = ""
        try! GDService.reply(to: application, withParams: error, bringClientToFront: .GDEPreferPeerInForeground, withAttachments: nil, requestID: requestID)
    }
    
    // MARK: GET requests
    func processRequestFor(_ application: String!, forService service: String!, withVersion version: String!, forMethod method: String!, withParams params: AnyObject!, withAttachments attachments: [AnyObject]!, forRequestID requestID: String!) {
        print(#file, #function)
        
        // Check for and possibly consume a front request
        // TODO: Describe more this one
        if !consumeFrontRequestService(service, forApplication: application, forMethod: method, withVersion: version) {
            if service == Constants.fileTransferGDServiceIdentifier {
                if version == Constants.fileTransferGDServiceVersionIdentifier {
                    if method == Constants.fileTransferGDServiceMethodIdentifier {
                        if (attachments != nil) {
                            if (params as? Dictionary<String, Any>) != nil {
                                print("Parameters for method \(String(describing: method)) should be nil but are \(String(describing: params))")
                            } else if attachments.count != 1 {
                                print("Attachments should have one element but has \(attachments.count)")
                            } else {
                                // Countinue
                                NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.serviceDidTransferedFileNotificationIdentifier), object: attachments[0])
                            }
                        } // Attachments
                    } // Method
                } // Version
            } // Service
        } // Consume front request
    }

    // This method will test the service ID of an incoming request and consume a front request. Although the current service
    // definition only has one method we should check anyway as later versions may add methods.
    func consumeFrontRequestService(_ service: String, forApplication application: String, forMethod method: String, withVersion version: String) -> Bool {
        if service == GDFrontRequestService && version == "1.0.0" {
            if method == GDFrontRequestMethod {
                try! GDService.bring(toFront:application, completion: { (success) in
                    print("bring to front to \(application) completed")
                })
            } else {
                let dictionary: Dictionary = ["Error" : NSLocalizedDescriptionKey]
                let error = NSError.init(domain: GDServicesErrorDomain, code: GDServicesErrorServiceNotFound, userInfo: dictionary)
                sendErrorTo(application, withError: error)
            }
            return true
        }
        return false
    }
        
    func getProvidersForService(serviceId: String)->[GDServiceProvider] {
       let serviceProviders = GDiOS.sharedInstance().getServiceProviders(for: serviceId, andVersion: nil, andServiceType: GDServiceType.application)
        return serviceProviders
    }
}

