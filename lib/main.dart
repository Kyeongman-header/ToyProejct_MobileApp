import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    title: 'Flutter Demo',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primaryColor: Colors.orange,
    ),
    initialRoute:'/login',
    routes:
    {
      '/login' : (context) => Login_View(),
      '/' : (context) => MyHomePage(title: '박경만'),
    },

    //home: MyHomePage(title:'박경만'),
  )
  );
}
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return
//   }
// }
class Login_View extends StatefulWidget{
  const Login_View({Key? key}) : super(key : key);
  @override
  State<Login_View> createState()=>_Login_View_State();
}
class _Login_View_State extends State<Login_View> {
  final myController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _pickedImgs=[];
  bool _imageornot = false;
  Future<void> _pickImg() async {
    final List<XFile>? images=await _picker.pickMultiImage();
    if(images!=null) {
      setState(() {
        _pickedImgs=images;
        _imageornot=true;
      });
    }
  }

  @override
  Widget build(BuildContext context){
    return WillPopScope (
        onWillPop: ()=>exit(0),
        child :Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text("기후행동 1.5 Toy Project"),
            backgroundColor : Colors.orangeAccent,
          ),
          body: Center(
              child : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height:MediaQuery.of(context).size.height*0.1),
                  Text("탄소포인트제 점수 화면 스크린샷을 올려주세요.",textAlign:TextAlign.center),
                  SizedBox(
                    height:MediaQuery.of(context).size.height*0.5,
                    child: DottedBorder(
                            child:Container(
                                child:Center(
                                    child:IconButton(
                                    onPressed:(){
                                      _pickImg();
                                    },
                                    icon:Icon(IconData(0xee3f, fontFamily: 'MaterialIcons')),
                                )
                            ),
                              decoration: _imageornot ?BoxDecoration(
                                  borderRadius:BorderRadius.circular(8),
                                  image:DecorationImage(
                                    fit:BoxFit.cover,
                                    image:FileImage(File(_pickedImgs![0].path))
                                  )
                              ):null,
                            ),
                            color:Colors.grey,
                            dashPattern:[5,5],
                            borderType:BorderType.RRect,
                            radius:Radius.circular(10)
                        )
                    ),
                  SizedBox(height:MediaQuery.of(context).size.height*0.1),
                  FloatingActionButton.extended(
                    icon:Icon(IconData(0xe048, fontFamily: 'MaterialIcons')),
                    label:Text("스크린샷 올리기"),
                    onPressed: ()async {
                      print("screenshot");
                      try {
                        Dio dio = Dio();
                        final List<MultipartFile> _files = _pickedImgs!.map((
                            img) =>
                            MultipartFile.fromFileSync(
                                img.path, contentType: new MediaType(
                                "image", "jpg"))).toList();
                        FormData _formData = FormData.fromMap({"user" : "Test","screenshot": _files,"title":"testfromFlutterApp"});
                        dio.options.contentType='multipart/form-data';
                        final res=await dio.post("http://ec2-52-79-240-95.ap-northeast-2.compute.amazonaws.com:8000/api/image/",data:_formData).then((res){
                          return res.data;
                        });
                        print(res);
                        Navigator.pushNamed(context,'/');
                      }
                      catch (e){
                        print(e);
                        showDialog(
                          context:context,
                          builder:(_)=>AlertDialog(
                            title: Text("오류"),
                            content:Text("이미지를 삽입해주세요."),
                            actions:[
                              TextButton(child: Text("확인"),onPressed:(){Navigator.pop(context);}),
                            ],
                            elevation:20.0,
                          ),

                        );
                      }
                    },
                  ),
                ],

              )
          )
        ),
    );
  }
}

class PointsData {
  final double point_one;
  final double point_two;
  final double point_three;
  final String user;
  final String pub_date;

  String get _user=> user;
  String get _pub_date=> pub_date;
  double get _point_one=> point_one;
  double get _point_two=> point_two;
  double get _point_three=> point_three;

  PointsData({required this.point_one,required this.point_two,required this.point_three,required this.user,required this.pub_date});

  // 사진의 정보를 포함하는 인스턴스를 생성하여 반환하는 factory 생성자
  factory PointsData.fromJson(Map<String, dynamic> json) {
    return PointsData(
      point_one: json['point_one'] as double,
      point_two: json['point_two'] as double,
      point_three: json['point_three'] as double,
      user: json['user'] as String,
      pub_date: json['pub_date'] as String,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _user = "Test";
  double _point_one= 0;
  double _point_two=0;
  double _point_three=0;

  Future<PointsData> fetchPointsData() async {
    // 해당 URL로 데이터를 요청하고 수신함
    final response =
    await http.get(Uri.parse('http://ec2-52-79-240-95.ap-northeast-2.compute.amazonaws.com:8000/api/points/?user='+_user));
    print(jsonDecode(response.body)[1]);
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return PointsData.fromJson(jsonDecode(response.body)[1]);
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
    // parsePhotos 함수를 백그라운도 격리 처리
    //return compute(parsePhotos, response.body);
  }

// 수신한 데이터를 파싱하여 List<Photo> 형태로 반환
//   List<Photo> parsePhotos(String responseBody) {
//     // 수신 데이터를 JSON 포맷(JSON Array)으로 디코딩
//     final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
//
//     // JSON Array를 List<Photo>로 변환하여 반환
//     return parsed.map<Photo>((json) => Photo.fromJson(json)).toList();
//   }
  Future<PointsData>? pointsdata;
  void initState() {
    super.initState();
    pointsdata = fetchPointsData();
    print(pointsdata);
  }
  @override
  Widget build(BuildContext context){
    return WillPopScope (
        onWillPop: ()=>exit(0),
    child :Scaffold(
    backgroundColor: Colors.orange,
    appBar: AppBar(
    title: Text("기후행동 1.5 Toy Project"),
    backgroundColor : Colors.orangeAccent,
    ),
    body: Center(
    child : Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: <Widget>[
      SizedBox(height:MediaQuery.of(context).size.height*0.2),
        Container(
          height:MediaQuery.of(context).size.height*0.2,
          width:MediaQuery.of(context).size.width*0.8,
          decoration:BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
            color: Colors.white,
            boxShadow:[
              BoxShadow(
                spreadRadius: 2,
                color: Colors.grey,
                offset: Offset(2, 3),
                blurRadius: 1.5,
              )
            ],
          ),
          child: Center(child:Text(_user+"님 탄소포인트 점수판",style:TextStyle(fontSize:30)),)
        ),
      SizedBox(height:MediaQuery.of(context).size.height*0.1),
      FutureBuilder(
        future:pointsdata,
        builder:(context,AsyncSnapshot snapshot){
          if(snapshot.hasError) print(snapshot.error);
          return snapshot.hasData ?
              Center(
                child:Container(
                  height:MediaQuery.of(context).size.height*0.2,
                  decoration:BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    color: Colors.white,
                    boxShadow:[
                      BoxShadow(
                        spreadRadius: 2,
                        color: Colors.grey,
                        offset: Offset(2, 3),
                        blurRadius: 1.5,
                      )
                    ],
                  ),
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children:[
                            Text("포인트 2\n"),
                            Text(snapshot.data!.point_one.toString(),style:TextStyle(fontSize:15, fontWeight:FontWeight.bold)),
                          ]
                      ),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children:[
                          Text("포인트 2\n"),
                          Text(snapshot.data!.point_two.toString(),style:TextStyle(fontSize:15, fontWeight:FontWeight.bold )),
                        ]
                      ),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children:[
                            Text("포인트 2\n"),
                            Text(snapshot.data!.point_three.toString(),style:TextStyle(fontSize:15, fontWeight:FontWeight.bold)),
                          ]
                      ),

                  ]
                  )
                ),

                )
              : Center(
              child: CircularProgressIndicator());
        }
      )

    ],
    )
    )
    )
    );
  }
}


