import 'package:flutter/material.dart';
              //컨텍스트만 리콰이어드
AppBar header(context, {bool isAppTitle=false, String strTitle, disappreareeBackButton = false}){

  return AppBar(
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    automaticallyImplyLeading: disappreareeBackButton ? false : true, //앱바에 뒤로가기 버튼을 없앰
    title: Text(
      isAppTitle ? "Instagram" : strTitle,
      style: TextStyle(
        color: Colors.white,
        fontFamily: isAppTitle ? "Signatra" : "",
        fontSize: isAppTitle ? 45.0 : 22.0,
      ),
      overflow: TextOverflow.ellipsis,       //텍스트가 길어지면 ...으로 표현해줌.
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );

}