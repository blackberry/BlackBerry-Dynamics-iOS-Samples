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

class ShareViewController: UITableViewController {
    
    var viewModel: ShareViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.accessibilityIdentifier = UIAccessibilityIdentifiers.SSCShareViewID
    }
           
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.serviceProviders.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.shareCellIdentifier, for: indexPath)
        
        let application = viewModel.serviceProviders[indexPath.row]
        cell.textLabel?.text = application.name
        cell.imageView?.image = application.icon
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let application = viewModel.serviceProviders[indexPath.row]
        viewModel.appSelected(application)
        
        userInterfaceIdiom(
            iPhone: { () -> Void in
                let vcs = self.navigationController?.popToViewController(self.previousViewController()!, animated: true)
                print("Popped vcs", vcs ?? "")
            },
            iPad: {() -> Void in
                self.dismiss(animated: true, completion: nil)
            }
        )
    }
}
