import 'package:flet/flet.dart';
import 'package:flutter/cupertino.dart';

import 'flet_extension.dart';
import 'flet_service_extension.dart';

class Extension extends FletExtension {
  @override
  Widget? createWidget(Key? key, Control control) {
    switch (control.type) {
      case "FletExtension":
        return FletExtensionControl(control: control);
      default:
        return null;
    }
  }

  @override
  FletService? createService(Control control) {
    switch (control.type) {
      case "FletServiceExtension":
        return FletServiceExtensionService(control: control);
      default:
        return null;
    }
  }
}
