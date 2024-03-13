import 'package:jsjson/jsjson.dart';
import 'package:test/test.dart';

void main() {
  const hasJS = const bool.fromEnvironment('dart.library.js_interop');
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

  test('Array is object?', () {
    var array = parseJson('[42]');
    if (array.tryAsMap != null) {
      fail('Should not happen');
    }
  });
}
