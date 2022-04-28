import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'app/services/auth_service.dart';
import 'firebase_options.dart';

void main() async {
  // configureApp(); //remove # in url
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    GetMaterialApp.router(
      debugShowCheckedModeBanner:false,
      title: "Application",
      initialBinding: BindingsBuilder((){
        Get.put(AuthService());
      }),
      getPages: AppPages.routes,
    ),
  );
}
