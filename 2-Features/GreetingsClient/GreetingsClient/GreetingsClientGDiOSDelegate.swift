/* Copyright (c) 2025 BlackBerry Ltd.
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

@MainActor
@objc class GreetingsClientGDiOSDelegate: NSObject, @preconcurrency GDiOSDelegate {
    
    @objc static let shared = GreetingsClientGDiOSDelegate()
    
    var greetingsClientSceneDelegate: GreetingsClientSceneDelegate?
    @objc var serviceController: ServiceController?
    
    private var hasAuthorized: Bool = false

    private override init() {
        // Initialization code for your shared instance
        super.init()
        self.serviceController = ServiceController()
        print("GreetingsClientGDiOSDelegate instance created.")
    }

    func handle(_ anEvent: GDAppEvent) {
        switch anEvent.type {
        case .authorized:
            onAuthorized(anEvent)
        case .notAuthorized:
            onNotAuthorized(anEvent)
        case .remoteSettingsUpdate:
            // handle app config changes
            break
        case .servicesUpdate:
            NSLog("Received Service Update event")
            onServiceUpdate(anEvent)
        default:
            NSLog("event not handled: %@", anEvent.message)
        }
    }

    private func onAuthorized(_ anEvent: GDAppEvent) {
        switch anEvent.code {
        case .errorNone:
            if !hasAuthorized {
                // launch application UI here
                hasAuthorized = true
                self.greetingsClientSceneDelegate?.launchApplicationUI()
            }
        default:
            break
        }
    }

    private func onNotAuthorized(_ anEvent: GDAppEvent) {
        switch anEvent.code {
        case .errorActivationFailed,
             .errorProvisioningFailed,
             .errorPushConnectionTimeout,
             .errorSecurityError,
             .errorAppDenied,
             .errorAppVersionNotEntitled,
             .errorBlocked,
             .errorWiped,
             .errorRemoteLockout,
             .errorPasswordChangeRequired:
            // an condition has occured denying authorization, an application may wish to log these events
            NSLog("onNotAuthorized %@", anEvent.message)
        case .errorIdleLockout:
            // idle lockout is benign & informational
            break
        default:
            NSException(name: NSExceptionName(rawValue: "UnhandledNotAuthorizedEvent"), reason: nil, userInfo: nil).raise()
        }
    }

    private func onServiceUpdate(_ anEvent: GDAppEvent) {
        switch anEvent.code {
        case .errorNone:
            // Post change
            NotificationCenter.default.post(name: Notification.Name(rawValue: kServiceConfigDidChangeNotification), object: nil)
        default:
            NSException(name: NSExceptionName(rawValue: "ServiceUpdateError"), reason: nil, userInfo: nil).raise()
        }
    }
}
