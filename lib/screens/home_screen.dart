import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

import '../controllers/user_data_controller.dart';
import '../models/journal_entry.dart';
import '../services/information_service.dart';
import '../routing/router.dart';
import '../dialogs/waiting_dialog.dart';

class HomeScreen extends StatefulWidget {
  static const route = '/home';
  static const name = 'Home';

  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(0, 0),
    zoom: 2,
  );
  bool _loadingLocation = true;

  @override
  void initState() {
    super.initState();
    _determinePosition().then((position) {
      setState(() {
        _initialPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15,
        );
        _loadingLocation = false;
      });
    }).catchError((e) {
      setState(() {
        _loadingLocation = false;
      });
      Info.showSnackbarMessage(context, message: e.toString(), label: "Error");
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied, we cannot request permissions.';
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<String> _getAddressFromGeoPoint(GeoPoint geoPoint) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(geoPoint.latitude, geoPoint.longitude);
      Placemark place = placemarks[0];
      return "${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}, ${place.country}";
    } catch (e) {
      print("Error fetching address: $e");
      return "Unknown location";
    }
  }

  void _showEntryDetails(BuildContext context, JournalEntry entry) async {
    String address = await _getAddressFromGeoPoint(entry.location);
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entry.imageUrls.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(CupertinoIcons.clear))
                  ],
                ),
              const SizedBox(height: 12),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(entry.imageUrls.first),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(CupertinoIcons.location_solid,
                      color: Colors.deepPurpleAccent),
                  const SizedBox(width: 4),
                  Text(
                    address,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(CupertinoIcons.calendar,
                      color: Colors.deepPurpleAccent),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat.yMMMMd().format(entry.date),
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(entry.content),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _loadingLocation
          ? const WaitingDialog(
              prompt: "Loading...",
              color: Colors.deepPurpleAccent,
            )
          : SafeArea(
              child: ValueListenableBuilder<List<JournalEntry>>(
                valueListenable:
                    UserDataController.instance.journalEntriesNotifier,
                builder: (context, entries, child) {
                  if (entries.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          "“Journaling is like whispering to one's self and listening at the same time.”\n\n- Mina Murray",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    );
                  }

                  Set<Marker> markers = entries.map((entry) {
                    return Marker(
                      markerId: MarkerId(entry.id),
                      position: LatLng(
                          entry.location.latitude, entry.location.longitude),
                      infoWindow: InfoWindow(
                          title: entry.title, snippet: entry.content),
                      onTap: () {
                        _showEntryDetails(context, entry);
                      },
                    );
                  }).toSet();

                  return GoogleMap(
                    initialCameraPosition: _initialPosition,
                    zoomControlsEnabled: false,
                    myLocationEnabled: true,
                    markers: markers,
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurpleAccent,
        onPressed: () {
          if (UserDataController.instance.currentUserId != null) {
            GlobalRouter.I.router.go('/entry/new');
          } else {
            Info.showSnackbarMessage(context,
                message: "Please log in to add a journal entry.");
          }
        },
        child: const Icon(
          CupertinoIcons.square_pencil,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
