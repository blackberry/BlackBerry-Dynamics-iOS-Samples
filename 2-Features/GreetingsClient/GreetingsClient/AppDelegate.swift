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

import UIKit
import BlackBerryDynamics.Runtime

@objc class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize the app
        disableAnimationsInUITests()
        GDiOS.sharedInstance().authorize(GreetingsClientGDiOSDelegate.shared)
        return true
    }

    // MARK: - UISceneSession lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Configure the scene session
        let sceneConfig = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = GreetingsClientSceneDelegate.self
        
        sceneConfig.sceneClass = UIWindowScene.self

        let storyboardName = UIDevice.current.userInterfaceIdiom == .phone ? "Main_iPhone" : "Main_iPad"
        sceneConfig.storyboard = UIStoryboard(name: storyboardName, bundle: nil)

        return sceneConfig
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Handle scene session discard
    }

    @objc func getProvidersForService(serviceId: String) -> [Any] {
        // Get service providers
        return GDiOS.sharedInstance().getServiceProviders(for: serviceId, andVersion: nil, andServiceType: GDServiceType.application) as [Any]
    }

    func disableAnimationsInUITests() {
        // Disable animations in UI tests
        if ProcessInfo.processInfo.arguments.contains("disableAnimations") {
            NSLog("Animations disabled in UITests")
            UIView.setAnimationsEnabled(false)
        }
    }
}
