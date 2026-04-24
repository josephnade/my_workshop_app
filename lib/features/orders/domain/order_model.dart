import 'package:learn_again_flutter/core/enums/app_enums.dart';

// Sipariş kalemi — Excel'deki Siparis_Kalemleri sheet'i
class SiparisKalemi {
  final KapiTuru kapiTuru;
  final int adet;
  final double birimFiyat;
  final double tutar;
  final IslemYapan pressiKimYapiyor;
  final IslemYapan kilidiKimDeliyor;
  final BoyaTipi boyaTipi;
  final double cncMaliyeti;
  final double maliyet;
  final double toplamMaliyet;

  const SiparisKalemi({
    required this.kapiTuru,
    required this.adet,
    required this.birimFiyat,
    required this.tutar,
    required this.pressiKimYapiyor,
    required this.kilidiKimDeliyor,
    required this.boyaTipi,
    required this.cncMaliyeti,
    required this.maliyet,
    required this.toplamMaliyet,
  });

  // Kâr hesabı
  double get kar => tutar - toplamMaliyet;
}

// Ana sipariş modeli — Excel'deki Siparişler sheet'i
class Siparis {
  final int id;
  final DateTime siparisTarihi;
  final DateTime deadline;
  final String musteriAdi;
  final int toplamAdet;
  final double toplamTutar;
  final double kar;
  final OdemeTuru odemeTuru;
  final double odenenTutar;
  final double kalanTutar;
  final SiparisDurumu durum;
  final List<SiparisKalemi> kalemler;

  const Siparis({
    required this.id,
    required this.siparisTarihi,
    required this.deadline,
    required this.musteriAdi,
    required this.toplamAdet,
    required this.toplamTutar,
    required this.kar,
    required this.odemeTuru,
    required this.odenenTutar,
    required this.kalanTutar,
    required this.durum,
    required this.kalemler,
  });

  // Ödeme yüzdesi — progress bar için
  double get odemeYuzdesi => toplamTutar > 0 ? odenenTutar / toplamTutar : 0;

  // Deadline geçti mi?
  bool get deadlineGecti =>
      deadline.isBefore(DateTime.now()) && durum != SiparisDurumu.bitti;
}
