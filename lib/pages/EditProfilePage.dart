import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta/Widgets/progress_widget.dart';
import 'package:flutter_insta/models/user.dart';
import 'package:flutter_insta/pages/homepage.dart';

class EditProfilePage extends StatefulWidget {
  final String currentOnlineUserId;

  EditProfilePage({this.currentOnlineUserId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController profileTextEditingController = TextEditingController();
  TextEditingController bioTextEditingController = TextEditingController();
  final _scaffoldGlobalkey = GlobalKey<ScaffoldState>(); //스캐폴드 전역키
  bool loading = false; //로딩중이냐?
  User user; //User Bean을 선언
  bool _bioValid = true;
  bool _profileNameValid = true;


  void initState(){         //앱이 시작되기전에 젤 처음 시작되는 메소드
    super.initState();

    getAndDisplayUserInfomation();
  }

  getAndDisplayUserInfomation() async {
    setState(() {
      loading = true;
    });
    DocumentSnapshot documentSnapshot = await userReference.document(widget.currentOnlineUserId).get();
    //도큐먼트 스냅샷으로 userreperce를 참조하여 현재 currentid를 가지고옴
    user = User.formDocument(documentSnapshot);
    //user에 documentsnapshot 정보를 넣어줌

    profileTextEditingController.text = user.profileName;     //에디트부분에 바로 profilename이 입력되도록
    bioTextEditingController.text = user.bio;

    setState(() {
      loading = false;
    });


  }




  updateUserData(){
    setState(() {
      profileTextEditingController.text.trim().length < 3 || profileTextEditingController.text.isEmpty ?
      _profileNameValid = false : _profileNameValid = true;

      bioTextEditingController.text.trim().length > 110 ? _bioValid = false : _bioValid = true;

      if(_bioValid && _profileNameValid){
        userReference.document(widget.currentOnlineUserId).updateData({
          "profileName" : profileTextEditingController.text,
          "bio" : bioTextEditingController.text,
        });

        SnackBar snackBar = SnackBar(content: Text("Profile has been updated successfully"));
        _scaffoldGlobalkey.currentState.showSnackBar(snackBar);

      }


    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldGlobalkey,                          //key 글로벌키 선언
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white70),
        title: Text("Edit Profile",style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(icon: Icon(Icons.done,color: Colors.white,size: 30,),
              onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: loading ? circularProgress() : ListView(
        children: [
          Container(
            child: Column(
              children: [
                Padding(padding: EdgeInsets.only(top: 15,bottom: 7),
                child: CircleAvatar(
                  radius: 52,
                  // backgroundImage: CachedNetworkImageProvider(user.url),
                ),
                ),
                Padding(padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      createProfileNameTextFormField(),     //프로필 네임 수정하는 필드
                      createBioTextFormField(),                //bio수정필드
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 29,left: 50,right: 50),
                  child: Container(
                    width: 200,
                    child: RaisedButton(
                      onPressed: updateUserData,
                      child: Text('Update',style: TextStyle(color: Colors.black,fontSize: 16),),
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 10,left: 50,right: 50),
                  child: Container(
                    width: 200,
                    child: RaisedButton(
                      onPressed: logoutUser,
                      child: Text('Logout',style: TextStyle(color: Colors.red,fontSize: 14),),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      )
    );
  }


  logoutUser()async{
    await gSign.signOut();
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>HomePage()), (route) => false);
  }

  Column createProfileNameTextFormField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:EdgeInsets.only(top: 13),
          child: Text("Profile Name",style: TextStyle(color: Colors.grey),),
        ),
        TextField(
          controller: profileTextEditingController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Write Profile name here",
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            hintStyle: TextStyle(color: Colors.grey),
            errorText: _profileNameValid ? null : "profile name is very short",
          ),
        ),
      ],
    );
  }

  Column createBioTextFormField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:EdgeInsets.only(top: 13),
          child: Text("Bio",style: TextStyle(color: Colors.grey),),
        ),
        TextField(
          controller: bioTextEditingController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Write Bio here",
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            hintStyle: TextStyle(color: Colors.grey),
            errorText: _bioValid ? null : "Bio is very long",
          ),
        ),
      ],
    );
  }
}
