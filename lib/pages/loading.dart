import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:mausam_app/worker/worker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {

  var city_name = "loading";

  var isLocFetched = false;

  var currentCity = "loading";

  Future<void> getCurrentLocation() async {
    // Check and request location permissions
    var status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);

        if (placemarks.isNotEmpty) {
          Placemark currentPlacemark = placemarks[0];
          setState(() {
            currentCity = currentPlacemark.locality ?? "Unknown City";
            isLocFetched = true;
          });
        }
      } catch (e) {
        print("Error getting current location: $e");
      }
    } else {
      currentCity = "Noida";
      isLocFetched=true;
      print("Location permission denied");
    }
  }

  void callAPI(String city_name) async {
    try {
      Worker jaspur = Worker(city: city_name);
      await jaspur.getAPIdata();

      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          city_name = jaspur.name;
        });
      }

      print("Description : " + jaspur.desc);
      print("Windspeed : " + jaspur.windspeed);
      print("Temperature : " + jaspur.temp);
      print("Humidity : " + jaspur.humidity);
      print("Icon : " + jaspur.icon);

      // Rest of your code...

      Future.delayed(Duration(seconds: 1), () {
        // Check if the widget is still mounted before navigating
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home', arguments: {
            "keyName": jaspur.name,
            "keyDesc": jaspur.desc,
            "keyWindspeed": jaspur.windspeed,
            "keyTemp": jaspur.temp,
            "keyHumidity": jaspur.humidity,
            "keyIcon": jaspur.icon,
          });
        }
      });
    } catch (e) {
      print("Error in callAPI: $e");
      // Handle errors here
    }
  }


  @override
  void initState() {
    super.initState();

    getCurrentLocation();
    print("init called");

  }


  @override
  Widget build(BuildContext context) {
    final homeMap = ModalRoute.of(context)!.settings.arguments as Map?;

    if (homeMap?.isNotEmpty ?? false){
      city_name = homeMap?['searchData'];
      callAPI(city_name);
    }
    else{
      if (isLocFetched){

      city_name = currentCity;
      callAPI(city_name);
      }
    }

    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    var devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    return Scaffold(
      body: Stack(
        children: [
          Lottie.network("https://assets5.lottiefiles.com/packages/lf20_HlhzUG.json", height: double.infinity, width: double.infinity, fit: BoxFit.cover),
          SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 100.h,),
                  Text("$city_name", style: TextStyle(fontSize: 45.sp, fontWeight: FontWeight.bold, color: Color(0xffe7ebf4), fontFamily: 'Jost'),),
                  SizedBox(height: 270.h,),
                  SpinKitFoldingCube(size: 50.w, color: Colors.white38,),
                  SizedBox(height: 250.h,),
                  Text("Mausam App", style: TextStyle(fontSize: 65.sp, fontWeight: FontWeight.bold, color: Color(0xffe7ebf4), fontFamily: 'Comforter'),),
                  Text("Discover the world through weather's ever-changing canvas.", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Color(0xffe7ebf4), fontStyle: FontStyle.italic, fontFamily: 'Jost'), ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

