import 'package:flutter/material.dart';

import '../utils/utils.dart';
import '../widgets/location_list_tile.dart';

class SearchLocationScreen extends StatefulWidget {
  const SearchLocationScreen({Key? key}) : super(key: key);

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: Constants.defaultPadding),
          child: CircleAvatar(
            backgroundColor: Constants.secondaryColor10LightTheme,
            // child: SvgPicture.asset(
            //   "assets/icons/location.svg",
            //   height: 16,
            //   width: 16,
            //   color: secondaryColor40LightTheme,
            // ),
          ),
        ),
        title: Text(
          "Set Delivery Location",
          style: TextStyle(color: Constants.textColorLightTheme),
        ),
        actions: [
          CircleAvatar(
            backgroundColor: Constants.secondaryColor10LightTheme,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.close, color: Colors.black),
            ),
          ),
          const SizedBox(width: Constants.defaultPadding)
        ],
      ),
      body: Column(
        children: [
          Form(
            child: Padding(
              padding: const EdgeInsets.all(Constants.defaultPadding),
              child: TextFormField(
                onChanged: (value) {},
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: "Search your location",
                  // prefixIcon: Padding(
                  //   padding: const EdgeInsets.symmetric(vertical: 12),
                  //   child: SvgPicture.asset(
                  //     "assets/icons/location_pin.svg",
                  //     color: secondaryColor40LightTheme,
                  //   ),
                  // ),
                ),
              ),
            ),
          ),
          Divider(
            height: 4,
            thickness: 4,
            color: Constants.secondaryColor5LightTheme,
          ),
          Padding(
            padding: const EdgeInsets.all(Constants.defaultPadding),
            child: ElevatedButton.icon(
              onPressed: () {},
              // icon: SvgPicture.asset(
              //   "assets/icons/location.svg",
              //   height: 16,
              // ),
              label: const Text("Use my Current Location"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.secondaryColor10LightTheme,
                foregroundColor: Constants.textColorLightTheme,
                elevation: 0,
                fixedSize: const Size(double.infinity, 40),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
          ),
          Divider(
            height: 4,
            thickness: 4,
            color: Constants.secondaryColor5LightTheme,
          ),
          LocationListTile(
            press: () {},
            location: "Banasree, Dhaka, Bangladesh",
          ),
        ],
      ),
    );
  }
}
