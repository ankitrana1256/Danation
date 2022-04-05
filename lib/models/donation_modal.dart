import 'dart:io';

enum DonationCategory { Food, Education, Health }

class Donation {
  final bool? accepted;
  final String donorID;
  final String donorEmail;
  final int donorPhone;
  final DateTime pickupDateTime;
  final DateTime? createdON;
  final String pickupCoordinates;
  final List<Map<String, dynamic>> items;
  final List<File> images;
  final String donorName;
  final DonationCategory donationCategory;

  Donation(
      {this.accepted,
      this.createdON,
      required this.donorName,
      required this.pickupDateTime,
      required this.donorEmail,
      required this.images,
      required this.items,
      required this.pickupCoordinates,
      required this.donorPhone,
      required this.donorID,
      required this.donationCategory});
}
