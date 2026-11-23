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

@objc class AppConfigurationGDiOSDelegate: NSObject, GDiOSDelegate {

    static let shared = AppConfigurationGDiOSDelegate()

    weak var sceneDelegate: AppConfigurationSceneDelegate? {
        didSet {
            tryInstallMainUI()
        }
    }

    private(set) var started = false

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
            break
        case .servicesUpdate:
            break
        case .policyUpdate:
            if started {
                if let viewController = sceneDelegate?.window?.rootViewController as? ViewController {
                    viewController.refreshUi()
                }
            }
        default:
            print("handleEvent \(anEvent.message)")
        }
    }

    func onNotAuthorized(anEvent: GDAppEvent) {
        switch anEvent.code {
        case .errorActivationFailed: break
        case .errorProvisioningFailed: break
        case .errorPushConnectionTimeout: break
        case .errorSecurityError: break
        case .errorAppDenied: break
        case .errorAppVersionNotEntitled: break
        case .errorBlocked: break
        case .errorWiped: break
        case .errorRemoteLockout: break
        case .errorPasswordChangeRequired:
            print("onNotAuthorized \(anEvent.message)")
        case .errorIdleLockout:
            break
        default:
            assertionFailure("Unhandled not authorized event")
        }
    }

    func onAuthorized(anEvent: GDAppEvent) {
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
}
