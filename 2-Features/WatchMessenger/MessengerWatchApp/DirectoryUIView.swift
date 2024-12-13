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
import WatchConnectivity

struct DirectoryUIView: View {
    
    @ObservedObject @MainActor var messenger = Messenger.shared
    
    var body: some View {
        List(messenger.files, id:\.self) { file in
            Button(file) {
                let sendAction = WKAlertAction(title: "Send + Meta", style: .default, handler: {
                    sendFileToPhone(file, sendMetadata: true)
                })
                let sendNoMetaAction = WKAlertAction(title: "Send w/o Meta", style: .default, handler: {
                    sendFileToPhone(file, sendMetadata: false)
                })
                let deleteAction = WKAlertAction(title: "Delete file", style: .destructive, handler: {
                    deleteFile(file)
                })
                let dismissAction = WKAlertAction(title:"Dismiss", style: .cancel, handler: {})
                
                let fileContent = FileHelper.sharedInstance.getContentOfFileFromWatchFolder(file)
                
                WKApplication.shared().rootInterfaceController?.presentAlert(withTitle: file, 
                                                                             message: fileContent,
                                                                             preferredStyle: .alert,
                                                                             actions: [sendAction,
                                                                                       sendNoMetaAction,
                                                                                       deleteAction,
                                                                                       dismissAction])
            }
        }
        .onAppear {
            refreshList()
        }
    }
    
    func sendFileToPhone(_ fileName: String, sendMetadata: Bool) {
        let fileURL = URL(fileURLWithPath: FileHelper.sharedInstance.watchFilesFolder + fileName)
        var metadataDict: [String : Any]? = nil
        if sendMetadata {
            metadataDict = [
                "metadataString" : "string",
                "metadataNumbers" : 1.0,
                "metadataData" : "Utf8 encoded data string".data(using: .utf8) ?? Data(),
                "metadataArray" : ["stringArray", 2],
                "metadataDict" : ["metadataStringNested" : "nested string"]
            ]
        }
        
        let fileContent = FileHelper.sharedInstance.getContentOfFileFromWatchFolder(fileName)
        
        print("Sending file: \(fileName) - content: \(fileContent) - metadata: \(String(describing: metadataDict))")
        WCSession.default.transferFile(fileURL, metadata: metadataDict)
    }
    
    func deleteFile(_ fileName: String) {
        FileHelper.sharedInstance.deleteFileFromWatchFolder(fileName)
        refreshList()
    }
    
    func refreshList() {
        messenger.refreshFileList()
    }
    
}

#Preview {
    DirectoryUIView()
}
