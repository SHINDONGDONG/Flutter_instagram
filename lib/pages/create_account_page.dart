import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_insta/Widgets/hader_widget.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>(); //스캐폴드키
  final _formKey = GlobalKey<FormState>(); //폼 키
  var username;

  submitUsername() {
    //입력받은 form데이터를 submit하는 메소드
    final form = _formKey.currentState; //현재 입력받은 폼키의 커런트 스테이트를 대입
    if (form.validate()) {
      //현재 입력받은 폼에 데이터가 있으면
      form.save(); //폼 세이브함
      SnackBar snackBar = SnackBar(
        content: Text('Wellcome to ${username}'),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
      Timer(Duration(seconds: 4),(){                       //타이머를 지정해주어 4초뒤 네비게이터로 페이지이동
        Navigator.pop(context,username);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, //스케폴드 키 지정
      appBar:
          header(context, strTitle: "Settings", disappreareeBackButton: true),
      body: ListView(
        children: [
          Container(
            child: Column(children: [
              Padding(
                padding: EdgeInsets.only(top: 26.0),
                child: Center(
                  child: Text(
                    'Set up a username',
                    style: TextStyle(fontSize: 26.0),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(17),
                child: Container(
                  child: Form(
                    key: _formKey, //폼키 지정
                    autovalidate: true,
                    child: TextFormField(
                      style: TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value.trim().length < 5 || value.isEmpty) {
                          //ID가 5자보다 짧거나 공백이면
                          return "user name is verry short.";
                        } else if (value.trim().length > 15) {
                          return "user name is verry long.";
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) => username = value,
                      decoration: InputDecoration(
                        //아이디 입력창 데코레이션
                        enabledBorder: UnderlineInputBorder(
                          //포커스가 되어있지 않은 보더값을 밑줄인풋 보더로
                          borderSide:
                              BorderSide(color: Colors.grey), //보더사이드 컬러를 그레이
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white), //클릭되면 화이트로 돌아오게함.
                        ),
                        border: OutlineInputBorder(),
                        labelText: "Username",
                        labelStyle: TextStyle(fontSize: 16.0),
                        hintText: "5자 이상 입력해주세요.",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                  onTap: submitUsername,
                  child: Container(
                    height: 55.0,
                    width: 360.0,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(
                      child: Text(
                        'Proceed',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )),
            ]),
          )
        ],
      ),
    );
  }
}
