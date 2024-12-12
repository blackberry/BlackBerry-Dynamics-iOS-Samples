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

private let kUISceneRequestErrorTitle = "UIScene Request Error"

class ScenesManager {
    
    private var numberOfScenes: [ColorSceneType: Int]
    
    func requestScene(with type: ColorSceneType, errorHandler: ErrorHandlerView?) {
        let activity = NSUserActivity(activityType: type.rawValue)
        UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil) { [weak errorHandler] (error) in
            errorHandler?.showAlert(title: kUISceneRequestErrorTitle, message: error.localizedDescription)
        }
    }
    
    func connectedScene(with type: ColorSceneType) {
        self.numberOfScenes[type] = (self.numberOfScenes[type] ?? 0) + 1
    }
    
    func getScenesCount(with type: ColorSceneType) -> Int {
        return self.numberOfScenes[type] ?? 1
    }
    
    static let sharedManager = { ScenesManager() }()
    init() {
        self.numberOfScenes = [:]
    }
    
}
