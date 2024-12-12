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

struct DBColorToggle : View {
    var colorLabel : String
    var fontColor : Color
    @Binding var isOn : Bool
    
    var body: some View {
        Toggle(isOn: $isOn, label: {
            Text(colorLabel).foregroundColor(fontColor)
                .bold()
        }).padding()
    }
}

struct DatabaseView: View {
    
    @StateObject var dbVC : DBController
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        Button("Load Color") {
                            dbVC.loadColours()
                        }.padding()
                        
                        Button("Save Color") {
                            dbVC.saveColours()
                        }.padding()
                        
                        Button("Clear") {
                            dbVC.clearColours()
                        }.padding()
                    }.padding()
                    
                    // Blue
                    DBColorToggle(colorLabel: "Blue", fontColor: .blue, isOn: $dbVC.isBlueOn)
                    
                    // Red
                    DBColorToggle(colorLabel: "Red", fontColor: .red, isOn: $dbVC.isRedOn)
                    
                    // Black
                    DBColorToggle(colorLabel: "Black", fontColor: .black, isOn: $dbVC.isBlackOn)
                    
                    // Pink
                    DBColorToggle(colorLabel: "Pink", fontColor: .pink, isOn: $dbVC.isPinkOn)
                    
                    // Green
                    DBColorToggle(colorLabel: "Green", fontColor: .green, isOn: $dbVC.isGreenOn)
                }
            }.navigationBarTitle("Database", displayMode: .inline)
        }
    }
}


// Cannot use preview because GD will not be provisioned in the preview environment which prevents the database from being initilized
//
//struct DatabaseView_Previews: PreviewProvider {
//    static var previews: some View {
//        DatabaseView(dbVC: DBController())
//    }
//}
