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
import WebKit

class PreviewViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
  
    var viewModel: PreviewViewModel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.accessibilityIdentifier = UIAccessibilityIdentifiers.SSCPreviewViewID
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.webView.load(viewModel.data as Data, mimeType: "application/pdf", characterEncodingName: "utf-8", baseURL: viewModel.url as URL)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == Constants.shareSegueIdentifier {
            // Prepare delegate for share
            let viewController = segue.destination as! ShareViewController
            viewController.viewModel = ShareViewModel(delegate: viewModel)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        super.shouldPerformSegue(withIdentifier: identifier, sender: sender)
        if UIDevice.current.userInterfaceIdiom == .pad {
            if identifier == Constants.shareSegueIdentifier {
                let mainStoryboard: UIStoryboard = UIStoryboard(name: Constants.mainStoryboardIdentifier, bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constants.shareViewControllerIdentifier) as! ShareViewController
                viewController.viewModel = ShareViewModel(delegate: viewModel)
                
                // Present the view controller using the popover style.
                viewController.modalPresentationStyle = .popover
                viewController.popoverPresentationController!.barButtonItem = shareButton
                self.present(viewController, animated: false, completion: nil)
            
                return false
            }
        }
        return true
    }
}
