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

import Foundation

open class RSSFeed : NSObject, NSSecureCoding {
    var rssName : String!
    var rssUrl : URL!
    
    fileprivate override init() {
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init()
        self.rssName = (aDecoder.decodeObject(of: NSString.self, forKey: "rssName") as String?) ?? ""
        self.rssUrl = (aDecoder.decodeObject(of: NSURL.self, forKey: "rssUrl") as URL?) ?? URL.init(string: "")
    }
    
    convenience init(name rssName: String, url rssUrl: URL) {
        self.init()
        self.rssName = rssName
        self.rssUrl  = rssUrl
    }
 
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(rssName, forKey: "rssName")
        aCoder.encode(rssUrl, forKey: "rssUrl")
    }
    
    public static var supportsSecureCoding: Bool {
      return true
    }
}
