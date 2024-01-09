import 'dart:convert';
import 'dart:io';
import '../message/message_widget.dart';
import '../message_1/message1_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'order1_model.dart';
export 'order1_model.dart';
import 'package:http/http.dart' as http;
import '/main.dart';
import '/database/storeDB.dart'; // 引入自定義的 SQL 檔案
import 'package:image_picker/image_picker.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:url_launcher/url_launcher.dart';






class Order1Widget extends StatefulWidget {
  const Order1Widget({Key? key, required this.B}) : super(key: key);
  final Map<String, dynamic> B;

  @override
  _Order1WidgetState createState() => _Order1WidgetState();
}

class _Order1WidgetState extends State<Order1Widget> {
  late Order1Model _model;
  late DBHelper dbHelper; // DBHelper 實例

  final scaffoldKey = GlobalKey<ScaffoldState>();

  getOrderContent() async {
    var url = Uri.parse(ip+"contract/getOrderContent");

    final responce = await http.post(url,body: {

      "contractAddress": widget.B["contract"],
      "wallet": FFAppState().account,
      "id": widget.B["id"],

    });
    if (responce.statusCode == 200) {
      var data = json.decode(responce.body);//將json解碼為陣列形式
      //print("訂單內容:${data["orderContent"].toString()}");
      return data["orderContent"];
    }
  }

  confirmPickUp() async {
    var url = Uri.parse(ip+"contract/confirmPickUp");

    final responce = await http.post(url,body: {

      "contractAddress": widget.B["contract"],
      "deliveryWallet": FFAppState().account,
      "deliveryPassword": FFAppState().password,
      "id": widget.B["id"],

    });
    if (responce.statusCode == 200) {
      var data = json.decode(responce.body);//將json解碼為陣列形式
      return data;
    }
  }

  confirmDelivery() async {
    var url = Uri.parse(ip+"contract/confirmDelivery");

    final responce = await http.post(url,body: {

      "contractAddress": widget.B["contract"],
      "deliveryWallet": FFAppState().account,
      "deliveryPassword": FFAppState().password,
      "id": widget.B["id"],

    });
    if (responce.statusCode == 200) {
      var data = json.decode(responce.body);//將json解碼為陣列形式
      return data;
    }
  }

  getorderStatus()  {
    String str = "";
    if(widget.B["orderStatus"]=='2'){
      setState(() {
      str = "店家準備中";
      });
    }
    else if (widget.B["orderStatus"]=='3'){
      setState(() {
      str = "外送員前往取餐";
      });
    }
    else if (widget.B["orderStatus"]=='4'){
      setState(() {
      str = "外送員前往送餐";
      });
    }
    else if (widget.B["orderStatus"]=='5'){
        setState(() {
        str = "等待消費者確認餐點";
        });
    }
    else if (widget.B["orderStatus"]=='6'){
          setState(() {
          str = "已送達";
          });
    }
    else if (widget.B["orderStatus"]=='7'){
      setState(() {
      str = "店家拒絕接單";
      });
    }
    else if (widget.B["orderStatus"]=='10'){
      setState(() {
      str = "店家未完成訂單";
      });
    }
    else if (widget.B["orderStatus"]=='11'){
      setState(() {
      str = "外送員未完成訂單";
      });
    }
    else if (widget.B["orderStatus"]=='12'){
      setState(() {
      str = "取消訂單";
      });
    }
    return str;
  }

  getStore() async {
    var url = Uri.parse(ip+"contract/getStore");

    final responce = await http.post(url,body: {

      "contractAddress": widget.B["contract"],
      "wallet": FFAppState().account,

    });
    if (responce.statusCode == 200) {
      var data = json.decode(responce.body);//將json解碼為陣列形式
      //print("店家名稱:${data["storeName"].toString()}");
      return data;
    }
  }


  List<Map<String, dynamic>> orderContentList = []; // 訂單內容

  Future<List> getData() async {
    await dbHelper.dbResetOrder_content();
    var orderContent = await getOrderContent();
    var storeaddress = await getStore();
    for (var i =0; i< orderContent.length;i++){
      Map<String, dynamic> A = {};//重要{}
      A['orderID']=orderContent[i][0];
      A['num']=orderContent[i][1];
      A['contract']=widget.B['contract'];
      A['id']=widget.B['id'];
      A['storeName']=widget.B["storeName"];
      A['fee']=widget.B["fee"];
      A['storeAddress']=storeaddress["storeAddress"];
      await dbHelper.dbInsertOrder_content(A); // 將訂單內容插入資料庫
    }
    print("訂單內容是: $orderContent");
    orderContentList = await dbHelper.dbGetOrder_content(); // 更新訂單內
    print(orderContentList);
    return orderContentList;
  }


  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => Order1Model());
    dbHelper = DBHelper(); // 初始化 DBHelper
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> myList =widget.B['consumer'].split(',');
    var str = getorderStatus();


    if (isiOS) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarBrightness: Theme.of(context).brightness,
          systemStatusBarContrastEnforced: true,
        ),
      );
    }

    context.watch<FFAppState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: Color(0xFFF1F4F8),
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          borderWidth: 1.0,
          buttonSize: 60.0,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: FlutterFlowTheme.of(context).primaryText,
            size: 30.0,
          ),
          onPressed: () async {
            context.pop();
          },
        ),
        title: Align(
          alignment: AlignmentDirectional(0.00, -1.00),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 56.0, 30.0),
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
        elevation: 2.0,
      ),
      body: SafeArea(
        top: true,
        child: Align(
          alignment: AlignmentDirectional(0.00, -1.00),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 24.0),
                  child: Wrap(
                    spacing: 16.0,
                    runSpacing: 16.0,
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    direction: Axis.horizontal,
                    runAlignment: WrapAlignment.start,
                    verticalDirection: VerticalDirection.down,
                    clipBehavior: Clip.none,
                    children: [
                      Text(
                        '訂單詳細資料',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              fontSize: 25.0,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      Container(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        height: MediaQuery.sizeOf(context).height * 0.45,
                        constraints: BoxConstraints(
                          maxWidth: 750.0,
                        ),
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4.0,
                              color: Color(0x33000000),
                              offset: Offset(0.0, 2.0),
                            )
                          ],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 16.0, 16.0, 16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '單號 : '+widget.B['id'],
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Readex Pro',
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                '餐點內容 :',
                                style: FlutterFlowTheme.of(context)
                                    .titleLarge
                                    .override(
                                      fontFamily: 'Outfit',
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              ListView(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 12.0),
                                    child:Container(
                                      width: MediaQuery.sizeOf(context).width * 1.0,
                                      height: MediaQuery.sizeOf(context).height * 0.1 ,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFF1F4F8),
                                        borderRadius: BorderRadius.circular(0.0),
                                      ),
                                      child:FutureBuilder<List>(
                                        future: getData(),
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
                                  ),
                                  Container(
                                    width: 100.0,
                                    height: 100.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            AutoSizeText(
                                              '外送費 : ',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .titleLarge
                                                      .override(
                                                        fontFamily: 'Outfit',
                                                        fontSize: 20.0,
                                                      ),
                                            ),
                                            AutoSizeText(
                                              widget.B['fee']+'元',
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .titleLarge
                                                      .override(
                                                        fontFamily: 'Outfit',
                                                        fontSize: 20.0,
                                                      ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          width: MediaQuery.sizeOf(context).width * 1.0,
                                          height: MediaQuery.sizeOf(context).height * 0.08,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                          ),
                                          child: AutoSizeText(
                                            '店家地址 : '+ widget.B["storeAddress"],
                                            style: FlutterFlowTheme.of(context)
                                                .titleLarge
                                                .override(
                                              fontFamily: 'Outfit',
                                              fontSize: 20.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.sizeOf(context).width * 1.0,
                                    height: MediaQuery.sizeOf(context).height *
                                        0.08,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                    ),
                                    child: AutoSizeText(
                                      '消費者地址 : '+myList[1],
                                      style: FlutterFlowTheme.of(context)
                                          .titleLarge
                                          .override(
                                            fontFamily: 'Outfit',
                                            fontSize: 20.0,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        height: MediaQuery.sizeOf(context).height * 0.16,
                        constraints: BoxConstraints(
                          maxWidth: 430.0,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFF1E9E9),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4.0,
                              color: Color(0x33000000),
                              offset: Offset(0.0, 5.0),
                            )
                          ],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 16.0, 16.0, 24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '備註',
                                style: FlutterFlowTheme.of(context).titleLarge,
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment:
                                          AlignmentDirectional(0.00, 0.00),
                                      child: Text(
                                        widget.B["note"],
                                        style: FlutterFlowTheme.of(context)
                                            .titleLarge,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        height: MediaQuery.sizeOf(context).height * 0.16,
                        constraints: BoxConstraints(
                          maxWidth: 430.0,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFD9BABA),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4.0,
                              color: Color(0x33000000),
                              offset: Offset(0.0, 5.0),
                            )
                          ],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 16.0, 16.0, 24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '當前狀態',
                                style: FlutterFlowTheme.of(context).titleLarge,
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 6.0, 0.0, 18.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment:
                                          AlignmentDirectional(0.00, 0.00),
                                      child: Text(
                                        str,
                                        style: FlutterFlowTheme.of(context)
                                            .titleLarge,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                        child: FFButtonWidget(
                          onPressed: () async {
                            Map<String, dynamic> C = {};
                            C['contract']=widget.B['contract'];
                            C['id']=widget.B['id'];
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MessageWidget(C: C, ),
                              ),
                            );
                            //context.pushNamed('message');
                          },
                          text: '聊天室',
                          options: FFButtonOptions(
                            width: MediaQuery.sizeOf(context).width * 1.0,
                            height: MediaQuery.sizeOf(context).height * 0.06,
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: Color(0xFF80D0E9),
                            textStyle: FlutterFlowTheme.of(context)
                                .titleLarge
                                .override(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w600,
                                ),
                            elevation: 2.0,
                            borderSide: BorderSide(
                              color: Colors.transparent,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(40.0),
                            hoverColor: FlutterFlowTheme.of(context).accent1,
                            hoverBorderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).primary,
                              width: 1.0,
                            ),
                            hoverTextColor:
                                FlutterFlowTheme.of(context).primary,
                          ),
                        ),
                      ),
                      /*Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                        child: FFButtonWidget(
                          onPressed: () async {
                            Map<String, dynamic> D = {};
                            D['contract']=widget.B['contract'];
                            D['id']=widget.B['id'];
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => Message1Widget(D: D, ),
                              ),
                            );
                          },
                          text: '傳送訊息給店家',
                          options: FFButtonOptions(
                            width: MediaQuery.sizeOf(context).width * 1.0,
                            height: MediaQuery.sizeOf(context).height * 0.06,
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: Color(0xFF80D0E9),
                            textStyle: FlutterFlowTheme.of(context)
                                .titleLarge
                                .override(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w600,
                                ),
                            elevation: 2.0,
                            borderSide: BorderSide(
                              color: Colors.transparent,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(40.0),
                            hoverColor: FlutterFlowTheme.of(context).accent1,
                            hoverBorderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).primary,
                              width: 1.0,
                            ),
                            hoverTextColor:
                                FlutterFlowTheme.of(context).primary,
                          ),
                        ),
                      ),*/
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          final Uri _url = Uri.parse('https://www.google.com/maps'); // 你可以在这里设置特定的位置或搜索
                          if (await launchUrl(_url)) {
                            await launchUrl(_url);
                          } else {
                            throw 'Could not launch $_url';
                          }
                        },
                        child: Container(
                          width: MediaQuery.sizeOf(context).width,
                          height: MediaQuery.sizeOf(context).height * 0.18,
                          constraints: BoxConstraints(
                            maxWidth: 430,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 4,
                                color: Color(0x33000000),
                                offset: Offset(0, 6),
                              )
                            ],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Align(
                                        alignment: AlignmentDirectional(0, 0),
                                        child: Text(
                                          '路程',
                                          style: FlutterFlowTheme.of(context).titleLarge,
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
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                        child: FFButtonWidget(
                          onPressed: () async {
                            // 打开相機
                            final image = await ImagePicker().pickImage(source: ImageSource.camera);

                            if (image != null) {
                              // 郵件發送
                              final smtpServer = gmail('C109154229@nkust.edu.tw', 'N126771748');

                              final message = Message()
                                ..from = Address('C109154229@nkust.edu.tw', '彥傑')
                                ..recipients.add('jeanyjyjyjyjyj@gmail.com')
                                ..subject = '主题'
                                ..text = '正文'
                                ..attachments.add(FileAttachment(File(image.path)));

                              try {
                                final sendReport = await send(message, smtpServer);
                                print('郵件發送成功：$sendReport');
                                await confirmPickUp();
                                print("更改狀態收餐");
                              } catch (e) {
                                print('郵件發送失败：$e');
                              }
                            } else {
                              print('用户取消了拍照');
                            }
                          },
                          text: '拍照進行收餐確認',
                          options: FFButtonOptions(
                            width: MediaQuery.sizeOf(context).width * 1.0,
                            height: MediaQuery.sizeOf(context).height * 0.06,
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: Color(0xFF80D0E9),
                            textStyle: FlutterFlowTheme.of(context)
                                .titleLarge
                                .override(
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w600,
                            ),
                            elevation: 2.0,
                            borderSide: BorderSide(
                              color: Colors.transparent,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(40.0),
                            hoverColor: FlutterFlowTheme.of(context).accent1,
                            hoverBorderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).primary,
                              width: 1.0,
                            ),
                            hoverTextColor:
                            FlutterFlowTheme.of(context).primary,
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                        child: FFButtonWidget(
                          onPressed: () async {
                            // 打开相機
                            final image = await ImagePicker().pickImage(source: ImageSource.camera);

                            if (image != null) {
                              // 郵件發送
                              final smtpServer = gmail('C109154229@nkust.edu.tw', 'N126771748');

                              final message = Message()
                                ..from = Address('C109154229@nkust.edu.tw', '彥傑')
                                ..recipients.add('jeanyjyjyjyjyj@gmail.com')
                                ..subject = '主题'
                                ..text = '正文'
                                ..attachments.add(FileAttachment(File(image.path)));

                              try {
                                final sendReport = await send(message, smtpServer);
                                print('郵件發送成功：$sendReport');
                                await confirmDelivery();
                                print("更改狀態送達");
                              } catch (e) {
                                print('郵件發送失败：$e');
                              }
                            } else {
                              print('用户取消了拍照');
                            }
                          },
                          text: '拍照進行送達確認',
                          options: FFButtonOptions(
                            width: MediaQuery.sizeOf(context).width * 1.0,
                            height: MediaQuery.sizeOf(context).height * 0.06,
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: Color(0xFF80D0E9),
                            textStyle: FlutterFlowTheme.of(context)
                                .titleLarge
                                .override(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w600,
                                ),
                            elevation: 2.0,
                            borderSide: BorderSide(
                              color: Colors.transparent,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(40.0),
                            hoverColor: FlutterFlowTheme.of(context).accent1,
                            hoverBorderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).primary,
                              width: 1.0,
                            ),
                            hoverTextColor:
                                FlutterFlowTheme.of(context).primary,
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        height: MediaQuery.sizeOf(context).height * 0.2,
                        constraints: BoxConstraints(
                          maxWidth: 430.0,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFD9BABA),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4.0,
                              color: Color(0x33000000),
                              offset: Offset(0.0, 5.0),
                            )
                          ],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.file(
                            File("/data/data/com.mycompany.deliveryapp/image/${widget.B["contract"]}"),
                            width: MediaQuery.sizeOf(context).width * 1.0,
                            height: MediaQuery.sizeOf(context).height * 1.0,
                            fit: BoxFit.cover,
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
      itemCount: list!.length,  //列表的數量
      itemBuilder: (ctx,i){    //列表的構建器
        return Container(
          width: MediaQuery.sizeOf(context).width *
              1.0,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context)
                .secondaryBackground,
            borderRadius:
            BorderRadius.circular(0.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                EdgeInsetsDirectional.fromSTEB(
                    0.0, 4.0, 0.0, 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment:
                  MainAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding:
                        EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 4.0, 0.0),
                        child: Column(
                          mainAxisSize:
                          MainAxisSize.max,
                          mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [
                            AutoSizeText(
                              list![i]["orderID"],
                              style: FlutterFlowTheme
                                  .of(context)
                                  .titleLarge
                                  .override(
                                fontFamily:
                                'Outfit',
                                fontSize: 20.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize:
                      MainAxisSize.max,
                      children: [
                        AutoSizeText(
                          "x"+list![i]["num"],
                          style:
                          FlutterFlowTheme.of(
                              context)
                              .titleLarge
                              .override(
                            fontFamily:
                            'Outfit',
                            fontSize: 20.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}