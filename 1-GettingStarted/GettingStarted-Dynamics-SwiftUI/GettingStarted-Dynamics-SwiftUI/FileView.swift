/* Copyright (c) 2021 BlackBerry Ltd.
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

import SwiftUI

struct FileView: View {
    
    @StateObject var fileVC : FileController
    
    var body: some View {
        NavigationView {
            ScrollView {
                HStack {
                    Text("File Exercise").bold()
                    Spacer()
                }
                HStack {
                    Button(action: {
                        fileVC.saveToFile()
                        hideKeyboard()
                    }, label: {
                        Text("Save")
                    }).padding()
                    
                    Button(action: {
                        fileVC.loadFromFile()
                        hideKeyboard()
                    }, label: {
                        Text("Load")
                    }).padding()
                    
                    Button(action: {
                        fileVC.clearText()
                        hideKeyboard()
                    }, label: {
                        Text("Clear")
                    }).padding()
                }
                HStack {
                    Text("Folder Exercise").bold()
                    Spacer()
                }
                VStack (alignment: .leading, spacing: 0, content: {
                    HStack {
                        Button(action: {
                            fileVC.createFolder()
                        }, label: {
                            Text("Create Folder")
                        }).padding()
                        
                        Button(action: {
                            fileVC.moveFile()
                        }, label: {
                            Text("Move File")
                        }).padding()
                        
                        Button(action: {
                            fileVC.renameFile()
                        }, label: {
                            Text("Rename File")
                        }).padding()
                    }
                    HStack {
                        Button(action: {
                            fileVC.deleteFile()
                        }, label: {
                            Text("Delete File")
                        }).padding()
                        
                        Button(action: {
                            fileVC.deleteFolder()
                        }, label: {
                            Text("Delete Folder")
                        }).padding()
                    }
                    Text(fileVC.statusUpdateMsg)
                        .bold()
                })
                VStack (alignment: .leading, spacing: 0, content: {
                    TextEditor(text: $fileVC.fileInfo)
                        .font(.footnote)
                })
                .border(Color.black, width: 1.0)
                .frame(
                      minWidth: 0,
                      maxWidth: .infinity,
                      minHeight: 0,
                      maxHeight: .infinity,
                      alignment: .topLeading
                    )
            }.navigationBarTitle("File", displayMode: .inline)
            .padding()
        }
    }
}

struct FileView_Previews: PreviewProvider {
    static var previews: some View {
        FileView(fileVC: FileController())
    }
}
