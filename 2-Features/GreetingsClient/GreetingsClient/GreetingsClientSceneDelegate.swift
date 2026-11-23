/* Copyright (c) 2025 BlackBerry Ltd.
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

@objc class GreetingsClientSceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // UIWindow Property
    var window: UIWindow?
    
    // Implement the required UISceneDelegate methods here.
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Called when the user hasn't previously been connected to the scene.
        guard let scene = (scene as? UIWindowScene) else { return }
        
        // With BlackBerry Dynamics 15.+, UISceneDelegate handling has changed.
        // Recommended implementation based on BlackBerry Dynamics 15.0 and newer
        if isDynamicsVersionGreaterThanOrEqualv15() {
            if let keyWin = scene.keyWindow {
                window = keyWin
            }
        } else {
            // for BlackBerry Dynamics 14.+ or earlier
            window = UIWindow(windowScene: scene)
            window?.makeKeyAndVisible()
        }
        
        GreetingsClientGDiOSDelegate.shared.greetingsClientSceneDelegate = self
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being disconnected from the session.
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
    }
    
    @objc public func launchApplicationUI() {
        // Load Main.storyboard and set root view controller
        
        let storyboard = UIDevice.current.userInterfaceIdiom == .phone ?
        UIStoryboard(name: "Main_iPhone", bundle: nil) :
        UIStoryboard(name: "Main_iPad", bundle: nil)
        
        let rootViewController = storyboard.instantiateInitialViewController()
        
        self.window?.rootViewController = rootViewController
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
