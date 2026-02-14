import 'package:provider/provider.dart';
import './weather_provider.dart';

final weatherProviders = [
  ChangeNotifierProvider<WeatherProvider>(
    create: (_) => WeatherProvider(),
  ),
];