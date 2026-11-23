/* Copyright (c) 2018 BlackBerry Ltd.
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
import BlackBerryDynamics.Runtime

@MainActor
@objc class ServicesGDiOSDelegate: NSObject, @preconcurrency GDiOSDelegate {

    @objc static let sharedInstance = ServicesGDiOSDelegate()

    weak var sceneDelegate: ServicesSceneDelegate?
    @objc weak var rootViewController: EmailServiceVC? {
        didSet { coordinateDidAuthorize() }
    }
    @objc weak var appDelegate: AppDelegate? {
        didSet { coordinateDidAuthorize() }
    }

    private(set) var hasAuthorized = false

    private override init() {
        super.init()
    }

    private func coordinateDidAuthorize() {
        if hasAuthorized, rootViewController != nil, appDelegate != nil {
            appDelegate?.didAuthorize()
        }
    }

    func handle(_ anEvent: GDAppEvent) {
        switch anEvent.type {
        case .authorized:
            onAuthorized(anEvent)
        case .notAuthorized:
            onNotAuthorized(anEvent)
        case .remoteSettingsUpdate, .servicesUpdate, .policyUpdate, .entitlementsUpdate:
            break
        default:
            NSLog("Unhandled Event")
        }
    }

    private func onNotAuthorized(_ anEvent: GDAppEvent) {
        switch anEvent.code {
        case .errorActivationFailed, .errorProvisioningFailed, .errorPushConnectionTimeout,
             .errorSecurityError, .errorAppDenied, .errorAppVersionNotEntitled, .errorBlocked,
             .errorWiped, .errorRemoteLockout, .errorPasswordChangeRequired:
            NSLog("onNotAuthorized %@", anEvent.message)
        case .errorIdleLockout:
            break
        default:
            assertionFailure("Unhandled not authorized event")
        }
    }

    private func onAuthorized(_ anEvent: GDAppEvent) {
        switch anEvent.code {
        case .errorNone:
            if !hasAuthorized {
                sceneDelegate?.launchApplicationUI()
                hasAuthorized = true
                coordinateDidAuthorize()
            }
        default:
            assertionFailure("Authorized startup with an error")
        }
    }
}
