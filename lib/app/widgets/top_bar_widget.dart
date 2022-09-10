import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../routes/app_pages.dart';

Widget topBar(String? semId) {
  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(
        children: [
          SizedBox(
              height: 70,
              width: 70,
              child: Image.asset('assets/handong_logo.png')),
          SizedBox(
            width: 8,
          ),
          GestureDetector(
            onTap: () {
              Get.rootDelegate.toNamed(Routes.HOME);
            },
            child: Text(
              'HISTUDY',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
            ),
          ),
          SizedBox(
            width: 8,
          ),
          TextButton(
              onPressed: () {
                if (semId != null) {
                  Get.rootDelegate.toNamed(
                    Routes.REPORT_LIST,
                    arguments: true,
                    parameters: {'semId': semId},
                  );
                }
              },
              child: Text(
                "REPORT",
                style: TextStyle(color: Color(0xff04589C)),
              )),
          TextButton(
              onPressed: () {
                if (semId != null) {
                  Get.rootDelegate.toNamed(
                    Routes.GROUP_INFO,
                    arguments: true,
                    parameters: {'semId': semId},
                  );
                }
              },
              child: Text(
                "TEAM",
                style: TextStyle(color: Color(0xff04589C)),
              )),
          TextButton(
              onPressed: () {
                if (semId != null) {
                  Get.rootDelegate.toNamed(
                    Routes.QUESTION,
                    arguments: true,
                    parameters: {'semId': semId},
                  );
                }
              },
              child: Text(
                "Q&A",
                style: TextStyle(color: Color(0xff04589C)),
              )),
          TextButton(
              onPressed: () {
                if (semId != null) {
                  Get.rootDelegate.toNamed(
                    Routes.ANNOUNCE,
                    arguments: true,
                    parameters: {'semId': semId},
                  );
                }
              },
              child: Text(
                "ANNOUNCEMENT",
                style: TextStyle(color: Color(0xff04589C)),
              )),
        ],
      ),
      Row(
        children: [
          TextButton(
              onPressed: () {
                if (semId != null) {
                  Get.rootDelegate.toNamed(
                    Routes.RANK,
                    arguments: true,
                    parameters: {'semId': semId},
                  );
                }
              },
              child: Text(
                "RANK",
                style: TextStyle(color: Color(0xff04589C)),
              )),
          TextButton(
              onPressed: () async {
                await launchUrl(Uri.parse(
                    "https://ryuha.notion.site/Histudy-Guildeline-da40cd57a8dc447ebc37cd0a9ff23c27"));
              },
              child: Text(
                "GUIDELINE",
                style: TextStyle(color: Color(0xff04589C)),
              )),
          TextButton(
              onPressed: () {
                if (semId != null) {
                  Get.rootDelegate.toNamed(
                    Routes.MY_PAGE,
                    arguments: true,
                    parameters: {'semId': semId},
                  );
                }
              },
              child: Text(
                "MY PAGE",
                style: TextStyle(color: Color(0xff04589C)),
              )),
        ],
      ),
    ]),
  );
}
