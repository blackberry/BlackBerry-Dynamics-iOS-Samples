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


class ServicesClientGDiOSDelegate: NSObject, GDiOSDelegate {
    
    static let sharedInstance = ServicesClientGDiOSDelegate()
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
    
    func handle(_ anEvent: GDAppEvent) {
        // Called from 'good' property when events occur, such as system startup
        switch anEvent.type {
        case .authorized :
            onAuthorized(anEvent)
        case .notAuthorized :
            onNotAuthorized(anEvent)
        case .servicesUpdate :
            onServiceUpdate(anEvent)
            
        default :
            print("Event not handled: '\(anEvent.message)'")
            break
        }
    }
    
    func onNotAuthorized(_ anEvent: GDAppEvent) {
        // Handle the Good Libraries not authorized event
    }
    
    func onAuthorized(_ anEvent: GDAppEvent) {
        // Handle the Good Libraries not authorized event
        switch anEvent.code {
        case .errorNone :
            if (!hasAuthorized) {
                // Prepare main storyboard and root view controller
                let mainStoryboard: UIStoryboard = UIStoryboard(name: Constants.mainStoryboardIdentifier, bundle: nil)
                let navigationViewController = mainStoryboard.instantiateViewController(withIdentifier: Constants.rootNavigationViewControllerIdentifier) as? UINavigationController
                navigationViewController!.navigationBar.tintColor = UIColor(red: 77.0/255.0, green: 91.0/255.0, blue: 103.0/255.0, alpha: 1.0)
                
                if (UIDevice.current.userInterfaceIdiom == .phone) {
                    self.appDelegate!.window?.rootViewController = navigationViewController
                    
                } else {
                    // For iPad create split view controller with root and about view controllers
                    let aboutViewController = mainStoryboard.instantiateViewController(withIdentifier: Constants.aboutNavigationViewControllerIdentifier)
                    
                    let splitViewController = SplitViewController()
                    splitViewController.viewControllers = NSArray(objects: navigationViewController!, aboutViewController) as! [UIViewController]
                    splitViewController.preferredDisplayMode = UISplitViewController.DisplayMode.oneBesideSecondary
                    self.appDelegate!.window?.rootViewController = splitViewController
                }
                hasAuthorized = true
                didAuthorize()
            }
        default:
            assert(false, "Authorized startup with an error")
            break
        }
    }
    
    func onServiceUpdate(_ anEvent: GDAppEvent) {
        switch anEvent.code {
        case .errorNone:
            //Post change
                //kServiceConfigDidChangeNotification
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.serviceConfigDidChangeNotification), object: nil)
            break;
        default:
            assert(false, "Service update error")
            break
        }
    }
}
