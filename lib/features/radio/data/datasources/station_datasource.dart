import '../../domain/station.dart';

class StationDataSource {
  static List<Station> getStationList() {
    return [
      Station(
        id: '1',
        name: 'Виктория',
        desc: 'Главное радио Якутии',
        art: 'assets/images/viktoria.jpg',
        icon: 'V',
        url:
            'https://stream2.sakhafm.ru/stream/viktoria/af62bbdf-2e52-45da-9ef5-a2f60a66ef8a/e625247a-13b8-4c31-aaeb-06415c8b1657',
        frequency: '98.5 FM',
      ),
      Station(
        id: '2',
        name: 'Тэтим',
        desc: 'НВК Саха',
        art: 'assets/images/tetim.jpg',
        icon: 'T',
        url: 'https://icecast-saha.cdnvideo.ru/saha',
        frequency: '103.4 FM',
      ),
      Station(
        id: '3',
        name: 'IR Radio',
        desc: 'Молодежные хиты',
        art: 'assets/images/ir_radio.jpg',
        icon: 'I',
        url: 'https://5.129.229.244.nip.io/legacy/stream',
        frequency: '104.5 FM',
      ),
      Station(
        id: '4',
        name: 'Европа Плюс',
        desc: 'Мировые хиты',
        art: 'assets/images/europa_plus.jpg',
        icon: 'E',
        url: 'https://ep256.hostingradio.ru:8052/europaplus256.mp3',
        frequency: '105.2 FM',
      ),
      Station(
        id: '5',
        name: 'Супердискотека 90-х',
        desc: 'Хиты 90-х годов',
        art: 'assets/images/superdisco.jpg',
        icon: 'S',
        url: 'https://radiorecord.hostingradio.ru/sd9096.aacp',
        frequency: '106.7 FM',
      ),
    ];
  }
}
