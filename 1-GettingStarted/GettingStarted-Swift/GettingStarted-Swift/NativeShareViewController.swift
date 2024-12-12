/* Copyright (c) 2022 BlackBerry Ltd.
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

import Foundation
import UIKit


class NativeShareViewController: UIViewController {
    
    private let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .link
        button.setTitle("Native Share Link", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        button.frame = CGRect(x: 0, y: 0, width: 200, height: 150)
        button.center = view.center
        button.addTarget(self, action: #selector(presentNativeShare), for: .touchUpInside)
        view.addSubview(button)
    }
    
    @objc private func presentNativeShare() {
        let shareURL = URL(string: "https://developers.blackberry.com/us/en")
        let shareSheetViewController = UIActivityViewController(activityItems: [shareURL!] ,applicationActivities: nil)
        present(shareSheetViewController, animated: true)
    }
}
