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

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        disableAnimationsInUITests()
        ServerServiceGDiOSDelegate.sharedInstance.appDelegate = self
        GDiOS.sharedInstance().authorize(ServerServiceGDiOSDelegate.sharedInstance)
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = ServerServicesSceneDelegate.self
        sceneConfig.sceneClass = UIWindowScene.self
        sceneConfig.storyboard = UIStoryboard(name: "Main", bundle: nil)
        return sceneConfig
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

    @objc func getRootViewController() -> UIViewController? {
        guard let window = ServerServiceGDiOSDelegate.sharedInstance.sceneDelegate?.window else {
            return nil
        }
        var rootViewController = window.rootViewController
        if let launcher = rootViewController as? GTLauncherViewController {
            rootViewController = launcher.baseViewController
        }
        return rootViewController
    }

    @objc func didAuthorize() {
        guard let navigationController = getRootViewController() as? UINavigationController,
              let topViewController = navigationController.topViewController,
              let masterViewController = topViewController as? MasterViewController else {
            return
        }
        masterViewController.authenticated = true
        masterViewController.didAuthenticate()
        NSLog("%s", #function)
    }

    func disableAnimationsInUITests() {
        if ProcessInfo.processInfo.arguments.contains("disableAnimations") {
            NSLog("Animations disabled in UITests")
            UIView.setAnimationsEnabled(false)
        }
    }
}
