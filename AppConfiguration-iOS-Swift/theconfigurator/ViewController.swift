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

import UIKit
import AVFoundation
import GD.Runtime

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var carImage: UIImageView!
    @IBOutlet weak var carDescription: UITextView!
    @IBOutlet weak var soundButton: UIButton!
    @IBOutlet weak var policyVersion: UILabel!
    
    var player: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        do {
            try self.configureAudioPlayer()
        } catch _ {
            print("Error initialising audio player")
        }
        
        self.refreshUi()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playSoundButtonPressed(_ sender: Any) {
        self.soundButton.isEnabled = false
        self.player.play()
    }
    
    public func refreshUi() {
        
        //use the application policy retrieved from GC and update UI
        let appPolicy = GDiOS.sharedInstance().getApplicationPolicy()
        let visibleElements: Array<String> = appPolicy["visibleElements"] as! Array<String>
        
        //print the policy as string
        print("Application policy as string \(GDiOS.sharedInstance().getApplicationPolicyString())")
        
        //Update Title
        var title: String? = "Hidden by policy"
        
        if (visibleElements.contains("name")) {
            
            title = appPolicy["carName"] as? String
            
            if (title == nil || (title?.isEmpty)!) {
                title = "Not set"
            }
        }
        
        self.navBar.topItem?.title = title
        
        //Update Car image
        self.carImage.isHidden = !visibleElements.contains("image")
        
        var carImageName: String = ""
        let color: Int = appPolicy["exteriorColor"] as! Int
        let convertible: Bool = appPolicy["isConvertible"] as! Bool
        switch (color) {
        case 0:
            if (convertible) {
                carImageName = "black_convertible"
            } else {
                carImageName = "black_coupe"
            }
        case 1:
            if (convertible) {
                carImageName = "blue_convertible"
            } else {
                carImageName = "blue_coupe"
            }
        case 2:
            if (convertible) {
                carImageName = "red_convertible"
            } else {
                carImageName = "red_coupe"
            }
        case 3:
            if (convertible) {
                carImageName = "silver_convertible"
            } else {
                carImageName = "silver_coupe"
            }
        case 4:
            if (convertible) {
                carImageName = "turquoise_convertible"
            } else {
                carImageName = "turquoise_coupe"
            }
        case 5:
            if (convertible) {
                carImageName = "yellow_convertible"
            } else {
                carImageName = "yellow_coupe"
            }
        default:
            carImageName = "car_placeholder"
        }
        self.carImage.image = UIImage(named: carImageName)
        
        
        //Update Text View
        self.carDescription.isHidden = !visibleElements.contains("description")
        var carDescription: String? = appPolicy["carDescription"] as? String
        if (carDescription == nil || (carDescription?.isEmpty)!) {
            carDescription = "Car description Not set"
        }
        self.carDescription.text = carDescription
        
        
        //Update Playsound
        self.soundButton.isHidden = !(appPolicy["enableSound"] as! Bool)
        
        //Play/Stop sound
        let autoplay: Bool = appPolicy["enableAutoPlaySound"] as! Bool
        if (autoplay == true) {
            self.playSoundButtonPressed(self.soundButton)
        }
        
        //Update Version String
        self.policyVersion.text = (appPolicy["version"] as! String)
        
    }
    
    func configureAudioPlayer() throws {
        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        let backgroundMusicPath = Bundle.main.path(forResource: "CarSound", ofType:"mp3")
        try self.player = AVAudioPlayer(contentsOf: URL(fileURLWithPath: backgroundMusicPath!))
        self.player.delegate = self
        self.player.numberOfLoops = 0
    }
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.soundButton.isEnabled = true
    }
    
    
    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        self.soundButton.isEnabled = true
    }
    
}

