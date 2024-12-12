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

class AboutViewController: UIViewController {

    var troubleshootingViewModel: TroubleshootingViewModel!
    
    override func viewDidLoad() {
        userInterfaceIdiom(
            iPhone: { () -> Void in
                
            },
            iPad: {() -> Void in
                self.navigationItem.leftBarButtonItem = nil
            }
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.troubleshootingViewModel = TroubleshootingViewModel(delegate: self)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.troubleshootingViewModel = nil
    }
    
    @IBAction func dismissViewController(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func presentTroubleshootingOptions(_ sender: UIBarButtonItem) {
        troubleshootingViewModel.troubleshoot(sender)
    }
    
}
