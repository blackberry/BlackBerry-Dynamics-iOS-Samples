/* Copyright (c) 2017 BlackBerry Ltd.
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
import GD.Runtime
import IQKeyboardManagerSwift

@MainActor
@objc class AdminConsoleGDiOSDelegate: NSObject, @preconcurrency GDiOSDelegate {

    @objc static let shared = AdminConsoleGDiOSDelegate()

    weak var sceneDelegate: AdminConsoleSceneDelegate?

    private var started = false

    private override init() {
        super.init()
    }

    func handle(_ anEvent: GDAppEvent) {
        switch anEvent.type {
        case .authorized:
            onAuthorized(anEvent)
        case .notAuthorized:
            onNotAuthorized(anEvent)
        case .remoteSettingsUpdate, .servicesUpdate, .policyUpdate:
            break
        default:
            print("handleEvent \(anEvent.message)")
        }
    }

    private func onNotAuthorized(_ anEvent: GDAppEvent) {
        switch anEvent.code {
        case .errorActivationFailed, .errorProvisioningFailed, .errorPushConnectionTimeout,
             .errorSecurityError, .errorAppDenied, .errorAppVersionNotEntitled, .errorBlocked,
             .errorWiped, .errorRemoteLockout, .errorPasswordChangeRequired:
            print("onNotAuthorized \(anEvent.message)")
        case .errorIdleLockout:
            break
        default:
            assertionFailure("Unhandled not authorized event")
        }
    }

    private func onAuthorized(_ anEvent: GDAppEvent) {
        switch anEvent.code {
        case .errorNone:
            if !started {
                started = true
                IQKeyboardManager.sharedManager().enable = true
                sceneDelegate?.launchApplicationUI()
            }
        default:
            assertionFailure("Authorized startup with an error")
        }
    }
}
