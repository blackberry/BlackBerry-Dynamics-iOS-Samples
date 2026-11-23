/* Copyright (c) 2026 BlackBerry Ltd.
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

@objc class GettingStartedGDiOSDelegate: NSObject, GDiOSDelegate {

    static let shared = GettingStartedGDiOSDelegate()

    weak var sceneDelegate: GettingStartedSceneDelegate? {
        didSet {
            tryInstallMainUI()
        }
    }

    private var started = false
    private var didInstallMainStoryboard = false

    private override init() {
        super.init()
    }

    private func tryInstallMainUI() {
        guard started, sceneDelegate != nil, !didInstallMainStoryboard else { return }
        didInstallMainStoryboard = true
        sceneDelegate?.launchApplicationUI()
    }

    func handle(_ anEvent: GDAppEvent) {
        switch anEvent.type {
        case .authorized:
            onAuthorized(anEvent: anEvent)
        case .notAuthorized:
            onNotAuthorized(anEvent: anEvent)
        case .remoteSettingsUpdate:
            if started {
                NotificationCenter.default.post(name: .gettingStartedDynamicsRemoteSettingsUpdated, object: nil)
            }
        case .servicesUpdate:
            break
        case .policyUpdate:
            if started {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AppPolicyUpdated"), object: nil)
            }
        default:
            print("handleEvent \(anEvent.message)")
        }
    }

    private func onAuthorized(anEvent: GDAppEvent) {
        switch anEvent.code {
        case .errorNone:
            if !started {
                started = true
                tryInstallMainUI()
            }
        default:
            assertionFailure("Authorized startup with an error")
        }
    }

    private func onNotAuthorized(anEvent: GDAppEvent) {
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
            print("onNotAuthorized \(anEvent.message)")
        case .errorIdleLockout:
            break
        default:
            assertionFailure("Unhandled not authorized event")
        }
    }
}

extension Notification.Name {
    /// Posted when Dynamics delivers `GDAppEventRemoteSettingsUpdate` after the app UI has started (`started`).
    static let gettingStartedDynamicsRemoteSettingsUpdated = Notification.Name("com.blackberry.dynamics.sample.gettingstartedbbd.remoteSettingsUpdated")
}
