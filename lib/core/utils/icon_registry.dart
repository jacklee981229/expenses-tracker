/// Category icons, stored in the database by key: Fluent Emoji 3D images
/// in `assets/icons/`, one per key, named after it.
///
/// This must stay a static const map, so a stored key can only ever name a
/// bundled image; an unknown key falls back to [kFallbackIconKey].
const Map<String, String> kIconRegistry = {
  'food': 'assets/icons/food.png',
  'fastfood': 'assets/icons/fastfood.png',
  'snack': 'assets/icons/snack.png',
  'coffee': 'assets/icons/coffee.png',
  'drinks': 'assets/icons/drinks.png',
  'groceries': 'assets/icons/groceries.png',
  'transport': 'assets/icons/transport.png',
  'car': 'assets/icons/car.png',
  'taxi': 'assets/icons/taxi.png',
  'train': 'assets/icons/train.png',
  'petrol': 'assets/icons/petrol.png',
  'parking': 'assets/icons/parking.png',
  'utilities': 'assets/icons/utilities.png',
  'rent': 'assets/icons/rent.png',
  'internet': 'assets/icons/internet.png',
  'phone': 'assets/icons/phone.png',
  'shopping': 'assets/icons/shopping.png',
  'clothes': 'assets/icons/clothes.png',
  'beauty': 'assets/icons/beauty.png',
  'entertainment': 'assets/icons/entertainment.png',
  'game': 'assets/icons/game.png',
  'music': 'assets/icons/music.png',
  'movie': 'assets/icons/movie.png',
  'book': 'assets/icons/book.png',
  'education': 'assets/icons/education.png',
  'health': 'assets/icons/health.png',
  'medical': 'assets/icons/medical.png',
  'gym': 'assets/icons/gym.png',
  'insurance': 'assets/icons/insurance.png',
  'subscription': 'assets/icons/subscription.png',
  'travel': 'assets/icons/travel.png',
  'pet': 'assets/icons/pet.png',
  'gift': 'assets/icons/gift.png',
  'charity': 'assets/icons/charity.png',
  'laundry': 'assets/icons/laundry.png',
  'haircut': 'assets/icons/haircut.png',
  'baby': 'assets/icons/baby.png',
  'tools': 'assets/icons/tools.png',
  'savings': 'assets/icons/savings.png',
  'others': 'assets/icons/others.png',
};

const String kFallbackIconKey = 'others';

String iconAssetForKey(String key) =>
    kIconRegistry[key] ?? kIconRegistry[kFallbackIconKey]!;

/// Interface icons from the same set, so every picture in the app matches.
abstract final class UiIcons {
  static const String receipt = 'assets/icons/ui_receipt.png';
  static const String chart = 'assets/icons/ui_chart.png';
  static const String gear = 'assets/icons/ui_gear.png';
  static const String sun = 'assets/icons/ui_sun.png';
  static const String calendar = 'assets/icons/ui_calendar.png';
  static const String label = 'assets/icons/ui_label.png';
  static const String plus = 'assets/icons/ui_plus.png';
}
