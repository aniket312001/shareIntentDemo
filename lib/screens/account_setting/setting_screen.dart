import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sno_biz_app/app_route/app_route.dart';
import 'package:sno_biz_app/screens/dashboard_screen.dart';
import 'package:sno_biz_app/services/localization.dart';
import 'package:sno_biz_app/services/select_language.dart';
import 'package:sno_biz_app/utils/color_constants.dart';
import 'package:sno_biz_app/widgets/custom_toaster.dart';
import 'package:sno_biz_app/widgets/next_button.dart';

import '../../utils/shared_pref.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  dynamic selectedLanguage = "en";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchSeletedLanguage(context);
  }

  fetchSeletedLanguage(context) async {
    // final lang = Provider.of<LanguageChange>(context, listen: false);

    dynamic language = await SharedPrefUtils.readPrefStr("selectedLanguage");

    setState(() {
      if (language.toString() != 'null') {
        // AppLocalizations.of(context)!.locale = const Locale("fr");
        // lang.changeAppLanguage(language);
        selectedLanguage = language;
      } else {
        selectedLanguage = "en";
        // lang.changeAppLanguage("en");
        // AppLocalizations.of(context)!.locale = const Locale("fr");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations? localizations = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.skyBlueColor,
      body: Consumer<LanguageChange>(
          builder: (context, languageChangeProvider, child) {
        return SafeArea(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
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
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: AppColors.purpleColor),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    '${localizations!.translate("Setting")}',
                    style: TextStyle(
                        letterSpacing: 0.2,
                        color: AppColors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.only(left: 15, right: 15, bottom: 20),
              child: Text('${localizations!.translate("Language")}',
                  style: TextStyle(
                      letterSpacing: 0.2,
                      color: AppColors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.bold)),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(width: 1, color: AppColors.purpleColor)),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 5.0, bottom: 5, left: 15, right: 5),
                child: RadioListTile(
                  fillColor: MaterialStateColor.resolveWith(
                      (states) => AppColors.purpleColor),
                  contentPadding: EdgeInsets.zero,
                  visualDensity: const VisualDensity(
                    horizontal: VisualDensity.minimumDensity,
                    vertical: VisualDensity.minimumDensity,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  controlAffinity: ListTileControlAffinity.trailing,
                  title: const Text(
                    "English",
                    style: TextStyle(color: AppColors.textColor),
                  ),
                  value: "en",
                  groupValue: selectedLanguage,
                  onChanged: (value) {
                    setState(() {
                      selectedLanguage = value.toString();
                    });
                  },
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * .024,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(width: 1, color: AppColors.purpleColor)),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 5.0, bottom: 5, left: 15, right: 5),
                child: RadioListTile(
                  fillColor: MaterialStateColor.resolveWith(
                      (states) => AppColors.purpleColor),
                  contentPadding: EdgeInsets.zero,
                  visualDensity: const VisualDensity(
                    horizontal: VisualDensity.minimumDensity,
                    vertical: VisualDensity.minimumDensity,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  controlAffinity: ListTileControlAffinity.trailing,
                  title: const Text(
                    "Dutch",
                    style: TextStyle(color: AppColors.textColor),
                  ),
                  value: "nl",
                  groupValue: selectedLanguage,
                  onChanged: (value) {
                    setState(() {
                      selectedLanguage = value.toString();
                    });
                  },
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * .024,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(width: 1, color: AppColors.purpleColor)),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 5.0, bottom: 5, left: 15, right: 5),
                child: RadioListTile(
                  fillColor: MaterialStateColor.resolveWith(
                      (states) => AppColors.purpleColor),
                  contentPadding: EdgeInsets.zero,
                  visualDensity: const VisualDensity(
                    horizontal: VisualDensity.minimumDensity,
                    vertical: VisualDensity.minimumDensity,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  controlAffinity: ListTileControlAffinity.trailing,
                  title: const Text(
                    "French",
                    style: TextStyle(color: AppColors.textColor),
                  ),
                  value: "fr",
                  groupValue: selectedLanguage,
                  onChanged: (value) {
                    setState(() {
                      selectedLanguage = value.toString();
                    });
                  },
                ),
              ),
            ),
            Spacer(),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: NextButton(
                  text: '${localizations!.translate('Submit')}',
                  onTap: () {
                    languageChangeProvider
                        .changeAppLanguage(selectedLanguage.toString());
                    SharedPrefUtils.saveStr(
                        'selectedLanguage', selectedLanguage.toString());

                    nextPagewithReplacement(context, DashboardScreen());
                    showCustomToast(
                        context: context,
                        message:
                            '${localizations!.translate("Language change Successfully!")}');
                  }),
            ),
          ],
        ));
      }),
    );
  }
}
