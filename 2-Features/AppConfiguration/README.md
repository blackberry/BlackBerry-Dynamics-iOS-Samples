# App Configuration

This sample demonstrates how to utilize custom app policies uploaded to BlackBerry UEM. 

## Description

BlackBerry Dynamics app configuration can be used to remotely configure a BlackBerry Dynamics application. After adding this sample to your UEM server, upload the included policy file "App Configuration UEM Policy.xml".

For more information, refer to the BlackBerry Developer Blog: [Custom App Policies in BlackBerry Dynamics Applications](http://devblog.blackberry.com/2016/08/custom-app-policies-in-good-dynamics-applications/)

## Requirements

See [Software Requirements](https://docs.blackberry.com/en/development-tools/blackberry-dynamics-sdk-ios/current/blackberry-dynamics-sdk-ios-devguide/gwj1489687014271/vcw1490294551674) of the BlackBerry Dynamics SDK (iOS) 

## How To Build and Deploy

1. Set up BlackBerry Dynamics Development Environment.
2. Clone the repo. 
3. Run `pod install` to create project workspace.
4. Launch Xcode and open the project.
5. Edit the *Bundle Identifier* to your own.
6. Edit the *URL identifier* and *URL Schemes* according to your own in the *info.plist*. See [Declaring a URL type to support BlackBerry Dynamics features](https://docs.blackberry.com/en/development-tools/blackberry-dynamics-sdk-ios/current/blackberry-dynamics-sdk-ios-devguide/gwj1489687014271) in the Developer Guide.
7. Edit the *GDApplicationID* to your own or use the default '*com.blackberry.dynamics.sample*' in the *info.plist*.
8. Assign the app entitlement to a user in your UEM server. This may also require adding the BlackBerry Dynamics App entitlement to UEM if you are using your own. See [Add an internal BlackBerry Dynamics app entitlement](https://docs.blackberry.com/en/endpoint-management/blackberry-uem/current/managing-apps/managing-blackberry-dynamics-apps).
9. Build and run on simulator or a device.

For more information on how to develop BlackBerry Dynamics apps, refer to [Get Started with BlackBerry Dynamics](https://developers.blackberry.com/us/en/resources/get-started/blackberry-dynamics-getting-started) 

## License

Apache 2.0 License

## Disclaimer

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.