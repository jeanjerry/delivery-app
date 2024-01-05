import 'dart:convert';

import '../order/order_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'home1_model.dart';
export 'home1_model.dart';
import 'package:http/http.dart' as http;
import '/main.dart';
import '/database/storeDB.dart'; // 引入自定義的 SQL 檔案
import 'package:decimal/decimal.dart';

class Home1Widget extends StatefulWidget {

  const Home1Widget({Key? key, required this.selectedItem}) : super(key: key);

  final Map<String, dynamic> selectedItem;


  @override
  _Home1WidgetState createState() => _Home1WidgetState();
}

class _Home1WidgetState extends State<Home1Widget> {
  late Home1Model _model;
  late DBHelper dbHelper;// DBHelper 實例


  getOrderContent(contractAddress,availableOrderID) async {
    var url = Uri.parse(ip+"contract/getOrderContent");

    final responce = await http.post(url,body: {

      "contractAddress": contractAddress,
      "wallet": FFAppState().account,
      "id": availableOrderID.toString(),

    });
    if (responce.statusCode == 200) {
      var data = json.decode(responce.body);//將json解碼為陣列形式
      //print("訂單內容:${data["orderContent"].toString()}");
      return data["orderContent"];
    }
  }

  deliveryAcceptOrder() async {
    var url = Uri.parse(ip+"contract/deliveryAcceptOrder");

    final responce = await http.post(url,body: {

      "contractAddress": widget.selectedItem['contract'],
      "id": widget.selectedItem['id'],
      "deliveryName": FFAppState().Name,
      "deliveryPhone": FFAppState().Telephone,
      "deliveryWallet": FFAppState().account,
      "deliveryPassword": FFAppState().password,
      "deliveryEmail": FFAppState().email,

    });
    if (responce.statusCode == 200) {
      var data = json.decode(responce.body);//將json解碼為陣列形式
      //print("店家:${data["contracts"].toString()}");
      return data;
    }
  }

  getOrder() async {
    var url = Uri.parse(ip+"contract/getOrder");

    final responce = await http.post(url,body: {

      "contractAddress": widget.selectedItem['contract'],
      "wallet": FFAppState().account,
      "id": widget.selectedItem['id'],

    });
    if (responce.statusCode == 200) {
      var data = json.decode(responce.body);//將json解碼為陣列形式
      return data;
    }
  }

  /*List<Map<String, dynamic>> orderList = []; // 訂單內容

  Future<List> getorderList() async {      //把getorder放入資料庫stores
    var orderlist = await getOrder();
    //await dbHelper.dbResetStores();// 重製訂單內容
    Map<String, dynamic> A = {};//重要{}
    A['id']=widget.selectedItem['id'];
    A['consumer']=orderlist["consumer"].toString();
    A['consumer'] = A['consumer'].replaceAll(RegExp(r'^\[|\]$'), '');
    A['fee']=orderlist["fee"];
    A['note']=orderlist['note'];
    A['delivery']=orderlist["delivery"].toString();
    A['delivery'] = A['delivery'].replaceAll(RegExp(r'^\[|\]$'), '');
    A['orderStatus']=orderlist["orderStatus"];
    A['contract']=widget.selectedItem['contract'];
    await dbHelper.dbInsertStore(A); // 將訂單內容插入資料庫
    orderList = await dbHelper.dbGetStores();
    print(orderList);
    return orderList;
  }*/

  List<Map<String, dynamic>> checkorderList = []; // 訂單內容

  Future<List> checkorder() async {      //把單號和店家合約放入資料庫checkorder
    //await dbHelper.dbResetcheckorder();// 重製訂單內容
    Map<String, dynamic> A = {};//重要{}
    A['id']=widget.selectedItem['id'];
    A['contract']=widget.selectedItem['contract'];
    A['storeName']=widget.selectedItem["storeName"];
    A['fee']=widget.selectedItem["fee"];
    await dbHelper.dbInsertcheckorder(A); // 將訂單內容插入資料庫
    checkorderList = await dbHelper.dbGetcheckorder();
    print(checkorderList);
    return checkorderList;
  }






  List<Map<String, dynamic>> orderContentList = []; // 訂單內容

     Future<List> getData() async {
       await dbHelper.dbResetOrder_content();
       orderContentList.clear();
       var orderContent = await getOrderContent(widget.selectedItem['contract'],widget.selectedItem['id']);
              for (var i =0; i< orderContent.length;i++){
                Map<String, dynamic> A = {};//重要{}
                A['orderID']=orderContent[i][0];
                A['num']=orderContent[i][1];
                A['contract']=widget.selectedItem['contract'];
                A['id']=widget.selectedItem['id'];
                A['storeName']=widget.selectedItem["storeName"];
                A['fee']=widget.selectedItem["fee"];
                await dbHelper.dbInsertOrder_content(A); // 將訂單內容插入資料庫
              }
              print("訂單內容是: $orderContent");
                orderContentList = await dbHelper.dbGetOrder_content(); // 更新訂單內
              //print(orderContentList);
              return orderContentList;
        }

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => Home1Model());
    dbHelper = DBHelper(); // 初始化 DBHelper

   // var result = await getOrderContent(widget.selectedItem['storeName'],widget.selectedItem['id']);
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    //print(orderContentList[0]["orderID"]);
    //print(orderContentList);

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
                        '單號 : '+widget.selectedItem["id"],
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              fontSize: 25.0,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      Container(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        height: MediaQuery.sizeOf(context).height * 0.38,
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
                                      height: MediaQuery.sizeOf(context).height * 0.16 ,
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
                                    width:
                                        MediaQuery.sizeOf(context).width * 1.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Divider(
                                          height: 0,
                                          thickness: 3,
                                          color: Colors.black,
                                        ),
                                        Padding(
                                          padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                "總金額 : "+(Decimal.parse(widget.selectedItem["foodCost"]) / Decimal.parse('1e18'))
                                                    .toDouble()
                                                    .toString()+" Eth",
                                                style: FlutterFlowTheme.of(context).titleLarge.override(
                                                  fontFamily: 'Outfit',
                                                  fontSize: 22,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 12.0, 0.0, 12.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          8.0, 0.0, 4.0, 0.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        '外送費用 : ',
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .titleLarge,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        8.0, 0.0, 0.0, 0.0),
                                                child: Text(
                                                  widget.selectedItem["fee"]+" 元 ",
                                                  textAlign: TextAlign.end,
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .titleLarge,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
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
                        height: MediaQuery.sizeOf(context).height * 0.15,
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
                                '備註文字',
                                style: FlutterFlowTheme.of(context).titleLarge,
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 20.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment:
                                          AlignmentDirectional(0.00, 0.00),
                                      child: Text(
                                        widget.selectedItem['note'],
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
                        height: MediaQuery.sizeOf(context).height * 0.2,
                        constraints: BoxConstraints(
                          maxWidth: 430.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4.0,
                              color: Color(0x33000000),
                              offset: Offset(0.0, 6.0),
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
                                        '路程',
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
                            /*Map<String, dynamic> A = {};//重要{}
                            A['id']=widget.selectedItem['id'];
                            A['contract']=widget.selectedItem['contract'];
                            print(A);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => OrderWidget( A: A, ),
                              ),
                            );*/
                            await deliveryAcceptOrder();
                            await checkorder();
                            context.pushNamed('order');
                          },
                          text: '接單',
                          options: FFButtonOptions(
                            width: MediaQuery.sizeOf(context).width * 1.0,
                            height: MediaQuery.sizeOf(context).height * 0.06,
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            iconPadding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: Color(0xFFE87F83),
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
                            borderRadius: BorderRadius.circular(50.0),
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
          width: MediaQuery.sizeOf(context).width * 1.0,
          height: MediaQuery.sizeOf(context).height * 0.055,
          decoration: BoxDecoration(
            color: Color(0xFFF1F4F8),
            borderRadius: BorderRadius.circular(0.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: MediaQuery.sizeOf(context).width * 1.0,
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                      ],
                    ),
                  ),
            ],
          ),
        )
      ]
          )
        );
      },
    );
  }
}