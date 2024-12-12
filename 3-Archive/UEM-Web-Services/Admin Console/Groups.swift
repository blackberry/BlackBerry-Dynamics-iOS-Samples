/* Copyright (c) 2017 BlackBerry Ltd.
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

import Foundation

//Groups class
class Groups {
    
    private var guid : String
    private var name : String
    private var directoryLinked : Bool
    
    var GUID: String {
        get { return guid }
    }
    
    var Name: String {
        get { return name }
    }
    
    var DirectoryLinked: Bool {
        get { return directoryLinked }
    }
    
    init(guid : String, name :String, dl :Bool) {
        self.guid = guid
        self.name = name
        self.directoryLinked = dl
    }
}
