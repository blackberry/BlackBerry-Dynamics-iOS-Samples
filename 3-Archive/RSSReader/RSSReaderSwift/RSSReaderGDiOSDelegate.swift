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
import UIKit
import BlackBerryDynamics.Runtime


class RSSReaderGDiOSDelegate: NSObject, GDiOSDelegate {
    
    static let sharedInstance = RSSReaderGDiOSDelegate()
    weak var appDelegate: AppDelegate? {
        didSet {
            didAuthorize()
        }
    }
    weak var rootViewController: UIViewController?{
        didSet {
            didAuthorize()
        }
    }
    
    var hasAuthorized:Bool = false
    
    
    fileprivate override init() {
        print(#file, #function)
        super.init()
    }
    
    deinit {
        print(#file, #function)
    }
    
    
    func didAuthorize() -> Void {
        if (hasAuthorized && (rootViewController != nil) && (appDelegate != nil) ) {
            self.appDelegate!.didAuthorize()
        }
    }
    
    func handle(_ anEvent:GDAppEvent) {
        
        switch anEvent.type
        {
        case .authorized:
            self.onAuthorized(anEvent);
            break;
            
        case .notAuthorized:
            self.onNotAuthorized(anEvent);
            break;
            
        case .remoteSettingsUpdate:
            //A change to application-related configuration or policy settings.
            break;
            
        case .servicesUpdate:
            //A change to services-related configuration.
            break;
            
        case .policyUpdate:
            //A change to one or more application-specific policy settings has been received.
            break;
            
        default:
            print("Event not handled: '\(anEvent.message)'")
            break
        }
    }
    
    func onNotAuthorized(_ anEvent:GDAppEvent ) {
        /* Handle the Good Libraries not authorized event. */
        switch anEvent.code {
        case .errorActivationFailed: break
        case .errorProvisioningFailed: break
        case .errorPushConnectionTimeout: break
        case .errorSecurityError: break
        case .errorAppDenied: break
        case .errorAppVersionNotEntitled: break
        case .errorBlocked: break
        case .errorWiped: break
        case .errorRemoteLockout: break
        case .errorPasswordChangeRequired:
            // an condition has occured denying authorization, an application may wish to log these events
            print("onNotAuthorized \(anEvent.message)")
        case .errorIdleLockout:
            // idle lockout is benign & informational
            break
            
        default: assert(false, "Unhandled not authorized event");
        }
    }
    
    func onAuthorized(_ anEvent: GDAppEvent) {
        // Handle the Good Libraries not authorized event
        switch anEvent.code {
        case .errorNone :
            if (!hasAuthorized) {
                // Prepare main storyboard and root view controller
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let rootViewController = mainStoryboard.instantiateInitialViewController()
                self.rootViewController = rootViewController;

                self.appDelegate!.window?.rootViewController = rootViewController
                hasAuthorized = true
                didAuthorize()
            }
        default:
            assert(false, "Authorized startup with an error")
            break
        }
    }
}
