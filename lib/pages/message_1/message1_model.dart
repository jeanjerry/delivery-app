import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'message1_widget.dart' show Message1Widget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Message1Model extends FlutterFlowModel<Message1Widget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // State field(s) for messag widget.
  FocusNode? messagFocusNode;
  TextEditingController? messagController;
  String? Function(BuildContext, String?)? messagControllerValidator;

  /// Initialization and disposal methods.

  void initState(BuildContext context) {}

  void dispose() {
    unfocusNode.dispose();
    messagFocusNode?.dispose();
    messagController?.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
