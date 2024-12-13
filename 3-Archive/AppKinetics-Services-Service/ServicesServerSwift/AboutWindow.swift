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
    
    fileprivate var onDismissWindow: UIWindow?;

    class func show() {
        let appDelegate =  UIApplication.shared.delegate! as! AppDelegate
        let appWindow = appDelegate.window
        
        if let _ = appWindow as? AboutWindow {
            print("About window is already shown")
            return
        }
        
        let instance = AboutWindow.init(frame: UIScreen.main.bounds)
        
        let storyboardName = "Main"
        
        let storyboard = UIStoryboard.init(name: storyboardName, bundle: nil)
        // set rootViewController for a new window instance
        let aboutVC = storyboard.instantiateViewController(withIdentifier: "navigationAbout")
        instance.rootViewController = aboutVC;
        
        instance.onDismissWindow = appWindow;
        // set new window as application window
        // it can be stored in another way,
        // but this is where Dynamics had problems in the past, before multiple windows support.
        appDelegate.window = instance;
        instance.makeKey()
        instance.isHidden = false;
        
        instance.alpha = 0;
        UIView.animate(withDuration: 0.7) {
            instance.alpha = 1;
        }
    }
    
    class func hide() {
        let appDelegate =  UIApplication.shared.delegate! as! AppDelegate
        let appWindow = appDelegate.window
        guard let aboutWindow = appWindow as? AboutWindow,
              let onDismissWindow = aboutWindow.onDismissWindow else {
                return;
        }
        
        UIView.animate(withDuration: 0.4, animations: {
            appWindow?.alpha = 0;
        }) { (finished) in
            appDelegate.window = onDismissWindow
            onDismissWindow .makeKeyAndVisible()
        }
    }
}
