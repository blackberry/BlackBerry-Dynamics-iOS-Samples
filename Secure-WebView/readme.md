# iOS Web View Demonstration
This repository has an application that demonstrates a mechanism for
implementing data leakage prevention (DLP) in a BlackBerry Dynamics application
that uses iOS web views. There are two targets in the application project. One
is for a BlackBerry Dynamics application, the other is "vanilla", i.e. without
BlackBerry Dynamics. The following are demonstrated.

-   Suppressing text selection and subsequent sharing via an Edit Menu.
-   Suppressing link selection and subsequent sharing via an Action Sheet.
-   Suppression in UIWebView.
-   Suppression in WKWebView.

## Requirements
-   Xcode 8 or later.
-   iOS SDK 9 or later.
-   Mobile device running iOS 9 or later.

## Author(s)
*   Jim Hawkins

**Contributing**

*   To contribute code to this repository you must be
    [signed up as an official contributor](http://blackberry.github.com/howToContribute.html).

## How To Build and Deploy
Clone the repository, set the application identifiers as usual, and build and
run the "Web View Demonstration" application. The application project is in the
[Web View Demonstration](Web View Demonstration) sub-directory.

The About tab has a description of the application's features, and shows the
BlackBerry Dynamics status at the bottom of the page.

For more information on BlackBerry Dynamics application development, visit the
[BlackBerry Dynamics application developer website](https://developers.blackberry.com/dynamics).

## Class Notes
### BBDDectector
The BBDDector class is a very small class with a single method. It returns true
if the project is linked with the BlackBerry Dynamics framework, which it
detects by the presence of the GDiOS class.

### BBDLoader
The BBDLoader class has one interface, but two implementations: actual and
dummy. The actual implementation should be included in the target if the
BlackBerry Dynamics framework is included. Otherwise, the dummy implementation
should be included.

This class illustrates an approach to having a single project with a BlackBerry
Dynamics target, and a vanilla target.

# Image Source
The following images are used as tab icons in the applications.

-   `about.xcf`
-   `UI.xcf`
-   `WK.xcf`

These are GIMP files.

Tab icon conform to the following.

-   Size is 41 pixels by 41.
-   Pixels are either black or transparent.

## License
Apache 2.0 License

## Disclaimer
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
