import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:day41/pages/find_friends.dart';

import 'package:geolocator/geolocator.dart';
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


    Socket.connect('192.168.1.33', 8889).then((socket) {

      String data = _currentPosition.toString();

      socket.encoding = utf8; // <== force the encoding
      socket.write(data);
      print("sent: $data");
    }).catchError(print);



    if (usernameController.text == 'asba') {
      // If the username is correct, navigate to the FindFriends page
      Navigator.push(context, MaterialPageRoute(builder: (context) => FindFriends(userLocation: _newLocation),),);
      // If the username is incorrect, display an error message
      setState(() {
        errorMessage = 'Incorrect username. Please try again.';
      });
    }
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
