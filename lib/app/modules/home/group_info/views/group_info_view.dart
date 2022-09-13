import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:histudy/app/widgets/top_bar_widget.dart';
import '../controllers/group_info_controller.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../routes/app_pages.dart';

class GroupInfoView extends StatefulWidget {
  const GroupInfoView({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<GroupInfoView> {
  //var firebaseUser = FirebaseAuth.instance.currentUser;
  // final FirebaseAuth _firebaseAuth =
  User? user = FirebaseAuth.instance.currentUser;

  bool admin = false;
  bool groupcheck = true;
  int curuser = 0;

  List<Color> changeCholor = [
    Color(0xffd32f2f),
    Color(0xff689f38),
    Color(0xff7b1fa2),
    Color(0xfffbc02d),
    Color(0xff303f9f),
    Color(0xfff57c00),
    Color(0xff0288d1),
    Color(0xff5d4037),
    Color(0xff00796b),
    Color(0xff455a64),
  ];

  List<Map<String, dynamic>> classInfo = List.empty(growable: true);
  Map<String, String> userClassData = {};
  @override
  void initState() {
    final CollectionReference _profile =
        FirebaseFirestore.instance.collection('Profile');
    _profile.doc(user?.uid).get().then((DocumentSnapshot ds) {
      setState(() {
        admin = ds['isAdmin'];
        curuser = ds['group'];
      });
      groupcheck = false;
    });
    String? semId = Get.rootDelegate.parameters['semId'];
    FirebaseFirestore.instance
        .collection("Class")
        .doc(semId)
        .collection('subClass')
        .get()
        .then((QuerySnapshot qs) {
      qs.docs.forEach((element) {
        var mapTemp = {
          "id": element.id,
          "class": element["class"],
          "professor": element["professor"]
        };
        classInfo.add(mapTemp);
      });
    });

    _profile.get().then((QuerySnapshot qs1) {
      qs1.docs.forEach((documentSnapshot) {
        if (documentSnapshot['classRegister'] == true) {
          String registeredClass = "true";
          _profile
              .doc(documentSnapshot.id)
              .collection('classScore')
              .doc(semId)
              .get()
              .then((DocumentSnapshot classDs) {
            //classDS는 id : 점수 항목들을 classDs[id] 이런식으로 나옴.
            //classDs들이 현재 과목 정보들을 담고 있음.
            //for 반복문으로 모든 class 정보 한번 훝고 확인함.
            Map<int, int> forSortScore = {};
            for (int j = 10; j > 0; j--) {
              for (int i = 0; i < classInfo.length; i++) {
                if (classDs[classInfo[i]["id"]] == j) {
                  registeredClass += "/" +
                      classInfo[i]["class"].toString() +
                      "(" +
                      classInfo[i]["professor"].toString() +
                      ")[" +
                      classDs[classInfo[i]["id"]].toString() +
                      "]";
                  Map<String, String> tempData = {
                    documentSnapshot.id: registeredClass
                  };
                  setState(() {
                    userClassData.addAll(tempData);
                  });
                }
              }
            }
          });
        }
      });
    });

    super.initState();
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _groupController = TextEditingController();

  bool isSwitched = false;
  User? currentUser;

  final CollectionReference _profile =
      FirebaseFirestore.instance.collection('Profile');

  Future<void> _deleteProduct(String productId) async {
    await _profile.doc(productId).delete();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a profile')));
  }

  @override
  Widget build(BuildContext context) {
    String? semId = Get.rootDelegate.parameters['semId'];

    return Scaffold(
        backgroundColor: Color(0xffFDFFFE),
        body: Column(children: [
          topBar(Get.rootDelegate.parameters["semId"], context),
          SizedBox(
            height: 30.h,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              '팀 멤버',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.black87),
            ),
          ]),
          SizedBox(
            height: 30,
          ),
          groupcheck
              ? Container()
              : admin
                  ? Flexible(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(80, 20, 80, 0),
                        child: Column(children: [
                          Divider(
                            thickness: 0.1,
                            color: Colors.black,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 230.w,
                                ),
                                Expanded(
                                    child: Text(
                                  '  이름',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                                Expanded(
                                    child: Text(
                                  '  이메일',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                                Expanded(
                                    child: Text(
                                  '  그룹',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                                Expanded(
                                    child: Text(
                                  '  관리자',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                                SizedBox(
                                  width: 180.w,
                                ),
                              ]),
                          Divider(
                            thickness: 0.3,
                            color: Colors.black,
                            height: 10,
                          ),
                          Flexible(
                            child: StreamBuilder(
                              stream: _profile
                                  .orderBy('group', descending: true)
                                  .snapshots(),
                              builder: (context,
                                  AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                                if (streamSnapshot.hasData) {
                                  return ListView.builder(
                                    itemCount: streamSnapshot.data!.docs.length,
                                    itemBuilder: (context, index) {
                                      final DocumentSnapshot documentSnapshot =
                                          streamSnapshot.data!.docs[index];

                                      return Container(
                                        margin: const EdgeInsets.all(10),
                                        child: Column(
                                          children: [
                                            ListTile(
                                              // title: Text(documentSnapshot['name']),
                                              title: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                          child: Text(
                                                              '${index + 1}')),
                                                      Expanded(
                                                          child: Text(
                                                              documentSnapshot[
                                                                  'name'])),
                                                      Expanded(
                                                          child: Text(
                                                              documentSnapshot[
                                                                      'email']
                                                                  .toString())),
                                                      Expanded(
                                                          child: Text(
                                                              '   Group ${documentSnapshot['group'].toString()}')),
                                                      Expanded(
                                                          child: Text(
                                                              documentSnapshot[
                                                                      'isAdmin']
                                                                  .toString())),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 12.h,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      admin
                                                          ? userClassData[
                                                                      documentSnapshot
                                                                          .id] !=
                                                                  null
                                                              ? Text(
                                                                  "${userClassData[documentSnapshot.id]}")
                                                              : Container()
                                                          : Container(),
                                                      SizedBox(
                                                        width: 10.w,
                                                      ),
                                                      Container(
                                                        width: 15,
                                                        height: 15,
                                                        color: changeCholor[
                                                            documentSnapshot[
                                                                    'group'] %
                                                                10],
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              // documentSnapshot['isAdmin'].toString() ?

                                              trailing: SizedBox(
                                                width: 100,
                                                child: Row(
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.edit),
                                                      onPressed: () {
                                                        String action =
                                                            'create';
                                                        if (documentSnapshot !=
                                                            null) {
                                                          action = 'update';
                                                          isSwitched =
                                                              documentSnapshot[
                                                                  'isAdmin'];
                                                          _nameController.text =
                                                              documentSnapshot[
                                                                  'name'];
                                                          _groupController
                                                                  .text =
                                                              documentSnapshot[
                                                                      'group']
                                                                  .toString();
                                                        }
                                                        Get.dialog(
                                                          AlertDialog(
                                                            title:
                                                                Text("유저정보 수정"),
                                                            content: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  '그룹 번호 변경',
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                                ),
                                                                TextField(
                                                                  keyboardType: const TextInputType
                                                                          .numberWithOptions(
                                                                      decimal:
                                                                          true),
                                                                  controller:
                                                                      _groupController,
                                                                  decoration:
                                                                      const InputDecoration(
                                                                    labelText:
                                                                        'change group number ',
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      'Admin 계정 지정',
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontSize:
                                                                            14,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      '  (화면상으로 바로 바뀌지 않습니다.)',
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.normal,
                                                                        fontSize:
                                                                            10,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Switch(
                                                                  value:
                                                                      isSwitched,
                                                                  onChanged:
                                                                      (value) {
                                                                    setState(
                                                                        () {
                                                                      isSwitched =
                                                                          value;
                                                                      Get.snackbar(
                                                                        value
                                                                            ? "Admin 지정 완료"
                                                                            : "Admin 지정 취소 완료",
                                                                        "Update 버튼을 클릭해 완료하세요",
                                                                        backgroundColor:
                                                                            Color(0xff04589C),
                                                                        colorText:
                                                                            Color(0xffF0F0F0),
                                                                      );
                                                                    });
                                                                  },
                                                                  activeTrackColor:
                                                                      Color(
                                                                          0xff04589C),
                                                                  activeColor:
                                                                      Colors
                                                                          .grey,
                                                                ),
                                                              ],
                                                            ),
                                                            actions: [
                                                              ElevatedButton(
                                                                child: Text(action ==
                                                                        'create'
                                                                    ? 'Create'
                                                                    : 'Update'),
                                                                onPressed:
                                                                    () async {
                                                                  //final String? name = _nameController.text;
                                                                  final double?
                                                                      group =
                                                                      double.tryParse(
                                                                          _groupController
                                                                              .text);
                                                                  if (group !=
                                                                          null &&
                                                                      semId !=
                                                                          null) {
                                                                    if (action ==
                                                                        'update') {
                                                                      //이전 그룹에서 유저 데이터를 삭제
                                                                      await FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              semId)
                                                                          .doc(
                                                                              semId)
                                                                          .collection(
                                                                              'Group')
                                                                          .doc(documentSnapshot['group']
                                                                              .toString())
                                                                          .get()
                                                                          .then(
                                                                              (value) {
                                                                        if (value
                                                                            .exists) {
                                                                          FirebaseFirestore
                                                                              .instance
                                                                              .collection(semId)
                                                                              .doc(semId)
                                                                              .collection('Group')
                                                                              .doc(documentSnapshot['group'].toString())
                                                                              .update({
                                                                            "members":
                                                                                FieldValue.arrayRemove([
                                                                              documentSnapshot.id
                                                                            ])
                                                                          });
                                                                        }
                                                                      });

                                                                      //이동할 그룹에 유저 데이터를 추가
                                                                      await FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              semId)
                                                                          .doc(
                                                                              semId)
                                                                          .collection(
                                                                              'Group')
                                                                          .doc(group
                                                                              .toString())
                                                                          .update({
                                                                        "members":
                                                                            FieldValue.arrayUnion([
                                                                          documentSnapshot
                                                                              .id
                                                                        ]),
                                                                      });
                                                                      await _profile
                                                                          .doc(documentSnapshot
                                                                              .id)
                                                                          .update({
                                                                        "group":
                                                                            group,
                                                                        "isAdmin":
                                                                            isSwitched
                                                                      });
                                                                      Get.back();
                                                                      Get.snackbar(
                                                                        "Update 완료",
                                                                        "화면 닫기 버튼을 클릭하여 되돌아가세요",
                                                                        backgroundColor: Color.fromARGB(
                                                                            255,
                                                                            5,
                                                                            109,
                                                                            195),
                                                                        colorText:
                                                                            Color(0xffF0F0F0),
                                                                      );
                                                                    }
                                                                    Get.back();
                                                                    // Clear the text fields
                                                                    // _nameController
                                                                    //     .text = '';
                                                                    // _groupController
                                                                    //     .text = '';

                                                                    // Hide the bottom sheet

                                                                  }
                                                                },
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  primary: Color(
                                                                      0xff04589C),
                                                                  side:
                                                                      BorderSide(
                                                                          width:
                                                                              1),
                                                                  shape: RoundedRectangleBorder(
                                                                      //to set border radius to button
                                                                      borderRadius: BorderRadius.circular(5)),
                                                                ),
                                                              ),
                                                              ElevatedButton(
                                                                child: Text(
                                                                    '화면 닫기'),
                                                                onPressed: () {
                                                                  Get.back();
                                                                },
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  primary: Color(
                                                                      0xff04589C),
                                                                  side:
                                                                      BorderSide(
                                                                          width:
                                                                              1),
                                                                  shape: RoundedRectangleBorder(
                                                                      //to set border radius to button
                                                                      borderRadius: BorderRadius.circular(5)),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    IconButton(
                                                        icon: const Icon(
                                                            Icons.delete),
                                                        onPressed: () =>
                                                            _deleteProduct(
                                                                documentSnapshot
                                                                    .id)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 8.h,
                                            ),
                                            Divider(
                                              thickness: 0.2,
                                              color: Colors.black,
                                              height: 10,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            ),
                          ),
                        ]),
                      ),
                    )
                  : curuser == 0
                      ? Container(
                          child: Text(
                            '아직 그룹이 배정되지 않았습니다. 그룹이 배정되면 그룹 정보가 나타납니다.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 20),
                          ),
                        )
                      : Flexible(
                          child: Padding(
                          padding: const EdgeInsets.fromLTRB(80, 20, 80, 0),
                          child: Column(children: [
                            Divider(
                              thickness: 0.1,
                              color: Colors.black,
                            ),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: Text(
                                    '      NO',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                                  Expanded(
                                      child: Text(
                                    '  이름',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                                  Expanded(
                                      child: Text(
                                    '  이메일',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                                  Expanded(
                                      child: Text(
                                    '  그룹 번호',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                                ]),
                            Divider(
                              thickness: 0.1,
                              color: Colors.black,
                              height: 10,
                            ),
                            Flexible(
                              child: StreamBuilder(
                                stream: _profile
                                    .where("group", isEqualTo: curuser)
                                    .snapshots(),
                                builder: (context,
                                    AsyncSnapshot<QuerySnapshot>
                                        streamSnapshot) {
                                  if (streamSnapshot.hasData) {
                                    return ListView.builder(
                                      itemCount:
                                          streamSnapshot.data!.docs.length,
                                      itemBuilder: (context, index) {
                                        final DocumentSnapshot
                                            documentSnapshot =
                                            streamSnapshot.data!.docs[index];
                                        return Container(
                                          margin: const EdgeInsets.all(10),
                                          child: Column(children: [
                                            ListTile(
                                                title: Row(children: <Widget>[
                                              Expanded(
                                                  child: Text('${index + 1}')),
                                              Expanded(
                                                  child: Text(documentSnapshot[
                                                      'name'])),
                                              Expanded(
                                                  child: Text(
                                                      documentSnapshot['email']
                                                          .toString())),
                                              SizedBox(width: 100.w),
                                              Expanded(
                                                  child: Text(
                                                      'Group ${documentSnapshot['group'].toString()}')),
                                            ])),
                                          ]),
                                        );
                                      },
                                    );
                                  }
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                              ),
                            ),
                          ]),
                        ))
        ]));
  }
}
