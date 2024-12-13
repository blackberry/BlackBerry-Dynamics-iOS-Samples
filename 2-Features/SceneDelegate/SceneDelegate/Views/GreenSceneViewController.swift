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

class GreenSceneViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var numberOfGreenScenesLabel: UILabel!
    @IBOutlet weak var sceneNameLabel: UILabel!
    
    // MARK: Properties
    private var presenter: ColorViewControllerPresenter!
    
    // MARK: ViewController Lifecycle
    override func loadView() {
        super.loadView()
        self.presenter = GreenViewControllerPresenter(view: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.viewDidLoad()
    }
    
    // MARK: IBActions
    @IBAction func requestGreenSceneButtonPressed(_ sender: UIButton) {
        self.presenter.requestGreenSceneButtonPressed()
    }
    
    @IBAction func requestOrangeSceneButtonPressed(_ sender: UIButton) {
        self.presenter.requestOrangeSceneButtonPressed()
    }
    
    @IBAction func requestRandomSceneButtonPressed(_ sender: UIButton) {
        self.presenter.requestRandomSceneButtonPressed()
    }
    
}

// MARK: ColorView protocol
extension GreenSceneViewController: ColorView {

    func updateViewsCount(_ count: Int, with color: UIColor) {
        self.numberOfGreenScenesLabel.text = String(count)
        self.numberOfGreenScenesLabel.textColor = color
        self.sceneNameLabel.textColor = color
    }
    
}
