import 'dart:math';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

double toPrecision(double value, {int precision = 1}){
  double factor = pow(10, precision).toDouble();
  value *= factor;
  value = value.roundToDouble();
  value = value/factor;
  return value;
}
String toDegreeFormat(double angle){
  String out = "";

  double value = angle.floorToDouble();
  out += value.toString() + "° ";
  angle = (angle.abs() - value) * 60;
  value = angle.floorToDouble();
  out += value.toString() + "' ";
  angle = (angle - value) * 60;
  value = angle.floorToDouble();
  out += value.toString() + "''";
  return out;
}

String speedToString(double? value, String unit, {double conversion = 1}){
  if(value == null){
    return "-- "+unit;
  }else{
    return toPrecision(value*conversion).toString()+" "+unit;
  }
}

Future<Map<String, String>> readSusfile(String assetFilename) async{
  final directory = await getApplicationDocumentsDirectory();
  final file = File(directory.path+"/"+assetFilename+".sus");
  final lines = await file.readAsLines();
  Map<String, String> data = {};
  List record;
  for(String line in lines){
    record = line.split(":");
    data[record[0].toString().trim()] = record[1].toString().trim();
  }
  return data;
}

Future<void> saveSusfile(String assetFilename, Map<String, String> data) async{
  final directory = await getApplicationDocumentsDirectory();
  final file = File(directory.path+"/"+assetFilename+".sus");
  String text = "";
  for(String key in data.keys){
    text += key+":"+data[key]!+"\n";//null value could make it crash
  }
  await file.writeAsString(text);
}