# BBDAutoFillBlockerField for Autofill blocking in UITextField

This sample demonstrates how to block Autofill suggestions in UITextField instances.
BBDAutoFillBlockerField is a subclass of the native UITextField for Autofill blocking.
Autofill blocking is achieved by providing custom secureTextEntry implementation and modifying textContentType property.
Custom secureTextEntry implementation tries to match the system one and includes:
  - text obscuring with bullets.
  - copy/paste blocking.
  - text autocorrection prevention.


### Usage
To block Autofill for UITextField instances on a particular screen
make sure that all text fields on the screen extend BBDAutoFillBlockerField.
If at least one UIView instance on the screen has secureTextEntry enabled, then Autofill suggestion
may appear randomly on any other UITextField instances on the same screen.
See: https://openradar.appspot.com/radar?id=6070058497343488.

## Authors

- **Boris Zinkovych** - Initial Work

## License

This sample is released as Open Source and licensed under [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0.html).
