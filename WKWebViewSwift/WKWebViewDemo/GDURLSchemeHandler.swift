  
/* Copyright (c) 2020 BlackBerry Limited.
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

import WebKit
import MobileCoreServices
import BlackBerryDynamics.SecureStore.File

class GDURLSchemeHandler: NSObject, WKURLSchemeHandler {
    
    func getContentLengthForFilePath(filePath: String) -> NSInteger {
        guard GDFileManager.default().fileExists(atPath: filePath),
            let fileAttribDict = try? GDFileManager.default().attributesOfItem(atPath: filePath),
            let fileSize = fileAttribDict[FileAttributeKey.size] as? NSNumber
            else {
                return -1
        }
        return fileSize.intValue
    }
    
    func getFileDataForFilePath(filePath: String) -> Data? {
        if self.getContentLengthForFilePath(filePath: filePath) == -1 {
            return nil
        }
        
        guard let inputStream = try? GDFileManager.getReadStream(filePath) else {
            NSLog("Error opening read stream to file \(filePath)")
            return nil
        }

        let fileData = NSMutableData()
        while inputStream.hasBytesAvailable {
            let kBufferSize = 64 * 1024
            var buffer = Array<UInt8>(repeating: 0, count: kBufferSize)
            let inRead = inputStream.read(&buffer, maxLength: kBufferSize)
            let dataChunk = Data(bytes: buffer, count: inRead)
            fileData.append(dataChunk)
        }
        inputStream.close()
        return fileData as Data
    }
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let filePath = urlSchemeTask.request.url?.standardized.path,
            let requestURL = urlSchemeTask.request.url,
            let fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, requestURL.pathExtension as CFString, nil)?.takeRetainedValue(),
            let mimeType = UTTypeCopyPreferredTagWithClass(fileUTI, kUTTagClassMIMEType)?.takeRetainedValue()
            else {
                urlSchemeTask.didFailWithError(NSError(domain: "", code: 0, userInfo: ["message": "Unknown Access"]))
                return
        }
        
        let fileSize = self.getContentLengthForFilePath(filePath: filePath)
        let fileData = self.getFileDataForFilePath(filePath: filePath)
        
        let response = URLResponse(url: requestURL, mimeType: mimeType as String?, expectedContentLength: fileSize, textEncodingName: nil)
        urlSchemeTask.didReceive(response)
        if let data = fileData {
            urlSchemeTask.didReceive(data)
        }
        urlSchemeTask.didFinish()
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        
    }
}
