import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String name = "Jaspur";
  String desc = "description";
  String windspeed = "0.0";
  String temperature = "00.0";
  String humidity = "0.0";
  String icon = "02d";

  var searchCtrl = TextEditingController();


  var sampleBanner = "ca-app-pub-3940256099942544/6300978111";
  var sampleInterstitial = "ca-app-pub-3940256099942544/1033173712";
  var actualBanner = "ca-app-pub-8307889997080678/3804387758";
  var actualInterstitial = "ca-app-pub-8307889997080678/8349604599";


  late BannerAd bannerAd;
  bool isBannerLoaded = false;


  late InterstitialAd interstitialAd;
  bool isInterstitialLoaded = false;

  var adUnitBanner;
  var adUnitInterstitial;

  void initInterestitialAd() async{
    await InterstitialAd.load(
      adUnitId: adUnitInterstitial,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad){

            if (mounted){
              setState(() {
                print("interestitial loaded");
                interstitialAd = ad;
                isInterstitialLoaded = true;
              });
            }

          },
          onAdFailedToLoad: (err){
            if (mounted){
              setState(() {
                print("interestitial error");
                print(err.toString());
                interstitialAd.dispose();
                isInterstitialLoaded = false;
              });
            }
          }
      ),
    );
  }
  void initBannerAd() async{
    bannerAd = BannerAd(
      size: AdSize.fullBanner,
      adUnitId: adUnitBanner,
      request: AdRequest(),
      listener: BannerAdListener(
          onAdLoaded: (ad){
            if (mounted){
              setState(() {
                print("banner loaded");
                isBannerLoaded = true;
              });
            }
          },
          onAdClosed: (ad){

            if (mounted){
              setState(() {
                print("banner closed");
                ad.dispose();
                isBannerLoaded = false;
              });
            }

          },
          onAdFailedToLoad: (ad, err){

            if (mounted) {
              setState(() {
                print("banner error");
                print(err.toString());
                ad.dispose();
                isBannerLoaded = false;
              });
            }
          }
      ),
    );

    await bannerAd.load();
  }

  @override
  void initState() {
    super.initState();

    adUnitBanner = Platform.isAndroid ? actualBanner : "ca-app-pub-3940256099942544/2934735716";
    adUnitInterstitial = Platform.isAndroid ? actualInterstitial : "ca-app-pub-3940256099942544/4411468910";


    initBannerAd();
    initInterestitialAd();
  }

  @override
  Widget build(BuildContext context) {

    final fetchedMap = ModalRoute.of(context)!.settings.arguments as Map;
    print(fetchedMap);

    name = fetchedMap['keyName'];
    desc = fetchedMap['keyDesc'];
    humidity = fetchedMap['keyHumidity'];
    icon = fetchedMap['keyIcon'];
    temperature = fetchedMap['keyTemp'];
    windspeed = fetchedMap['keyWindspeed'];

    if (windspeed == "NA" && temperature =="NA"){

    }
    else{
      windspeed = fetchedMap['keyWindspeed'].toString().substring(0,3);
      temperature = fetchedMap['keyTemp'].toString().substring(0,4);
    }



    return Scaffold(
      extendBody: true,
      bottomNavigationBar: isBannerLoaded ? SizedBox(
        height: 60.h,
        width: double.infinity,
        child: AdWidget(ad: bannerAd,),
      ) : Container(height: 60.h,),
      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: EdgeInsets.fromLTRB(23.w, 56.h, 23.w, 0),
            child: Column(
              children: [
                Container(
                  height: 51.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.r),
                    color: Color(0xffc3c8cb),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(18.w, 0, 8.w, 0),
                        child: InkWell(
                            onTap: (){
                              HapticFeedback.heavyImpact();
                              if (searchCtrl.text.replaceAll(" ", "") != ""){

                                if (isInterstitialLoaded){
                                  interstitialAd.show();
                                  interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
                                      onAdDismissedFullScreenContent: (ad){
                                        setState(() {
                                          ad.dispose();
                                          isInterstitialLoaded = false;
                                          Navigator.pushReplacementNamed(context, '/loading', arguments: {
                                            "searchData": searchCtrl.text.trim().toString(),
                                          });
                                          print("Navigator");
                                        });
                                      },
                                      onAdFailedToShowFullScreenContent: (ad, error){
                                        setState(() {
                                          ad.dispose();
                                          Navigator.pushReplacementNamed(context, '/loading', arguments: {
                                            "searchData": searchCtrl.text.trim().toString(),
                                          });
                                          print(error.toString());
                                        });
                                      }
                                  );
                                }
                                else {
                                  Navigator.pushReplacementNamed(context, '/loading', arguments: {
                                    "searchData": searchCtrl.text.trim().toString(),
                                  });
                                }
                              }

                            },
                            child: Icon(CupertinoIcons.search, size: 25.r,),),
                      ),
                      Expanded(
                        child: TextField(
                          controller: searchCtrl,

                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              if (isInterstitialLoaded){
                                interstitialAd.show();
                                interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
                                    onAdDismissedFullScreenContent: (ad){
                                      setState(() {
                                        ad.dispose();
                                        isInterstitialLoaded = false;
                                        Navigator.pushReplacementNamed(context, '/loading', arguments: {
                                          "searchData": value.trim().toString(),
                                        });
                                        print("Navigator");
                                      });
                                    },
                                    onAdFailedToShowFullScreenContent: (ad, error){
                                      setState(() {
                                        ad.dispose();
                                        Navigator.pushReplacementNamed(context, '/loading', arguments: {
                                          "searchData": value.trim().toString(),
                                        });
                                        print(error.toString());
                                      });
                                    }
                                );
                              }
                              else {
                                Navigator.pushReplacementNamed(context, '/loading', arguments: {
                                  "searchData": value.trim().toString(),
                                });
                              }
                            }
                          },
                          decoration: InputDecoration(
                            hintText: "Search any city name....",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 44.h,),
                Text("$name", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Jost', color: Color(0xffc3c8cb), fontSize: 27.sp,)),
                Text("TODAY", style: TextStyle(fontWeight: FontWeight.normal, fontFamily: 'Jost', color: Color(0xffc3c8cb), fontSize: 14.h,)),
                SizedBox(height: 44.h,),
                Image.network("https://openweathermap.org/img/wn/$icon@2x.png",
                  height: 90.h,
                  width: 90.w,),
                Text("$desc",style: TextStyle(fontWeight: FontWeight.normal, fontFamily: 'Jost', color: Color(0xffc3c8cb), fontSize: 14.h,)),

                SizedBox(height: 48.h,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      // height: 128.h,
                      child: Text(temperature, style: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.bold, color: Color(0xffc3c8cb), fontSize: 88.sp),),
                    ),
                    SizedBox(width: 17.w,),
                    Container(
                      // padding: EdgeInsets.only(top: 10,),
                      // height: 128.h,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("o", style: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.bold, color: Color(0xffc3c8cb), fontSize: 30.sp),),
                          SizedBox(height: 11.h,),
                          Row(
                            children: [
                              SizedBox(width: 11.w,),
                              Text("C", style: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.bold, color: Color(0xffc3c8cb), fontSize: 33.sp),),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 54.h,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Container(
                        height: 193.h,
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                        margin: EdgeInsets.only(right: 8.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          color: Colors.white12,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.water_drop_rounded, color: Color(0xffc3c8cb), size: 30.r,),
                              ],
                            ),
                            SizedBox(height: 15.h,),
                            Text("$humidity", style: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.bold, color: Color(0xffc3c8cb), fontSize: 38.sp),),
                            Text("%", style: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.normal, color: Color(0xffc3c8cb), fontSize: 17.sp),),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 193.h,
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                        margin: EdgeInsets.only(left: 8.r),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          color: Colors.black12,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.waves, color: Color(0xffc3c8cb), size: 30.r,),
                              ],
                            ),
                            SizedBox(height: 15.h,),
                            Text("$windspeed", style: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.bold, color: Color(0xffc3c8cb), fontSize: 38.sp),),
                            Text("km/hr", style: TextStyle(fontFamily: 'Jost', fontWeight: FontWeight.normal, color: Color(0xffc3c8cb), fontSize: 17.sp),),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 69.h,),
                Text("powered by OpenWeatherAPI", style: TextStyle(fontSize: ScreenUtil().setSp(13), fontStyle: FontStyle.italic, color: Color(
                    0xffb1b5b7)),),

              ],
            ),
          ),
        ),
      ),
      backgroundColor: Color(0xff313945),

    );
  }
}
