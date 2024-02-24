import 'dart:convert';
import 'dart:math';

import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'wallet_model.dart';
export 'wallet_model.dart';
import '/main.dart';
import 'package:http/http.dart' as http;
import '/database/storeDB.dart'; // 引入自定義的 SQL 檔案
import 'package:decimal/decimal.dart';

class WalletWidget extends StatefulWidget {
  const WalletWidget({Key? key}) : super(key: key);

  @override
  _WalletWidgetState createState() => _WalletWidgetState();
}

class _WalletWidgetState extends State<WalletWidget>
    with TickerProviderStateMixin {
  late DBHelper dbHelper;// DBHelper 實例

  var money;

  Future getBalance() async {
    var url = Uri.parse(ip+"getBalance");

    final responce = await http.post(url,body: {

      "account": FFAppState().account,

    });
    if (responce.statusCode == 200) {
      var data = json.decode(responce.body);//將json解碼為陣列形式
      var wallet;
      wallet=data["balance"];
      setState(() {
        if (wallet != null) {
            money = (double.parse(wallet) / pow(10, 18)).toString();// 將獲取的餘額轉換為以太幣並更新 UI
        }
      });

    }
  }

  getOrder(contractAddress,id) async {
    var url = Uri.parse(ip+"contract/getOrder");

    final responce = await http.post(url,body: {

      "contractAddress":contractAddress,
      "wallet": FFAppState().account,
      "id": id,

    });
    if (responce.statusCode == 200) {
      var data = json.decode(responce.body);//將json解碼為陣列形式
      return data;
    }
  }

  getStore(contractAddress) async {
    var url = Uri.parse(ip+"contract/getStore");

    final responce = await http.post(url,body: {

      "contractAddress": contractAddress,
      "wallet": FFAppState().account,

    });
    if (responce.statusCode == 200) {
      var data = json.decode(responce.body);//將json解碼為陣列形式
      //print("店家名稱:${data["storeName"].toString()}");
      return data;
    }
  }

  List<Map<String, dynamic>> checkorderList = []; // 確定接單的訂單單號與店家合約
  List<Map<String, dynamic>> orderList = []; // 訂單內容

  Future<List> getorderList1() async {   //從資料庫得到完成訂單的小費
    checkorderList = await dbHelper.dbGetcheckorder();
    print("已接訂單長度是:"+checkorderList.length.toString());
    await dbHelper.dbResetwallet();// 重製訂單內容
    for(int i = 0; i<checkorderList.length;i++){
      var orderlist = await getOrder(checkorderList[i]["contract"],checkorderList[i]["id"]);
      var name = await getStore(checkorderList[i]["contract"]);
      Map<String, dynamic> A = {};//重要{}
      if(orderlist["orderStatus"] == "6"){
        A['orderStatus']=orderlist["orderStatus"];
        A['storeName']=name["storeName"];
        A['fee']=(Decimal.parse(orderlist["fee"]) / Decimal.parse('1e18'))
            .toDouble()
            .toString();
        A['id']=orderlist["id"];
        await dbHelper.dbInsertwallet(A);
      }
    }
    orderList = await dbHelper.dbGetwallet(); // 更新訂單內
    print(orderList);
    return orderList;
  }

  late WalletModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = {
    'textOnPageLoadAnimation1': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        VisibilityEffect(duration: 1.ms),
        FadeEffect(
          curve: Curves.easeInOut,
          delay: 0.ms,
          duration: 600.ms,
          begin: 0.0,
          end: 1.0,
        ),
        MoveEffect(
          curve: Curves.easeInOut,
          delay: 0.ms,
          duration: 600.ms,
          begin: Offset(0.0, 20.0),
          end: Offset(0.0, 0.0),
        ),
      ],
    ),
    'textOnPageLoadAnimation2': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        VisibilityEffect(duration: 1.ms),
        FadeEffect(
          curve: Curves.easeInOut,
          delay: 0.ms,
          duration: 600.ms,
          begin: 0.0,
          end: 1.0,
        ),
        MoveEffect(
          curve: Curves.easeInOut,
          delay: 0.ms,
          duration: 600.ms,
          begin: Offset(0.0, 20.0),
          end: Offset(0.0, 0.0),
        ),
      ],
    ),
    'textOnPageLoadAnimation3': AnimationInfo(
      trigger: AnimationTrigger.onPageLoad,
      effects: [
        FadeEffect(
          curve: Curves.easeInOut,
          delay: 0.ms,
          duration: 600.ms,
          begin: 0.0,
          end: 1.0,
        ),
        MoveEffect(
          curve: Curves.easeInOut,
          delay: 0.ms,
          duration: 600.ms,
          begin: Offset(0.0, 80.0),
          end: Offset(0.0, 0.0),
        ),
      ],
    ),
  };
  Future<List>? _orderListFuture;
  @override
  void initState() {
    future:getBalance();
    dbHelper = DBHelper(); // 初始化 DBHelper
    super.initState();
    _orderListFuture = getorderList1();
    _model = createModel(context, () => WalletModel());

    setupAnimations(
      animationsMap.values.where((anim) =>
          anim.trigger == AnimationTrigger.onActionTrigger ||
          !anim.applyInitialState),
      this,
    );
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
        backgroundColor: Color(0xFFF1F4F8),
        appBar: AppBar(
          backgroundColor: Color(0xFFF1F4F8),
          automaticallyImplyLeading: false,
          title: Align(
            alignment: AlignmentDirectional(0.00, -1.00),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 30.0),
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
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(1.0, 0.0, 0.0, 0.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(16.0, 15.0, 16.0, 0.0),
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * 1.0,
                      height: MediaQuery.sizeOf(context).height * 0.1,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: FlutterFlowTheme.of(context).alternate,
                          width: 2.0,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            16.0, 12.0, 16.0, 12.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 2.0, 0.0, 0.0),
                                  child: Text(
                                    'balance',
                                    style: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          fontSize: 34.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ).animateOnPageLoad(animationsMap[
                                      'textOnPageLoadAnimation1']!),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 2.0, 0.0, 0.0),
                              child: AutoSizeText(
                                '$money ETH',
                                style: const TextStyle(fontSize: 20),
                              ).animateOnPageLoad(
                                  animationsMap['textOnPageLoadAnimation2']!),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional(-1.00, 0.00),
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(16.0, 10.0, 16.0, 8.0),
                      child: Text(
                        'Transaction details',
                        style: FlutterFlowTheme.of(context).labelLarge.override(
                              fontFamily: 'Readex Pro',
                              fontSize: 25.0,
                              fontWeight: FontWeight.w600,
                            ),
                      ).animateOnPageLoad(
                          animationsMap['textOnPageLoadAnimation3']!),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 44.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 1.0),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width * 0.9,
                            height: MediaQuery.sizeOf(context).height * 1.0,
                            decoration: BoxDecoration(
                              color: Color(0xFFF1F4F8),
                              borderRadius: BorderRadius.circular(0.0),
                            ),
                            child:FutureBuilder<List>(
                              future: _orderListFuture,
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
                      ],
                    ),
                  ),
                ],
              ),
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
    //Widget divider1=Divider(color: Colors.blue, thickness: 3.0,);
    //Widget divider2=Divider(color: Colors.green,thickness: 3.0,);
    Widget divider0 = const Divider(
      color: Colors.red,
      thickness: 3,
    );
    Widget divider1 = const Divider(
      color: Colors.orange,
      thickness: 3,
    );
    Widget divider2 = Divider(
      color: Colors.yellow.shade600,
      thickness: 3,
    );
    Widget divider3 = const Divider(
      color: Colors.green,
      thickness: 3,
    );
    Widget divider4 = const Divider(
      color: Colors.blue,
      thickness: 3,
    );
    Widget divider5 = Divider(
      color: Colors.blue.shade900,
      thickness: 3,
    );
    Widget divider6 = const Divider(
      color: Colors.purple,
      thickness: 3,
    );
    Widget ChooseDivider(int index) {
      return index % 7 == 0
          ? divider0
          : index % 7 == 1
          ? divider1
          : index % 7 == 2
          ? divider2
          : index % 7 == 3
          ? divider3
          : index % 7 == 4
          ? divider4
          : index % 7 == 5
          ? divider5
          : divider6;
    }
    return ListView.separated(
      itemCount: list!.length,  //列表的數量
      itemBuilder: (ctx,i){    //列表的構建器
        return Container(
          width: MediaQuery.sizeOf(context).width * 0.9,
          height: MediaQuery.sizeOf(context).height * 0.1,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).info,
            boxShadow: [
              BoxShadow(
                blurRadius: 0.0,
                color: FlutterFlowTheme.of(context).alternate,
                offset: Offset(5.0, 5.0),
              )
            ],
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
                16.0, 8.0, 16.0, 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                        12.0, 0.0, 0.0, 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          list![i]["storeName"]+"number:"+list![i]["id"],
                          style: FlutterFlowTheme.of(context)
                              .bodyLarge
                              .override(
                            fontFamily: 'Readex Pro',
                            fontSize: 22.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AutoSizeText(
                  list![i]["fee"],
                  textAlign: TextAlign.end,
                  style:
                  FlutterFlowTheme.of(context).titleLarge,
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return ChooseDivider(index);
      },
    );
  }
}