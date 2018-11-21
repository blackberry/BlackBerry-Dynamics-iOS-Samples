# **BlackBerry Sample-Detection Library**

This project demonstrates how to utilize the BlackBerry Dynamics SDK if you are a vendor of a Mobile Threat Detection library.

### Features provided by the reference library
1. Library Entitlement
2. Registration for local notifications from BlackBerry Dynamics SDK.
- Entitement Update
- Policy Update
- Service Update
3. Request to execute online lock.
4. Request to execute offline lock.
5. Notify users through local notifications. 
6. Check compatible version. (BlackBerry Dynamics SDK Version).
7. Sample detection logic. 


# **BlackBerry Sample-Detection App**

This project is a sample BlackBerry Dynamics app hosting both BlackBerry Dynamics SDK and a sample mobile detection library. 

### Features provided by the app
1. Initialise the Sample Detection Library.
2. Demonstrates the following when a threat is detected
- Local Lock
- Remote Lock
- Notify user

## How to run

### UEM
1. Add a unique Internal BlackBerry Dynamics App Entitlement. e.g com.bbreference.detectionapp
2. Go to the App page under BlackBerry Dynamics tab, upload a Application Configuration template. The XML is provided in the project "policy.xml". A default configuration will be added to the app.
3. Click on the version number and add "BlackBerry MTD Service - 1.0.0.0" to the application.
4. Under iOS tab, enter your app's Bundle Identifier under "iOS app package id".
5. Click Save.
6. Assign this app to the user and make sure the default App Configuration is selected.

### BlackBerry Sample-Detection App
Change the Bundle ID of the project to be the same as the entitlement ID entered in UEM. Info.plist file is setup to listen to the bundle ID changes.


## Authors

- **Gurjit Ghangura** - [Gurjit Ghangura](mailto:gghangura@blackberry.com)
- **Eunkung Choi** - [EK](mailto:echoi@blackberry.com)


