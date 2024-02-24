import 'dart:convert';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../flutter_flow/flutter_flow_drop_down.dart';
import '../../flutter_flow/flutter_flow_model.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../../flutter_flow/form_field_controller.dart';
import 'message_model.dart';
export 'message_model.dart';
import 'package:http/http.dart' as http;
import '/main.dart';
import '/database/storeDB.dart'; // 引入自定義的 SQL 檔案


class MessageWidget extends StatefulWidget {
  const MessageWidget({Key? key, required this.C}) : super(key: key);
  final Map<String, dynamic> C;
  @override
  _MessageWidgetState createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  late MessageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<List<List<dynamic>>> getMessage() async {
    var url = Uri.parse(ip + "contract/getMessage");

    final response = await http.post(url, body: {
      "contractAddress": widget.C["contract"],
      "wallet": FFAppState().account,
      "id": widget.C["id"],
    });

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print("對話內容:${data["message"].toString()}");

      List<List<dynamic>> filteredMessages = [];
      for (var message in data["message"]) {
        // 判斷 message[0] 的值是否為 "3" 或 "1"
        // 判斷 message[1] 的值是否為 "2"
        /*if ((message[0] == "3" && message[1] == "2") || (message[0] == "2" && message[1] == "3")) {
          // 將符合條件的 message 轉換為 [3, 2, message[2]]
          filteredMessages.add([message[0],message[1],message[2]]);
        }*/

          filteredMessages.add([message[0],message[1],message[2]]);
      }

      //print(filteredMessages);
      print("getMessage-ok");
      return filteredMessages; // 返回 Future<List<List<dynamic>>>
    } else {
      throw Exception("Failed to load messages");
    }
  }




  sendMessage() async {
    var url = Uri.parse(ip + "contract/sendMessage");
    var people ;
    if(FFAppState().people=="consumer"){
      people = "2";
    }
    else if (FFAppState().people=="store"){
      people = "1";
    }
    final response = await http.post(url, body: {
      "contractAddress": widget.C["contract"],
      "wallet": FFAppState().account,
      "password": FFAppState().password,
      "id": widget.C["id"],
      "sender": "3",
      "receiver": people,
      "messageContent": _model.messagController.text,
    });

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print("sendMessage-ok");
      return data;
    }
  }







  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MessageModel());

    _model.messagController ??= TextEditingController();
    _model.messagFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isiOS) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarBrightness: Theme.of(context).brightness,
          systemStatusBarContrastEnforced: true,
        ),
      );
    }

    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color(0xFFF1F4F8),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 30,
            ),
            onPressed: () async {
              Navigator.of(context).pop();
            },
          ),
          title: Align(
            alignment: AlignmentDirectional(0, -1),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, 0, 56, 30),
              child: Text(
                'Blofood',
                style: FlutterFlowTheme.of(context).displaySmall.override(
                  fontFamily: 'Outfit',
                  color: Color(0xFFF35E5E),
                ),
              ),
            ),
          ),
          actions: [],
          centerTitle: true,
          elevation: 2,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height * 0.87,
                  decoration: BoxDecoration(
                    color: Color(0xFFF1F4F8),
                  ),
                  alignment: AlignmentDirectional(0, 1),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        height: MediaQuery.sizeOf(context).height * 0.7 ,
                        decoration: BoxDecoration(
                          color: Color(0xFFF1F4F8),
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        child:FutureBuilder<List>(
                          future: getMessage(),
                          builder: (ctx,ss) {
                            if(ss.hasError){
                              print("error");
                            }
                            if(ss.hasData){
                              return Items(list:ss.data);
                            }
                            else{
                              return CircularProgressIndicator();
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        child: FlutterFlowDropDown<String>(
                          controller: _model.dropDownValueController ??=
                              FormFieldController<String>(
                                _model.dropDownValue ??= FFAppState().people,
                              ),
                          options: ['consumer', 'store'],
                          onChanged: (val) async {
                            setState(() => _model.dropDownValue = val);
                            setState(() {
                              FFAppState().people = _model.dropDownValue!;
                            });
                          },
                          width: MediaQuery.sizeOf(context).width * 0.8,
                          height: MediaQuery.sizeOf(context).height * 0.08,
                          textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Readex Pro',
                            fontSize: 20,
                          ),
                          hintText: 'Please select someone to talk to',
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            size: 24,
                          ),
                          fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                          elevation: 2,
                          borderColor: FlutterFlowTheme.of(context).alternate,
                          borderWidth: 2,
                          borderRadius: 8,
                          margin: EdgeInsetsDirectional.fromSTEB(16, 4, 16, 4),
                          hidesUnderline: true,
                          isOverButton: true,
                          isSearchable: false,
                          isMultiSelect: false,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 5),
                        child: Container(
                          width: MediaQuery.sizeOf(context).width,
                          child: TextFormField(
                            controller: _model.messagController,
                            focusNode: _model.messagFocusNode,
                            onChanged: (_) => EasyDebounce.debounce(
                              '_model.messagController',
                              Duration(milliseconds: 2000),
                                  () => setState(() {}),
                            ),
                            onFieldSubmitted: (_) async {
                              if (_model.messagController.text.isNotEmpty) {
                                await sendMessage();
                                setState(() {});
                              }
                            },
                            textCapitalization: TextCapitalization.words,
                            obscureText: false,
                            decoration: InputDecoration(
                              labelText: 'Please enter message',
                              labelStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                fontFamily: 'Readex Pro',
                                fontSize: 20,
                              ),
                              hintStyle:
                              FlutterFlowTheme.of(context).labelMedium,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                  FlutterFlowTheme.of(context).alternate,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                  FlutterFlowTheme.of(context).primary,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).error,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).error,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              contentPadding:
                              EdgeInsetsDirectional.fromSTEB(20, 24, 0, 24),
                              suffixIcon:
                              _model.messagController!.text.isNotEmpty
                                  ? InkWell(
                                onTap: () async {
                                  _model.messagController?.clear();
                                  setState(() {});
                                },
                                child: Icon(
                                  Icons.clear,
                                  color: Color(0xFF757575),
                                  size: 22,
                                ),
                              )
                                  : null,
                            ),
                            style: FlutterFlowTheme.of(context).bodyMedium,
                            validator: _model.messagControllerValidator
                                .asValidator(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class Items extends StatelessWidget {
  List? list;

  Items({this.list});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: list!.length, // 列表的數量
      itemBuilder: (ctx, i) {
        String str = "";
        who() {
          String str = "";
          if (list![i][0] == '2' && list![i][1] == '3') {
            str = "Consumers to delivery people :";
          } else if (list![i][0] == '3' && list![i][1] == '2') {
            str = "Delivery workers to consumers :";
          }
          else if (list![i][0] == '1' && list![i][1] == '2') {
            str = "store to consumer :";
          }
          else if (list![i][0] == '2' && list![i][1] == '1') {
            str = "Consumer to store :";
          }
          else if (list![i][0] == '3' && list![i][1] == '1') {
            str = "Delivery boy versus store owner :";
          }
          else if (list![i][0] == '1' && list![i][1] == '3') {
            str = "Store delivery person :";
          }
          return str;
        }

        str = who();
        return Container(
          decoration: BoxDecoration(
            //border: Border.all(), //顯示邊框
          ),
          child: Text(
            str + list![i][2],
            style: TextStyle(fontSize: 22.0), // 設定字體大小
          ),
          padding: EdgeInsets.all(10.0), // 設定內邊距
        );
      },
    );
  }
}
