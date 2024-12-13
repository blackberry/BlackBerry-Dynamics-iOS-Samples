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

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        userInterfaceIdiom(
            iPhone: { () -> Void in
                
            },
            iPad: {() -> Void in
                ServicesServerGDiOSDelegate.sharedInstance.rootViewController = self
            }
        )
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func splitViewController(  _ splitViewController: UISplitViewController,
                               collapseSecondary secondaryViewController: UIViewController,
                                                               onto primaryViewController: UIViewController) -> Bool {
        
        // Returning false tells the split view controller to use its default behavior
        // to try and incorporate the secondary view controller into the collapsed interface
        // the UINavigationController class responds by pushing the secondary view controller onto its navigation stack
        
        if primaryViewController.isKind( of: UINavigationController.self) {
            return false
        }
        
        // if primary viewController is not instance of uinavigation controller,
        // do nothing with view hierarchy
        
        return false
    }
    
    func primaryViewController( forExpanding splitViewController: UISplitViewController) -> UIViewController? {
        return splitViewController.viewControllers.first
    }
    
    func splitViewController(  _ splitViewController: UISplitViewController,
                               separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: Constants.mainStoryboardIdentifier, bundle: nil)
        
        guard let navVC = primaryViewController as? UINavigationController else {
            return primaryViewController
        }
        
        if (navVC.topViewController?.isKind(of: AppKineticsViewController.self) == false ) {
            return navVC.topViewController
        }
        
        let aboutViewController = mainStoryboard.instantiateViewController(withIdentifier: Constants.aboutNavigationViewControllerIdentifier)
        
        return aboutViewController
        
    }

}
