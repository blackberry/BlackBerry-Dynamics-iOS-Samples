/* Copyright (c) 2016 BlackBerry Ltd.
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

import Foundation
import UIKit
import BlackBerryDynamics
import PDFKit
import LinkPresentation

class ShareViewController: UIViewController {
    
    
    @IBOutlet weak var dlpOutLabel: UILabel!
    @IBOutlet weak var dlpInLabel: UILabel!
    
    func appDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //save local bundle PDF to secure Dynamics storage for later access
        let _ = savePDFtoSecureStorage()
        
        button.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
        button.center = view.center
        button.addTarget(self, action: #selector(presentNativeShare), for: .touchUpInside)
        view.addSubview(button)
        self.refreshUI()
    }
    
    /*
        Save PDF to secure storage
        Occurs on Initalization of ViewController
        Allows getPDFfromSecureStorage to have a file to grab when grabbing for Share Sheet.
     */
    private func savePDFtoSecureStorage() -> Bool {
        /*Get URL of file from local bundle /Resources/dynamics.pdf. It will be saved to secure storage */
        let fileUrl = Bundle.main.url(forResource: "helloworld", withExtension: "pdf")
        //Initialize GDFileManger to read
        let fileManager = GDFileManager.default()
        
        if let fileContents = try? Data(contentsOf: fileUrl!) {
            let fileCreated = fileManager.createFile(atPath: documentsFolderPathForNamed(name: "securely_saved.pdf"), contents: fileContents, attributes: nil)
            return fileCreated
        }
        else {
            //could not load local PDF from bundle URL
            return false
        }
    }
    
    func documentsFolderPathForNamed(name : String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory.appending(name)
    }
    
    /*
        Get PDF from Secure Storage to share
        via share sheet
     
     */
    private func getPDFfromSecureStorage() -> Data? {
        
        let filePath = self.documentsFolderPathForNamed(name: "securely_saved.pdf")
        //Initialize GDFileManger to read
        let fileManager = GDFileManager.default()
        
        if (fileManager.fileExists(atPath: filePath) == true) {
            
            var fileHandle = GDFileHandle.init()
            do {
                fileHandle = try GDFileHandle.init(forReadingFrom: URL.init(string: filePath)!)
            }
            catch {
                print(error.localizedDescription)
            }
            
            let resData = fileHandle.availableData
            let encryptedPath = GDFileManager.getAbsoluteEncryptedPath(filePath)
            print(encryptedPath!)
            return resData
        }
        else {
            print("ERROR: File does not exist")
            return nil
        }
    }
    
        
    private let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .link
        button.setTitle("Share Secure PDF", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    public func refreshUI() {
        
        /*Documentation on all keys https://developer.blackberry.com/devzone/files/blackberry-dynamics/ios/interface_g_di_o_s.html#a3265c6148406a8850ba673b26e472ece   */
        let config:NSDictionary = appDelegate().good?.getApplicationConfig() as! NSDictionary
        let isDLPoutEnabled = config.object(forKey: GDAppConfigKeyPreventDataLeakageOut) as! Bool
        let isDLPinEnabled = config.object(forKey: GDAppConfigKeyPreventDataLeakageIn) as! Bool

        self.dlpInLabel.text = isDLPinEnabled ? "Do not allow copy data in" : "Allow copy data in"
        self.dlpInLabel.textColor = isDLPinEnabled ? UIColor.green : UIColor.red
        
        self.dlpOutLabel.text = isDLPoutEnabled ? "Do not allow copying data out" : "Allow copy data out"
        self.dlpOutLabel.textColor = isDLPoutEnabled ? UIColor.green : UIColor.red

    }
    
    @objc private func presentNativeShare() {
        let didSaveToSecureStorage = savePDFtoSecureStorage()
        if (didSaveToSecureStorage) {
            
            if let rawPDFData = getPDFfromSecureStorage() {
                /*
                 https://stackoverflow.com/questions/62855746/issue-loading-pdf-for-uiactivityviewcontroller-with-datarepresentation
                 INFO: Because we are passing raw data (not a URL that it wants) we do not get the benifit of a Preview Icon.
                        We also do not get the benifit of auto generated choices of applications that will accept a PDF.
                        This could be solved by saving the Data into a temporary file. However, this might be considered insecure to save a once encrypted data file to open (non-secure) temp storage.
                        A workaround of Previewing/Custom App Share might exist using customized UIActivityItem
                 
                    The Current solution works, just missing the comforts of a preview and PDF based app choices
                 https://stackoverflow.com/questions/59684922/ios-13-custom-image-title-and-subtitle-in-the-presented-uiactivityviewcontroll
                 */
                if let pdfDocument = PDFDocument(data: rawPDFData) {
                    var filesToShare = [Any]()
                    filesToShare.append(pdfDocument.dataRepresentation()!)
                    let shareSheetViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
                    
        
                    present(shareSheetViewController, animated: true, completion: nil)
                }
                else
                {
                    print("ERROR: Did not convert raw data from secure storage into PDF Document!")
                }
            }
            else {
                print("ERROR: Did not get data from secure Storage!")
            }
            
            
        } else {
            print("ERROR: Did not save to secure storage!")
            
        }
    }
}

