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
import AEXML

//Class to create XML header for SOAP call
class SoapXml {
    
    //Generate XML header for getting all users.
    func XMLDataForUsers() -> AEXMLDocument {
        
        let soapRequest = AEXMLDocument()
        let attributes = ["xmlns:soapenv" : "http://schemas.xmlsoap.org/soap/envelope/", "xmlns:adm" : "http://ws.rim.com/enterprise/admin"]
        let envelope = soapRequest.addChild(name: "soapenv:Envelope", attributes: attributes)
        envelope.addChild(name: "soapenv:Header")
        let body = envelope.addChild(name: "soapenv:Body")
        let GetUsersRequest = body.addChild(name :"adm:GetUsersRequest")
        let meta = GetUsersRequest.addChild(name : "adm:metadata")
        meta.addChild(name: "adm:locale", value: "en_US")
        meta.addChild(name: "adm:clientVersion", value: "12")
        meta.addChild(name: "adm:organizationUid", value: "0")
        let sort = GetUsersRequest.addChild(name: "adm:sortBy")
        sort.addChild(name: "adm:DISPLAY_NAME", value: "true")
        
        GetUsersRequest.addChild(name: "sortAscedning", value: "true")
        
        return soapRequest
    }
    
    //Generate XML header to delete a device
    func XMLDataToWipeDevice() -> AEXMLDocument {
        
        let soapRequest = AEXMLDocument()
        let attributes = ["xmlns:soapenv" : "http://schemas.xmlsoap.org/soap/envelope/", "xmlns:adm" : "http://ws.rim.com/enterprise/admin"]
        let envelope = soapRequest.addChild(name: "soapenv:Envelope", attributes: attributes)
        envelope.addChild(name: "soapenv:Header")
        let body = envelope.addChild(name: "soapenv:Body")
        let SetDevicesWipeRequest = body.addChild(name :"adm:SetDevicesWipeRequest")
        let meta = SetDevicesWipeRequest.addChild(name : "adm:metadata")
        meta.addChild(name: "adm:locale", value: "en_US")
        meta.addChild(name: "adm:clientVersion", value: "12")
        meta.addChild(name: "adm:organizationUid", value: "0")
        let users = SetDevicesWipeRequest.addChild(name: "adm:devices")
        SetDevicesWipeRequest.addChild(name: "adm:organizationWipeOnly", value: "true")
        users.addChild(name: "adm:uid", value: Global.sharedInstance.soapDeviceState["ns2:uid"].value)
        let offBoardingType = SetDevicesWipeRequest.addChild(name: "adm:offboardingType")
        offBoardingType.addChild(name: "adm:DISABLE_AND_REMOVE_USER_STATE", value: "true")
        return soapRequest
    }
    
    //Generate XML header to get the application of the user
    func XMLDataToGetApplicationsDevice() -> AEXMLDocument {
        
        let soapRequest = AEXMLDocument()
        let attributes = ["xmlns:soapenv" : "http://schemas.xmlsoap.org/soap/envelope/", "xmlns:adm" : "http://ws.rim.com/enterprise/admin"]
        let envelope = soapRequest.addChild(name: "soapenv:Envelope", attributes: attributes)
        envelope.addChild(name: "soapenv:Header")
        let body = envelope.addChild(name: "soapenv:Body")
        let GetUsersDetailRequest = body.addChild(name :"adm:GetUsersDetailRequest")
        let meta = GetUsersDetailRequest.addChild(name : "adm:metadata")
        meta.addChild(name: "adm:locale", value: "en_US")
        meta.addChild(name: "adm:clientVersion", value: "12")
        meta.addChild(name: "adm:organizationUid", value: "0")
        let users = GetUsersDetailRequest.addChild(name: "adm:users")
        users.addChild(name: "adm:uid", value: Global.sharedInstance.soapUser["ns2:uid"].value)
        
        GetUsersDetailRequest.addChild(name: "adm:loadApplications", value: "true")
        
        return soapRequest
    }
    
    //Generate XML header to get the encoded username
    func XMLDataToGetAuthHeader(username : String) -> AEXMLDocument {
        
        let soapRequest = AEXMLDocument()
        let attributes = ["xmlns:soapenv" : "http://schemas.xmlsoap.org/soap/envelope/", "xmlns:adm" : "http://ws.rim.com/enterprise/admin"]
        let envelope = soapRequest.addChild(name: "soapenv:Envelope", attributes: attributes)
        envelope.addChild(name: "soapenv:Header")
        let body = envelope.addChild(name: "soapenv:Body")
        let GetEncodedUsernameRequest = body.addChild(name :"adm:GetEncodedUsernameRequest")
        let meta = GetEncodedUsernameRequest.addChild(name : "adm:metadata")
        meta.addChild(name: "adm:locale", value: "en_US")
        meta.addChild(name: "adm:clientVersion", value: "12")
        meta.addChild(name: "adm:organizationUid", value: "0")
        
        GetEncodedUsernameRequest.addChild(name: "adm:username", value: username)
        
        let authenticator = GetEncodedUsernameRequest.addChild(name: "adm:authenticator")
        authenticator.addChild(name: "adm:uid", value: "BlackBerry Administration Service")
        authenticator.addChild(name: "adm:authenticatorType").addChild(name: "adm:INTERNAL", value: "true")
        authenticator.addChild(name: "adm:name", value: "BlackBerry Administration Service")
        
        GetEncodedUsernameRequest.addChild(name: "adm:credentialType").addChild(name: "adm:PASSWORD", value: "true")
        
        return soapRequest
    }
    
}
