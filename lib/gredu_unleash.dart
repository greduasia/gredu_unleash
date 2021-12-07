library gredu_unleash;

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:gredu_unleash/extention.dart';
import 'package:gredu_unleash/gredu_unleash_config.dart';

import 'feature_flags_entity.dart';

class GreduUnleash {

  GreduUnleashConfig? _config;

  FeatureFlagsEntity? _data;

  GreduUnleashConfig? getConfig() {
    return _config;
  }

  /// Get response data from call API
  /// This is the standard of Unleash opensource API response
  FeatureFlagsEntity? getData() {
    return _data;
  }

  /// Check your feature is enabled or disabled
  /// Put your toggle name / feature name as params
  /// Toggle name should be representing which feature that you want to check
  /// You can put your default value for your own business requirement
  bool isFeatureEnabled(String toggleName, {bool defaultValue = true}) {
    if (_config == null) {
      log("GreduUnleash hasn't initialized");
      return defaultValue;
    } else {
      return _isEnabled(toggleName, defaultValue);
    }
  }

  void _checkInterval() async {
    if (_config != null) {
      if (_config!.pollInterval != null) {
        await Future.delayed(_config!.pollInterval!);
        _poll(_config!.pollInterval!);
      }
    }
  }

  Future<void> _getUnleashClient() async {
    if (_config != null) {
      debug("fetching data...");
      final client = http.Client();
      try {
        final response = await client.get(Uri.parse(_config!.proxyUrl), headers: _config!.headers);
        if (response.statusCode != 200) throw HttpException('${response.statusCode}');
        _onSuccess(jsonDecode(response.body));
      } on SocketException {
        debug('No Internet connection');
      } on HttpException {
        debug('Network not found');
      } on FormatException {
        debug('Unparsable response format');
      } on TimeoutException {
        debug('Connection timeout');
      }
    }
  }

  void _onSuccess(Map<String, dynamic> res) {
    debug("Data ---> $res");
    _data = FeatureFlagsEntity().fromJson(res);
  }

  bool _isEnabled(String toggleName, bool defaultValue) {
    bool isEnabled = false;
    if (_data?.toggles != null) {
      if (_data!.toggles!.isNotEmpty) {
        _data?.toggles?.forEach((element) {
          if (element.name == toggleName) { isEnabled = true; }
        });
      } else { isEnabled = defaultValue; }
    } else { isEnabled = defaultValue; }
    debug("toggleName = $toggleName, is enabled = $isEnabled");
    return isEnabled;
  }

  Future _poll(Duration interval) async {
    debug("polling is started");
    var count = 0.0;
    bool flag = true;

    while (flag){
      count++;
      debug("going on $count");
      _getUnleashClient();
      await Future.delayed(interval);
    }
  }


  static GreduUnleash? _unleash;

  /// Static method for initialization
  /// It's required function
  static Future<GreduUnleash> init({required GreduUnleashConfig config}) async {
    _unleash ??= GreduUnleash();
    _unleash!._config ??= config;
    await _unleash!._getUnleashClient();
    _unleash!._checkInterval();
    return _unleash!;
  }

}
