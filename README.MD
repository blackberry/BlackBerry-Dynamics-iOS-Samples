# BlackBerry Dynamics iOS Samples

Samples built with BlackBerry Dynamics SDK.

## BlackBerry Dynamics Overview

[BlackBerry Dynamics](https://docs.blackberry.com/en/endpoint-management/blackberry-dynamics) is a mobile application development platform that enables secure communication, secure storage and exchange of data between enterprise apps according to enterprise security policies.

For details on features and a development guide, see [BlackBerry Dynamics SDK for iOS](https://docs.blackberry.com/en/development-tools/blackberry-dynamics-sdk-ios/)

## Samples

This repository contains sample projects that demonstrate the use of BlackBerry Dynamics APIs on iOS.

### Getting Started

This sample demonstrate features commonly used in the BlackBerry Dynamics applications. These include how to use secure file storage, secure database and secure communication.

| App Name                                                     | Language        |
| :----------------------------------------------------------- | --------------- |
| [GettingStarted-Dynamics-ObjC](https://github.com/blackberry/BlackBerry-Dynamics-iOS-Samples/tree/master/1-GettingStarted/GettingStarted-Dynamics-ObjC) | Obj-C           |
| [GettingStarted-Dynamics-Swift](https://github.com/blackberry/BlackBerry-Dynamics-iOS-Samples/tree/master/1-GettingStarted/GettingStarted-Dynamics-Swift) | Swift           |
| [GettingStarted-Dynamics-SwiftUI](https://github.com/blackberry/BlackBerry-Dynamics-iOS-Samples/tree/master/1-GettingStarted/GettingStarted-Dynamics-SwiftUI) | Swift & SwiftUI |

A version of this sample prior to Dynamics integration called 'GettingStarted' can also be found in the Getting Started folder.

### Features

These samples demonstrate specific features available in BlackBerry Dynamics applications. They are updated with best effort as not all are tested and updated against each SDK release.

------
| App Name                                                     | Language      | Description                                              |
| ------------------------------------------------------------ | ------------- | ------------------------------------------------------------ |
| [AppBasedCertImport](https://github.com/blackberry/BlackBerry-Dynamics-iOS-Samples/tree/master/2-Features/AppBasedCertImport) | Obj-C | How to use the app-based PKI solution to provide certificates for use by BlackBerry Dynamics. |
| [AppConfiguration](https://github.com/blackberry/BlackBerry-Dynamics-iOS-Samples/tree/master/2-Features/AppConfiguration) | Swift | How to develop apps with custom app policies configured in BlackBerry UEM. |
| [AppKinetics](https://github.com/blackberry/BlackBerry-Dynamics-iOS-Samples/tree/master/2-Features/AppKinetics) [SaveEditClient](https://github.com/blackberry/BlackBerry-Dynamics-iOS-Samples/tree/master/2-Features/AppKinetics-SaveEditClient) [SaveEditService](https://github.com/blackberry/BlackBerry-Dynamics-iOS-Samples/tree/master/2-Features/AppKinetics-SaveEditService)| Obj-C| How to search for, create, and implement an Application-Based Service, using BlackBerry Dynamics AppKinetics. These concepts are demonstrated together in the AppKinetics sample by implementing a consumer and a provider for the Transfer File service. The SaveEditClient and SaveEditService samples split out the consumer and provider into different apps to illustrate transferring the file between apps on the device. |
| [AutoFillBlocking](https://github.com/blackberry/BlackBerry-Dynamics-iOS-Samples/tree/master/2-Features/AutofillBlocking)| Obj-C | How to block AutoFill suggestions in UITextField instances.  |
| [Crypto](https://github.com/blackberry/BlackBerry-Dynamics-iOS-Samples/tree/master/2-Features/Crypto) | Obj-C | Demonstrates how to use the Crypto APIs that enable signing and verification of messages or documents, such as PDFs. |
| [GreetingsClient](https://github.com/blackberry/BlackBerry-Dynamics-iOS-Samples/tree/master/2-Features/GreetingsClient)<br /> [GreetingsServer](https://github.com/blackberry/BlackBerry-Dynamics-iOS-Samples/tree/master/2-Features/GreetingsServer) | Obj-C | Demonstrates how to create your own AppKinetics application-based service. This example uses a fictitious Greetings Service to show how to securely share a greeting between two Dynamics applications (client and server). |
| [KeyManager](https://github.com/blackberry/BlackBerry-Dynamics-iOS-Samples/tree/master/2-Features/KeyManager) | Obj-C | This app demonstrates how to present a Credential Manager user interface that enables the user to set up, review, and manage user certificates and keys. The user is granted this capability by admin through assignment of User Certificate and User Credential profiles. |
| [Launcher](https://github.com/blackberry/BlackBerry-Dynamics-iOS-Samples/tree/master/2-Features/Launcher) | Obj-C | The “Launcher” is a UX concept whereby an icon is displayed permanently on each screen, “floating” over the content. This sample demonstrates how to customize the Launcher |
| [UIScene Delegate](https://github.com/blackberry/BlackBerry-Dynamics-iOS-Samples/tree/master/2-Features/SceneDelegate) | Swift | Simple Swift application illustrating how to integrate Dynamics using UISceneDelegate. |
| [WebSocket](https://github.com/blackberry/BlackBerry-Dynamics-iOS-Samples/tree/master/2-Features/WebSocket) | Obj-C | A secure WebSocket client based on Jetfire and BlackBerry Dynamics Socket which conforms to RFC 6455. |
| [WKWebView](https://github.com/blackberry/BlackBerry-Dynamics-iOS-Samples/tree/master/2-Features/WKWebView) | Swift | This sample demonstrates how to render different file types in WKWebView. |


### Archive

These older samples are not maintained and included for reference.

| App Name                                                     | Language      | Description                                              |
| ------------------------------------------------------------ | ------------- | ------------------------------------------------------------ |
| [AppConfiguration](https://github.com/blackberry/BlackBerry-Dynamics-iOS-Samples/tree/master/3-Archive/AppConfiguration-Swift) | Obj-C | How to develop apps with custom app policies configured in BlackBerry UEM. |
| [AppKinetics-Services-Client](https://github.com/blackberry/BlackBerry-Dynamics-iOS-Samples/tree/master/3-Archive/AppKinetics-ServicesClient) <br>[AppKinetics-Services-Service](https://github.com/blackberry/BlackBerry-Dynamics-iOS-Samples/tree/master/3-Archive/AppKinetics-Services-Service)  | Swift | Services-Client demonstrates how to use the AppKinetics programming interface as a consumer, whilst Services-Service acts as a sample provider.|
| [BEMS-SharedServices](https://github.com/blackberry/BlackBerry-Dynamics-iOS-Samples/tree/master/3-Archive/BEMS-SharedServices) | Obj-C | How to use BEMS (BlackBerry Enterprise Mobility Server) and BlackBerry Mobile Services. For example, send email service, or transfer file service. |
| [BypassUnlock](https://github.com/blackberry/BlackBerry-Dynamics-iOS-Samples/tree/master/3-Archive/BypassUnlock) | Obj-C | Shows how part of the application user interface can remain accessible after the BlackBerry Dynamics idle time out has expired. |
| RSSReader <br />[Swift](https://github.com/blackberry/BlackBerry-Dynamics-iOS-Samples/tree/master/3-Archive/RSSReader) & [Obj-C](https://github.com/blackberry/BlackBerry-Dynamics-iOS-Samples/tree/master/3-Archive/RSSReader-ObjC) | Swift & Obj-C | Demonstrates how to use the BlackBerry Dynamics secure communication APIs to fetch RSS feeds. Networking, TLS, NSURLSession Authentication. |
| Secure-Storage <br />[Swift](https://github.com/blackberry/BlackBerry-Dynamics-iOS-Samples/tree/master/3-Arcive/Secure-Storage) & [Obj-C](https://github.com/blackberry/BlackBerry-Dynamics-iOS-Samples/tree/master/3-Archive/Secure-Storage-ObjC)| Swift & Obj-C| This sample demonstrates how to use Secure CoreData and Secure SQL database APIs in Objective-C. |
| [ServerServices](https://github.com/blackberry/BlackBerry-Dynamics-iOS-Samples/tree/master/3-Archive/ServerServices) | Obj-C | Intended as a starting point for developers making use of BlackBerry Dynamics Server-Based Services. It retrieves the details of any available com.blackberry.example.gdservice.time-zone service providers using the getServiceProvidersFor programming interface. The user then enters a latitude and longitude, and the application retrieves the corresponding results from the Google service. |
| [UEM-Web-Services](https://github.com/blackberry/BlackBerry-Dynamics-iOS-Samples/tree/master/3-Archive/UEM-Web-Services) | Swift | This sample demonstrates various REST and SOAP APIs including authentication to UEM, automating administrative tasks, and integrations with BlackBerry UEM. |
| [WKWebView](https://github.com/blackberry/BlackBerry-Dynamics-iOS-Samples/tree/master/3-Archive/WKWebView-ObjC) | Obj-C | This sample demonstrates how to render different file types in WKWebView. |


**Contribute**

* To contribute to this repository, [sign up as an official contributor](http://blackberry.github.com/howToContribute.html).

## License

Apache 2.0 License

## Disclaimer

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.