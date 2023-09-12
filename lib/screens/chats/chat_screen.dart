import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sno_biz_app/app_route/app_route.dart';
import 'package:sno_biz_app/services/api_services.dart';
import 'package:sno_biz_app/utils/color_constants.dart';
import 'package:sno_biz_app/widgets/custom_loader.dart';
import 'package:sno_biz_app/widgets/custom_toaster.dart';
import 'package:sno_biz_app/widgets/imageViewer.dart';
import 'package:sno_biz_app/widgets/pdfViewer.dart';

import '../../utils/api_urls.dart';
import '../../utils/shared_pref.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ChatScreen extends StatefulWidget {
  ChatScreen(
      {required this.data,
      this.fromNotification = false,
      this.updateReadFlag = false});

  dynamic data;
  bool fromNotification = false;
  bool updateReadFlag = false;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessageText = TextEditingController();
  final ScrollController _controller = ScrollController();

  dynamic userId = '';
  bool _isLoading = true;

  dynamic myTitlechat = [];
  dynamic chatList = [];
  dynamic userImage = null;
  late StreamSubscription<DatabaseEvent> subscription;
  dynamic attachmentList = [
    {"name": "Camera", "Icon": Icons.camera_alt_rounded},
    {"name": "Gallery", "Icon": Icons.image},
    {"name": "Document", "Icon": Icons.picture_as_pdf}
  ];
  dynamic _imageFile;

  void _pickPDFFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: ['pdf'],
    );

    if (result == null) {
      return;
    }

    if (result!.files[0].size > 5000000) {
      showCustomToast(context: context, message: "File is too Big in Size");
      return;
    }

    log(result!.files[0].path.toString() + " pdf");

    uploadDocument(result!.files[0].path.toString(), "pdf");

    // for (final file in result!.files) {
    //   setState(() {
    //     // _imageFile = File(file.path!);
    //     uploadDocument(file.path, "image");
    //   });
    // }

    // sendMessage("pdf", "");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    initializeTimeZones();
    fetchUserId();
    fetchUserData();

    if (widget.updateReadFlag) {
      markedAsReadNotification();
    }
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  void initializeTimeZones() {
    tz.initializeTimeZones();
  }

  fetchUserData() async {
    dynamic userId = await SharedPrefUtils.readPrefStr("userId");
    log(userId.toString());
    dynamic obj = {"userId": userId};
    dynamic allData = await APIServices.makeApiCall("fetch-profile.php", obj);
    log(allData.toString() + " data found");
    if (allData['errorCode'] == '0000') {
      setState(() {
        dynamic myProfile = Map<String, dynamic>.from(allData);

        if (myProfile['photo'] != '' && myProfile['photo'] != null) {
          userImage = myProfile['photo'];
        }
      });
    } else {
      // showCustomToast(context: context, message: allData['errorMessage']);
    }
  }

  markedAsReadNotification() async {
    log("Making read mark");
    dynamic userId = await SharedPrefUtils.readPrefStr("userId");

    dynamic obj = {
      "userId": userId,
      "id": widget.data['id'],
      "mode": widget.data.containsKey('actionType')
          ? widget.data['actionType']
          : widget.data['mode'],
      "type": ""
    };
    log(obj.toString() + "request for read");
    dynamic allData =
        await APIServices.makeApiCall("read-notification.php", obj);

    if (allData['errorCode'] == '0000') {
      setState(() {
        log(allData['errorMessage'].toString() + " after read");
      });
    } else {
      log(allData['errorMessage'].toString());
      // showCustomToast(context: context, message: allData['errorMessage']);
    }
  }

  fetchTitleDecription() async {
    if (widget.fromNotification) {
      dynamic obj = {"userId": userId, "ticketId": widget.data['id']};
      log(obj.toString() + " my object for getting detail");
      dynamic allData =
          await APIServices.makeApiCall("fetch-ticket-detail.php", obj);
      log(allData.toString() + " detail found");

      if (allData['errorCode'] == '0000') {
        setState(() {
          widget.data['assignTo'] = allData['assignTo'];
          widget.data['subject'] = allData['subject'];
          widget.data['description'] = allData['description'];
          widget.data['filetype'] = allData['filetype'];
          widget.data['file'] = allData['file'];
        });
      } else {
        showCustomToast(context: context, message: allData['errorMessage']);
      }
    }
    setState(() {
      myTitlechat = [
        {
          "senderId": userId,
          "receiverId": widget.data['assignTo'].toString(),
          "chatId": widget.data['id'],
          "date": "",
          "messageType": "text",
          "id": "",
          "message": widget.data['subject'].toString() +
              "\n" +
              widget.data['description'].toString(),
          "timestamp": DateTime(2001).microsecondsSinceEpoch,
        },
        // {
        //   "senderId": userId,
        //   "receiverId": widget.data['assignTo'].toString(),
        //   "chatId": widget.data['id'],
        //   "date": "",
        //   "messageType": "text",
        //   "id": "",
        //   "message": widget.data['description'].toString(),
        //   "timestamp": DateTime(2002).microsecondsSinceEpoch
        // }
      ];

      if (widget.data['file'] != '') {
        myTitlechat.add({
          "senderId": userId,
          "receiverId": widget.data['assignTo'].toString(),
          "chatId": widget.data['id'],
          "date": "",
          "messageType": widget.data['fileType'].toString(),
          "id": "",
          "message": widget.data['file'].toString(),
          "timestamp": DateTime(2002).microsecondsSinceEpoch
        });
      }
    });

    fetchChatList();
  }

  fetchUserId() async {
    dynamic myUserId = await SharedPrefUtils.readPrefStr("userId");
    setState(() {
      userId = myUserId;
    });
    fetchTitleDecription();
  }

  Future<void> _pickImage(ImageSource source) async {
    dynamic pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      File file = File(pickedFile!.path);

      int fileSizeInBytes = file.lengthSync();
      log(fileSizeInBytes.toString());

      if (fileSizeInBytes > 5000000) {
        showCustomToast(context: context, message: "File is too Big in Size");
        return;
      } else {
        uploadDocument(pickedFile.path, "image");
      }

      // sendMessage("image", "");
    }
  }

  fetchChatList() async {
    final databaseReference =
        FirebaseDatabase.instance.ref('TicketChat/${widget.data['id']}/');

    Query query = databaseReference.orderByChild('timestamp');

    Stream<DatabaseEvent> stream = query.onValue;

    subscription = stream.listen((DatabaseEvent event) {
      dynamic values = event.snapshot.value;

      log(values.toString() + "data ");
      if (values != null) {
        setState(() {
          chatList = values.values.toList();

          chatList.sort((a, b) {
            return int.parse(b['timestamp'])
                .compareTo(int.parse(a['timestamp'])) as int;
          });
          chatList = chatList.reversed.toList();

          chatList = [...myTitlechat, ...chatList];
        });

        log(chatList.toString());

        Future.delayed(const Duration(milliseconds: 500), () {
          _controller.jumpTo(_controller.position.maxScrollExtent);
        });

        // checkRejectApproveCondition(); // check if block or reject/accept
      } else {
        setState(() {
          chatList = myTitlechat;
        });
      }

      setState(() {
        _isLoading = false;
      });
    });
  }

  sendMessageToFirebase(msg, msgType) async {
    DatabaseReference chatRef =
        FirebaseDatabase.instance.reference().child('TicketChat');

    DatabaseReference messageRef = chatRef.child(widget.data['id']);
    var newEntryRef = messageRef.push();
    String newEntryKey = newEntryRef.key!;

    dynamic amsterdam = tz.getLocation('Europe/Amsterdam');
    dynamic nowInAmsterdam = tz.TZDateTime.now(amsterdam);

    String formattedDate = DateFormat('yyyy-MMM-dd').format(nowInAmsterdam);

    Map<String, dynamic> newMessage = {
      "chatId": widget.data['id'],
      "senderId": userId,
      "receiverId": widget.data['assignTo'].toString(),
      "message": msg, // (text, image Link , pdf link),
      "messageType": msgType, //(text, image, pdf),
      "readFlag": "0",
      'date': formattedDate,
      'timestamp': DateFormat('yyyyMMddHHmmss').format(DateTime.now()),
      'time': DateFormat('HH:mm:ss').format(nowInAmsterdam),
      'id': newEntryKey
    };

    log("adding");
    messageRef
        .child(newEntryKey)
        .update(newMessage)
        .then((_) {})
        .catchError((error) {
      print('Failed to send message: $error');
      // Handle any error that occurs during message sending
    });
  }

  uploadDocument(filePath, fileType) async {
    CustomLoader.showProgressBar(context);

    File? file = File(filePath);
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('FileUploads/ticket/${userId}/${fileType}/$fileName.jpg');
    UploadTask uploadTask = firebaseStorageRef.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();

    print(downloadUrl);

    sendMessageToFirebase(downloadUrl, fileType);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.skyBlueColor,
        body: SafeArea(
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: AppColors.purpleColor),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Stack(children: [
                    Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.blueColor),
                          image: DecorationImage(
                              image: AssetImage('assets/images/support.jpg'),
                              fit: BoxFit.cover)),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Kontinu Support Team",
                        style: TextStyle(
                            color: AppColors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Online",
                        style: TextStyle(
                            color: AppColors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                            color: AppColors.blueColor),
                      )
                    : chatList.length == 0
                        ? Container(
                            width: MediaQuery.of(context).size.width / 1.3,
                            child: Image.asset(
                              "assets/images/image.png",
                              fit: BoxFit.contain,
                            ))
                        : ListView.builder(
                            controller: _controller,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 13),
                                child: Row(
                                  mainAxisAlignment:
                                      chatList[index]['senderId'] != userId
                                          ? MainAxisAlignment.start
                                          : MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (chatList[index]['senderId'] != userId)
                                      Container(
                                        height: 35,
                                        width: 35,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color:
                                                    AppColors.lightgreyColor),
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    'assets/images/support.jpg'),
                                                fit: BoxFit.cover)),
                                      ),
                                    if (chatList[index]['senderId'] != userId)
                                      const SizedBox(width: 15),
                                    chatList[index]['messageType'] == "text"
                                        ? Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                color: chatList[index]
                                                            ['senderId'] ==
                                                        userId
                                                    ? AppColors.purpleColor
                                                    : AppColors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            constraints: BoxConstraints(
                                                maxWidth: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    1.8),
                                            child: Text(
                                              chatList[index]['message'],
                                              style: TextStyle(
                                                  color: chatList[index]
                                                              ['senderId'] ==
                                                          userId
                                                      ? AppColors.white
                                                      : AppColors.black,
                                                  fontSize: 15),
                                            ),
                                          )
                                        : chatList[index]['messageType'] ==
                                                "image"
                                            ? GestureDetector(
                                                onTap: () {
                                                  showImage(context,
                                                      file: chatList[index]
                                                          ['message']);
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                      color: chatList[index][
                                                                  'senderId'] ==
                                                              userId
                                                          ? AppColors
                                                              .purpleColor
                                                          : AppColors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Container(
                                                    constraints: BoxConstraints(
                                                      maxWidth:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              1.8,
                                                    ),
                                                    height: 200,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        image: DecorationImage(
                                                          image:
                                                              CachedNetworkImageProvider(
                                                            chatList[index]
                                                                ['message'],
                                                            cacheManager:
                                                                DefaultCacheManager(),
                                                          ),
                                                          fit: BoxFit.cover,
                                                        )),
                                                  ),
                                                ),
                                              )
                                            : GestureDetector(
                                                onTap: () {
                                                  nextPage(
                                                      context,
                                                      PDFScreen(
                                                          name: "PDF",
                                                          pdfPath:
                                                              chatList[index]
                                                                  ['message']));
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 13,
                                                      horizontal: 20),
                                                  decoration: BoxDecoration(
                                                      color: chatList[index][
                                                                  'senderId'] ==
                                                              userId
                                                          ? AppColors
                                                              .purpleColor
                                                          : AppColors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Row(
                                                    children: [
                                                      if (chatList[index]
                                                              ['senderId'] !=
                                                          userId)
                                                        Text(
                                                          "PDF",
                                                          style: TextStyle(
                                                              color: chatList[index]
                                                                          [
                                                                          'senderId'] ==
                                                                      userId
                                                                  ? AppColors
                                                                      .white
                                                                  : AppColors
                                                                      .black,
                                                              fontSize: 15,
                                                              letterSpacing:
                                                                  0.3,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      if (chatList[index]
                                                              ['senderId'] !=
                                                          userId)
                                                        SizedBox(
                                                          width: 11,
                                                        ),
                                                      Icon(
                                                        Icons.picture_as_pdf,
                                                        size: 28,
                                                        color: chatList[index][
                                                                    'senderId'] !=
                                                                userId
                                                            ? AppColors
                                                                .purpleColor
                                                            : AppColors.white,
                                                      ),
                                                      if (chatList[index]
                                                              ['senderId'] ==
                                                          userId)
                                                        SizedBox(
                                                          width: 11,
                                                        ),
                                                      if (chatList[index]
                                                              ['senderId'] ==
                                                          userId)
                                                        Text(
                                                          "PDF",
                                                          style: TextStyle(
                                                              color: chatList[index]
                                                                          [
                                                                          'senderId'] ==
                                                                      userId
                                                                  ? AppColors
                                                                      .white
                                                                  : AppColors
                                                                      .black,
                                                              fontSize: 15,
                                                              letterSpacing:
                                                                  0.3,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                    if (chatList[index]['senderId'] == userId)
                                      const SizedBox(width: 15),
                                    if (chatList[index]['senderId'] == userId)
                                      userImage == null
                                          ? Container(
                                              height: 35,
                                              width: 35,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColors.blueColor,
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.person,
                                                  size: 16,
                                                ),
                                              ),
                                            )
                                          : Container(
                                              height: 35,
                                              width: 35,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: AppColors
                                                          .lightgreyColor),
                                                  color: AppColors.white,
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                      image:
                                                          CachedNetworkImageProvider(
                                                        userImage,
                                                        cacheManager:
                                                            DefaultCacheManager(),
                                                      ),
                                                      fit: BoxFit.cover)),
                                            ),
                                  ],
                                ),
                              );
                            },
                            itemCount: chatList.length)),
            const SizedBox(height: 3),
            Container(
              decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15))),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      showAttachmentList();
                    },
                    child: Container(
                      height: 47,
                      width: 47,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.skyBlueColor),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/images/attachment.svg',
                          width: 24, // Adjust the width as needed
                          height: 24, // Adjust the height as needed
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 47,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.skyBlueColor, width: 1)),
                      child: TextField(
                        controller: MessageText,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Type here..",
                            hintStyle: TextStyle(
                                fontSize: 16, color: AppColors.greyColor),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 15)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      log(MessageText.text.toString());
                      if (MessageText.text.toString() == '') {
                        showCustomToast(
                            context: context,
                            message: "Please write a message");
                      } else {
                        dynamic obj = {
                          "message": MessageText.text,
                          "type": "sender",
                          "messageType": "text"
                        };
                        setState(() {
                          // sendMessage("text", MessageText.text);

                          sendMessageToFirebase(MessageText.text, "text");
                          // chatList.add(obj);
                          MessageText.clear();
                          // Future.delayed(const Duration(seconds: 1), () {
                          //   _controller
                          //       .jumpTo(_controller.position.maxScrollExtent);
                          // });
                        });
                      }
                    },
                    child: Container(
                      height: 47,
                      width: 47,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.skyBlueColor),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/images/paper-plane.svg',
                          width: 23, // Adjust the width as needed
                          height: 23, // Adjust the height as needed
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }

  showAttachmentList() {
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
            child: Container(
              color: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(height: 5),
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: attachmentList.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              if (attachmentList[index]['name'] == 'Camera') {
                                _pickImage(ImageSource.camera);
                              } else if (attachmentList[index]['name'] ==
                                  'Gallery') {
                                _pickImage(ImageSource.gallery);
                              } else if (attachmentList[index]['name'] ==
                                  'pdf') {
                                _pickPDFFile();
                              }
                            },
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                attachmentList[index]['Icon'],
                                color: AppColors.blueColor,
                              ),
                              title: Text(
                                attachmentList[index]['name'],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          index != attachmentList.length - 1
                              ? const Divider(
                                  height: 1,
                                )
                              : Container()
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
