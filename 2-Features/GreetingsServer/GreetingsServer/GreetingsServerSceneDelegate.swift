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
 */

import UIKit
import BlackBerryDynamics

@objc class GreetingsServerSceneDelegate: UIResponder, UIWindowSceneDelegate {
    @objc var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // With BlackBerry Dynamics 15.+, UISceneDelegate handling has changed.
        if isDynamicsVersionGreaterThanOrEqualv15() {
            // Recommended implementation based on BlackBerry Dynamics 15.0 and newer
            if let keyWin = windowScene.keyWindow {
                window = keyWin
            }
        } else {
            // for BlackBerry Dynamics 14.+ or earlier
            window = UIWindow(windowScene: windowScene)
            window?.makeKeyAndVisible()
        }

        GreetingsServerGDiOSDelegate.shared.gServiceSceneDelegate = self
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        
    }
    
    /// Checks if the current BlackBerry Dynamics version is greater than or equal to v15.0
    /// - Returns: True if the current Dynamics version is 15.0 or greater, false otherwise
    func isDynamicsVersionGreaterThanOrEqualv15() -> Bool {
        // Get the current Dynamics version
        let dynamicsVersion = GDiOS.sharedInstance().getVersion()
        
        // Parse the version string (format: "major.minor.patch.build")
        let versionComponents = dynamicsVersion.components(separatedBy: ".")
        guard versionComponents.count >= 1 else {
            return false
        }
        
        // Extract current major version
        guard let currentMajor = Int(versionComponents[0]) else {
            return false
        }
        
        // Check if major version is 15 or greater
        return currentMajor >= 15
    }
}
