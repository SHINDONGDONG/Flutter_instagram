import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta/Widgets/progress_widget.dart';
import 'package:flutter_insta/models/user.dart';
import 'package:flutter_insta/pages/homepage.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  // final String timestamp;
  final dynamic likes;
  final String username;
  final String description;
  final String loaction;
  final String url;

  Post({this.postId,
      this.ownerId,
      // this.timestamp,
      this.likes,
      this.username,
      this.description,
      this.loaction,
      this.url});

  //factory 인스턴스를 대신 생성해주어 반환해주는 기법
  factory Post.fromDocument(DocumentSnapshot documentSnapshot){
    return Post(
      postId : documentSnapshot["postId"],
      ownerId : documentSnapshot["ownerId"],
      // timestamp : documentSnapshot["timestamp"],
      likes : documentSnapshot["Likes"],
      username : documentSnapshot["username"],
      description : documentSnapshot["description"],
      loaction : documentSnapshot["loaction"],
      url : documentSnapshot["url"],

    );
  }

  int getTotalNumberOfLikes(like) {
    if (like == null) {
      return 0;
    }
    int counter = 0;
    like.values.forEach((eachValue) {
      if(eachValue == true){
        counter = ++counter;
      }
    });
    return counter;
  }

  @override
  _PostState createState() => _PostState(
    postId : this.postId,
    ownerId : this.ownerId,
    // timestamp : documentSnapshot["timestamp"],
    Likes : this.likes,
    username : this.username,
    description : this.description,
    loaction : this.loaction,
    url : this.url,
    likeCount:getTotalNumberOfLikes(this.likes),

  );


}

class _PostState extends State<Post> {
  final String postId;
  final String ownerId;
  // final String timestamp;
  Map Likes;
  final String username;
  final String description;
  final String loaction;
  final String url;
  int likeCount;
  bool isLiked;
  bool showHeart = false;
  final String currentOnlineUserId = currenUser?.id;




  _PostState({this.postId,
    this.ownerId,
    // this.timestamp,
    this.Likes,
    this.username,
    this.description,
    this.loaction,
    this.url,
    this.likeCount});



  //profile 밑에 들어갈 내 사진들
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          createPostHead(),
          createPostPicture(),
          createPostFooter(),
        ],
      ),
    );
  }

  createPostFooter(){
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.only(top: 40,left: 20),),
            GestureDetector(
              onTap: () => print("liked post"),
              child: Icon(
                Icons.favorite,color: Colors.grey,
                // isLiked ? Icons.favorite : Icons.favorite_border,
                // size: 28,
                // color: Colors.pink,
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 20),),
            GestureDetector(
              onTap: () => print("show comments"),
              child: Icon(Icons.chat_bubble_outline,color: Colors.white,size: 28,),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text("$likeCount likes",
              style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text("$username",
              style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
            ),
            Expanded(
              child: Text(description,style: TextStyle(color: Colors.white),),
            )
          ],
        ),
      ],
    );
  }

  createPostPicture(){
    return GestureDetector(
      onDoubleTap: () => print("Post Like"),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(url)
        ],
      ),
    );
  }

  createPostHead(){
    return FutureBuilder(
      future: userReference.document(ownerId).get(),  //오너 아이디를 가져온다.
      builder: (context,dataSnapshot){           //데이터 스냅샷이없으면
        if(!dataSnapshot.hasData){
          return circularProgress();           //뺑뺑이돌린다
        }
        User user = User.formDocument(dataSnapshot.data); //있으면 user bean에  formDocument로 datasanpshot.data를 넣어준다.
        bool isPostOwner = currentOnlineUserId == ownerId;  //currentonlineuserid와 ownerid가 같으면 ispostowner에 true

        return ListTile(
          leading: CircleAvatar(backgroundImage: CachedNetworkImageProvider(user.url),backgroundColor: Colors.grey,),
          title: GestureDetector(
            onTap: () => print("show profile"),
            child: Text(
              user.username,
              style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
            ),
          ),
          subtitle: Text(loaction,style: TextStyle(color: Colors.white),),
          trailing: isPostOwner? IconButton(icon: Icon(Icons.more_vert),
              onPressed:() => print("Delete"), ) : Text(""),
        );
      },
    );
  }
}
