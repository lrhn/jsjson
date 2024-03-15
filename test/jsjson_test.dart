// ignore_for_file: prefer_single_quotes

import 'package:jsjson/jsjson.dart';
import 'package:test/test.dart';

void main() {
  const hasJS = bool.fromEnvironment('dart.library.js_interop');
  print("Mode: ${hasJS ? "JS" : "Dart"}");
  test('mode is ${hasJS ? 'JS' : 'Dart'}', () {
    expect(jsjsonMode, hasJS ? 'JS' : 'Dart');
  });
  test('testParse1', () {
    var src = '{"x": [1, 2, true, null, ["banana"]], "y": 3.14, "z": 1.0}';
    var srcJS = '{"x": [1, 2, true, null, ["banana"]], "y": 3.14, "z": 1}';
    var js = parseJson(src);
    if (js case JsonMap map) {
      var v1 = map.listAt('x');
      var v2 = map.numAt('y').toDouble;
      var v3 = map.numAt('z').toDouble;

      var i1 = v1[0]!.asNum.toInt;
      var i2 = v1.numAt(1).toInt;
      var i3 = v1[2].asBool.value;
      var i4 = v1[3] as Null;
      var i5 = v1[4].asList;
      var i51 = i5[0].asString;
      var banana = i51.value;

      var rebuild =
          '{"x": [$i1, $i2, $i3, $i4, ["$banana"]], "y": $v2, "z": $v3}';

      expect(rebuild, isIn([src, srcJS]));
    }
  });

  group('correct type', () {
    test('null', () {
      var value = parseJson('null');
      expect(value, null);
      // Extension methods.
      expect(value.tryAsString, null);
      expect(value.tryAsBool, null);
      expect(value.tryAsNum, null);
      expect(value.tryAsList, null);
      expect(value.tryAsMap, null);

      expect(() => value.asString, throwsA(isA<TypeError>()));
      expect(() => value.asBool, throwsA(isA<TypeError>()));
      expect(() => value.asNum, throwsA(isA<TypeError>()));
      expect(() => value.asList, throwsA(isA<TypeError>()));
      expect(() => value.asMap, throwsA(isA<TypeError>()));
    });
    test('String', () {
      var value = parseJson('"string"');
      expect(value, isNotNull);

      // Calling extension method.

      expect(value.tryAsBool, null);
      expect(value.tryAsNum, null);
      expect(value.tryAsList, null);
      expect(value.tryAsMap, null);

      expect(() => value.asBool, throwsA(isA<TypeError>()));
      expect(() => value.asNum, throwsA(isA<TypeError>()));
      expect(() => value.asList, throwsA(isA<TypeError>()));
      expect(() => value.asMap, throwsA(isA<TypeError>()));

      var tryAsString = value.tryAsString;
      expect(tryAsString, isNotNull);
      expect(tryAsString!.value, 'string');
      var asString = value.asString;
      expect(asString.value, 'string');

      value!; // Calling non-extension method.

      expect(value.tryAsBool, null);
      expect(value.tryAsNum, null);
      expect(value.tryAsList, null);
      expect(value.tryAsMap, null);

      expect(() => value!.asBool, throwsA(isA<TypeError>()));
      expect(() => value!.asNum, throwsA(isA<TypeError>()));
      expect(() => value!.asList, throwsA(isA<TypeError>()));
      expect(() => value!.asMap, throwsA(isA<TypeError>()));

      tryAsString = value.tryAsString;
      expect(tryAsString, isNotNull);
      expect(tryAsString!.value, 'string');
      asString = value.asString;
      expect(asString.value, 'string');
    });
    test('Number - int', () {
      var value = parseJson('42');
      expect(value, isNotNull);

      // Calling extension method.

      expect(value.tryAsString, null);
      expect(value.tryAsBool, null);
      expect(value.tryAsList, null);
      expect(value.tryAsMap, null);

      expect(() => value.asString, throwsA(isA<TypeError>()));
      expect(() => value.asBool, throwsA(isA<TypeError>()));
      expect(() => value.asList, throwsA(isA<TypeError>()));
      expect(() => value.asMap, throwsA(isA<TypeError>()));

      var tryAsNum = value.tryAsNum;
      expect(tryAsNum, isNotNull);
      expect(tryAsNum!.toInt, 42);
      expect(tryAsNum!.toDouble, 42.0);
      var asNum = value.asNum;
      expect(asNum!.toInt, 42);
      expect(asNum!.toDouble, 42.0);

      value!; // Calling non-extension method.

      expect(value.tryAsString, null);
      expect(value.tryAsBool, null);
      expect(value.tryAsList, null);
      expect(value.tryAsMap, null);

      expect(() => value!.asString, throwsA(isA<TypeError>()));
      expect(() => value!.asBool, throwsA(isA<TypeError>()));
      expect(() => value!.asList, throwsA(isA<TypeError>()));
      expect(() => value!.asMap, throwsA(isA<TypeError>()));

      tryAsNum = value.tryAsNum;
      expect(tryAsNum, isNotNull);
      expect(tryAsNum!.toInt, 42);
      expect(tryAsNum!.toDouble, 42.0);
      asNum = value.asNum;
      expect(asNum!.toInt, 42);
      expect(asNum!.toDouble, 42.0);
    });
    test('Number - float', () {
      var value = parseJson('3.14');
      expect(value, isNotNull);

      // Calling extension method.

      expect(value.tryAsString, null);
      expect(value.tryAsBool, null);
      expect(value.tryAsList, null);
      expect(value.tryAsMap, null);

      expect(() => value.asString, throwsA(isA<TypeError>()));
      expect(() => value.asBool, throwsA(isA<TypeError>()));
      expect(() => value.asList, throwsA(isA<TypeError>()));
      expect(() => value.asMap, throwsA(isA<TypeError>()));

      var tryAsNum = value.tryAsNum;
      expect(tryAsNum, isNotNull);
      //expect(tryAsNum!.toInt, 3);
      expect(tryAsNum!.toDouble, 3.14);
      var asNum = value.asNum;
      //expect(asNum!.toInt, 3);
      expect(asNum!.toDouble, 3.14);

      value!; // Calling non-extension method.

      expect(value.tryAsString, null);
      expect(value.tryAsBool, null);
      expect(value.tryAsList, null);
      expect(value.tryAsMap, null);

      expect(() => value!.asString, throwsA(isA<TypeError>()));
      expect(() => value!.asBool, throwsA(isA<TypeError>()));
      expect(() => value!.asList, throwsA(isA<TypeError>()));
      expect(() => value!.asMap, throwsA(isA<TypeError>()));

      tryAsNum = value.tryAsNum;
      expect(tryAsNum, isNotNull);
      expect(tryAsNum!.toInt, 3);
      expect(tryAsNum!.toDouble, 3.14);
      asNum = value.asNum;
      expect(asNum!.toInt, 3);
      expect(asNum!.toDouble, 3.14);
    });
    test('bool', () {
      var value = parseJson('true');
      expect(value, isNotNull);

      // Calling extension method.

      expect(value.tryAsString, null);
      expect(value.tryAsNum, null);
      expect(value.tryAsList, null);
      expect(value.tryAsMap, null);

      expect(() => value.asString, throwsA(isA<TypeError>()));
      expect(() => value.asNum, throwsA(isA<TypeError>()));
      expect(() => value.asList, throwsA(isA<TypeError>()));
      expect(() => value.asMap, throwsA(isA<TypeError>()));

      var tryAsBool = value.tryAsBool;
      expect(tryAsBool, isNotNull);
      expect(tryAsBool!.value, true);
      var asBool = value.asBool;
      expect(asBool.value, true);

      value!; // Calling non-extension method.

      expect(value.tryAsString, null);
      expect(value.tryAsNum, null);
      expect(value.tryAsList, null);
      expect(value.tryAsMap, null);

      expect(() => value!.asString, throwsA(isA<TypeError>()));
      expect(() => value!.asNum, throwsA(isA<TypeError>()));
      expect(() => value!.asList, throwsA(isA<TypeError>()));
      expect(() => value!.asMap, throwsA(isA<TypeError>()));

      tryAsBool = value.tryAsBool;
      expect(tryAsBool, isNotNull);
      expect(tryAsBool!.value, true);
      asBool = value.asBool;
      expect(asBool.value, true);
    });
    test('List', () {
      var value = parseJson('[]');
      expect(value, isNotNull);

      // Calling extension method.

      expect(value.tryAsString, null);
      expect(value.tryAsBool, null);
      expect(value.tryAsNum, null);
      expect(value.tryAsMap, null);

      expect(() => value.asString, throwsA(isA<TypeError>()));
      expect(() => value.asBool, throwsA(isA<TypeError>()));
      expect(() => value.asNum, throwsA(isA<TypeError>()));
      expect(() => value.asMap, throwsA(isA<TypeError>()));

      var tryAsList = value.tryAsList;
      expect(tryAsList, isNotNull);
      expect(tryAsList!.length, 0);
      var asList = value.asList;
      expect(asList.length, 0);

      value!; // Calling non-extension method.

      expect(value.tryAsString, null);
      expect(value.tryAsBool, null);
      expect(value.tryAsNum, null);
      expect(value.tryAsMap, null);

      expect(() => value!.asString, throwsA(isA<TypeError>()));
      expect(() => value!.asBool, throwsA(isA<TypeError>()));
      expect(() => value!.asNum, throwsA(isA<TypeError>()));
      expect(() => value!.asMap, throwsA(isA<TypeError>()));

      tryAsList = value.tryAsList;
      expect(tryAsList, isNotNull);
      expect(tryAsList!.length, 0);
      asList = value.asList;
      expect(asList.length, 0);
    });
    test('Map', () {
      var value = parseJson('{}');
      expect(value, isNotNull);

      // Calling extension method.

      expect(value.tryAsString, null);
      expect(value.tryAsBool, null);
      expect(value.tryAsNum, null);
      expect(value.tryAsList, null);

      expect(() => value.asString, throwsA(isA<TypeError>()));
      expect(() => value.asBool, throwsA(isA<TypeError>()));
      expect(() => value.asNum, throwsA(isA<TypeError>()));
      expect(() => value.asList, throwsA(isA<TypeError>()));

      var tryAsMap = value.tryAsMap;
      expect(tryAsMap, isNotNull);
      expect(tryAsMap!.keys, isEmpty);
      var asMap = value.asMap;
      expect(asMap.keys, isEmpty);

      value!; // Calling non-extension method.

      expect(value.tryAsString, null);
      expect(value.tryAsBool, null);
      expect(value.tryAsNum, null);
      expect(value.tryAsList, null);

      expect(() => value!.asString, throwsA(isA<TypeError>()));
      expect(() => value!.asBool, throwsA(isA<TypeError>()));
      expect(() => value!.asNum, throwsA(isA<TypeError>()));
      expect(() => value!.asList, throwsA(isA<TypeError>()));

      tryAsMap = value.tryAsMap;
      expect(tryAsMap, isNotNull);
      expect(tryAsMap!.keys, isEmpty);
      asMap = value.asMap;
      expect(asMap.keys, isEmpty);
    });
  });
  test('Array is not Object', () {
    var array = parseJson('[]');
    expect(array.tryAsMap, null);
    expect(array.tryAsList, isNotNull);

    var object = parseJson('{}');
    expect(object.tryAsMap, isNotNull);
    expect(object.tryAsList, null);
  });
}
