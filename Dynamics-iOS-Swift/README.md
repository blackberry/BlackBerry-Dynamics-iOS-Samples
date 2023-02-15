# BlackBerry Dynamics Sample App for iOS - Swift

This sample pairs with Basic-iOS-Swift as examples of iOS apps before and after integrating with the BlackBerry Dynamics SDK. The two samples demostrate features commonly used in the BlackBerry Dynamics applications; secure file storage, secure database (SQL and CoreData), secure communication (HTTP/S and Socket) and a Data Loss Prevention Share View example.


## Requirements

* Xcode 13 or later
* iOS 15 or later


## Author(s)

* [EunKyung Choi](http://www.twitter.com/echotown)
* [Matthew Falkner](https://www.linkedin.com/in/matthewfalkner/)

**Contributing**

* To contribute code to this repository you must be signed up as an official contributor.


## How To Build and Deploy

1. Set up BlackBerry Dynamics environment
2. Clone the repo to your computer.
3. Run `pod install` to create project workspace.
4. Launch Xcode and open the project.
5. Edit Bundle ID to your own
6. Edit URL identifier and URL Schemes in the info.plist.
7. Edit GD Application ID to your own in the info.plist.
8. Build, deploy and run on a testing device. 

**Note:** Bitcode is disabled for the project

For more information on how to develop BlackBerry Dynamics iOS apps, visit [BlackBerry Dynamics SDK for iOS](https://docs.blackberry.com/en/development-tools/blackberry-dynamics-sdk-ios/) 
/*Documentation on all keys    */

## How to test Share Sheet DLP Example
 `ShareViewController.swift`  is updated by `AppDelegate.swift` when changes to the users/app Dynamics Policy Configuration occur. 
 When `GDAppConfigKeyPreventDataLeakageIn` is `true`, the application cannot import data from other applications or services. 
 When `GDAppConfigKeyPreventDataLeakageOut` is `true`, the application cannot share data to other applications. 
 _[Documentation](https://developer.blackberry.com/devzone/files/blackberry-dynamics/ios/interface_g_di_o_s.html#a3265c6148406a8850ba673b26e472ece)_
 
 You can test this functionality by creating a `BlackBerry Dynamics Profile` under `Policies and Pofiles` in your UEM Console. Configure two profiles. One profile can be named as `Enabled DLP`, and the other,`Disable DLP`. 
 
 ![DLP Pplicy](./DLP_UEM.png)

 You can assign these to your test user which the application is activated with.  
 
 Once assigned you can navigate to the `ShareViewController.swift` on your test device, and attempt to share under both cases. 
 
 
## License

Apache 2.0 License


## Disclaimer

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
