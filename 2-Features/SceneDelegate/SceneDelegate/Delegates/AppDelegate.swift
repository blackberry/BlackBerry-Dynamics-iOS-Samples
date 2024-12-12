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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GDiOS.sharedInstance().authorize(AppGDiOSDelegate.sharedInstance)
        // Override point for customization after application launch.
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        var sceneDelegateClass: AnyClass = GreenSceneDelegate.self
        
        if let activity = options.userActivities.first, let sceneType = ColorSceneType(rawValue: activity.activityType) {
            switch sceneType {
                case .green:
                    sceneDelegateClass = GreenSceneDelegate.self
                case .orange:
                    sceneDelegateClass = OrangeSceneDelegate.self
                case .random:
                    sceneDelegateClass = RandomSceneDelegate.self
            }
        }
        
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        config.sceneClass = UIWindowScene.self
        config.delegateClass = sceneDelegateClass
        return config
    }

}

