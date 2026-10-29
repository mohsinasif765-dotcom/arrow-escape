import '../../services/app_settings.dart';

/// Tiny EN/UR string table for home + settings.
class AppStrings {
  AppStrings(this.app);

  final AppSettings app;

  bool get _ur => app.isUrdu;

  String get levels => _ur ? 'لیولز' : 'Levels';
  String get level => _ur ? 'لیول' : 'Level';
  String get unlocked => _ur ? 'انلاک' : 'unlocked';
  String get quests => _ur ? 'کوئسٹس' : 'Quests';
  String get settingsTitle => _ur ? 'سیٹنگز' : 'Settings';
  String get language => _ur ? 'زبان' : 'Language';
  String get contactUs => _ur ? 'رابطہ کریں' : 'Contact Us';
  String get aboutUs => _ur ? 'ہمارے بارے میں' : 'About Us';
  String get english => 'English';
  String get urdu => 'اردو';
  String get save => _ur ? 'محفوظ' : 'Save';
  String get cancel => _ur ? 'منسوخ' : 'Cancel';
  String get editName => _ur ? 'نام بدلیں' : 'Edit name';
  String get chooseAvatar => _ur ? 'اواتار چنیں' : 'Choose avatar';
  String get aboutBody => _ur
      ? 'Arrow Escape ایک پہیلی گیم ہے — تیر درست ترتیب میں نکالیں۔'
      : 'Arrow Escape is a casual puzzle — clear arrows in the right order.';
  String get version => _ur ? 'ورژن' : 'Version';
  String get comingSoon => _ur ? 'جلد آرہا ہے' : 'coming soon';
  String get contactSubject => 'Arrow Escape feedback';
  String get nameHint => _ur ? 'اپنا نام لکھیں' : 'Your name';
  String get close => _ur ? 'بند' : 'Close';
}
