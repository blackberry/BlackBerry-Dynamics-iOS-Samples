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

open class SWAddFeedViewController : UIViewController, UITextFieldDelegate {
    
    var rssFeed : RSSFeed?
    
    fileprivate var alert : UIAlertController?
    
    @IBOutlet weak var feedNameTextField: UITextField!
    @IBOutlet weak var feedURLTextField: UITextField!
    @IBOutlet weak var addUpdateButton: UIButton!
    
    @IBAction func addFeed(_ sender: AnyObject?) {
        if (RSSManager.sharedRSSManager.save(rssFeed: self.rssFeed, feedName: self.feedNameTextField.text!, urlString: self.feedURLTextField.text!) == false) {
            self.alert = UIAlertController(title: "Feed Insert Error",
                message: "There was a problem with the new feed details\nPlease check that you have entered a name for the feed and a valid URL",
                preferredStyle: .alert)
            self.alert!.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { alert in self.alert = nil }))
            self.present(self.alert!, animated: true, completion: nil)
            
        } else {
            
            let vc = self.navigationController?.popViewController(animated: true)
            print("Popped vc - ", String(describing: vc))
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.accessibilityIdentifier = UIAccessibilityIdentifiers.SRSSAddFeedViewID
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (rssFeed == nil) {
            self.title = "Add RSS Feed"
            addUpdateButton.setTitle("Add feed", for: UIControl.State())
        } else {
            self.title = "Edit RSS Feed"
            addUpdateButton.setTitle("Update feed", for: UIControl.State())
            
            feedURLTextField.text = rssFeed!.rssUrl.absoluteString
            feedNameTextField.text = rssFeed!.rssName
        }
        
        feedNameTextField.delegate = self
        feedURLTextField.delegate = self
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.feedNameTextField.resignFirstResponder()
        self.feedURLTextField.resignFirstResponder()
        
        feedNameTextField.delegate = nil
        feedURLTextField.delegate = nil
    }
    
    // This allows the user to tab through to the Next UITextField
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let nextTeg = textField.tag + 1
        
        let responder = textField.superview?.viewWithTag(nextTeg)
        if ((responder) != nil) {
            responder?.becomeFirstResponder()
        } else {
            self.addFeed(nil)
        }
        
        return false; // We do not want UITextField to insert line-breaks.
    }
}
