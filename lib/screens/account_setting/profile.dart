import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sno_biz_app/app_route/app_route.dart';
import 'package:sno_biz_app/services/api_services.dart';
import 'package:sno_biz_app/utils/color_constants.dart';
import 'package:sno_biz_app/utils/shared_pref.dart';
import 'package:sno_biz_app/widgets/custom_dialog.dart';
import 'package:sno_biz_app/widgets/custom_loader.dart';
import 'package:sno_biz_app/widgets/custom_toaster.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/localization.dart';
import '../../widgets/image_cropper.dart';

class ProfileSettingScreen extends StatefulWidget {
  const ProfileSettingScreen({super.key});

  @override
  State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
  bool accessFiles = false;
  bool accessCamera = false;
  bool saveData = false;
  Map<String, String> codeId = {
    "name": "Netherlands",
    "dial_code": "+31",
    "code": "NL"
  };
  Map<String, String>? newCountryCode;

  final TextEditingController newName = TextEditingController();
  final TextEditingController newNumber = TextEditingController();
  final TextEditingController newEmail = TextEditingController();
  final TextEditingController newAddress = TextEditingController();

  dynamic myProfile = {};
  dynamic _imageFile;

  void initState() {
    // TODO: implement initState
    super.initState();

    fetchData();
  }

  fetchData() async {
    dynamic userId = await SharedPrefUtils.readPrefStr("userId");
    log(userId.toString());
    dynamic obj = {"userId": userId};
    dynamic allData = await APIServices.makeApiCall("fetch-profile.php", obj);
    log(allData.toString() + " data found");
    if (allData['errorCode'] == '0000') {
      setState(() {
        myProfile = Map<String, dynamic>.from(allData);

        newName.text = myProfile['fullName'];
        newAddress.text =
            myProfile['address'] == null ? '' : myProfile['address'];
        newEmail.text = myProfile['email'] == null ? '' : myProfile['email'];
        newNumber.text = myProfile['phone'] == null ? '' : myProfile['phone'];

        if (myProfile.containsKey('countryCode') &&
            myProfile['countryCode'] != null) {
          newCountryCode = APIServices.allCountries.firstWhere(
              (country) => country['dial_code'] == myProfile['countryCode'],
              orElse: () => {});
        } else {
          newCountryCode = APIServices.allCountries.firstWhere(
              (country) => country['dial_code'] == "+31",
              orElse: () => {});
        }

        // if (myProfile['accessCamera'] == 'yes') {
        //   accessCamera = true;
        // } else {
        //   accessCamera = false;
        // }
        // if (myProfile['accessFile'] == 'yes') {
        //   accessFiles = true;
        // } else {
        //   accessFiles = false;
        // }
        // if (myProfile['saveDatatoDevice'] == 'yes') {
        //   saveData = true;
        // } else {
        //   saveData = false;
        // }
      });
    } else {
      showCustomToast(context: context, message: allData['errorMessage']);
    }
  }

  updateProfile(BuildContext context, localizations, {required mode}) async {
    //  take mode in parameter and if mode address then only change address or else user myprofile Object
    if (mode == 'profile') CustomLoader.showProgressBar(context);
    dynamic userId = await SharedPrefUtils.readPrefStr("userId");

    dynamic obj = {
      "userId": userId,
      "fullName": mode == 'username' ? newName.text : myProfile['fullName'],
      "email": mode == 'email' ? newEmail.text : myProfile['email'],
      "address": mode == 'address' ? newAddress.text : myProfile['address'],
      "phone": mode == 'number' ? newNumber.text : myProfile['phone'],
      "saveDatatoDevice": mode == 'saveDataToDevice'
          ? saveData
              ? "yes"
              : "no"
          : myProfile['saveDatatoDevice'],
      "accessFile": mode == 'accessFile'
          ? accessFiles
              ? "yes"
              : "no"
          : myProfile['accessFile'],
      "accessCamera": mode == 'accessCamera'
          ? accessCamera
              ? "yes"
              : "no"
          : myProfile['accessCamera'],
      "profilePhoto": myProfile['photo'] != null ? myProfile['photo'] : "",
      "countryCode":
          mode == 'number' ? newCountryCode!['dial_code'] : codeId['dial_code'],
    };

    log(obj.toString() + " obj");

    if (mode == 'profile') {
      //  upload profile to firebase
      File? file = File(_imageFile!.path);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('FileUploads/profile/${userId}/images/$fileName.jpg');
      UploadTask uploadTask = firebaseStorageRef.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      print(downloadUrl);

      if (myProfile['photo'] != '') {
        FirebaseStorage.instance.refFromURL(myProfile['photo']).delete();
      }

      obj['profilePhoto'] = downloadUrl;
    }

    dynamic result = await APIServices.makeApiCall("update-profile.php", obj);
    log(result.toString() + " result");
    if (mode == 'profile') Navigator.pop(context);
    showToast(localizations!.translate(result['errorMessage'].toString()));
    if (result['errorCode'] == '0000') {
      fetchData();
    }
  }

  showToast(msg) async {
    // await Future.delayed(Duration(seconds: 2));
    showCustomToast(context: context, message: msg);
  }

  Future<void> _pickImage(ImageSource source, localizations) async {
    dynamic pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      File file = File(pickedFile!.path);

      pickedFile = await Image_Cropper.cropFile(pickedFile);
      setState(() {
        _imageFile = File(pickedFile.path);

        updateProfile(context, localizations, mode: "profile");
      });
    }
  }

  showIcon() {
    if (_imageFile != null) {
      return false;
    } else if (myProfile['photo'] != '' && myProfile.containsKey('photo')) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localizations = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      // appBar: AppBar(
      //   backgroundColor: AppColors.white,
      //   leading: GestureDetector(
      //     onTap: () {
      //       Navigator.pop(context);
      //     },
      //     child: Icon(
      //       Icons.arrow_back,
      //       color: AppColors.black,
      //       size: 28,
      //     ),
      //   ),
      // ),
      body: SafeArea(
          child: SingleChildScrollView(
              child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(top: 28, bottom: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: AppColors.black,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),

            Center(
              child: Stack(children: [
                Container(
                  height: 110,
                  width: 110,
                  decoration: BoxDecoration(
                      color: AppColors.blueColor,
                      shape: BoxShape.circle,
                      image: _imageFile != null
                          ? DecorationImage(
                              image: FileImage(
                                _imageFile,
                              ),
                              fit: BoxFit.cover)
                          : myProfile['photo'] != '' &&
                                  myProfile.containsKey('photo')
                              ? DecorationImage(
                                  image: CachedNetworkImageProvider(
                                    myProfile['photo'],
                                    cacheManager: DefaultCacheManager(),
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null),
                  child: showIcon()
                      ? Icon(
                          Icons.person,
                          size: 45,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 3,
                  right: 2,
                  child: GestureDetector(
                    onTap: () {
                      showCustomDialog(
                          context, 'Camera', 'Gallery', AppColors.blueColor,
                          () {
                        _pickImage(ImageSource.camera, localizations);
                        Navigator.pop(context);
                      }, () {
                        _pickImage(ImageSource.gallery, localizations);
                        Navigator.pop(context);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4.5),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.white),
                        shape: BoxShape.circle,
                        color: AppColors.purpleColor,
                      ),
                      child: const Icon(
                        CupertinoIcons.add_circled_solid,
                        color: AppColors.white,
                        size: 14.5,
                      ),
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 15),
            Text("${myProfile['fullName']}",
                style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black)),
            // const SizedBox(height: 8),
            // Text("Client ID: ${myProfile['clientId']}",
            //     style: TextStyle(
            //         fontSize: 18, color: AppColors.faqDescriptionColor)),
            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 65,
                  child: Text('${localizations!.translate("Name")}',
                      style: TextStyle(
                          color: AppColors.greyColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w400)),
                ),
                const SizedBox(width: 20),
                Expanded(
                    child: Text("${myProfile['fullName']}",
                        style: TextStyle(
                            color: AppColors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500))),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    UpdateData(context, "name", localizations);
                  },
                  child: SvgPicture.asset(
                    'assets/images/pencil-alt.svg',
                    width: 15, // Adjust the width as needed
                    height: 15, //
                  ),
                ),
                const SizedBox(width: 5),
              ],
            ),
            const Divider(
              height: 40,
              thickness: 1,
              color: AppColors.dividerColor,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 65,
                  child: Text('${localizations!.translate("Email")}',
                      style: TextStyle(
                          color: AppColors.greyColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w400)),
                ),
                const SizedBox(width: 20),
                Expanded(
                    child: Text("${myProfile['email']}",
                        style: TextStyle(
                            color: AppColors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500))),
                const SizedBox(width: 2),
                // GestureDetector(
                //   onTap: () {
                //     UpdateData(context, "email");
                //   },
                //   child: SvgPicture.asset(
                //     'assets/images/pencil-alt.svg',
                //     width: 15, // Adjust the width as needed
                //     height: 15, //
                //   ),
                // ),
                const SizedBox(width: 5),
              ],
            ),
            const Divider(
              height: 40,
              thickness: 1,
              color: AppColors.dividerColor,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 65,
                  child: Text('${localizations!.translate("Phone")}',
                      style: TextStyle(
                          color: AppColors.greyColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w400)),
                ),
                const SizedBox(width: 20),
                Expanded(
                    child: Text(
                        "${myProfile.containsKey('countryCode') && myProfile['countryCode'] != null ? myProfile['countryCode'] : codeId['dial_code']}  ${myProfile['phone']}",
                        style: TextStyle(
                            color: AppColors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500))),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    UpdateData(context, "phone", localizations);
                  },
                  child: SvgPicture.asset(
                    'assets/images/pencil-alt.svg',
                    width: 15, // Adjust the width as needed
                    height: 15, //
                  ),
                ),
                const SizedBox(width: 5),
              ],
            ),
            const Divider(
              height: 40,
              thickness: 1,
              color: AppColors.dividerColor,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 65,
                  child: Text('${localizations!.translate("Address")}',
                      style: TextStyle(
                          color: AppColors.greyColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w400)),
                ),
                const SizedBox(width: 20),
                Expanded(
                    child: Text(
                        "${myProfile['address'] == null ? '-' : myProfile['address']}",
                        style: TextStyle(
                            color: AppColors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500))),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    UpdateData(context, "address", localizations);
                  },
                  child: SvgPicture.asset(
                    'assets/images/pencil-alt.svg',
                    width: 15, // Adjust the width as needed
                    height: 15, //
                  ),
                ),
                const SizedBox(width: 5),
              ],
            ),
            const SizedBox(height: 45),
            // const Row(
            //   children: [
            //     Expanded(
            //         child: Text("Permissions Granted",
            //             style: TextStyle(
            //                 fontSize: 19,
            //                 fontWeight: FontWeight.bold,
            //                 color: AppColors.black)))
            //   ],
            // ),
            // const SizedBox(height: 25),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     SvgPicture.asset(
            //       'assets/images/save.svg',
            //       width: 21, // Adjust the width as needed
            //       height: 21, //
            //     ),
            //     const SizedBox(width: 18),
            //     const Expanded(
            //         child: Text("Save Data to Device",
            //             style: TextStyle(
            //                 color: AppColors.black,
            //                 fontSize: 16,
            //                 fontWeight: FontWeight.w500))),
            //     const SizedBox(width: 10),
            //     FlutterSwitch(
            //       height: 23.0,
            //       width: 40.0,
            //       padding: 4.0,
            //       toggleSize: 15.0,
            //       borderRadius: 12.0,
            //       activeColor: AppColors.purpleColor,
            //       value: saveData,
            //       onToggle: (value) {
            //         setState(() {
            //           saveData = value;
            //           updateProfile(context, mode: "saveDataToDevice");
            //         });
            //       },
            //     ),
            //   ],
            // ),
            // const Divider(
            //   height: 40,
            //   thickness: 1,
            //   color: AppColors.dividerColor,
            // ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     SvgPicture.asset(
            //       'assets/images/location-arrow.svg',
            //       width: 20, // Adjust the width as needed
            //       height: 20, //
            //     ),
            //     const SizedBox(width: 18),
            //     const Expanded(
            //         child: Text("Access Files",
            //             style: TextStyle(
            //                 color: AppColors.black,
            //                 fontSize: 16,
            //                 fontWeight: FontWeight.w500))),
            //     const SizedBox(width: 10),
            //     FlutterSwitch(
            //       height: 23.0,
            //       width: 40.0,
            //       padding: 4.0,
            //       toggleSize: 15.0,
            //       borderRadius: 12.0,
            //       activeColor: AppColors.purpleColor,
            //       value: accessFiles,
            //       onToggle: (value) {
            //         setState(() {
            //           accessFiles = value;

            //           updateProfile(context, mode: "accessFile");
            //         });
            //       },
            //     ),
            //   ],
            // ),
            // const Divider(
            //   height: 40,
            //   thickness: 1,
            //   color: AppColors.dividerColor,
            // ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     SvgPicture.asset(
            //       'assets/images/photo_camera.svg',
            //       width: 21, // Adjust the width as needed
            //       height: 21, //
            //     ),
            //     const SizedBox(width: 18),
            //     const Expanded(
            //         child: Text("Access Camera",
            //             style: TextStyle(
            //                 color: AppColors.black,
            //                 fontSize: 16,
            //                 fontWeight: FontWeight.w500))),
            //     const SizedBox(width: 10),
            //     FlutterSwitch(
            //       height: 23.0,
            //       width: 40.0,
            //       padding: 4.0,
            //       toggleSize: 15.0,
            //       borderRadius: 12.0,
            //       activeColor: AppColors.purpleColor,
            //       value: accessCamera,
            //       onToggle: (value) {
            //         setState(() {
            //           accessCamera = value;

            //           updateProfile(context, mode: "accessCamera");
            //         });
            //       },
            //     ),
            //   ],
            // ),
          ],
        ),
      ))),
    );
  }

  UpdateData(BuildContext context, data, localizations) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                insetPadding: const EdgeInsets.symmetric(horizontal: 25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: Container(
                  height: 40,
                  width: screenWidth,
                  padding: const EdgeInsets.only(left: 15, right: 3),
                  decoration: const BoxDecoration(
                    color: AppColors.purpleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                content: Container(
                    width: screenWidth,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Container(
                        child: data == 'address'
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${localizations!.translate("Change Address")}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: AppColors.faqDescriptionColor),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: AppColors.textColor),
                                    ),
                                    child: Form(
                                      child: TextField(
                                        // keyboardType: TextInputType.number,
                                        // inputFormatters: [
                                        //   FilteringTextInputFormatter.allow(
                                        //       RegExp(r'[0-9]')),
                                        //   LengthLimitingTextInputFormatter(6),
                                        // ],
                                        controller: newAddress,
                                        style: const TextStyle(
                                            color: AppColors.lightBlack,
                                            fontSize: 15),
                                        decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            focusColor: Colors.transparent,
                                            contentPadding: EdgeInsets.only(
                                                left: 15,
                                                right: 15,
                                                bottom: 5,
                                                top: 5)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                      width: double.infinity,
                                      height: 40,
                                      child: ElevatedButton(
                                          onPressed: () {
                                            if (newAddress.text == '') {
                                              showCustomToast(
                                                  context: context,
                                                  message:
                                                      '${localizations!.translate("Please add Address")}');
                                              return;
                                            }
                                            Navigator.pop(context);

                                            updateProfile(
                                                context,
                                                mode: "address",
                                                localizations);
                                          },
                                          child: Text(
                                              '${localizations!.translate("Save")}'),
                                          style: ElevatedButton.styleFrom(
                                            fixedSize: const Size(
                                                double.infinity,
                                                double.infinity),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(7)),
                                            backgroundColor:
                                                AppColors.purpleColor,
                                          )))
                                ],
                              )
                            : data == 'name'
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${localizations!.translate("Update Name")}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color:
                                                AppColors.faqDescriptionColor),
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: AppColors.textColor),
                                        ),
                                        child: Form(
                                          child: TextField(
                                            keyboardType: TextInputType.name,
                                            controller: newName,
                                            style: const TextStyle(
                                                color: AppColors.lightBlack,
                                                fontSize: 15),
                                            decoration: const InputDecoration(
                                                border: InputBorder.none,
                                                focusColor: Colors.transparent,
                                                contentPadding: EdgeInsets.only(
                                                    left: 15,
                                                    right: 15,
                                                    bottom: 5,
                                                    top: 5)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Container(
                                          width: double.infinity,
                                          height: 40,
                                          child: ElevatedButton(
                                              onPressed: () async {
                                                // final RegExp emailRegex = RegExp(
                                                //     r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');

                                                if (newName.text == '') {
                                                  showCustomToast(
                                                      context: context,
                                                      message:
                                                          '${localizations!.translate("Please add name")}');
                                                  return;
                                                }

                                                Navigator.pop(context);
                                                updateProfile(
                                                    context, localizations,
                                                    mode: "username");
                                              },
                                              child: Text(
                                                  '${localizations!.translate("Save")}'),
                                              style: ElevatedButton.styleFrom(
                                                fixedSize: const Size(
                                                    double.infinity,
                                                    double.infinity),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7)),
                                                backgroundColor:
                                                    AppColors.purpleColor,
                                              )))
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${localizations!.translate("Update Phone Number")}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color:
                                                AppColors.faqDescriptionColor),
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.grey,
                                                width: 0.8,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          width: double.infinity,
                                          child: Row(children: [
                                            Container(
                                              width: 80,
                                              child: DropdownButtonFormField(
                                                style: const TextStyle(
                                                    fontSize: 1,
                                                    color: Color.fromARGB(
                                                        221, 57, 56, 56)),
                                                decoration:
                                                    const InputDecoration(
                                                  focusedBorder:
                                                      InputBorder.none,
                                                  border: InputBorder.none,
                                                  isDense: true,
                                                  contentPadding:
                                                      EdgeInsets.only(
                                                          left: 10, right: 0),
                                                ),
                                                value: newCountryCode,
                                                // onChanged: null,
                                                onChanged: (dynamic value) {
                                                  setState(() {
                                                    newCountryCode = value;
                                                  });
                                                },
                                                items: APIServices.allCountries
                                                    .map<DropdownMenuItem>(
                                                        (Map<String, String>
                                                            value) {
                                                  return DropdownMenuItem<
                                                      Map<String, String>>(
                                                    value: value,
                                                    child: Text(
                                                      value['dial_code']
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontSize: 15),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                            Container(
                                              height: 20.0,
                                              width: 1.0,
                                              color: const Color.fromARGB(
                                                  77, 0, 0, 0),
                                              margin: const EdgeInsets.only(
                                                  left: 10.0, right: 5.0),
                                            ),
                                            Expanded(
                                              child: TextFormField(
                                                controller: newNumber,
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp(r'[0-9]')),
                                                  LengthLimitingTextInputFormatter(
                                                      10),
                                                ],
                                                decoration:
                                                    const InputDecoration(
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide.none),
                                                  border: OutlineInputBorder(
                                                      borderSide:
                                                          BorderSide.none),
                                                  isDense: true,
                                                  contentPadding:
                                                      EdgeInsets.only(
                                                          bottom: 10.0,
                                                          top: 5.0),
                                                  prefix: Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 15.0)),
                                                ),
                                              ),
                                            ),
                                          ])),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Container(
                                          height: 40,
                                          width: double.infinity,
                                          child: ElevatedButton(
                                              onPressed: () async {
                                                final phoneNumber =
                                                    newNumber.text.trim();
                                                if (phoneNumber.isEmpty) {
                                                  showCustomToast(
                                                      context: context,
                                                      message:
                                                          '${localizations!.translate("Please Add a phone number")}');

                                                  return;
                                                }
                                                if (phoneNumber.length < 10) {
                                                  showCustomToast(
                                                      context: context,
                                                      message:
                                                          '${localizations!.translate("Phone number must have 10-digits")}');
                                                  return;
                                                }

                                                Navigator.pop(context);
                                                updateProfile(
                                                    context, localizations,
                                                    mode: "number");
                                              },
                                              child: Text(
                                                  '${localizations!.translate("Save")}'),
                                              style: ElevatedButton.styleFrom(
                                                fixedSize: const Size(
                                                    double.infinity,
                                                    double.infinity),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7)),
                                                backgroundColor:
                                                    AppColors.purpleColor,
                                              )))
                                    ],
                                  ))));
          });
        });
  }
}
