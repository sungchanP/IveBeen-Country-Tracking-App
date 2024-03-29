
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class GetCountryCodeHelper{

  Position? curPositionStatus;
  //List<Placemark>? placemarks;
  Placemark? placemark;
  String? countryCode;
  bool ableToGetLocation = false;

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the 
      // App to enable the location services.
      throw Exception('Location services are disabled.');
      //return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale 
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        throw Exception('Location permissions are denied');
        //return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      throw Exception('Location permissions are permanently denied, we cannot request permissions.');
      // return Future.error(
      //   'Location permissions are permanently denied, we cannot request permissions.');
    } 

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    ableToGetLocation = true;
    return await Geolocator.getCurrentPosition();
  }

  // Future getCountry() async{
  //   await _determinePosition().then((value) {
  //       if (ableToGetLocation){
  //         curPositionStatus = value;
  //       }
  //     }
  //   );
  //   return convertGeocode(curPositionStatus!.latitude, curPositionStatus!.longitude);
  // }

  Future getCountry() async{
    try{
      var value = await _determinePosition();
      return convertGeocode(value.latitude, value.longitude);
    } catch (e){
      //print(e);
      return e;
      //Geolocator.openLocationSettings();
    }
    //var value = await _determinePosition().catchError((Object obj) => (obj as Future).catchError(print));
    // print(value.runtimeType);
    // return convertGeocode(value.latitude, value.longitude);
  }

  Future<String?> convertGeocode(double lat, double long) async{
    await placemarkFromCoordinates(lat, long).then((value) {
      placemark = value[0];
    });
    return placemark!.isoCountryCode;
  }

}