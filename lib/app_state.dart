import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _account = prefs.getString('ff_account') ?? _account;
    });
    _safeInit(() {
      _password = prefs.getString('ff_password') ?? _password;
    });
    _safeInit(() {
      _Name = prefs.getString('ff_Name') ?? _Name;
    });
    _safeInit(() {
      _Telephone = prefs.getString('ff_Telephone') ?? _Telephone;
    });
    _safeInit(() {
      _email = prefs.getString('ff_email') ?? _email;
    });
    Future initializePersistedState() async {
      prefs = await SharedPreferences.getInstance();
      _safeInit(() {
        _name = prefs.getStringList('ff_name') ?? _name;
      });
    }
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  List<String> _name = [];
  List<String> get name => _name;
  set name(List<String> _value) {
    _name = _value;
    prefs.setStringList('ff_name', _value);
  }

  void addToName(String _value) {
    _name.add(_value);
    prefs.setStringList('ff_name', _name);
  }

  void removeFromName(String _value) {
    _name.remove(_value);
    prefs.setStringList('ff_name', _name);
  }

  void removeAtIndexFromName(int _index) {
    _name.removeAt(_index);
    prefs.setStringList('ff_name', _name);
  }

  void updateNameAtIndex(
      int _index,
      String Function(String) updateFn,
      ) {
    _name[_index] = updateFn(_name[_index]);
    prefs.setStringList('ff_name', _name);
  }

  void insertAtIndexInName(int _index, String _value) {
    _name.insert(_index, _value);
    prefs.setStringList('ff_name', _name);
  }

  String _account = '';
  String get account => _account;
  set account(String _value) {
    _account = _value;
    prefs.setString('ff_account', _value);
  }

  String _password = '';
  String get password => _password;
  set password(String _value) {
    _password = _value;
    prefs.setString('ff_password', _value);
  }

  String _Name = '';
  String get Name => _Name;
  set Name(String _value) {
    _Name = _value;
    prefs.setString('ff_Name', _value);
  }

  String _Telephone = '';
  String get Telephone => _Telephone;
  set Telephone(String _value) {
    _Telephone = _value;
    prefs.setString('ff_Telephone', _value);
  }

  String _email = '';
  String get email => _email;
  set email(String _value) {
    _email = _value;
    prefs.setString('ff_email', _value);
  }
}

LatLng? _latLngFromString(String? val) {
  if (val == null) {
    return null;
  }
  final split = val.split(',');
  final lat = double.parse(split.first);
  final lng = double.parse(split.last);
  return LatLng(lat, lng);
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
