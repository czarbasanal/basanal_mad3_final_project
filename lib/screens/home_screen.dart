import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  late CameraPosition _initialPosition = CameraPosition(
    target: LatLng(0, 0),
    zoom: 2,
  );
  bool _loadingLocation = true;
  final userDataController = GetIt.instance<UserDataController>();

  @override
  void initState() {
    super.initState();
    _requestLocationPermission().then((_) => _setInitialLocation());
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      Info.showSnackbarMessage(context,
          message: "Location permission permanently denied.", label: "Error");
    }
  }

  Future<void> _setInitialLocation() async {
    try {
      Position position = await _determinePosition();
      setState(() {
        _initialPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 12.0,
        );
        _loadingLocation = false;
        _updateLoadingState(_loadingLocation);
      });
    } catch (e) {
      print('Error fetching location: $e');
      setState(() {
        _loadingLocation = false;
        _updateLoadingState(_loadingLocation);
      });
    }
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

  void _updateLoadingState(bool loading) {
    if (mounted) {
      setState(() => _loadingLocation = loading);
    }
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
                valueListenable: userDataController.journalEntriesNotifier,
                builder: (context, entries, child) {
                  if (entries.isEmpty) {
                    return const Center(
                        child: Text('No journal entries found'));
                  }
                  return GoogleMap(
                    initialCameraPosition: _initialPosition,
                    zoomControlsEnabled: false,
                    markers: entries.map((entry) {
                      return Marker(
                        markerId: MarkerId(entry.id),
                        position: LatLng(
                            entry.location.latitude, entry.location.longitude),
                        infoWindow: InfoWindow(
                            title: entry.title, snippet: entry.content),
                        onTap: () {
                          GlobalRouter.I.router.go('/entry/${entry.id}');
                        },
                      );
                    }).toSet(),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurpleAccent,
        onPressed: () {
          if (userDataController.currentUserId != null) {
            GlobalRouter.I.router.go('/entry/new');
          } else {
            Info.showSnackbarMessage(context,
                message: "Please log in to add a journal entry.");
          }
        },
        child: const Icon(
          CupertinoIcons.square_pencil,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
