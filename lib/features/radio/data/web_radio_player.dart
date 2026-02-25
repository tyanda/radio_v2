// Фабрика для создания платформенно-специфичного плеера
export 'radio_player_interface.dart';

import 'radio_player_interface.dart';
import 'radio_player_web.dart'
    if (dart.library.io) 'radio_player_stub.dart';

/// Фабрика для создания платформы-специфичного плеера
RadioPlayerInterface createRadioPlayer() => createRadioPlayerImpl();
