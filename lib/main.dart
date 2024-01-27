import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mausam_app/pages/home.dart';
import 'package:mausam_app/pages/loading.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();

  var deviceIds = ["48E0041DFD6567F7509C3B093E447BDD, 90DB8426209025157901D4CFA3F7FDBC"];
  RequestConfiguration requestConfiguration = RequestConfiguration(
    testDeviceIds: deviceIds,
  );
  MobileAds.instance.updateRequestConfiguration(requestConfiguration);


  runApp(
      ScreenUtilInit(
          designSize: const Size(430, 932),
          builder: (_ , child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              routes: {
                "/" : (context) => LoadingPage(),
                "/home" : (context) => HomePage(),
                "/loading" : (context) => LoadingPage(),

              },
            );
          }
      ),
      );
}

