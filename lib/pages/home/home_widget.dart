import 'dart:convert';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'home_model.dart';
export 'home_model.dart';
import 'package:http/http.dart' as http;
import '/main.dart';
import '/database/storeDB.dart'; // 引入自定義的 SQL 檔案

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {




    getContract() async {
      var url = Uri.parse(ip+"signUp/getContract");

      final responce = await http.post(url,body: {

        "account": FFAppState().account,

      });
      if (responce.statusCode == 200) {
        var data = json.decode(responce.body);//將json解碼為陣列形式
        //print("店家:${data["contracts"].toString()}");
        return data["contracts"];
      }
    }

    checkAvailableOrder(contractAddress) async {
      var url = Uri.parse(ip+"contract/checkAvailableOrder");

      final responce = await http.post(url,body: {

        "contractAddress": contractAddress,
        "wallet": FFAppState().account,

      });
      if (responce.statusCode == 200) {
        var data = json.decode(responce.body);//將json解碼為陣列形式
        //print("店家是否有訂單:${data["result"].toString()}");
        return data["result"];
      }
    }

    getAvailableOrder(contractAddress) async {
      var url = Uri.parse(ip+"contract/getAvailableOrder");

      final responce = await http.post(url,body: {

        "contractAddress": contractAddress,
        "wallet": FFAppState().account,

      });
      if (responce.statusCode == 200) {
        var data = json.decode(responce.body);//將json解碼為陣列形式
        //print("店家可接單號:${data["availableOrderID"].toString()}");
        return data["availableOrderID"];
      }
    }

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

    getOrder(contractAddress,availableOrderID) async {
      var url = Uri.parse(ip+"contract/getOrder");

      final responce = await http.post(url,body: {

        "contractAddress": contractAddress,
        "wallet": FFAppState().account,
        "id": availableOrderID.toString(),

      });
      if (responce.statusCode == 200) {
        var data = json.decode(responce.body);//將json解碼為陣列形式
        return data;
      }
    }

    List<Map<String, dynamic>> orderContentList = []; // 訂單內容

    Future<List> getlist() async {
      List contracts = await getContract();
      await dbHelper.dbResetOrder();
      for (int i = 0; i < contracts.length; i++) {
        var result = await checkAvailableOrder(contracts[i]);
        if (result == true) {
          List availableOrderID = await getAvailableOrder(contracts[i]);
          var name = await getStore(contracts[i]);
          if (availableOrderID != null) {
            print("${contracts[i]} 店家的可接單號 ID 為: $availableOrderID");
            for(int j = 0; j < availableOrderID.length; j++){
              var fee = await getOrder(contracts[i],availableOrderID[j]);
                Map<String, dynamic> A = {};//重要{}
                A['id']=availableOrderID[j];
                A['storeName']=name["storeName"];
                A['fee']=fee["fee"];
                await dbHelper.dbInsertOrder(A); // 將訂單內容插入資料庫
            }
          }
        }
      }
      orderContentList = await dbHelper.dbGetOrder(); // 更新訂單內容
      print(orderContentList);
      return orderContentList;
    }


    /*Future<List> getData() async {
      List storeNameList = ["storeNameList"];
      List contracts = await getContract();
      //orderContentList = await dbHelper.dbGetOrder_content();

      for (int i = 0; i < contracts.length; i++) {
        await dbHelper.dbResetOrder_content();
        var result = await checkAvailableOrder(contracts[i]);
        if (result == true) {
          List availableOrderID = await getAvailableOrder(contracts[i]);
          var name = await getStore(contracts[i]);
          if (availableOrderID != null) {
            print("${contracts[i]} 店家的可接單號 ID 為: $availableOrderID");
            for(int j = 0; j < availableOrderID.length; j++){
              var fee = await getOrder(contracts[i],availableOrderID[j]);
              var orderContent = await getOrderContent(contracts[i],availableOrderID[j]);
              for (var i =0; i< orderContent.length;i++){
                Map<String, dynamic> A = {};//重要{}
                A['orderID']=orderContent[i][0];
                A['num']=orderContent[i][1];
                A['contract']=contracts[i];
                A['id']=availableOrderID[j];
                A['storeName']=name["storeName"];
                A['fee']=fee["fee"];
                await dbHelper.dbInsertOrder_content(A); // 將訂單內容插入資料庫
              }
              print("訂單內容是: $orderContent");
              orderContentList = await dbHelper.dbGetOrder_content(); // 更新訂單內容

            }
          }
        }
      }
      print(orderContentList);
      return orderContentList;
    }*/

  late HomeModel _model;
    late DBHelper dbHelper; // DBHelper 實例
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper(); // 初始化 DBHelper
    _model = createModel(context, () => HomeModel());
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
                          '可接送的外送單',
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
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: [
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {
                          context.pushNamed('home-1');
                        },
                       child:Container(
                         width: MediaQuery.sizeOf(context).width * 1.0,
                         height: MediaQuery.sizeOf(context).height * 1.0,
                         decoration: BoxDecoration(
                           color: Color(0xFFF1F4F8),
                           borderRadius: BorderRadius.circular(0.0),
                         ),
                         child:FutureBuilder<List>(
                           future: getlist(),
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
          width: MediaQuery.sizeOf(context).width * 1.0,
          height: MediaQuery.sizeOf(context).height * 0.22,
          decoration: BoxDecoration(
            color: Color(0xFFF1F4F8),
            borderRadius: BorderRadius.circular(0.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: MediaQuery.sizeOf(context).width * 0.9,
                height:
                MediaQuery.sizeOf(context).height * 0.15,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context)
                      .secondaryBackground,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    'https://i.epochtimes.com/assets/uploads/2022/05/id13748758-557776.png',
                    width:
                    MediaQuery.sizeOf(context).width * 1.0,
                    height:
                    MediaQuery.sizeOf(context).height * 1.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        list![i]["storeName"],
                    //FFAppState().name[1].toString(),
                        style: FlutterFlowTheme.of(context)
                            .bodyMedium
                            .override(
                          fontFamily: 'Readex Pro',
                          fontSize: 19.0,
                        ),
                      ),
                      AutoSizeText(
                        '店家距離: 變數',
                        style: FlutterFlowTheme.of(context)
                            .bodyMedium
                            .override(
                          fontFamily: 'Readex Pro',
                          fontSize: 19.0,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        '外送費: '+list![i]["fee"],
                        style: FlutterFlowTheme.of(context)
                            .bodyMedium
                            .override(
                          fontFamily: 'Readex Pro',
                          fontSize: 19.0,
                        ),
                      ),
                      AutoSizeText(
                        '消費者距離: 變數',
                        style: FlutterFlowTheme.of(context)
                            .bodyMedium
                            .override(
                          fontFamily: 'Readex Pro',
                          fontSize: 19.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return ChooseDivider(index);
      },
    );
  }
}