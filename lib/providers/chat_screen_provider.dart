import 'package:flutter/cupertino.dart';

enum ImageViewState {
  imageIdle,
  imageLoading
}

enum ImageOnTapAvailability{
  yes,no
}
class ChatScreenProvider extends ChangeNotifier{
  ImageViewState _imageViewState = ImageViewState.imageIdle;
  ImageOnTapAvailability _imageOnTapAvailability = ImageOnTapAvailability.no;

  ImageOnTapAvailability get imageOnTapAvailability => _imageOnTapAvailability;

  set imageOnTapAvailability(ImageOnTapAvailability value) {
    _imageOnTapAvailability = value;
  }

  ImageViewState get imageViewState => _imageViewState;

  void setToLoading(){
    _imageViewState = ImageViewState.imageLoading;
    notifyListeners();
  }

  void setToIdle(){
    _imageViewState = ImageViewState.imageIdle;
    notifyListeners();
  }


}