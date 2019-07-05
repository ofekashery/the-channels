import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class Cache {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> getFile(String key) async {
    final path = await _localPath;
    return File('$path/$key.json');
  }

  static Future<dynamic> get(String key) async {
    try {
      final file = await Cache().getFile(key);
      Map<String, dynamic> body = jsonDecode(await file.readAsString());
      if (body['expires-date'] == null || body['expires-date'] >= DateTime.now().millisecondsSinceEpoch) {
        return body['data'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<File> set(String key, dynamic json, Duration expiresDuration) async {
    final file = await Cache().getFile(key);
    Map map = {
      'expires-date': expiresDuration != null ? DateTime.now().add(expiresDuration).millisecondsSinceEpoch : null,
      'data': json
    };

    // Write the file
    return file.writeAsString(jsonEncode(map));
  }
}
