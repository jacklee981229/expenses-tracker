class DefaultCategory {
  const DefaultCategory(this.name, this.iconKey, this.colorHex);

  final String name;
  final String iconKey;
  final String colorHex;
}

/// Seeded on first launch, in this order. Colours are from the palette in
/// `category_colors.dart`.
const List<DefaultCategory> kDefaultCategories = [
  DefaultCategory('Food', 'food', 'E9695B'),
  DefaultCategory('Groceries', 'groceries', '4AB771'),
  DefaultCategory('Transport', 'transport', 'F6AA55'),
  DefaultCategory('Petrol', 'petrol', 'F3776B'),
  DefaultCategory('Toll & Parking', 'parking', '3DBEA9'),
  DefaultCategory('Utilities', 'utilities', 'FAC551'),
  DefaultCategory('Rent', 'rent', 'EA967A'),
  DefaultCategory('Phone & Internet', 'internet', '6395EC'),
  DefaultCategory('Shopping', 'shopping', 'E47CC0'),
  DefaultCategory('Entertainment', 'entertainment', 'A16AEA'),
  DefaultCategory('Health', 'health', '4FB3E8'),
  DefaultCategory('Education', 'education', '7B80E8'),
  DefaultCategory('Travel', 'travel', 'A5C85A'),
  DefaultCategory('Others', 'others', '9E9EA3'),
];
