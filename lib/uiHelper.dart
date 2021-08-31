import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Custom{
  static const Color light = Color.fromRGBO(235, 235, 235, 1);
  static const Color light2 = Color.fromRGBO(184, 184, 184, 1.0);
  static const Color dark = Color.fromRGBO(67, 70, 76, 1);
  static const Color dark2 = Color.fromRGBO(86, 90, 97, 1.0);
  static const Color error = Color.fromRGBO(208,0,0, 1);
  static const Color success = Color.fromRGBO(96,153,45,1);
  static const Color highlight = Color.fromRGBO(224, 109, 6, 1);
  static const Color empty = Color.fromRGBO(0, 0, 0, 0);

  static const BoxShadow boxShadow = BoxShadow( offset: Offset(0, 1), blurRadius: 0, spreadRadius: 0);
  static String theme = "dark";

  static Text newText(String value, {Color color = empty, double size = 30, TextDecoration decoration = TextDecoration.none, TextAlign align = TextAlign.justify}){
    if(color == empty){
      color = foreground;
    }
    return Text(value, style: TextStyle(color: color, fontSize: size, decoration:  decoration), textAlign: align,);
  }
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
            newText(snapshot.error.toString(), color: error, size: 10.0)
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
  static Color get secondary2{
    if(theme == "dark"){
      return dark2;
    }else{
      return light2;
    }
  }
}