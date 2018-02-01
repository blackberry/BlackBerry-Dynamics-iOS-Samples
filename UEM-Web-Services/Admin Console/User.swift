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

//User class
class User {
    
    private var userName : String
    private var firstName : String
    private var lastName : String
    private var displayName : String
    private var eMail : String
    
    var UserName: String {
        get { return userName }
    }
    
    var FirstName: String {
        get { return firstName }
    }
    
    var LastName: String {
        get { return lastName }
    }
    
    var DisplayName: String {
        get { return displayName }
    }
    
    var EMail: String {
        get { return eMail }
    }
    
    init(uName : String, fName :String, lName :String, dName :String, email :String) {
        self.userName = uName
        self.firstName = fName
        self.lastName = lName
        self.displayName = dName
        self.eMail = email
    }
    
}
