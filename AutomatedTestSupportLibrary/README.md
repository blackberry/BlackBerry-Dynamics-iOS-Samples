# Automated Test Support Library (ATSL) for iOS

The BlackBerry Dynamics SDK includes the BlackBerry Dynamics Automated Test Support Library (ATSL) to support automated testing for your BlackBerry Dynamics apps. This library is delivered as a dynamic framework with the BlackBerry Dynamics SDK, but is made available as sources here to enable you to review the implementation and customize it.

The library includes helper functions for testing common user interactions in BlackBerry Dynamics apps, such as activation and authorization. The configuration and structure of the library is compatible with the tools offered by Apple for user interface testing.

You can use this library and the native library components to automate the building, execution, and reporting of your application tests.

For more information refer to 'Implementing automated testing for BlackBerry Dynamics apps' within the [BlackBerry Dynamics Developer Guide](https://docs.blackberry.com/en/development-tools/blackberry-dynamics-sdk-ios/) 

### Prerequisites

 - BlackBerry Dynamics SDK for iOS
 - iOS SDK supported by BlackBerry Dynamics 

Please see 'Requirements' within the [BlackBerry Dynamics Developer Guide](https://docs.blackberry.com/en/development-tools/blackberry-dynamics-sdk-ios/) for the currently supported SDK and iOS versions.

### Usage

The following steps assume that the target app is already configured to use the BlackBerry Dynamics SDK.
1. If necessary, create a target in the project to run user interface tests. The target must have the type “iOS UI Testing Bundle”.

2. Add the ATSL to the test target.

	To import the BlackBerry Dynamics ATSL, add the following folder to the application project: BBD_SDK_HOME_FOLDER/AutomatedTestSupport/Core. Select the option to copy the ATSL folder into the project folder.

3. Add or write code for your app tests. Use the helper functions in the ATSL in your test code.

	You can use the code for the app tests in any of the sample apps as a starting point. The first app test called 'testProvision' executes BlackBerry Dynamics activation and unlock as an automated test.

## Support

-   BlackBerry Developer Community:  [https://developers.blackberry.com](https://developers.blackberry.com)

## License

Released as Open Source and licensed under [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0.html).
