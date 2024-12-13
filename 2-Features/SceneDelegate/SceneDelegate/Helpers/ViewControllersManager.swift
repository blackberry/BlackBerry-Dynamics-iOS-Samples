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

fileprivate let kUIStoryboardName          = "Main"
fileprivate let kGreenSceneViewController  = "GreenSceneViewController"
fileprivate let kOrangeSceneViewController = "OrangeSceneViewController"
fileprivate let kRandomSceneViewController = "RandomSceneViewController"

class ViewControllersManager {
    
    private let storyboard: UIStoryboard
    
    func initialViewController(for sceneType: ColorSceneType) -> UIViewController {
        switch sceneType {
            case .green:
                return storyboard.instantiateViewController(identifier: kGreenSceneViewController)
            case .orange:
                return storyboard.instantiateViewController(identifier: kOrangeSceneViewController)
            case .random:
                return storyboard.instantiateViewController(identifier: kRandomSceneViewController)
        }
    }
    
    static let sharedManager = { ViewControllersManager() }()
    init() {
        self.storyboard = UIStoryboard(name: kUIStoryboardName, bundle: nil)
    }
}
