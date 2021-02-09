import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_insta/Widgets/progress_widget.dart';
import 'package:flutter_insta/models/user.dart';
import 'package:flutter_insta/pages/homepage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as ImD ;

class UploadPage extends StatefulWidget {

  final User gCurrentUser;
  UploadPage({this.gCurrentUser});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> with AutomaticKeepAliveClientMixin<UploadPage> {
  File file;
  bool uploading = false;
  String postId = Uuid().v4();
  TextEditingController descriptionTextEditingController = TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();

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

  clearPostInfo(){
    locationTextEditingController.clear();
    descriptionTextEditingController.clear();
    setState(() {
      file= null;
    });
  }

  getCurrentLoaction() async { //async처리로 이벤트등록
    Position positioned = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    //Position을 Geolocator API를 사용하여 현재위치를 넣어준다.
    List<Placemark> placeMarks = await Geolocator().placemarkFromCoordinates(positioned.latitude, positioned.longitude);
    //List 에 Placemark클래스로 위도경도를 넣어준다,
    Placemark mPlaceMark = placeMarks[0];
    String completeAddressinfo =
        '${mPlaceMark.subThoroughfare} ${mPlaceMark.thoroughfare}, '
        '${mPlaceMark.subLocality} ${mPlaceMark.locality}, '
        '${mPlaceMark.subAdministrativeArea} ${mPlaceMark.administrativeArea},'
        '${mPlaceMark.postalCode} ${mPlaceMark.country}';
    String specificAddress = '${mPlaceMark.locality},${mPlaceMark.country}';
    locationTextEditingController.text = specificAddress;
    print('위도경도 $completeAddressinfo' );
  }


  compressingPhoto() async {
    final tDirectory = await getTemporaryDirectory();
    final path = tDirectory.path;
    ImD.Image mImageFile = ImD.decodeImage(file.readAsBytesSync());  //이미지를 불러와 바이트 싱크
    final compressedImageFile = File('$path/img_$postId.jpg')..writeAsBytesSync(ImD.encodeJpg(mImageFile,quality: 90));
    //파일 img_uuid로 부여받고.jpg 형식으로 싱크를 맞추어준다 퀄리티는 90
    setState(() {
      file = compressedImageFile;  //디코더한 이미지파일을 파일에 담아준다.
    });
  }

  controlUploadAndSave() async {
    setState(() {
      uploading = true;    //uploading을 true로
    });
    await compressingPhoto();  //컴프로세싱 포토(사진압축)
    //firestore 업로드할 때 주소를 가져와야함.
    String downloadUrl = await uploadPhoto(file);

    savePostInfoFireStore(
        url: downloadUrl,
        location : locationTextEditingController.text,
        description: descriptionTextEditingController.text);

    //업로드가 끝난 뒤 컨트롤러의 텍스트를 모두 지워주고
    locationTextEditingController.clear();
    descriptionTextEditingController.clear();
    //셋 스테이터스로 파일,업로딩,포스트 아이디 초기화 시켜줌.
    setState(() {
      file = null;
      uploading = false;
      postId = Uuid().v4();
    });

  }

  savePostInfoFireStore({String url,String location,String description}) async {
    postsReference.document(widget.gCurrentUser.id,).collection("usersPosts").document(postId).setData({
      "postId" : postId,
      "ownerId": widget.gCurrentUser.id,
      "timestamp" : timestamp,
      "Likes" : {},
      "username" : widget.gCurrentUser.username,
      "description" : description,
      "loaction" : location,
      "url" : url,
    });

  }

  Future<String> uploadPhoto(mImageFile) async {
    //스토리지 업로드작업
    StorageUploadTask mStorageUploadTask = storageReference.child("post_$postId.jpg").putFile(mImageFile);
    StorageTaskSnapshot storageTaskSnapshot = await mStorageUploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;

  }

  displayUploadFormScreen(){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(icon: Icon(Icons. arrow_back,color: Colors.white,),onPressed: () => clearPostInfo(),),
        title: Text("New Post",style: TextStyle(fontSize: 24,color: Colors.white,fontWeight: FontWeight.bold),),
        centerTitle: true,
        actions: [
          FlatButton(
              onPressed: uploading? null : ()=>controlUploadAndSave(),
              child: Text("Share",style: TextStyle(color: Colors.lightGreenAccent,fontSize: 16,fontWeight: FontWeight.bold),),)
        ],
      ),
      body: ListView(
        children: [
          uploading ? linearProgress() : Text(""),
          Container(
            height: 230,
            width: MediaQuery.of(context).size.width*0.8,
            child: Center(
              child: AspectRatio(          //사진의 가로세로의 비율을 맞춰준다 어느 사이즈든
                aspectRatio: 16/9,        //16/9 사이즈로 맞춰줌.
                child: Container(
                  decoration: BoxDecoration(image: DecorationImage(image: FileImage(file),fit: BoxFit.cover)),
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 12.0),),
          ListTile(
            leading: CircleAvatar(backgroundImage: CachedNetworkImageProvider(widget.gCurrentUser.url),),
            title: Container(
              width: 250,
              child:TextField(
                style: TextStyle(color: Colors.white),
                controller: descriptionTextEditingController,
                decoration: InputDecoration(
                  hintText: "Say Something about image.",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person_pin_circle,color: Colors.white,size: 36,),
            title: Container(
              width: 250,
              child:TextField(
                style: TextStyle(color: Colors.white),
                controller: locationTextEditingController,
                decoration: InputDecoration(
                  hintText: "Write the location here",
                  hintStyle: TextStyle(color: Colors.white),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 220,
            height: 110.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(35)),
              color: Colors.green,
              icon: Icon(Icons.location_on,color: Colors.white,),
              label: Text("Get my Current location",style: TextStyle(color: Colors.white),),
              onPressed: getCurrentLoaction,
            ),
          ),
        ],
      ),
    );
  }


  bool get wantKeepAlive => true;    //with AutomaticKeepAliveClientMixin 사용하기 위하여 선언
  @override
  Widget build(BuildContext context) {
    return file == null ? displayUploadScreen() : displayUploadFormScreen();
    //file에 들어가 있는값이 없으면 displayupload스크린을 보여주고 들어가있으면 업로드 폼스크린을 보여준다.
  }
}
