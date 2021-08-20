import 'package:flutter/material.dart';

class Custom{
  static const Color light = Color.fromRGBO(255,209,102, 1);
  static const Color light2 = Color.fromRGBO(194, 157, 77, 1.0);
  static const Color dark = Color.fromRGBO(28,49,68, 1);
  static const Color dark2 = Color.fromRGBO(66, 73, 97, 1.0);
  static const Color error = Color.fromRGBO(208,0,0, 1);
  static const Color success = Color.fromRGBO(96,153,45,1);
  static const Color highlight = Color.fromRGBO(224, 109, 6, 1);
  static const Color empty = Color.fromRGBO(0, 0, 0, 0);
  static String theme = "dark";

  static Text newText(String value, {Color color = empty, double size = 30, TextDecoration decoration = TextDecoration.none}){
    if(color == empty){
      color = foreground;
    }
    return Text(value, style: TextStyle(color: color, fontSize: size, decoration:  decoration));
  }
  static Container newTile(Widget child, {String? title, double titleSize = 10, int flexPriority = 1}){
    if(title != null){
      child = Column(children: [
        child,
        Container(margin: EdgeInsets.fromLTRB(0, titleSize, 0, 0,)
      ],
      );
    }
    return Container(
        child: Expanded(
          flex: flexPriority,
          child: Center(child: child),
        ),
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(shape: BoxShape.rectangle),
    );
  }

  static FutureBuilder<Widget> newAsyncWidget(Future<Widget> target, String errorMessage){
    return FutureBuilder(future: target, builder: (BuildContext context, AsyncSnapshot<Widget> snapshot){
      if(snapshot.hasData){
        return snapshot.data!;
      }else if(snapshot.hasError){
        return Center(child: newTile(Column(
          children: [
            Icon(Icons.warning, color: foreground,),
            newText(errorMessage, color: error, size: 10.0)
          ],
        )));
      }else{
        return Center(child: LinearProgressIndicator(backgroundColor: background, valueColor: AlwaysStoppedAnimation<Color>(foreground)));
      }
    });
  }

  static Color get background{
    if(theme == "dark"){
      return dark;
    }else{
      return light;
    }
  }
  static Color get foreground{
    if(theme == "dark"){
      return light;
    }else{
      return dark;
    }
  }
  static Color get secondary{
    if(theme == "dark"){
      return light2;
    }else{
      return dark2;
    }
  }
}