import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta/models/user.dart';
import 'package:flutter_insta/pages/create_account_page.dart';
import 'package:flutter_insta/pages/upload_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'notifi_page.dart';
import 'profile_page.dart';
import 'timeline_page.dart';
import 'search_page.dart';



class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

final GoogleSignIn gSign = GoogleSignIn(); //구글 로그인을 할 수 있는 api
final userReference = Firestore.instance.collection("users"); //userReference 변수에 Firestore인스턴스 콜렉션(users테이블 가져오기)
final StorageReference storageReference = FirebaseStorage.instance.ref().child("Posts Pictures"); //스토레지 생성될 파일명.
final postsReference = Firestore.instance.collection("posts"); //postReference 변수에 Firestore인스턴스 콜렉션(posts테이블 가져오기)


final DateTime timestamp = DateTime.now();           //현시각을 타임스탬프에 대입해준다.
 User currenUser = User();

class _HomePageState extends State<HomePage> {
  PageController pageController;
  var isSignedIn = false;
  int getPageIndex=0; //페이지의 인덱스 번호를 부여


  void initState() {
    super.initState();

    pageController = PageController();

    gSign.onCurrentUserChanged.listen((gSignAccount) {
      controlSignIn(gSignAccount);
    }, onError: (gError) {
      print("Error Message ${gError}");
    });

    gSign.signInSilently(suppressErrors: false).then((gSignAccount) {
      controlSignIn(gSignAccount);
    }).catchError((gError) {
      print("Error Message $gError");
    });
  }

  controlSignIn(GoogleSignInAccount signInAccount) async {
    //구글로그인 허가 비허가 컨트롤러
    await saveUserInfoToFireStore(); //유저정보를 파이어 스토어에 저장하는 메소드
    if (signInAccount != null) {
      setState(() {
        isSignedIn = true;
      });
    } else {
      isSignedIn = false;
    }
  }

  saveUserInfoToFireStore() async{
    final GoogleSignInAccount gCurrentUser = gSign.currentUser; //현재 로그인 되어있는 커런트유저를 google 사인어카운트에 대입
    DocumentSnapshot documentSnapshot = await userReference.document(gCurrentUser.id).get(); 
    //스냅샷에 userReference를 빼온다 gCureentUser.id와 비교해서 맞으면 빼옴
    if(!documentSnapshot.exists){     //존재하지 않는 아이디이면
      final username = await Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateAccountPage()));

      userReference.document(gCurrentUser.id).setData({
      "id" : gCurrentUser.id,
      "profileName": gCurrentUser.displayName,
      "username" : username,
        "url" : gCurrentUser.photoUrl,
        "email" : gCurrentUser.email,
        "bio" : "",
        "timestamp" : timestamp
      });
      documentSnapshot = await userReference.document(gCurrentUser.id).get(); //gcurrentuser.id를 가져와야한다.
    }
    currenUser = User.formDocument(documentSnapshot);          //model user에 모든걸 대입한다.
  }


  void dispose(){       //상태 객체가 제거될때  변수에 할당된 메모리를 해제하기 위함.
    pageController.dispose();
    super.dispose();
  }

  loginUser() {
    //로그인유저 메소드를 만듬
    gSign.signIn();
  }

  logoutUser() {
    setState(() {
      gSign.signOut(); //사인아웃 메소드
    });
    this.isSignedIn = false;
    print('Log out');
  }

  whenPageChanges(int pageIndex){
    setState(() {
    this.getPageIndex = pageIndex;     //그림을 다시 그려야 하기 때문에 setState
      print("current Page index : ${this.getPageIndex}");
    });
  }

  onTapCahngePage(int pageIndex){                                                           //커브 시각적인 효과
    pageController.animateToPage(pageIndex, duration: Duration(microseconds: 1), curve: Curves.bounceInOut);
  }

  Scaffold buildHomeScreen()   //사인아웃 레이지드 버튼
  {
    return Scaffold(
      body: PageView(             //페이지 뷰의 칠드런들은 자동으로 index를 부여받게된다.
        children: [
          TimeLinePage(),
          // RaisedButton.icon(onPressed:(){return logoutUser();}, icon: Icon(Icons.close), label: Text('Close')),
          SearchPage(),
          UploadPage(gCurrentUser: currenUser,),
          NotificationsPage(),
          ProfilePage(userProfileId: currenUser.id),
        ],
        controller: pageController,           //페이지를 컨트롤 할 수 있다. 컨트롤러로
        onPageChanged: whenPageChanges,         //페이지를 바꾸면 자동으로 인덱스번호가 whenpagechanges메소드로 입력되어 getpa인덱스로대입
        physics: NeverScrollableScrollPhysics(),  //사용자가 스크롤 할 수없는 스크롤 물리를 만듭니다.
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: getPageIndex,            //현재 인덱스는 getpageindex로 당연히 설정
        onTap: onTapCahngePage,              //ontap하였을 때 애니메이션을 줄수 있는 메소드를 만듬
        backgroundColor: Theme.of(context).accentColor,
        activeColor: Colors.white,
        inactiveColor: Colors.grey,          //선택되어있지 않을 때의 비활성화
        items: [

          BottomNavigationBarItem(icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera,size: 37,),
          ),
          BottomNavigationBarItem(icon: Icon(Icons.favorite),
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person),
          ),
        ],

      ),
    );
  }
    //   onPressed: logoutUser(),
    // child: Row(
    //   mainAxisAlignment: MainAxisAlignment.center,
    //  children: [
    //     Icon(Icons.close,color: Colors.white,),
    //     Text('Sign Out',style: TextStyle(color: Colors.white),),
    //  ],
    // )



  Scaffold buildSignInScreen() => Scaffold(
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                Theme.of(context).accentColor,
                Theme.of(context).primaryColor
              ])),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Instagram',
                style: TextStyle(
                    fontSize: 92.0,
                    color: Colors.white,
                    fontFamily: 'Signatra'),
              ),
              GestureDetector(
                onTap: () => loginUser(),
                child: Container(
                  width: 270.0,
                  height: 65.0,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(
                              "assets/images/google_signin_button.png"))),
                ),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (isSignedIn) {
      return buildHomeScreen();
    } else {
      return buildSignInScreen();
    }
  }
}
