import 'dart:convert';

import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'database/storeDB.dart';
import 'flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/internationalization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'flutter_flow/nav/nav.dart';
import 'index.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:geocoding_platform_interface/src/models/location.dart' as GeoLocation;
import 'package:geolocator/geolocator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  await FlutterFlowTheme.initialize();

  final appState = FFAppState(); // Initialize FFAppState
  await appState.initializePersistedState();

  dbHelper = DBHelper(); // 初始化 DBHelper
  runApp(ChangeNotifierProvider(
    create: (context) => appState,
    child: MyApp(),
  ));
  startBackgroundTask();
}

List<Map<String, dynamic>> checkorderList = []; // 訂單內容

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

currentLocation(contract,id,_location) async {
  var url = Uri.parse(ip+"contract/currentLocation");

  final responce = await http.post(url,body: {

    "contractAddress": contract,
    "deliveryWallet": FFAppState().account,
    "deliveryPassword": FFAppState().password,
    "id": id,
    "deliveryLocation": _location,

  });
  if (responce.statusCode == 200) {
    var data = json.decode(responce.body);//將json解碼為陣列形式
    return data;
  }
}
String _locationMessage = '';
_getLocation() async {
  try {
    // 請求位置權限
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      // 使用者拒絕了位置權限
        _locationMessage = '使用者拒絕了位置權限';
    } else if (permission == LocationPermission.deniedForever) {
      // 使用者永久拒絕了位置權限

        _locationMessage = '使用者永久拒絕了位置權限';

    } else {
      // 使用者同意位置權限，繼續取得位置
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );


        _locationMessage =
        /*'緯度: ${position.latitude}, 經度: ${position.longitude}';*/
        '${position.latitude}%2C${position.longitude}';

    }
  } catch (e) {

      _locationMessage = '無法獲取位置: $e';

  }

  print("本地位置 $_locationMessage");
}

late DBHelper dbHelper; // DBHelper 實例
Future<void> startBackgroundTask() async {
  // 使用Timer.periodic設定定時任務
  checkorderList = await dbHelper.dbGetcheckorder();
  Timer.periodic(Duration(seconds: 60), (Timer timer) async {
    // 在這裡執行你的背景任務
    print("長度"+checkorderList.length.toString());
    for(int i = 0; i < checkorderList.length; i++){
      var orderStatus = await getOrder(checkorderList[i]['contract'],checkorderList[i]['id']);
      print("接單狀態"+orderStatus["orderStatus"]);
      if(orderStatus["orderStatus"]=="3"||orderStatus["orderStatus"]=="4"||orderStatus["orderStatus"]=="5"){
        await _getLocation();
        print(_locationMessage);
        await currentLocation(checkorderList[i]['contract'],checkorderList[i]['id'],_locationMessage.toString());
        print("寄送本地位置完成");
      }
    }
    print("執行一次");
  });
}


var ip =('http://140.127.114.38:15000/');

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
  }

  void setLocale(String language) {
    setState(() => _locale = createLocale(language));
  }

  void setThemeMode(ThemeMode mode) => setState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'delivery APP',
      localizationsDelegates: [
        FFLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: _locale,
      supportedLocales: const [Locale('en', '')],
      theme: ThemeData(
        brightness: Brightness.light,
        scrollbarTheme: ScrollbarThemeData(),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scrollbarTheme: ScrollbarThemeData(),
      ),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}

class NavBarPage extends StatefulWidget {
  NavBarPage({Key? key, this.initialPage, this.page}) : super(key: key);

  final String? initialPage;
  final Widget? page;

  @override
  _NavBarPageState createState() => _NavBarPageState();
}

/// This is the private State class that goes with NavBarPage.
class _NavBarPageState extends State<NavBarPage> {
  String _currentPageName = 'home';
  late Widget? _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPageName = widget.initialPage ?? _currentPageName;
    _currentPage = widget.page;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = {
      'home': HomeWidget(),
      'order': OrderWidget(A: {},),
      'wallet': WalletWidget(),
      'setting': SettingWidget(),
    };
    final currentIndex = tabs.keys.toList().indexOf(_currentPageName);

    return Scaffold(
      body: _currentPage ?? tabs[_currentPageName],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => setState(() {
          _currentPage = null;
          _currentPageName = tabs.keys.toList()[i];
        }),
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Color(0x8A000000),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 22.0,
            ),
            label: '外送廣場',
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.border_color,
              size: 22.0,
            ),
            label: '已接訂單',
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.attach_money_rounded,
              size: 24.0,
            ),
            label: '錢包',
            tooltip: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings_sharp,
              size: 24.0,
            ),
            label: '設定',
            tooltip: '',
          )
        ],
      ),
    );
  }
}
