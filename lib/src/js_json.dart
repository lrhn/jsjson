// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Default implementation of new API on top of the built-in Dart JSON parser.
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

const jsjsonMode = 'JS';

// JS interop.
@JS('Object.getOwnPropertyNames')
external JSArray<JSString> _objectKeys(JSObject object);

@JS('Object.hasOwn')
external bool _objectHasKey(JSObject object, String key);

@JS('Object.entries')
external JSArray<JSArray<JSAny?>> _objectEntries(JSObject object);

@JS('JSON.parse')
external JSAny? _jsonParse(String source);

final JSString _jsLengthString = 'length'.toJS;

extension<T extends JSAny?> on JSArray<T> {
  int get length => getProperty<JSNumber>(_jsLengthString).toDartInt;
  T operator [](int index) => getProperty<T>(index.toJS);
}

// Parsing.

/// Parses the JSON string [jsonSource] to a [JsonAny].
///
/// Throws a [FormatException] if the input cannot be parsed as JSON.
JsonAny? parseJson(String jsonSource) {
  var jsJson = _jsonParse(jsonSource);
  return JsonAny._from(jsJson);
}

/// Parses the UTF-8 encoded JSON string [jsonBytes] to a [JsonAny].
///
/// Throws a [FormatException] if the input cannot be parsed as JSON.
JsonAny? parseUtf8Json(Uint8List jsonBytes) {
  // TODO
  throw UnimplementedError();
}


class _JsonTypeError extends TypeError {
  final String _type;
  _JsonTypeError(this._type);
  @override
  String toString() => 'TypeError: Value is not a $_type';
}

// JsonAny types.

/// An unknown JSON value.
///
/// Use any of the `as...` method to check if the value is of that type,
/// which it is if the returned value is not `null`,
/// then use that value.
extension type JsonAny._(JSAny _) {
  static JsonAny? _from(JSAny? value) => value as JsonAny?;

  JsonString? get tryAsString => _ is JSString ? JsonString._(_) : null;
  JsonNum? get tryAsNum => _ is JSNumber ? JsonNum._(_) : null;
  JsonBool? get tryAsBool => _ is JSBoolean ? JsonBool._(_) : null;
  JsonList? get tryAsList => _ is JSArray ? JsonList._(_) : null;
  JsonMap? get tryAsMap => _ is JSObject && _ is! JSArray ? JsonMap._(_) : null;

  JsonString get asString => tryAsString ?? (throw _JsonTypeError('String'));
  JsonNum get asNum => tryAsNum ?? (throw _JsonTypeError('num'));
  JsonBool get asBool => tryAsBool ?? (throw _JsonTypeError('bool'));
  JsonList get asList => tryAsList ?? (throw _JsonTypeError('List'));
  JsonMap get asMap => tryAsMap ?? (throw _JsonTypeError('Map'));
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

extension type const JsonString._(JSString _) {
  /// The string value of this JSON string.
  String get value => _.toDart;

  /// Converts this string to an integer.
  ///
  /// Succeeds if [int.parse] can parse the string.
  int get toInt {
    return int.parse(value);
  }

  /// Converts this string to a [double].
  ///
  /// Succeeds if [double.parse] can parse the string.
  double get toDouble {
    return double.parse(value);
  }

  /// Converts this string to a [bool].
  ///
  /// Returns `true` if [value] is `"true"` and `false` otherwise.
  /// If [yes] is provided, that string will return `true` instead.
  /// If [no] is provided, only that string will return `false`,
  /// and a [FormatException] is thrown if [value] is neither [yes] nor [no].
  bool toBool({String yes = 'true', String? no}) {
    var value = this.value;
    return value == yes ||
        no == null ||
        value == no ||
        (throw FormatException("Neither '$yes' nor '$no'", _));
  }
}

extension type const JsonBool._(JSBoolean _) {
  /// The boolean value of this JSON boolean.
  bool get value => _.toDart;
}

extension type const JsonNum._(JSNumber _) {
  /// This number as a Dart integer.
  int get toInt => _.toDartInt;

  /// This number as a Dart [double].
  double get toDouble => _.toDartDouble;
}

extension type const JsonList._(JSArray<JSAny?> _) {
  JSAny? _get(int index) {
    if (index >= 0) {
      var result = _[index];
      if (result != null || index < length) {
        return result;
      }
    }
    throw IndexError.withLength(index, length);
  }

  /// Whether this JSON list is empty.
  bool get isEmpty => length == 0;

  /// Whether this JSON list is non-empty.
  bool get isNotEmpty => length != 0;

  /// The number of elements in this JSON list.
  int get length => _.length;

  /// Looks up the value at position [index] in this list and returns its value.
  ///
  /// The [index] must be a valid index, 0 &le; `index` &lt; [length].
  JsonAny? operator [](int index) => JsonAny._from(_get(index));

  /// Reads a string value at position [index].
  ///
  /// The [index] must be a valid index, 0 &le; `index` &lt; [length].
  /// The value at position [index] must be a JSON string.
  JsonString stringAt(int index) =>
      this[index]?.tryAsString ?? (throw _JsonTypeError('String'));

  /// Reads a number value at position [index].
  ///
  /// The [index] must be a valid index, 0 &le; `index` &lt; [length].
  /// The value at position [index] must be a JSON number.
  JsonNum numAt(int index) =>
      this[index]?.tryAsNum ?? (throw _JsonTypeError('num'));

  /// Reads a boolean value at position [index].
  ///
  /// The [index] must be a valid index, 0 &le; `index` &lt; [length].
  /// The value at position [index] must be a JSON boolean.
  JsonBool boolAt(int index) =>
      this[index]?.tryAsBool ?? (throw _JsonTypeError('bool'));

  /// Reads a list value at position [index].
  ///
  /// The [index] must be a valid index, 0 &le; `index` &lt; [length].
  /// The value at position [index] must be a JSON list.
  JsonList listAt(int index) =>
      this[index]?.tryAsList ?? (throw _JsonTypeError('List'));

  /// Reads a map value at position [index].
  ///
  /// The [index] must be a valid index, 0 &le; `index` &lt; [length].
  /// The value at position [index] must be a JSON map.
  JsonMap mapAt(int index) =>
      this[index]?.tryAsMap ?? (throw _JsonTypeError('Map'));

  /// Converts this `JsonMap` to a Dart map.
  ///
  /// This may require some computation, and it does not recursively
  /// transform the elements of the list.
  List<JsonAny?> toList() => _.toDart as List<JsonAny?>;
}

extension type const JsonMap._(JSObject _) {
  /// Looks up [key] in this map and returns its value.
  ///
  /// If the key is not in this map, when [containsKey] returns false, then
  /// `null` is returned. Since a key's value can be `null`, it may be necessary
  /// to use [containsKey] to check if a `null` represents a key with a `null`
  /// value, or no key, if the distinction matters.
  JsonAny? operator [](String key) =>
      JsonAny._from(_.getProperty<JSAny?>(key.toJS));

  /// Reads a string value for [key].
  ///
  /// The [key] must be a key of this JSON map, and
  /// the value for [key] must be a JSON string.
  JsonString stringAt(String key) =>
      this[key]?.tryAsString ?? (throw _JsonTypeError('String'));

  /// Reads a number value for [key].
  ///
  /// The [key] must be a key of this JSON map, and
  /// the value for [key] must be a JSON number.
  JsonNum numAt(String key) =>
      this[key]?.tryAsNum ?? (throw _JsonTypeError('num'));

  /// Reads a boolean value for [key].
  ///
  /// The [key] must be a key of this JSON map, and
  /// the value for [key] must be a JSON boolean.
  JsonBool boolAt(String key) =>
      this[key]?.tryAsBool ?? (throw _JsonTypeError('bool'));


  /// Reads a list value for [key].
  ///
  /// The [key] must be a key of this JSON map, and
  /// the value for [key] must be a JSON list.
  JsonList listAt(String key) =>
      this[key]?.tryAsList ?? (throw _JsonTypeError('List'));


  /// Reads a map value for [key].
  ///
  /// The [key] must be a key of this JSON map, and
  /// the value for [key] must be a JSON map.
  JsonMap mapAt(String key) =>
      this[key]?.tryAsMap ?? (throw _JsonTypeError('Map'));



  /// The keys of this JSON map, in no guaranteed order.
  List<String> get keys {
    var keys = _objectKeys(_);
    return [
      for (var i = 0, n = keys.length; i < n; i++)
        _.getProperty<JSString>(i.toJS).toDart
    ];
  }

  /// Whether this JSON map contains [key] as a key.
  bool containsKey(String key) => _objectHasKey(_, key);

  /// Converts this `JsonMap` to a Dart map.
  ///
  /// This may require some computation, and it does not recursively
  /// transform the values of the map.
  Map<String, JsonAny?> toMap() {
    var entries = _objectEntries(_);
    return {
      for (var i = 0, n = entries.length; i < n; i++)
        if (entries[i] case var entry)
          entry.getProperty<JSString>(0.toJS).toDart: JsonAny._from(entry[1])
    };
  }
}
