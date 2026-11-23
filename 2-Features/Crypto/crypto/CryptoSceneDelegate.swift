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

import UIKit
import BlackBerryDynamics.Runtime

@objc(CryptoSceneDelegate)
@objcMembers
final class CryptoSceneDelegate: UIResponder, UIWindowSceneDelegate {

    static weak var current: CryptoSceneDelegate?

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        if isDynamicsVersionGreaterThanOrEqualv15() {
            if let keyWin = windowScene.keyWindow {
                window = keyWin
            } else {
                window = UIWindow(windowScene: windowScene)
                window?.makeKeyAndVisible()
            }
        } else {
            window = UIWindow(windowScene: windowScene)
            window?.makeKeyAndVisible()
        }

        Self.current = self
        GDiOSDelegate.sharedInstance().presentMainUIIfNeeded()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        if Self.current === self {
            Self.current = nil
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}

    private func isDynamicsVersionGreaterThanOrEqualv15() -> Bool {
        let dynamicsVersion = GDiOS.sharedInstance().getVersion()
        let versionComponents = dynamicsVersion.components(separatedBy: ".")
        guard let major = Int(versionComponents.first ?? "") else { return false }
        return major >= 15
    }
}
