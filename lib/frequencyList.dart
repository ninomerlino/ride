import 'common.dart';

class FrequencyList{//the structure stores a list of values and the frequencies they are present in the list
  Map<double, int> _data = Map();
  double? _last;
  double? _max;
  double _total = 0;

  void reset(){
    _data.clear();
    _last = null;
    _max = null;
    _total = 0;
  }

  void push(double? value){
    if(value == null){
      _last = null;
      return;
    }
    value = toPrecision(value);
    _last = value;
    _total += value;
    if(_max == null || value > _max!)_max = value;
    if(_data.containsKey(value)){
      _data[value] = _data[value]! + 1;
    }else{
      _data[value] = 1;
    }
  }
  double? get last{
    return _last;
  }
  double? get max{
    return _max;
  }
  double? get avg{
    int n = 0;
    for(int samples in _data.values)n += samples;
    if(n == 0)return null;
    return toPrecision(_total / n);
  }
  double get total{
    return _total;
  }
}