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
import BlackBerryDynamics.SecureCommunication

public func RGB(_ r: Float, g: Float, b: Float) -> UIColor {
    return UIColor(red: CGFloat(r/255), green: CGFloat(g/255), blue: CGFloat(b/255), alpha: 1.0)
}

public func maincolor() -> UIColor {
    return RGB(77, g: 91, b: 103)
}

let kRSSTitle = "BBC World"
let kRSSUrl =  URL(string:"http://feeds.bbci.co.uk/news/world/rss.xml")
let kFeedSaveFile = "feedSaveFile.dat"

public func fullPathOfFile(name fileName: String) -> String {
    let libPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory,
                                                        FileManager.SearchPathDomainMask.userDomainMask,
                                                        true)
    let libPath = libPaths[0] as NSString
    let applicationDirectory = libPath.deletingLastPathComponent
    return (applicationDirectory + "/") + (fileName as String)
}

public func reachabilityStateOutputInfo() {
    let flags  = GDReachability.sharedInstance().status
    let strMsg = "GDReachabilityNotReachable = \((flags == .notReachable) ? "true" : "false"), GDReachabilityViaWiFi = \((flags == .viaWiFi) ? "true" : "false"), GDReachabilityViaCellular = \((flags == .viaCellular) ? "true" : "false")"
    NSLog(strMsg)
}

public func screenAccordingToOrientation() -> CGFloat {
    
    if (UIDevice.current.orientation.isLandscape) {
        return UIScreen.main.bounds.size.height
    }

    return UIScreen.main.bounds.size.width
}

extension String {
    func heightWithConstrainedWidth(_ width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return boundingBox.height
    }
}
