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

import UIKit
import BlackBerryDynamics.Runtime

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        disableAnimationsInUITests()
        ServicesClientGDiOSDelegate.sharedInstance.appDelegate = self
        GDiOS.sharedInstance().authorize(ServicesClientGDiOSDelegate.sharedInstance)
        
        return true
    }
    
    func didAuthorize() -> Void {
        print(#file, #function)
    }
    
    func disableAnimationsInUITests() -> Void {
        if (CommandLine.arguments.contains("disableAnimations")) {
            print("Animations disabled in UITests")
            UIView.setAnimationsEnabled(false)
        }
    }
}

