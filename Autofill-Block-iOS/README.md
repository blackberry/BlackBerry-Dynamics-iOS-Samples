# AutoFill blocking solution for Password AutoFill in UITextField

This sample demonstrates how to block AutoFill suggestions in UITextField instances.
BBDAutoFillBlockerField is a subclass of the native UITextField for AutoFill blocking.
AutoFill blocking is achieved by providing custom secureTextEntry implementation and modifying textContentType property.
Custom secureTextEntry implementation tries to match the system one and includes:
  - text obscuring with bullets.
  - copy/paste blocking.
  - text autocorrection prevention.
  - dictation and custom keyboards blocking.
  - emoji prevention.



### Usage
To block AutoFill for UITextField instances on a particular screen
make sure that all text fields on the screen extend BBDAutoFillBlockerField.
If at least one UIView instance on the screen has secureTextEntry enabled, then AutoFill suggestion
may appear randomly on any other UITextField instances on the same screen.
See: https://openradar.appspot.com/radar?id=6070058497343488.

The solution has a module for dictation and custom keyboards blocking for secured text fields.
Custom keyboards blocking is achieved by overriding shouldAllowExtensionPointIdentifier method
of UIApplicationDelegate(see NSObject+KeyboardBlocking category).
In the case if an application already has this method implemented in application delegate,
that method needs to be rewritten in the same way as NSObject+KeyboardBlocking category works.



## Author(s)

- **Boris Zinkovych** - Initial Work



## License

This sample is released as Open Source and licensed under [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0.html).



## Disclaimer

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.