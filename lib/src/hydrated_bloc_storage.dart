import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Interface which `HydratedBlocDelegate` uses to persist and retrieve
/// state changes from the local device.
abstract class HydratedStorage {
  /// Returns value for key
  dynamic read(String key);

  /// Persists key value pair
  Future<void> write(String key, dynamic value);

  /// Clears all key value pairs from storage
  Future<void> clear();
}

/// Implementation of `HydratedStorage` which uses `PathProvider` and `dart.io`
/// to persist and retrieve state changes from the local device.
class HydratedBlocStorage implements HydratedStorage {
  static const String _hydratedBlocStorageName = '.hydrated_bloc.json';
  static HydratedBlocStorage _instance;
  Map<String, dynamic> _storage;
  File _file;

  /// Returns an instance of `HydratedBlocStorage`.
  static Future<HydratedBlocStorage> getInstance() async {
    if (_instance != null) {
      return _instance;
    }

    final Directory directory = await getTemporaryDirectory();
    final File file = File('${directory.path}/$_hydratedBlocStorageName');
    Map<String, dynamic> storage = Map<String, dynamic>();

    if (await file.exists()) {
      storage = json.decode(await file.readAsString()) as Map<String, dynamic>;
    }

    _instance = HydratedBlocStorage._(storage, file);
    return _instance;
  }

  HydratedBlocStorage._(this._storage, this._file);

  @override
  dynamic read(String key) {
    return _storage[key];
  }

  @override
  Future<void> write(String key, dynamic value) async {
    _storage[key] = value;
    await _file.writeAsString(json.encode(_storage));
    return _storage[key] = value;
  }

  @override
  Future<void> clear() async {
    _storage = Map<String, dynamic>();
    _instance = null;
    return await _file.exists() ? await _file.delete() : null;
  }
}
