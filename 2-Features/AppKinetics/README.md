# AppKinetics

How to use BlackBerry Dynamics AppKinetics to securely share files and content between applications on device.

## Description

This sample shows how to search for, create, and implement an Application-Based Service, using BlackBerry Dynamics AppKinetics. It demonstrates these concepts by implementing a consumer and a provider for the Transfer File service. Users can select any of the installed Dynamics apps to transfer the file to, or they can select the native Apple Open In.. function. It is intended as a starting point for developers making use of application-based services. 

The SaveEditClient and SaveEditService samples split out the consumer and provider into different apps to illustrate transferring the file between apps on the device.

This sample also demonstrates how multiple windows can be used in Dynamics application, and proves multiple window support in Dynamics SDK.

## Requirements

See [Software Requirements](https://docs.blackberry.com/en/development-tools/blackberry-dynamics-sdk-ios/current/blackberry-dynamics-sdk-ios-devguide/gwj1489687014271/vcw1490294551674) of the BlackBerry Dynamics SDK (iOS) 

## SDK integration (Swift Package Manager)

This project references the BlackBerry Dynamics iOS SDK as a Swift package:

Package: BlackBerry Dynamics iOS SDK
URL: `https://github.com/blackberry/BlackBerry-Dynamics-iOS-SDK`

Linked products:

- **BlackBerryDynamics** — main application target
- **GSEProvider** — main application target
- **BlackBerryDynamicsAutomatedTestSupportLibrary** — UI test target (if present)

The project references the package on the default branch and resolves the **latest** SDK when you build or run **File → Packages → Resolve Package Versions**.

## How To Build and Deploy

1. Set up your [BlackBerry Dynamics development environment](https://developers.blackberry.com/us/en/resources/get-started/blackberry-dynamics-getting-started).
2. Clone this repository.
3. Open **AppKinetics.xcodeproj** in Xcode.
4. Resolve packages: **File → Packages → Resolve Package Versions**.
5. Edit the **Bundle Identifier** to your own.
6. Edit **URL identifier** and **URL Schemes** in `Info.plist` per [Declaring a URL type](https://docs.blackberry.com/en/development-tools/blackberry-dynamics-sdk-ios/current/blackberry-dynamics-sdk-ios-devguide/gwj1489687014271).
7. Set **GDApplicationID** in `Info.plist` (default export value: `com.blackberry.dynamics.sample`).
8. Assign the app entitlement to a user in UEM. See [Add an internal BlackBerry Dynamics app entitlement](https://docs.blackberry.com/en/endpoint-management/blackberry-uem/current/managing-apps/managing-blackberry-dynamics-apps).
9. Build and run on a simulator or device.

For more information, see [Get Started with BlackBerry Dynamics](https://developers.blackberry.com/us/en/resources/get-started/blackberry-dynamics-getting-started).

## License

Apache 2.0 License

## Disclaimer

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.