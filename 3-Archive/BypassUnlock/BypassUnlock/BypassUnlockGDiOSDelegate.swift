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
@objc class BypassUnlockGDiOSDelegate: NSObject, @preconcurrency GDiOSDelegate {

    @objc static let sharedInstance = BypassUnlockGDiOSDelegate()

    weak var sceneDelegate: BypassUnlockSceneDelegate?
    @objc weak var rootViewController: BPStartViewController? {
        didSet { coordinateDidAuthorize() }
    }
    @objc weak var appDelegate: AppDelegate? {
        didSet { coordinateDidAuthorize() }
    }

    private(set) var hasAuthorized = false
    private var localComplianceManagerStorage: LocalComplianceManager?

    @objc var localComplianceManager: LocalComplianceManager? {
        return localComplianceManagerStorage
    }

    private override init() {
        super.init()
    }

    private func coordinateDidAuthorize() {
        if hasAuthorized, rootViewController != nil, appDelegate != nil {
            appDelegate?.didAuthorize()
        }
    }

    private func setupLocalComplianceManager() {
        if localComplianceManagerStorage == nil {
            localComplianceManagerStorage = LocalComplianceManager()
        }
    }

    func handle(_ anEvent: GDAppEvent) {
        switch anEvent.type {
        case .authorized:
            onAuthorized(anEvent)
        case .notAuthorized:
            onNotAuthorized(anEvent)
        case .remoteSettingsUpdate, .servicesUpdate, .entitlementsUpdate:
            break
        case .policyUpdate:
            NotificationCenter.default.post(name: NSNotification.Name("GDAppEventPolicyUpdateNotification"), object: nil)
        default:
            NSLog("Unhandled Event")
        }
    }

    private func onNotAuthorized(_ anEvent: GDAppEvent) {
        switch anEvent.code {
        case .errorActivationFailed, .errorProvisioningFailed, .errorPushConnectionTimeout,
             .errorSecurityError, .errorAppDenied, .errorAppVersionNotEntitled, .errorBlocked:
            setupLocalComplianceManager()
            localComplianceManagerStorage?.addUnblockButton()
        case .errorWiped, .errorRemoteLockout:
            BPCallManager.shared().appStarted = false
            hasAuthorized = false
            NSLog("onNotAuthorized %@", anEvent.message)
        case .errorPasswordChangeRequired:
            NSLog("onNotAuthorized %@", anEvent.message)
        case .errorIdleLockout:
            BPCallManager.shared().appIdleLocked = true
            NSLog("onNotAuthorized %@", anEvent.message)
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
                setupLocalComplianceManager()
            }
            BPCallManager.shared().appIdleLocked = false
        default:
            assertionFailure("Authorized startup with an error")
        }
    }
}
