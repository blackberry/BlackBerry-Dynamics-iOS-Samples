# Bypass Unlock

This sample shows how part of the application user interface can remain accessible after the BlackBerry Dynamics idle time out has expired.

## Description

This sample demonstrates the bypass unlock feature in BlackBerry Dynamics. It permits part of the application user interface to remain accessible after the BlackBerry Dynamics idle time out has expired.

Bypass Unlock can be allowed or disallowed by enterprise policy. This is implemented using the BlackBerry Dynamics Application Policies feature. (Application Policies are sometimes known as Application Configurations) 

To switch on Bypass Unlock, update the policy setting in the management console to allow parts of the user interface to be displayed when the idle lock is in place.

The part of the user interface that bypasses the unlock screen can be opened by:

-   Pressing the volume controls, if the application is in foreground.
-   Using the auxiliary 'notifier' application, from the sub-project, if the
    application is in background.

The BlackBerry Dynamics unlock screen can be bypassed only when the user is already authorized, and after the idle time out has expired. If the user opens a Bypass Activity from cold start, i.e. before authorizing, they will have to enter their password.

## Prerequisites

This sample uses *GDApplicationID* '*com.good.example.sdk.bypassunlock*' which has an entitlement to use the Background Unlock feature. 

To request use of this feature within your application, please contact [BlackBerry](https://www.blackberry.com/us/en/partners/isv-partner).

## Requirements

See [Software Requirements](https://docs.blackberry.com/en/development-tools/blackberry-dynamics-sdk-ios/current/blackberry-dynamics-sdk-ios-devguide/gwj1489687014271/vcw1490294551674) of the BlackBerry Dynamics SDK (iOS) 

## How To Build and Deploy

1. Set up BlackBerry Dynamics Development Environment.
2. Clone the repo. 
3. Run `pod install` to create project workspace.
4. Launch Xcode and open the project.
5. Edit the *Bundle Identifier* to your own.
6. Edit the *URL identifier* and *URL Schemes* according to your own in the *info.plist*. See [Declaring a URL type to support BlackBerry Dynamics features](https://docs.blackberry.com/en/development-tools/blackberry-dynamics-sdk-ios/current/blackberry-dynamics-sdk-ios-devguide/gwj1489687014271) in the Developer Guide.
7. Only use the *GDApplicationID* '*com.good.example.sdk.bypassunlock*' in the *info.plist* as this ID has specific entitlements to use this feature.
8. Assign the app entitlement to a user in your UEM server. This may also require adding the BlackBerry Dynamics App entitlement to UEM if you are using your own. See [Add an internal BlackBerry Dynamics app entitlement](https://docs.blackberry.com/en/endpoint-management/blackberry-uem/current/managing-apps/managing-blackberry-dynamics-apps).
9. Build and run on simulator or a device.

For more information on how to develop BlackBerry Dynamics apps, refer to [Get Started with BlackBerry Dynamics](https://developers.blackberry.com/us/en/resources/get-started/blackberry-dynamics-getting-started) 

## License

Apache 2.0 License

## Disclaimer

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.