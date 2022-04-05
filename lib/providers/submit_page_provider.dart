import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ngo/models/category_field_modal.dart';

class SubmitPageProvider with ChangeNotifier {
  // CategoryFieldModal categoryFieldModal = CategoryFieldModal(id: id)

  final _items = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> get items => List.unmodifiable(_items);

  final List<File> _images = [];
  List<File> get images => _images;

  final List<TextEditingController> _typeFoodControllers =
      <TextEditingController>[];
  List<TextEditingController> get typeFoodControllers => _typeFoodControllers;

  final List<TextEditingController> _quantityControllers =
      <TextEditingController>[];
  List<TextEditingController> get quantityControllers => _quantityControllers;

  bool foodControllerIsEmpty = false;
  bool quantityControllerIsEmpty = false;

  void addQuantityControllerToControllerList(
      TextEditingController textEditingController) {
    _quantityControllers.add(textEditingController);
    notifyListeners();
  }

  void removeQuantityControllerFromControllerList(
      TextEditingController textEditingController) {
    _quantityControllers.remove(textEditingController);
    notifyListeners();
  }

  void removeAllQuantityControllerFromControllerList() {
    _quantityControllers.clear();
    notifyListeners();
  }

  void addTypeFoodControllerToControllerList(
      TextEditingController textEditingController) {
    _typeFoodControllers.add(textEditingController);
    notifyListeners();
  }

  void removeTypeFoodControllerFromControllerList(
      TextEditingController textEditingController) {
    _typeFoodControllers.remove(textEditingController);
    notifyListeners();
  }

  void removeAllTypeFoodControllerFromControllerList() {
    _typeFoodControllers.clear();
    notifyListeners();
  }

  void addItemToImagesList(File imageFile) {
    _images.add(imageFile);
    notifyListeners();
  }

  void removeItemToImagesList(File imageFile) {
    _images.remove(imageFile);
    notifyListeners();
  }

  void removeAllItemFromImageList() {
    _images.clear();
    notifyListeners();
  }

  void deleteItem(String id) {
    final item = _items.firstWhere((element) => element['id'] == id);
    int index = _items.indexOf(item);
    _items.removeAt(index);
    notifyListeners();
  }

  void deleteAll() {
    _items.clear();
  }

  void addItem(CategoryFieldModal item) {
    _items.add(item.toJson());
    notifyListeners();
  }
}
