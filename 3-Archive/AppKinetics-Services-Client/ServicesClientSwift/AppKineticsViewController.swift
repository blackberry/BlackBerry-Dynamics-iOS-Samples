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

class AppKineticsViewController: UITableViewController {
    
    var viewModel: AppKineticsViewModel!
        
    // MARK: - IBActions

    @IBAction func refresh(_ sender: UIBarButtonItem) {
        viewModel.reload()
        reload()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.accessibilityIdentifier = UIAccessibilityIdentifiers.SSCAppKineticsViewID
    }
    
    @objc func reload() {
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,
					selector: #selector(AppKineticsViewController.reload),
					name: NSNotification.Name(rawValue: Constants.documentsModelChangedNotificationIdentifier),
					object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
        
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.count()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.appKineticsCellIdentifier, for: indexPath)
        cell.accessoryType = .disclosureIndicator

        cell.textLabel!.text = viewModel.elementAtIndex(indexPath.row)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.viewModel.delete(tableView, indexPath: indexPath)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == Constants.previewSegueIdentifier {

            // Pass file title for preview
            let cell = sender as! UITableViewCell
            let viewController = segue.destination as! PreviewViewController
            viewController.viewModel = PreviewViewModel(file: cell.textLabel!.text!, delegate: viewController)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        super.shouldPerformSegue(withIdentifier: identifier, sender: sender)
        if UIDevice.current.userInterfaceIdiom == .pad {
            if identifier == Constants.previewSegueIdentifier {
                let mainStoryboard: UIStoryboard = UIStoryboard(name: Constants.mainStoryboardIdentifier, bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: Constants.previewViewControllerIdentifier) as! PreviewViewController
                
                let cell = sender as! UITableViewCell
                viewController.viewModel = PreviewViewModel(file: cell.textLabel!.text!, delegate: viewController)
                
                let navigationController = UINavigationController(rootViewController: viewController)
                splitViewController?.showDetailViewController(navigationController, sender: nil)
                
                return false
            }
        }
        return true
    }
    
}
