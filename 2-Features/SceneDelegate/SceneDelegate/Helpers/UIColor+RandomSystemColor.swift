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

fileprivate let systemColors = [
        UIColor.red,
        UIColor.systemBlue,
        UIColor.systemYellow,
        UIColor.systemPink,
        UIColor.systemPurple,
        UIColor.systemTeal,
        UIColor.systemIndigo,
        UIColor.systemGray
    ]

extension UIColor {
    
    class var randomSystemColor: UIColor {
        systemColors.randomElement() ?? UIColor.systemBlue
    }
    
}
