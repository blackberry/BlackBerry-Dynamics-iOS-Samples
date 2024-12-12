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

struct MainUIView: View {
    @ObservedObject @MainActor var messenger = Messenger.shared

    @State private var secureOnLaunch = UserDefaults.standard.bool(forKey: "secureOnLaunch")
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                VStack {
                    NavigationLink(destination:MessageUIView()) { 
                        Text("Messages")
                    }
                    NavigationLink(destination:FileUIView()) { 
                        Text("Files")
                    }
                    NavigationLink(destination:SettingsUIView()) {
                        Text("Settings")
                    }
                }
            }
            .onAppear {
                if (secureOnLaunch) {
                    messenger.secureCommunication()
                }
            }
            .navigationTitle("Features")
        }
    }
}

#Preview {
    MainUIView()
}
