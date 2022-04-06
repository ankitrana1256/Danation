import 'dart:async';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ngo/apptheme.dart';
import 'package:ngo/authentication/functions/firebase.dart';
import 'package:ngo/models/donation_modal.dart';
import 'package:ngo/widgets/button.dart';
import 'package:ngo/widgets/field_title.dart';
import 'package:ngo/widgets/input.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import '../../providers/submit_page_provider.dart';
import 'donation_submit_loading_screen.dart';

class UserInfo extends StatefulWidget {
  // final List<File> images;
  // final List<Map<String,dynamic>> items;

  UserInfo({Key? key}) : super(key: key);

  @override
  _UserInfoState createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  String username = 'user';
  final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
  bool hasValue = false;
  // late StreamSubscription _streamSubscription;
  // late final manager;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final Set<Marker> _markers = {};
  Location currentLocation = Location();
  GoogleMapController? _googleMapController;
  final _formKey = GlobalKey<FormState>();
  TimeOfDay? time;
  late DateTime date;
  late int _phoneNumber;
  late StreamSubscription _streamSubscription;
  var _initialCameraPosition = const CameraPosition(
    target: LatLng(20.5937, 78.9629),
    zoom: 0,
  );

  Future fetchUserData() async {
    final Map<String, dynamic> userInfo = await getUserInfo(currentUserUid);
    username = userInfo['username']!;
    _emailController.text = userInfo['email']!;
  }

  void getLocation() async {
    _streamSubscription = currentLocation.onLocationChanged.listen(
      (LocationData loc) {
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0),
          ),
        );
        setState(() {
          _initialCameraPosition = CameraPosition(
            target: LatLng(loc.latitude!, loc.longitude!),
            zoom: 16,
          );
          if (hasValue == false) {
            _googleMapController!.animateCamera(
              CameraUpdate.newCameraPosition(_initialCameraPosition),
            );
            hasValue = true;
          }
          _markers.add(Marker(
              onTap: () {
                _locationController.text = '${loc.latitude},${loc.longitude}';
              },
              infoWindow: const InfoWindow(title: 'Address set'),
              markerId: const MarkerId('Home'),
              position: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0)));
          // ('${loc.latitude} ${loc.longitude}');
        });
      },
    );
  }

  void getDate() async {
    date = (await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 0)),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    ))!;

    if (date != null) {
      _dateController.text = '${date.day}/${date.month}/${date.year}';
    }
  }

  void getTime() async {
    time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      _timeController.text = DateFormat().add_jm().format(DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          time!.hour,
          time!.minute));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData().whenComplete(() => setState(() => {}));
    getLocation();
    print('getting in init');
    // getLocation();
  }

  @override
  void dispose() {
    _googleMapController?.dispose();
    // _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<SubmitPageProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        foregroundColor: Colors.black,
        title: const Text(
          'Donation Request',
          style: AppTheme.title,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: CircleAvatar(
                backgroundColor: AppTheme.button,
                foregroundColor: Colors.white,
                radius: 50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 36,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      username.toLowerCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const FieldTitle(title: 'Email'),
            InputField(_emailController, TextInputType.emailAddress),
            const SizedBox(height: 14),
            const FieldTitle(title: 'Phone Number'),
            Form(
              key: _formKey,
              child: Container(
                margin: const EdgeInsets.only(top: 8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 1),
                    )
                  ],
                  color: AppTheme.nearlyWhite,
                ),
                child: TextFormField(
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10)
                  ],
                  controller: _phoneController,
                  cursorColor: Colors.black,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 14),
                  validator: (text) {
                    if (text != null && (text.length < 10 || text.isEmpty)) {
                      return 'Enter a valid mobile number';
                    }
                  },
                  onChanged: (text) {
                    _formKey.currentState!.validate();
                    setState(() => _phoneNumber = int.parse(text));
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Add the location of  pickup place, if you want ngo to come and pick it up',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 10),
            Row(
              // crossAxisAlignment: CrossAxisAlignment.baseline,
              // textBaseline: TextBaseline.alphabetic,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FieldTitle(title: 'Date'),
                        GestureDetector(
                          onTap: getDate,
                          child: AbsorbPointer(
                            child: InputField(
                              _dateController,
                              TextInputType.text,
                              suffix: const Icon(Icons.date_range,
                                  color: Colors.black),
                              textAlignVertical: TextAlignVertical.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FieldTitle(title: 'Time'),
                        GestureDetector(
                          onTap: getTime,
                          child: AbsorbPointer(
                            child: InputField(
                              _timeController,
                              TextInputType.text,
                              suffix: const Icon(Icons.access_time,
                                  color: Colors.black),
                              textAlignVertical: TextAlignVertical.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const FieldTitle(title: 'Address of Pickup'),
            const SizedBox(height: 8),
            InputField(
              _locationController,
              TextInputType.streetAddress,
              readOnlyField: true,
            ),
            const SizedBox(height: 14),
            Container(
              color: Colors.black.withOpacity(0.3),
              height: 200,
              child: Stack(
                children: [
                  GoogleMap(
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    initialCameraPosition: _initialCameraPosition,
                    onMapCreated: (controller) =>
                        _googleMapController = controller,
                    markers: _markers,
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: ElevatedButton(
                      onPressed: () => _googleMapController!.animateCamera(
                          CameraUpdate.newCameraPosition(
                              _initialCameraPosition)),
                      child: const Text('Tap on marker'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Button('SUBMIT', () async {
              if (_emailController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Enter the email address.'),
                  backgroundColor: Theme.of(context).errorColor,
                ));
              } else if (_phoneController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Enter the phone number.'),
                  backgroundColor: Theme.of(context).errorColor,
                ));
              } else if (!_formKey.currentState!.validate()) {
                // on success, notify the parent widget
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Check your phone number again.'),
                  backgroundColor: Theme.of(context).errorColor,
                ));
              } else if (_dateController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Enter the pickup date.'),
                  backgroundColor: Theme.of(context).errorColor,
                ));
              } else if (_timeController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Enter the pickup time.'),
                  backgroundColor: Theme.of(context).errorColor,
                ));
              } else if (_locationController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Enter the pickup location.'),
                  backgroundColor: Theme.of(context).errorColor,
                ));
              } else {
                Donation donation = Donation(
                    donorName: username,
                    images: manager.images,
                    items: manager.items,
                    accepted: false,
                    pickupDateTime: DateTime(date.year, date.month, date.day,
                        time!.hour, time!.minute),
                    donorEmail: _emailController.text,
                    pickupCoordinates: _locationController.text,
                    donorID: currentUserUid,
                    donorPhone: _phoneNumber,
                    createdON: DateTime.now(),
                    donationCategory: DonationCategory.Food);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            SubmitLoadingScreen(donation: donation)));
              }
            }),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: const Color(0xFFE78888),
              ),
              child: const Text(
                'Warning:  False Requests for pickup can result in ban of your account',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
