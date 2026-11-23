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

class AboutWindow: UIWindow {

    fileprivate var onDismissWindow: UIWindow?
    private static var activeAboutOverlay: AboutWindow?

    class func show() {
        guard let sceneDelegate = ServicesServerGDiOSDelegate.sharedInstance.sceneDelegate,
              let mainWindow = sceneDelegate.window else {
            print("AboutWindow: scene delegate window is nil")
            return
        }

        if activeAboutOverlay != nil {
            print("About window is already shown")
            return
        }

        let windowScene = mainWindow.windowScene
        let instance: AboutWindow
        if let windowScene = windowScene {
            instance = AboutWindow(windowScene: windowScene)
        } else {
            instance = AboutWindow(frame: UIScreen.main.bounds)
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let aboutVC = storyboard.instantiateViewController(withIdentifier: "navigationAbout")
        instance.rootViewController = aboutVC
        instance.windowLevel = .alert
        instance.onDismissWindow = mainWindow
        activeAboutOverlay = instance
        instance.makeKeyAndVisible()
        instance.alpha = 0
        UIView.animate(withDuration: 0.7) {
            instance.alpha = 1
        }
    }

    class func hide() {
        guard let aboutWindow = activeAboutOverlay,
              let onDismissWindow = aboutWindow.onDismissWindow else {
            return
        }

        UIView.animate(withDuration: 0.4, animations: {
            aboutWindow.alpha = 0
        }) { _ in
            aboutWindow.isHidden = true
            activeAboutOverlay = nil
            onDismissWindow.makeKeyAndVisible()
        }
    }
}
