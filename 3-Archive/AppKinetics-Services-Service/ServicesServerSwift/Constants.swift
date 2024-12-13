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

enum UIUserInterfaceIdiom : Int {
    case unspecified
    case phone
    case pad
}

public func userInterfaceIdiom(iPhone: () -> Void, iPad: () -> Void) {
    switch UIDevice.current.userInterfaceIdiom {
    case .phone:
        iPhone()
    case .pad:
        iPad()
    default: break
    }
}

struct Constants {
    static let servicesClientGDIdentifier = "com.good.example.sdk.services-client"
    
    static let fileTransferGDServiceIdentifier = "com.good.gdservice.transfer-file"
    static let fileTransferGDServiceVersionIdentifier = "1.0.0.0"
    static let fileTransferGDServiceMethodIdentifier = "transferFile"
    
    static let greetingsGDServiceIdentifier = "com.good.gd.example.services.greetings"
    static let greetingsGDServiceVersionIdentifier = "1.0.0"
    static let greetingsGDServiceMethodIdentifier = "greetMe"
    
    static let dateAndTimeGDServiceIdentifier = "com.gd.example.services.dateandtime"
    static let dateAndTimeGDServiceVersionIdentifier = "1.0.0"
    static let dateAndTimeGDServiceMethodIdentifier = "getDateAndTime"
    
    static let mainStoryboardIdentifier = "Main"
    static let rootNavigationViewControllerIdentifier = "navigationRoot"
    static let aboutNavigationViewControllerIdentifier = "navigationAbout"
    
    static let shareViewControllerIdentifier = "share"
    static let previewViewControllerIdentifier = "preview"
    
    static let appKineticsSegueIdentifier = "AppKineticsSegueIdentifier"
    static let previewSegueIdentifier = "PreviewSegueIdentifier"
    static let shareSegueIdentifier = "ShareSegueIdentifier"
    
    static let appKineticsCellIdentifier = "AppKineticsCell"
    static let shareCellIdentifier = "ShareCell"
    
    static let documentsModelChangedNotificationIdentifier = "kDocumentsModelChangedNotification"
    static let serviceDidTransferedFileNotificationIdentifier = "kServiceDidTransferedFileNotification"
    
    static let serviceClientDidReceiveFromNotificationIdentifier = "kServiceClientDidReceiveFromNotification"
    
    static let serviceClientDidStartSendingToNotificationIdentifier = "kServiceClientDidStartSendingToNotification"
    static let serviceClientDidFinishSendingToNotificationIdentifier = "kServiceClientDidFinishSendingToNotification"
}

