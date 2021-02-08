import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta/Widgets/progress_widget.dart';
import 'package:flutter_insta/models/user.dart';
import 'package:flutter_insta/pages/homepage.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with AutomaticKeepAliveClientMixin{ //자동연결

  TextEditingController searchTextEditingController = TextEditingController();     //텍스트를 컨트롤할 수 있는 컨트롤러
  Future<QuerySnapshot> futureSearchResult;

  controlSearching(String str){
    Future<QuerySnapshot> allUser = userReference.where("profileName",isGreaterThanOrEqualTo: str).getDocuments();
    //미래에 들어올 QuerySnapshot을 alluser에  userReference.where문으로 profileName을 Get하여 입력된 파라메터와 비교하여 가져온다.
    setState(() {
      futureSearchResult = allUser;  //실시간으로 검색되어진 유저들으ㅢ profileName을 allUser에 담는다.
    });
  }

  AppBar searchPageHeader(){
    return AppBar(
      backgroundColor: Colors.black,
      title: TextFormField(                                              //텍스트 필드 (폼 기능까지 )
        style: TextStyle(fontSize: 18.0,color: Colors.white),
        controller: searchTextEditingController,                         //텍스트폼필드에 입력한게 컨트롤러에 입력됨
        decoration: InputDecoration(                                     //박스만듬
          hintText: "Search Here..",
          hintStyle: TextStyle(fontSize: 16.0,color: Colors.grey),
          enabledBorder: UnderlineInputBorder(                           //언더라인 (밑줄)
            borderSide: BorderSide(
              color: Colors.grey,                                       //클릭 안되어있을 때 회색
            ),
          ),
          focusedBorder: UnderlineInputBorder(                         //언더라인 클릭 되었을 때 흰색
            borderSide: BorderSide(color: Colors.white),
          ),
          filled: true,
          prefixIcon: Icon(Icons.search,color: Colors.white,size: 30,),
          suffixIcon: IconButton(icon: Icon(Icons.clear),onPressed: () => searchTextEditingController.clear(),color: Colors.white,)
        ),
        onFieldSubmitted: controlSearching,      //서칭을 담당하는 메소드

      ),
    );
  }

  displayNoSearchResultScreen(){
      final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Icon(Icons.group,color: Colors.grey,size: 200.0,),
            Text("Serach User",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 65.0),
            ),
          ],
        ),
      ),
    );
  }

  displayUserFoundScreen(){
    return FutureBuilder(
      future: futureSearchResult, //futer (이벤트에 futersearchResult를 등록해주고)
      builder: (context,dataSnapshot){  //빌더 데이터스냅샷에
        if(!dataSnapshot.hasData){      //데이터가 없으면
          return circularProgress();    //서큘 프로그레스 (뻉뻉이를 반환해줌)
        }
        List<UserResult> searchUserResult = [];     //List를 UserResult 타입으로 받아준다.
        dataSnapshot.data.documents.forEach((document){   //값이 있을 시 datasanpshot.data.documents 를 끝까지 반복해 돌림
          User eachUser = User.formDocument(document);  //model User에 User.formDocument로 위에서 foreach로 돌려준것을 담아줌.
          UserResult userResult = UserResult(eachUser);  //생성자를 통하여 foreach로 돌린 profilenmae들을 넣어준다.
          searchUserResult.add(userResult);        //List에 add해줌.
        });
          return ListView(children:searchUserResult);       //마지막엔 리스트뷰로 searchUserResult를 반환해줌.
      },
    );
  }


  bool get wantKeepAlive => true;    //with AutomaticKeepAliveClientMixin 사용하기 위하여 선언
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: searchPageHeader(),
      body: futureSearchResult == null ? displayNoSearchResultScreen() : displayUserFoundScreen(),
      //위에서 만든 futreSearchResult에 alluser가 없으면 noSearch메소드 실행,있으면 Userfound실행.
    );
  }
}

class UserResult extends StatelessWidget {
  final User eachUser;
  UserResult(this.eachUser);

  @override
  Widget build(BuildContext context) {     //Searchㅎ하여 정보가 넘어오면 아래의 UI로 값을 리턴해줌
    return Padding(
      padding: EdgeInsets.all(3),
      child: Container(
        color: Colors.white54,
        child: Column(
          children: [
            GestureDetector(  //검색이 될 시 프로필으로 리다이렉션 (이동가능하게제스쳐 디렉터)
              onTap: () => print("tapped"),
              child: ListTile(          //ListTile 으로 깔끔하게 한줄씩 표현한다.
                 leading: CircleAvatar(
                   backgroundColor: Colors.black,
                   backgroundImage: CachedNetworkImageProvider(eachUser.url),  //eachuser로 넘어온 정보의 url (사진)캐쉬네트워크 이미지로
                 ),
                title: Text(
                  eachUser.profileName,                                //eachuser로 넘어온 profilename
                  style: TextStyle(
                      fontSize: 16.0,fontWeight: FontWeight.bold,color: Colors.black
                  ),
                ),
                subtitle: Text(                                //subtitle로 eachuser로 넘어온 닉네임
                    eachUser.username,
                  style: TextStyle(
                    color: Colors.grey,fontSize: 13,
                  ),

                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
