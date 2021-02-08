import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File file;

  captureImageWithCamera()async{  //이벤트등록
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 680,
      maxWidth: 970
    );
    setState(() {
      this.file = imageFile;
    });
  }

  pickImageFromGallery() async{
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(
        source: ImageSource.gallery,
    );
    setState(() {
      this.file = imageFile;
    });
  }

  takeImage(mContext){
    return showDialog(                      //다이어로그를 보여준다
      context: mContext,
      builder: (context){
        return SimpleDialog(                 //심플 다이어로그
          title: Text('New Post',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
          children: [
            SimpleDialogOption(
              child: Text('Capture Image with Camera',style: TextStyle(color: Colors.white), ),
              onPressed: captureImageWithCamera,     //클릭하면 휴대전화의 카메라를 열 수 있는 메소드
            ),
            SimpleDialogOption(
              child: Text('Select Image from Gallery',style: TextStyle(color: Colors.white), ),
              onPressed: pickImageFromGallery,     //클릭하면 휴대전화의 카메라를 열 수 있는 메소드
            ),
            SimpleDialogOption(
              child: Text('Cancel',style: TextStyle(color: Colors.white), ),
              onPressed: ()=>Navigator.pop(context),     //클릭하면 휴대전화의 카메라를 열 수 있는 메소드
            ),
          ],
        );
      }
    );
  }

  displayUploadScreen() {
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate,color: Colors.grey,size: 200,),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9.0),),
              child: Text("Upload Images",style: TextStyle(color: Colors.white,fontSize: 20,),),
              color: Colors.green,
              onPressed: () => takeImage(context),    //이미지를 가지고오는 메소드
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return displayUploadScreen();
  }
}
