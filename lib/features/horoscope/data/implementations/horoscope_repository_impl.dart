import '../interfaces/horoscope_repository.dart';
import '../models/horoscope_data.dart';
import '../services/horoscope_service.dart';

class HoroscopeRepositoryImpl implements HoroscopeRepository {
  final HoroscopeService _service;

  HoroscopeRepositoryImpl(this._service);

  @override
  Future<HoroscopeData> getHoroscope(String sign, String period) {
    return _service.getHoroscope(sign, period);
  }
}