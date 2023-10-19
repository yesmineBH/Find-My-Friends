import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:day41/pages/find_friends.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:day41/model/login_page.dart';
import 'package:day41/model/map_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LatLng? _newLocation;
  Position? _currentPosition;

  Future<void> _getLocation() async {
    LocationPermission permission;
    try {
      permission = await Geolocator.requestPermission();
    } catch (e) {
      print('Erreur lors de la demande d\'autorisation de localisation : $e');
      return;
    }

    if (permission == LocationPermission.denied) {
      print('L\'utilisateur a refusé l\'autorisation de localisation.');
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      setState(() {
        _currentPosition = position;
        print('***********************'+_currentPosition.toString());
      });
    } catch (e) {
      print('Erreur lors de la récupération de la localisation : $e');
    }
  }


  TextEditingController usernameController = TextEditingController();
  String errorMessage = ''; // Store error message

  void onFindFriendsPressed() async {
    await _getLocation();

    while (_currentPosition == null) {
      _getLocation();
    }

    setState(() {
      // Save the new location
      if (_currentPosition != null) {
        _newLocation =LatLng(_currentPosition?.latitude ?? 0.0, _currentPosition?.longitude ?? 0.0);
      }
    });

    Map<String, dynamic> userData = {
      "name": usernameController.text,
      "position": _newLocation,
      "marker": 'assets/markers/marker-1.png',
      "image": 'assets/images/avatar-1.png',
    };
    if (usernameController.text == 'asba') {
      // If the username is correct, navigate to the FindFriends page
      Navigator.push(context, MaterialPageRoute(builder: (context) => FindFriends(userData: userData),),);
      // If the username is incorrect, display an error message
      setState(() {
        errorMessage = 'Incorrect username. Please try again.';
      });
    }
    // Convert the list to a JSON string for sending
    String jsonData = json.encode(userData);

    Socket.connect('192.168.1.182', 8889).then((socket) {

      socket.encoding = utf8; // <== force the encoding
      socket.write(jsonData);
      print("sent: $jsonData");
    }).catchError(print);




  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Who are you ?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: onFindFriendsPressed,
                child: Text('Find My Friends'),
              ),
              if (errorMessage.isNotEmpty) // Display error message if not empty
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
