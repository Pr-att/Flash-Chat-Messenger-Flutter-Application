import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class InternalStorage {
  static const FlutterSecureStorage storage = FlutterSecureStorage();

  setValue(String key, String value) async {
    await storage.write(key: key, value: value);
  }

  getValue(String key) async {
    return await storage.read(key: key);
  }

  deleteValue(String key) async {
    await storage.delete(key: key);
  }

  deleteAll() async {
    await storage.deleteAll();
  }

  containsKey(String key) async {
    return await storage.containsKey(key: key);
  }

  getKeys() async {
    return await storage.readAll();
  }

  getKeysWithPrefix(String prefix) async {
    return await storage.readAll().then((value) {
      return value.keys.where((element) => element.startsWith(prefix)).toList();
    });
  }
}
