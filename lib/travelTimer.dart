class TravelTimer{//
  Duration _timer = Duration(seconds: 0);
  DateTime? _start;
  bool _running = false;

  bool get running{
    return _running;
  }
  int get count{
    if(running){
      DateTime now = DateTime.now();
      _timer += now.difference(_start!);
      _start = now;
    }
    return _timer.inSeconds;
  }
  void start(){
    _running = true;
    _start = DateTime.now();
  }
  void stop(){
    if(_start != null){
      _running = false;
      _timer += DateTime.now().difference(_start!);
    }
  }
  void reset(){
    _timer = Duration(seconds: 0);
  }
}