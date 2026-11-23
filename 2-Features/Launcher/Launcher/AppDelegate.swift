/* Copyright (c) 2026 BlackBerry Ltd.
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
import SwiftUI
import UIKit
import BlackBerryDynamics.Runtime
import BlackBerryDynamics.Launcher

@main
final class AppDelegate: UIResponder, UIApplicationDelegate, GDiOSDelegate, GTLauncherViewControllerDelegate {

    var gdLibrary: GDiOS?
    var started: Bool = false

    private var pendingRootViewController: UIViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        gdLibrary = GDiOS.sharedInstance()
        gdLibrary?.delegate = self
        started = false
        gdLibrary?.authorize()
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = LauncherSceneDelegate.self
        sceneConfig.sceneClass = UIWindowScene.self
        return sceneConfig
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}

    /// Installs `ContentView` on the active scene window once Dynamics is authorized and the scene exists.
    func presentMainUIIfNeeded() {
        guard started, let root = pendingRootViewController else { return }
        guard let scene = LauncherSceneDelegate.current, let win = scene.window else { return }
        win.rootViewController = root
        pendingRootViewController = nil
        win.makeKeyAndVisible()
    }

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {}

    // MARK: - Good Dynamics Delegate Methods

    func handle(_ anEvent: GDAppEvent) {

        switch anEvent.type {
        case .authorized:
            onAuthorized(anEvent: anEvent)
        case .notAuthorized:
            onNotAuthorized(anEvent: anEvent)
        case .remoteSettingsUpdate:
            break
        case .servicesUpdate:
            break
        case .policyUpdate:
            if started {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AppPolicyUpdated"), object: nil)
            }
        default:
            print("handleEvent \(anEvent.message)")
        }
    }

    func onNotAuthorized(anEvent: GDAppEvent) {
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
            print("onNotAuthorized \(anEvent.message)")
        case .errorIdleLockout:
            break
        default:
            assertionFailure("Unhandled not authorized event")
        }
    }

    func onAuthorized(anEvent: GDAppEvent) {
        switch anEvent.code {
        case .errorNone:
            if !started {
                started = true
                let vc = UIHostingController(rootView: ContentView())

                GTLauncherViewController.setCacheExpiry(5 * 60)
                GDiOS.sharedInstance().getManagedLauncherViewController()?.delegate = self

                pendingRootViewController = vc
                presentMainUIIfNeeded()
            }
        default:
            assertionFailure("Authorized startup with an error")
        }
    }

    // MARK: BlackBerry Dynamics Launcher Delegate

    func applicationSettingsTableViewController(forLauncher controller: GTLauncherViewController) -> UITableViewController? {
        SettingsTableView()
    }

    func commonSettingsCellConfiguration(for cellType: GTLCommonSettingsCellType, launcherViewController controller: GTLauncherViewController) -> GTLCommonSettingsCellConfiguration? {
        let config = GTLCommonSettingsCellConfiguration.defaultConfiguration(for: cellType)

        if cellType == GTLCommonSettingsCellTypeChangePassword {
            config.textFont = .boldSystemFont(ofSize: 14.0)
            config.textColor = .brown
        } else if cellType == GTLCommonSettingsCellTypeUploadLogs {
            config.textFont = .italicSystemFont(ofSize: 14.0)
            config.textColor = .red
        } else if cellType == GTLCommonSettingsCellTypeLauncher {
            config.textFont = .systemFont(ofSize: 10.0)
            config.textColor = .blue
        }

        return config
    }
}
