class CategoryFieldModal {
  final String id;
  String foodType;
  double foodQuantity;
  String quantityType;

  CategoryFieldModal({
    required this.id,
    this.foodQuantity = 0.0,
    this.foodType = '',
    this.quantityType = 'Kg',
  });

  Map<String,dynamic> toJson() => {
    'id':id,
    'foodType':foodType,
    'foodQuantity':foodQuantity,
    'quantityType':quantityType
  };

}
