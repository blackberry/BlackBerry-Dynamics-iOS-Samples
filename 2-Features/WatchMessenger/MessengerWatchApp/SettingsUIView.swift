/* Copyright (c) 2024 BlackBerry Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License")
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

import SwiftUI
import BlackBerryDynamicsWatch

struct SettingsUIView: View {
    
    @ObservedObject @MainActor var messenger = Messenger.shared

    @State var appUnlocked = false
    @State var companionInstalled = false
    @State var companionReachable = false
    @State var deviceNeedsUnlockReachable = false
    
    @State private var secureOnLaunch = UserDefaults.standard.bool(forKey: "secureOnLaunch")
    
    var body: some View {
        ScrollView(.vertical) {
            VStack{
                HStack() {
                    Text("Connect on Launch")
                    Toggle("", isOn: $secureOnLaunch).labelsHidden()
                        .onChange(of: secureOnLaunch) { value in
                            UserDefaults.standard.setValue(secureOnLaunch, forKey: "secureOnLaunch")
                        }
                }
                Button("Reset Trust") {
                    DynamicsWatch.sharedBBDWatchIOS().resetTrustBetweenDevices()
                    updateAppState()
                }
                Divider()
                Text(messenger.watchState)
                Spacer()
                HStack{
                    Image(systemName:appUnlocked ? "lock.open" : "lock").foregroundColor(appUnlocked ? .green : .red)
                    Image(systemName:"apps.iphone").foregroundColor(companionInstalled ? .green : .red)
                    Image(systemName:companionReachable ? "wifi" : deviceNeedsUnlockReachable ? "wifi.exclamationmark" : "wifi.slash").foregroundColor(companionReachable ? .green : .red)
                }
            }
        }
        .onAppear {
            updateAppState()
        }
    }
    
    func updateAppState() {
        appUnlocked = messenger.dynamicsWatch?.watchCommunicationState() == .ready
        companionInstalled = messenger.wcSession.isCompanionAppInstalled
        companionReachable = messenger.wcSession.isReachable
        deviceNeedsUnlockReachable = messenger.wcSession.iOSDeviceNeedsUnlockAfterRebootForReachability
        
        messenger.updateWatchCommunicationString()
        
        print("comm state \(messenger.dynamicsWatch?.watchCommunicationState() ?? .stateNotSet) appReady \(appUnlocked) companionAppInstalled \(companionInstalled) companionReachable \(companionReachable)")
    }
}

#Preview {
    SettingsUIView()
}
