import '../models/horoscope_data.dart';

abstract class HoroscopeRepository {
  Future<HoroscopeData> getHoroscope(String sign, String period);
}
