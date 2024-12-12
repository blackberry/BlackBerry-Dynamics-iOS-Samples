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

open class RedToolbar : UIToolbar {
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.tintColor = maincolor()
    }
    
    override open func setItems(_ items: [UIBarButtonItem]?, animated: Bool) {
        super.setItems(items, animated: animated)
        
        if let items = self.items {
            if items.count > 0 {
                let barButtonItem = items[0]
                let button = UIButton(type: .infoLight)
                button.addTarget(barButtonItem.target, action: barButtonItem.action!, for: .touchUpInside)
                barButtonItem.customView = button
            }
        }
    }
}
