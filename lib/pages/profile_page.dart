import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta/Widgets/hader_widget.dart';
import 'package:flutter_insta/Widgets/progress_widget.dart';
import 'package:flutter_insta/models/user.dart';
import 'package:flutter_insta/pages/EditProfilePage.dart';
import 'package:flutter_insta/pages/homepage.dart';

class ProfilePage extends StatefulWidget {
  final String userProfileId;

  ProfilePage({this.userProfileId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
 final String currentOnlineUserId = currenUser?.id;

  createProfileTopViwe(){
    return FutureBuilder(                   //이벤트에 등록 퓨처빌드
      future: userReference.document(widget.userProfileId).get(), //유저도큐먼트에서 userprofileId 로 들어온걸 검색해서 가져온다.
      builder: (context,dataSnapshot){                          //데이터 스냅샷에 저장
        if(!dataSnapshot.hasData){                             //데이터 스냅샷에 데이터가 없으면
          return circularProgress();                           //뺑뺑이돌리고
        }
        User user = User.formDocument(dataSnapshot.data);        //있으면 User.formDocument로 data를 User 빈에 넣어줌.
        return Padding(
          padding: EdgeInsets.all(17),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.url),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            createColumns("posts",0),
                            createColumns("followers",0),
                            createColumns("following",0),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 13),
                child: Text(
                  '${user.username}',style: TextStyle(color: Colors.white,fontSize: 14),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  '${user.profileName}',style: TextStyle(color: Colors.white,fontSize: 18),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 3),
                child: Text(
                  '${user.bio}',style: TextStyle(color: Colors.white54,fontSize: 18),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  createButton(),
                ],
              ),
            ],
          ),
        );

      },
    );
  }

  createButton(){
   bool ownProfile =currentOnlineUserId == widget.userProfileId; //오너 프로파일이 커런트userid, 입력된userprofile이 동일하면 true
    if(ownProfile){
      return createButtonTitleAndFunction(title:"Edit Profile",performFunction: editUserProfile,);
    }
  }

 Container createButtonTitleAndFunction(
      {String title, Function performFunction}){
  return Container(
    padding: EdgeInsets.only(top: 3),
    child: FlatButton(
      onPressed: performFunction,
      child: Container(
        width: MediaQuery.of(context).size.width*0.8  ,
        height: 26,
        child: Text(title,style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold),),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black,border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(6.0),
        ),
      ),
    ),
  );
 }

 //사용자가 편집버튼을 누르면 들어가지는 메소드
  editUserProfile(){
    Navigator.push(context, MaterialPageRoute(builder: (context)=>EditProfilePage(currentOnlineUserId:currentOnlineUserId)));
  }

  Column createColumns(String title,int count){
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(count.toString(),style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold),),
        Container(
          margin: EdgeInsets.only(top: 5),
          child: Text(
            title,
            style: TextStyle(fontSize: 16,color: Colors.grey,fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context,strTitle: "Profile",isAppTitle: false),
      body: ListView(                //리스뷰로 바디를 보여주고
        children: [
          createProfileTopViwe(),         //프로파일 탑 뷰 메소드작성
        ],
      ),
    );
  }
}
