import 'dart:convert';

import 'package:appflowy_backend/log.dart';
import 'package:flutter/material.dart';

const JsonEncoder _encoder = JsonEncoder.withIndent('  ');
void prettyPrintJson(Object? object) {
  Log.trace(_encoder.convert(object));
  debugPrint('ABC: ${_encoder.convert(object)}');
}
