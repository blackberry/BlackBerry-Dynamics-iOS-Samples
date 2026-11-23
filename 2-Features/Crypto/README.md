# Crypto

This sample app demonstrates how to use the Dynamics Crypto C API.

## Description

The Crypto C language programming interface allows an app to retrieve public key certificates that are stored in the BlackBerry Dynamics credentials store and use those certificates for signing, encryption, decryption, and verification of messages and documents such as PDFs, while keeping the private key 
confidential and inaccessible to the application.

Before proceeding you will need to provision appropriate signing and encryption credentials using a UEM User Certificate, User Credential, or SCEP profile.  To verify documents, you will also need to setup your trusted Certificate Authorities using UEM CA Certificate profiles.

You may transfer documents and signatures using iTunes File Sharing.

For more information, see the Crypto C Programming Interface appendix in the API reference.

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
3. Open **Crypto.xcodeproj** in Xcode.
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