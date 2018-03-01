/* Copyright (c) 2018 BlackBerry Ltd.
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

//Protocol to reload table
protocol reloadTable {
    func reloadTable()
}

class CommonVC: UIViewController, reloadTable {
    
    //Protocol function
    func reloadTable() {
        tableView.reloadData()
    }

    @IBOutlet weak var tableView: UITableView!
    
    //Setup background image
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView = UIImageView(image: UIImage.init(named: "book.jpg")!)
        tableView.layer.cornerRadius = 20
        self.tableView.backgroundColor = UIColor.clear
        
        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
        imageView.addSubview(blurEffectView)
        self.tableView.backgroundView = imageView
    }
    
    //Switch the delegate class
    override func viewWillAppear(_ animated: Bool) {
        tableView.delegate = self.parent as? UITableViewDelegate
        tableView.dataSource = self.parent as? UITableViewDataSource
        
        if NSStringFromClass((self.parent?.classForCoder)!).contains("SecureSQL") {
            (self.parent as! SecureSQLVC).tableDelegate = self
        } else {
            (self.parent as! SecureCoreDataVC).tableDelegate = self
        }
        tableView.reloadData()
    }
}
