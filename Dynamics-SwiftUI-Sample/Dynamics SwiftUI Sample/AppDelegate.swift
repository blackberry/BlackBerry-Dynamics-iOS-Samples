/* Copyright (c) 2021 BlackBerry Ltd.
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
import SwiftUI
import BlackBerryDynamics.Runtime

class AppDelegate : NSObject, UIApplicationDelegate, GDiOSDelegate {

    var window: UIWindow?
    var gdLibrary: GDiOS?
    var started: Bool = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        //Call BlackBerry Dynamics to authorise the app
        self.gdLibrary = GDiOS.sharedInstance()
        self.gdLibrary!.delegate = self
        self.started = false
        
        // Show the Good Authentication UI.
        self.gdLibrary!.authorize()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }


    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }


    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }


    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }


    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - Good Dynamics Delegate Methods

    func handle(_ anEvent: GDAppEvent) {
         
        switch anEvent.type {
                case .authorized:
                    onAuthorized(anEvent: anEvent)
                    break
                   
                case .notAuthorized:
                    self.onNotAuthorized(anEvent: anEvent)
                    break
                    
                case .remoteSettingsUpdate:
                    //A change to application-related configuration or policy settings.
                    break
                    
                case .servicesUpdate:
                    //A change to services-related configuration.
                    break
                      
                 case .policyUpdate:
                    if started {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AppPolicyUpdated"), object: nil)
                    }
                    break
                      
                default:
                    print("handleEvent \(anEvent.message)")
                }
    }

        
    func onNotAuthorized(anEvent:GDAppEvent ) {
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

        
    func onAuthorized(anEvent:GDAppEvent ) {
        /* Handle the Good Libraries authorized event. */
        switch anEvent.code {
            case .errorNone:
                if !self.started {
                    //Show the User UI
                    self.started = true
                    self.window?.rootViewController = UIHostingController(rootView: MainView())
                    self.window?.makeKeyAndVisible()
                }
            default:
                assert(false, "Authorized startup with an error")
                break
            }
    }
}
