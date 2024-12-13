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
import BlackBerryDynamics.SecureStore.File

public let kRSSFeedAddedNotification = "kRSSFeedAddedNotification"
public let kRSSRequestModeChangedNotification = "kRSSRequestModeChangedNotification"

public enum RequestMode : Int {
    case nsurl = 0
}

open class RSSManager : NSObject {
    public static let sharedRSSManager = RSSManager()
    
    fileprivate var rssFeeds : NSMutableArray!
    open var currentRequestMode : RequestMode = .nsurl
    
    fileprivate override init() {
        super.init()
        self.initaliseFeedsArray()
    }
    
    fileprivate func initaliseFeedsArray() {
        
        guard let data = GDFileManager.default.contents(atPath: fullPathOfFile(name: kFeedSaveFile)) else {
            rssFeeds = NSMutableArray()
            let goodFeed = RSSFeed.init(name: kRSSTitle, url: kRSSUrl!)
            rssFeeds.add(goodFeed)
            return
        }
        
        if data.count > 0 {
            do {
                rssFeeds = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSMutableArray.self, from: data)
            } catch {
                // error in unarchive
            }
        }
    }
    
    open var numberOfFeeds : Int {
        get {
            return rssFeeds.count
        }
    }
    
    open func feedAt(_ pos: Int) -> RSSFeed? {
        return self.rssFeeds[pos] as? RSSFeed
    }
    
    /*
    * Validates the RSS for name and URL and then saves locally and to secure storage
    */
    open func save(rssFeed feed: RSSFeed?, feedName name:String, urlString anURL:String) -> Bool {
        if (name.isEmpty || anURL.isEmpty) {
            return false
        }
		
		var url = anURL
		
        //Check for protocol
        let range = url.range(of: "://")
        if (range == nil) {
            url = "http://" + url;
        }
        
        //Test URL is valid
        let rssURL = URL(string: url);
        if (rssURL == nil) {
            return false
        }
        
        if (feed != nil) {
            
            // update existing
            feed!.rssName = name
            feed!.rssUrl = rssURL
            
        } else {
            //Add the feed to the url
            let rssFeed = RSSFeed(name: name, url: rssURL!)
            rssFeeds.add(rssFeed)
        }
        
        self.saveFeeds()
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: kRSSFeedAddedNotification), object: nil)
        
        return true
    }
    
    /*
    * Removes a feed from the local array and saves the changes to secure storage
    */
    open func removeFeed(atPos pos: NSInteger) {
        if (self.rssFeeds.count > pos) {
            rssFeeds.removeObject(at: pos)
            self.saveFeeds();
        }
    }
    
    /*
    * Saves the feed table to secure storage
    */
    open func saveFeeds () {
        
        //Convert RSSFeeds dictionarie
        do {
            let encodedData = try NSKeyedArchiver.archivedData(withRootObject: rssFeeds as NSMutableArray, requiringSecureCoding: true)
            if ( !GDFileManager.default.createFile(atPath: self.fullPathOfFileWithName(kFeedSaveFile), contents: encodedData, attributes: nil) ) {
                
                let alert = UIAlertController(title: "Error Saving Feeds", message: "\n", preferredStyle: UIAlertController.Style.alert)
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: { (alertAction: UIAlertAction) -> Void in })
                alert.addAction(alertAction)
                let windowScenes = UIApplication.shared.connectedScenes.compactMap{$0 as? UIWindowScene}
                let windowGroup = windowScenes.flatMap{$0.windows}
                let window = windowGroup.first{$0.isKeyWindow}
                
                window?.rootViewController?.present(alert, animated: true, completion: nil)
            }
        } catch {
            // error while encoding
        }
    }
    
    // MARK:- Utilities
    
    fileprivate func fullPathOfFileWithName(_ fileName: String) -> String {
        let libPaths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
        let libPath = libPaths[0]
        let applicationDirectory = NSString(string: libPath).deletingLastPathComponent
        return applicationDirectory + "/" + fileName
    }

}
