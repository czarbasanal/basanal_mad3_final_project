import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/place_type.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationPickerScreen extends StatefulWidget {
  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late GoogleMapController mapController;
  LatLng? _pickedLocation;
  LatLng? _currentLocation;
  final TextEditingController controller = TextEditingController();
  final String googleAPIKey = 'AIzaSyA8gbYPIkeogFe1SMXhvSrvHcPC8I76veU';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _pickedLocation = _currentLocation;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onTap(LatLng location) {
    setState(() {
      _pickedLocation = location;
    });
    _moveCamera(location);
  }

  void _confirmLocation() {
    Navigator.of(context).pop(_pickedLocation);
  }

  void _moveCamera(LatLng location) {
    mapController.animateCamera(CameraUpdate.newLatLng(location));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick Location'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _confirmLocation,
          )
        ],
      ),
      body: _currentLocation == null
          ? const Center(
              child: SpinKitChasingDots(color: Colors.deepPurpleAccent))
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation!,
                    zoom: 14,
                  ),
                  onTap: _onTap,
                  markers: _pickedLocation != null
                      ? {
                          Marker(
                            markerId: const MarkerId('pickedLocation'),
                            position: _pickedLocation!,
                          ),
                        }
                      : {},
                ),
                Positioned(
                  top: 16.0,
                  left: 16.0,
                  right: 16.0,
                  child: GooglePlaceAutoCompleteTextField(
                    textEditingController: controller,
                    googleAPIKey: googleAPIKey,
                    inputDecoration: InputDecoration(
                      hintText: 'Search location...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 16.0),
                    ),
                    debounceTime: 600,
                    countries: const ["ph"],
                    isLatLngRequired: true,
                    getPlaceDetailWithLatLng: (Prediction prediction) {
                      print("placeDetails" + prediction.lng.toString());
                    },
                    itemClick: (Prediction prediction) async {
                      setState(() {
                        controller.text = prediction.description!;
                        controller.selection = TextSelection.fromPosition(
                          TextPosition(offset: prediction.description!.length),
                        );
                      });

                      final placeId = prediction.placeId;
                      final details = await getPlaceDetails(placeId!);
                      if (details != null) {
                        final location = details['geometry']['location'];
                        final latLng = LatLng(location['lat'], location['lng']);
                        setState(() {
                          _pickedLocation = latLng;
                        });
                        _moveCamera(latLng);
                      }
                    },
                    itemBuilder: (context, index, Prediction prediction) {
                      return Container(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(prediction.description ?? ""),
                            ),
                          ],
                        ),
                      );
                    },
                    seperatedBuilder: const Divider(),
                    isCrossBtnShown: true,
                    containerHorizontalPadding: 10,
                    placeType: PlaceType.geocode,
                  ),
                ),
              ],
            ),
    );
  }

  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$googleAPIKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['result'];
    }
    return null;
  }
}
