// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Default implementation of new API on top of the built-in Dart JSON parser.
library;

import 'dart:convert';
import 'dart:typed_data';

const jsjsonMode = 'Dart';

/// Parses the JSON string [jsonSource] to a [JsonAny].
///
/// Throws a [FormatException] if the input cannot be parsed as JSON.
JsonAny? parseJson(String jsonSource) {
  return JsonAny._from(jsonDecode(jsonSource));
}

/// Parses the UTF-8 encoded JSON string [jsonBytes] to a [JsonAny].
///
/// Throws a [FormatException] if the input cannot be parsed as JSON.
JsonAny? parseUtf8Json(Uint8List jsonBytes) {
  return JsonAny._from(
      const Utf8Decoder().fuse(const JsonDecoder()).convert(jsonBytes));
}

class _JsonTypeError extends TypeError {
  final String _type;
  _JsonTypeError(this._type);
  @override
  String toString() => 'TypeError: Value is not a $_type';
}

/// An unknown JSON value.
///
/// Use any of the `as...` method to check if the value is of that type,
/// which it is if the returned value is not `null`,
/// then use that value.
extension type JsonAny._(Object _) {
  static JsonAny? _from(Object? value) => value as JsonAny?;

  JsonString? get tryAsString => _ is String ? JsonString._(_) : null;
  JsonNum? get tryAsNum => _ is num ? JsonNum._(_) : null;
  JsonBool? get tryAsBool => _ is bool ? JsonBool._(_) : null;
  JsonList? get tryAsList => _ is List<JsonAny?> ? JsonList._(_) : null;
  JsonMap? get tryAsMap => _ is Map<String, JsonAny?> ? JsonMap._(_) : null;

  JsonString get asString =>
      _ is String ? JsonString._(_) : (throw _JsonTypeError('String'));
  JsonNum get asNum => _ is num ? JsonNum._(_) : (throw _JsonTypeError('num'));
  JsonBool get asBool =>
      _ is bool ? JsonBool._(_) : (throw _JsonTypeError('bool'));
  JsonList get asList =>
      _ is List<JsonAny?> ? JsonList._(_) : (throw _JsonTypeError('List'));
  JsonMap get asMap =>
      _ is Map<String, JsonAny?> ? JsonMap._(_) : (throw _JsonTypeError('Map'));
}

/// A JSON string.
extension type const JsonString._(String _) {
  /// The string value of this JSON string.
  String get value => _;

  /// Converts this string to an integer.
  ///
  /// Succeeds if [int.parse] can parse the string.
  int get toInt {
    return int.parse(_);
  }

  /// Converts this string to a [double].
  ///
  /// Succeeds if [double.parse] can parse the string.
  double get toDouble {
    return double.parse(_);
  }

  /// Converts this string to a [bool].
  ///
  /// Returns `true` if [value] is `"true"` and `false` otherwise.
  /// If [yes] is provided, that string will return `true` instead.
  /// If [no] is provided, only that string will return `false`,
  /// and a [FormatException] is thrown if [value] is neither [yes] nor [no].
  bool toBool({String yes = 'true', String? no}) {
    return _ == yes ||
        no == null ||
        _ == no ||
        (throw FormatException("Neither '$yes' nor '$no'", _));
  }
}

/// A JsON boolean.
extension type const JsonBool._(bool _) {
  /// The boolean value of this JSON boolean.
  bool get value => _;
}

/// A JSON number.
///
/// May be used as either an integer or a double.
extension type const JsonNum._(num _) {
  /// This number as a Dart integer.
  int get toInt => _.toInt();

  /// This number as a Dart [double].
  double get toDouble => _.toDouble();
}

extension JsonAnyOrNull on JsonAny? {
  JsonString? get tryAsString => this?.tryAsString;
  JsonNum? get tryAsNum => this?.tryAsNum;
  JsonBool? get tryAsBool => this?.tryAsBool;
  JsonList? get tryAsList => this?.tryAsList;
  JsonMap? get tryAsMap => this?.tryAsMap;

  JsonString get asString =>
      this?.tryAsString ?? (throw _JsonTypeError('String'));
  JsonNum get asNum => this?.tryAsNum ?? (throw _JsonTypeError('num'));
  JsonBool get asBool => this?.tryAsBool ?? (throw _JsonTypeError('bool'));
  JsonList get asList => this?.tryAsList ?? (throw _JsonTypeError('List'));
  JsonMap get asMap => this?.tryAsMap ?? (throw _JsonTypeError('Map'));
}

/// A JSON list.
extension type const JsonList._(List<JsonAny?> _) {
  /// Whether this JSON list is empty.
  bool get isEmpty => length == 0;

  /// Whether this JSON list is non-empty.
  bool get isNotEmpty => length != 0;

  /// The number of elements in this JSON list.
  int get length => _.length;

  /// Looks up the value at position [index] in this list and returns its value.
  ///
  /// The [index] must be a valid index, 0 &le; `index` &lt; [length].
  JsonAny? operator [](int index) => _[index];

  /// Reads a string value at position [index].
  ///
  /// The [index] must be a valid index, 0 &le; `index` &lt; [length].
  /// The value at position [index] must be a JSON string.
  JsonString stringAt(int index) {
    if (_[index] case String v) return JsonString._(v);
    throw _JsonTypeError('String');
  }

  /// Reads a number value at position [index].
  ///
  /// The [index] must be a valid index, 0 &le; `index` &lt; [length].
  /// The value at position [index] must be a JSON number.
  JsonNum numAt(int index) {
    if (_[index] case num v) return JsonNum._(v);
    throw _JsonTypeError('num');
  }

  /// Reads a boolean value at position [index].
  ///
  /// The [index] must be a valid index, 0 &le; `index` &lt; [length].
  /// The value at position [index] must be a JSON boolean.
  JsonBool boolAt(int index) {
    if (_[index] case bool v) return JsonBool._(v);
    throw _JsonTypeError('bool');
  }

  /// Reads a list value at position [index].
  ///
  /// The [index] must be a valid index, 0 &le; `index` &lt; [length].
  /// The value at position [index] must be a JSON list.
  JsonList listAt(int index) {
    if (_[index] case List<JsonAny?> v) return JsonList._(v);
    throw _JsonTypeError('List');
  }

  /// Reads a map value at position [index].
  ///
  /// The [index] must be a valid index, 0 &le; `index` &lt; [length].
  /// The value at position [index] must be a JSON map.
  JsonMap mapAt(int index) {
    if (_[index] case Map<String, JsonAny?> v) return JsonMap._(v);
    throw _JsonTypeError('Map');
  }

  /// Converts this `JsonMap` to a Dart map.
  ///
  /// This may require some computation, and it does not recursively
  /// transform the elements of the list.
  List<JsonAny?> toList() => _;
}

extension type const JsonMap._(Map<String, JsonAny?> _) {
  /// Looks up [key] in this map and returns its value.
  ///
  /// If the key is not in this map, when [containsKey] returns false, then
  /// `null` is returned. Since a key's value can be `null`, it may be necessary
  /// to use [containsKey] to check if a `null` represents a key with a `null`
  /// value, or no key, if the distinction matters.
  JsonAny? operator [](String key) => _[key];

  /// Reads a string value for [key].
  ///
  /// The [key] must be a key of this JSON map, and
  /// the value for [key] must be a JSON string.
  JsonString stringAt(String key) {
    if (_[key] case String v) return JsonString._(v);
    throw _JsonTypeError('String');
  }

  /// Reads a number value for [key].
  ///
  /// The [key] must be a key of this JSON map, and
  /// the value for [key] must be a JSON number.
  JsonNum numAt(String key) {
    if (_[key] case num v) return JsonNum._(v);
    throw _JsonTypeError('num');
  }

  /// Reads a boolean value for [key].
  ///
  /// The [key] must be a key of this JSON map, and
  /// the value for [key] must be a JSON boolean.
  JsonBool boolAt(String key) {
    if (_[key] case bool v) return JsonBool._(v);
    throw _JsonTypeError('bool');
  }

  /// Reads a list value for [key].
  ///
  /// The [key] must be a key of this JSON map, and
  /// the value for [key] must be a JSON list.
  JsonList listAt(String key) {
    if (_[key] case List<JsonAny?> v) return JsonList._(v);
    throw _JsonTypeError('List');
  }

  /// Reads a map value for [key].
  ///
  /// The [key] must be a key of this JSON map, and
  /// the value for [key] must be a JSON map.
  JsonMap mapAt(String key) {
    if (_[key] case Map<String, JsonAny?> v) return JsonMap._(v);
    throw _JsonTypeError('Map');
  }

  /// The keys of this JSON map, in no guaranteed order.
  Iterable<String> get keys => _.keys;

  /// Whether this JSON map contains [key] as a key.
  bool containsKey(String key) => _.containsKey(key);

  /// Converts this `JsonMap` to a Dart map.
  ///
  /// This may require some computation, and it does not recursively
  /// transform the values of the map.
  Map<String, JsonAny?> toMap() => _;
}
