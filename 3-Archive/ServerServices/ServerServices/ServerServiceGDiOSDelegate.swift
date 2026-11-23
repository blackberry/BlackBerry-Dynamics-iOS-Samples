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
import BlackBerryDynamics.Runtime

@MainActor
@objc class ServerServiceGDiOSDelegate: NSObject, @preconcurrency GDiOSDelegate {

    @objc static let sharedInstance = ServerServiceGDiOSDelegate()

    weak var sceneDelegate: ServerServicesSceneDelegate?
    @objc weak var rootViewController: MasterViewController? {
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
            NSLog("event not handled: %@", anEvent.message)
        }
    }

    private func onNotAuthorized(_ anEvent: GDAppEvent) {
        switch anEvent.code {
        case .errorActivationFailed, .errorProvisioningFailed, .errorPushConnectionTimeout,
             .errorSecurityError, .errorAppDenied, .errorBlocked, .errorAppVersionNotEntitled,
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
            assertionFailure("authorized startup with an error")
        }
    }
}
