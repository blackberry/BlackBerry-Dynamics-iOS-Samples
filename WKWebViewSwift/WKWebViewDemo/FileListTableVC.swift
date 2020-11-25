  
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

import UIKit
import GD.SecureStore.File

@available(iOS 13.0, *)
class FileListTableVC: UITableViewController {

    let fileArr = ["sample.docx", "sample.pdf"]
    override func viewDidLoad() {
        super.viewDidLoad()
        WKWebViewDemoGDiOSDelegate.sharedInstance.rootViewController = self;
        self.title = "File List"
    }

    func writeFileInGDContainer(fileName: String) -> URL? {
        let file: NSString = fileName as NSString
        let fileName = file.deletingPathExtension
        let fileExtension = file.pathExtension
        
        // Write file in gd container
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else { return nil }
        let fileData = GDFileManager.default().contents(atPath: url.path)
        
        guard let basePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return nil }
        let filePath = basePath + "/" + fileName + "." + fileExtension
        guard GDFileManager.default().createFile(atPath: filePath, contents: fileData, attributes: nil) else { return nil }
        
        // Secure gd url for file
        let gdURL = URL(string: String(format: "gd://%@",filePath.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!))
        return gdURL
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileArr.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell", for: indexPath)
        cell.textLabel?.text = fileArr[indexPath.row];
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fileURL = writeFileInGDContainer(fileName: fileArr[indexPath.row])
        
        // Navigate to preview view controller
        guard let previewVC: WKWebViewPreviewVC = self.storyboard?.instantiateViewController(identifier: "PreviewVC") as? WKWebViewPreviewVC else { return }
        previewVC.fileGDURL = fileURL
        self.navigationController?.pushViewController(previewVC, animated: true)
    }
    
}
