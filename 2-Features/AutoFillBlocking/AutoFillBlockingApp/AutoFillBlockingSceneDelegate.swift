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
 */

import UIKit

@objc class AutoFillBlockingSceneDelegate: UIResponder, UIWindowSceneDelegate {

    /// Weak so we do not retain the window past scene teardown; updated from the active scene instance.
    private static weak var registeredPresentationWindow: UIWindow?

    var window: UIWindow?

    /// Window used for UI that is not tied to a specific `UIResponder` chain (e.g. ObjC alert presenter).
    @objc static func presentationWindow() -> UIWindow? {
        registeredPresentationWindow
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        window = UIWindow(windowScene: windowScene)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window?.rootViewController = storyboard.instantiateInitialViewController()
        window?.makeKeyAndVisible()
        Self.registeredPresentationWindow = window
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        if Self.registeredPresentationWindow === window {
            Self.registeredPresentationWindow = nil
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
