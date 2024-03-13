// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A platform specialized JSON parser.
///
/// Uses the native JavaScript `JSON.parse` when available,
/// otherwise falls back on the default Dart JSON parser.
///
/// Exposes JSON values using an API that abstracts over the differences.
library;

export 'src/json.dart' if (dart.library.js_interop) 'src/js_json.dart';
