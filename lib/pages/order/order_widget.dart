import 'dart:convert';
import 'dart:math';

import '../order_1/order1_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'order_model.dart';
export 'order_model.dart';
import 'package:http/http.dart' as http;
import '/main.dart';
import '/database/storeDB.dart'; // 引入自定義的 SQL 檔案
import 'package:decimal/decimal.dart';

class OrderWidget extends StatefulWidget {
  const OrderWidget({Key? key, required this.A}) : super(key: key);
  final Map<String, dynamic> A;

  @override
  _OrderWidgetState createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  late OrderModel _model;
  late DBHelper dbHelper; // DBHelper 實例


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

  Future<List> getorderList() async {//從資料庫得到有幾筆已接訂單
    orderList.clear();
    checkorderList = await dbHelper.dbGetcheckorder();
    print("已接訂單長度:"+checkorderList.length.toString());
    await dbHelper.dbResetStores();// 重製訂單內容
    for(int i = 0; i<checkorderList.length;i++){
      var orderlist = await getOrder(checkorderList[i]["contract"],checkorderList[i]["id"]);
      var storeaddress = await getStore(checkorderList[i]['contract']);
      //print("A$orderlist");
      Map<String, dynamic> A = {};//重要{}
      A['id']=checkorderList[i]['id'];
      A['consumer']=orderlist["consumer"].toString();
      A['consumer'] = A['consumer'].replaceAll(RegExp(r'^\[|\]$'), '');
      A['fee']=(Decimal.parse(orderlist["fee"]) / Decimal.parse('1e18'))
        .toDouble()
        .toString();
      A['note']=orderlist['note'];
      A['delivery']=orderlist["delivery"].toString();
      A['delivery'] = A['delivery'].replaceAll(RegExp(r'^\[|\]$'), '');
      A['orderStatus']=orderlist["orderStatus"];
      A['contract']=checkorderList[i]['contract'];
      A['storeAddress']=storeaddress["storeAddress"];
      await dbHelper.dbInsertStore(A); // 將訂單內容插入資料庫
    }
    orderList = await dbHelper.dbGetStores();
    print(orderList);
    return orderList;

    /*for(int i=0 ; i<checkorderList.length; i++){
      List<String> consumer = checkorderList[i]["consumer"].split(',');

    }*/
    /*if(FFAppState().Name==orderList){}

    var orderlist = await getOrder();
    //await dbHelper.dbResetStores();// 重製訂單內容
    Map<String, dynamic> A = {};//重要{}
    A['id']=widget.selectedItem['id'];
    A['consumer']=orderlist["consumer"].toString();
    A['fee']=orderlist["fee"];
    A['note']=orderlist['note'];
    A['delivery']=orderlist["delivery"].toString();
    A['orderStatus']=orderlist["orderStatus"];
    A['contract']=widget.selectedItem['contract'];
    await dbHelper.dbInsertStore(A); // 將訂單內容插入資料庫*/

    //print(myList[0]);

  }


  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OrderModel());
    dbHelper = DBHelper(); // 初始化 DBHelper
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //print("c$checkorderList");

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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
          title: Align(
            alignment: AlignmentDirectional(0.00, -1.00),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 30.0),
              child: AutoSizeText(
                'Blofood',
                textAlign: TextAlign.start,
                style: FlutterFlowTheme.of(context).displaySmall.override(
                      fontFamily: 'Outfit',
                      color: Color(0xFFF35E5E),
                    ),
              ),
            ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(16.0, 10.0, 16.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
                        child: Text(
                          '已接訂單',
                          style:
                              FlutterFlowTheme.of(context).labelMedium.override(
                                    fontFamily: 'Readex Pro',
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(10.0, 10.0, 10.0, 0.0),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: [
                      Container(
                      width: MediaQuery.sizeOf(context).width * 1.0,
                      height: MediaQuery.sizeOf(context).height * 0.7 ,
                      decoration: BoxDecoration(
                        color: Color(0xFFF1F4F8),
                        borderRadius: BorderRadius.circular(0.0),
                      ),
                      child:FutureBuilder<List>(
                        future: getorderList(),
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





                      /*Container(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        height: MediaQuery.sizeOf(context).height * 0.32,
                        decoration: BoxDecoration(
                          color: Color(0xFFA1DAA1),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4.0,
                              color: Color(0x33000000),
                              offset: Offset(2.0, 6.0),
                            )
                          ],
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            context.pushNamed('order-1');
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    10.0, 0.0, 10.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    AutoSizeText(
                                      '單號',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Readex Pro',
                                            fontSize: 24.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          170.0, 0.0, 0.0, 0.0),
                                      child: AutoSizeText(
                                        '查看更多',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Readex Pro',
                                              fontSize: 24.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      size: 24.0,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    10.0, 10.0, 10.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    AutoSizeText(
                                      '外送費 :  30元',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Readex Pro',
                                            fontSize: 24.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    10.0, 10.0, 10.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    AutoSizeText(
                                      '地址 :  807高雄市三民區建工路415號',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Readex Pro',
                                            fontSize: 24.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                      minFontSize: 1.0,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    10.0, 10.0, 10.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    AutoSizeText(
                                      '距離店家:1.2km',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Readex Pro',
                                            fontSize: 24.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                      minFontSize: 1.0,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    10.0, 10.0, 10.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    AutoSizeText(
                                      '距離消費者:1.5km',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Readex Pro',
                                            fontSize: 24.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                      minFontSize: 1.0,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    10.0, 10.0, 10.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AutoSizeText(
                                      '店家餐點準備中',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Readex Pro',
                                            fontSize: 24.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                      minFontSize: 1.0,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),*/
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
        List<String> myList =list![i]['consumer'].split(',');
        String str = "";
        getorderStatus()  {
          String str = "";
          if(list![i]["orderStatus"]=='2'){
            str = "店家準備中";
          }
          else if (list![i]["orderStatus"]=='3'){
            str = "外送員前往取餐";
          }
          else if (list![i]["orderStatus"]=='4'){
            str = "外送員前往送餐";
          }
          else if (list![i]["orderStatus"]=='5'){
            str = "等待消費者確認餐點";
          }
          else if (list![i]["orderStatus"]=='6'){
            str = "已送達";
          }
          else if (list![i]["orderStatus"]=='7'){
            str = "店家拒絕接單";
          }
          else if (list![i]["orderStatus"]=='10'){
            str = "店家未完成訂單";
          }
          else if (list![i]["orderStatus"]=='11'){
            str = "外送員未完成訂單";
          }
          else if (list![i]["orderStatus"]=='12'){
            str = "取消訂單";
          }
          return str;
        }
        str = getorderStatus();
        return Container(
          width: MediaQuery.sizeOf(context).width * 1.0,
          height: MediaQuery.sizeOf(context).height * 0.28,
          decoration: BoxDecoration(
            color: Color(0xFFA1DAA1),
            boxShadow: [
              BoxShadow(
                blurRadius: 4.0,
                color: Color(0x33000000),
                offset: Offset(2.0, 6.0),
              )
            ],
            borderRadius: BorderRadius.circular(14.0),
          ),
          child: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              Map<String, dynamic> B = await list![i];
              //print("a$B");  //測試用
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Order1Widget(B: B, ),
                ),
              );
              //context.pushNamed('order-1');
            },
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                      10.0, 0.0, 10.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      AutoSizeText(
                        '單號 : '+list![i]["id"],
                        style: FlutterFlowTheme.of(context)
                            .bodyMedium
                            .override(
                          fontFamily: 'Readex Pro',
                          fontSize: 24.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            135.0, 0.0, 0.0, 0.0),
                        child: AutoSizeText(
                          '查看更多',
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                            fontFamily: 'Readex Pro',
                            fontSize: 24.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: FlutterFlowTheme.of(context)
                            .primaryText,
                        size: 24.0,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                      10.0, 10.0, 10.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      AutoSizeText(
                        '外送費 : '+list![i]["fee"]+'  Eth',
                        style: FlutterFlowTheme.of(context)
                            .bodyMedium
                            .override(
                          fontFamily: 'Readex Pro',
                          fontSize: 24.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(10, 10, 10, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: MediaQuery.sizeOf(context).width * 0.89,
                        height: MediaQuery.sizeOf(context).height * 0.09,
                        decoration: BoxDecoration(
                          color: Color(0xFFA1DAA1),
                        ),
                        child: AutoSizeText(
                          '地址 : '+myList[1],
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Readex Pro',
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                          minFontSize: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                /*Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                      10.0, 10.0, 10.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      AutoSizeText(
                        '距離店家:1.2km',
                        style: FlutterFlowTheme.of(context)
                            .bodyMedium
                            .override(
                          fontFamily: 'Readex Pro',
                          fontSize: 24.0,
                          fontWeight: FontWeight.w500,
                        ),
                        minFontSize: 1.0,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                      10.0, 10.0, 10.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      AutoSizeText(
                        '距離消費者:1.5km',
                        style: FlutterFlowTheme.of(context)
                            .bodyMedium
                            .override(
                          fontFamily: 'Readex Pro',
                          fontSize: 24.0,
                          fontWeight: FontWeight.w500,
                        ),
                        minFontSize: 1.0,
                      ),
                    ],
                  ),
                ),*/
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                      10.0, 10.0, 10.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AutoSizeText(
                        "$str",
                        style: FlutterFlowTheme.of(context)
                            .bodyMedium
                            .override(
                          fontFamily: 'Readex Pro',
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                        minFontSize: 1.0,
                      ),
                    ],
                  ),
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
  /*getorderStatus() async {
    if(list![i]["id"]){}

  }*/
}