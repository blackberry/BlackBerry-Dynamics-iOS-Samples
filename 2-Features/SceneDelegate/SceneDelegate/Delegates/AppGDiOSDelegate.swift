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

import BlackBerryDynamics.Runtime

class AppGDiOSDelegate: NSObject, GDiOSDelegate {
    
    var hasAuthorized: Bool
    private var uiLaunchers: [WeakWrapper<UserInterfaceLauncher>]
    
    func handle(_ anEvent: GDAppEvent) {
        switch anEvent.type {
            case .authorized:
                self.onAuthorized(anEvent);
            case .notAuthorized:
                self.onNotAuthorized(anEvent);
            default:
                print("Event not handled: '\(anEvent.message)'")
        }
    }
    
    func onNotAuthorized(_ anEvent:GDAppEvent ) {
        /* Handle the BlackBerryDynamic Library not authorized event */
        self.hasAuthorized = false
        print("AppGDiOSDelegate onNotAuthorized \(anEvent.message)")
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
            case .errorPasswordChangeRequired: break
            case .errorIdleLockout: break
            default: assert(false, "Unhandled not authorized event");
        }
    }
    
    func onAuthorized(_ anEvent: GDAppEvent) {
        /* Handle the Good Library authorized event */
        switch anEvent.code {
            case .errorNone :
                self.hasAuthorized = true
                self.startSheduledInterfaces()
            default:
                assert(false, "Authorized startup with an error")
        }
    }
    
    func scheduleInterfaceLaunching(with launcher: UserInterfaceLauncher) {
        self.uiLaunchers.append(WeakWrapper(value: launcher))
    }
    
    func removeScheduledLaunching(with launcher: UserInterfaceLauncher) {
        self.uiLaunchers.removeAll(where: { $0.value === launcher })
    }
    
    private func startSheduledInterfaces() {
        uiLaunchers.forEach { (launcher) in
            launcher.value?.launchApplicationUI()
        }
        uiLaunchers.removeAll()
    }
    
    static let sharedInstance = { AppGDiOSDelegate() }()
    override private init() {
        self.hasAuthorized = false
        self.uiLaunchers = [WeakWrapper<UserInterfaceLauncher>]()
        super.init()
    }
    
}
