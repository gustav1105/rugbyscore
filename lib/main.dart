import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rugbyscore/ui/home.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  var data = await readData();
  debugPrint(data);
  runApp(new MaterialApp(
    title:'rugbyscore',
    home: new Home(),
  ));
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return new File('$path/data.txt');
}

Future<String> readData() async {

  try {
    final file = await _localFile;
    String data = await file.readAsString();
    return data;
  }catch($e) {
    return "error";
  }
}