import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



class Custom{
  static const Color white = Color.fromRGBO(235, 235, 235, 1);
  static const Color light_grey = Color.fromRGBO(184, 184, 184, 1.0);
  static const Color dark_grey = Color.fromRGBO(67, 70, 76, 1);
  static const Color grey = Color.fromRGBO(86, 90, 97, 1.0);
  static const Color error = Color.fromRGBO(208,0,0, 1);
  static const Color success = Color.fromRGBO(96,153,45,1);
  static const Color orange = Color.fromRGBO(224, 109, 6, 1);
  static const Color empty = Color.fromRGBO(0, 0, 0, 0);

  static const BoxShadow boxShadow = BoxShadow( offset: Offset(0, 1), blurRadius: 0, spreadRadius: 0);
  static String theme = "dark";


  static Container newAutoText(String value, BuildContext context, {Color color = empty, double fontSize = 30, TextDecoration decoration = TextDecoration.none, TextAlign align = TextAlign.left
  , double? heightScale, double? widthScale, int maxLines = 1}){
    if(color == empty){
      color = foreground;
    }
    Size size = MediaQuery.of(context).size;
    if(widthScale != null)widthScale = size.width * widthScale;
    if(heightScale != null)heightScale = size.height * heightScale;
    return Container(
      width: widthScale ,
      height: heightScale,
      child: FittedBox(
        child: Text(value, style: TextStyle(color: color, fontSize: fontSize, decoration:  decoration), maxLines: maxLines, textAlign: align,)
      ),
    );
  }

  static FutureBuilder<Widget> newAsyncWidget(Future<Widget> target){
    return FutureBuilder(future: target, builder: (BuildContext context, AsyncSnapshot<Widget> snapshot){
      if(snapshot.hasData){
        return snapshot.data!;
      }else if(snapshot.hasError){
        return Center(child: Container( child : Column(
          children: [
            Icon(Icons.warning, color: foreground,),
            Text(snapshot.error.toString(), style: TextStyle(fontSize: 10, color: Custom.error), textAlign: TextAlign.justify)
          ],
        ),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), border: Border.all(color: foreground)),
        ));
      }else{
        return Center(child: LinearProgressIndicator(backgroundColor: background, valueColor: AlwaysStoppedAnimation<Color>(foreground)));
      }
    });
  }

  static Widget newMapInfoRow(String fieldName, String fieldValue, double max){
    return Padding(
      padding: EdgeInsets.fromLTRB(0, max*0.02, 0, 0),
      child:Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(fieldName, style: TextStyle(fontSize: max*0.030, color: Custom.secondary)),
          Flexible(child: Text(fieldValue, style: TextStyle(fontSize: max*0.03, color: Custom.foreground), maxLines: 2, textAlign: TextAlign.end,),)
        ],
      )
    );
  }

  static Widget debugBox(Widget child, {Color color = Colors.white}){
    return Container(
    color: color,
    child: child,
    );
  }

  static MaterialColor toMaterialColor(Color color){
    Map<int,Color> swatch = {
      50:color.withOpacity(0.1),
      100:color.withOpacity(0.2),
      200:color.withOpacity(0.3),
      300:color.withOpacity(0.4),
      400:color.withOpacity(0.5),
      500:color.withOpacity(0.6),
      600:color.withOpacity(0.7),
      700:color.withOpacity(0.8),
      800:color.withOpacity(0.9),
      900:color.withOpacity(1),
    };
    return MaterialColor(color.value, swatch);
  }

  static Color get background{
    if(theme == "dark"){
      return dark_grey;
    }else{
      return white;
    }
  }
  static Color get foreground{
    if(theme == "dark"){
      return white;
    }else{
      return dark_grey;
    }
  }
  static Color get secondary{
    if(theme == "dark"){
      return light_grey;
    }else{
      return grey;
    }
  }
  static Color get secondary2{
    if(theme == "dark"){
      return grey;
    }else{
      return light_grey;
    }
  }
}