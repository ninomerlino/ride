import 'dart:math';

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
