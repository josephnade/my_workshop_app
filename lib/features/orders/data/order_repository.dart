import 'package:learn_again_flutter/core/enums/app_enums.dart';
import '../domain/order_model.dart';

// Şu an mock data — ileride SQLite/Hive ile değişecek
class SiparisRepository {
  // Tüm siparişleri getir
  Future<List<Siparis>> getSiparisler() async {
    // Gerçek uygulamada: return await db.query('siparisler');
    return _mockSiparisler;
  }

  // Yeni sipariş ekle
  Future<void> ekle(Siparis siparis) async {
    _mockSiparisler.add(siparis);
  }

  // Sipariş güncelle
  Future<void> guncelle(Siparis siparis) async {
    final index = _mockSiparisler.indexWhere((s) => s.id == siparis.id);
    if (index != -1) _mockSiparisler[index] = siparis;
  }

  // Sipariş sil
  Future<void> sil(int id) async {
    _mockSiparisler.removeWhere((s) => s.id == id);
  }

  // Excel'den gelen gerçek veriler
  final List<Siparis> _mockSiparisler = [
    Siparis(
      id: 1,
      siparisTarihi: DateTime(2025, 11, 20),
      deadline: DateTime(2025, 12, 16),
      musteriAdi: '101 Kapı Sahibi',
      toplamAdet: 101,
      toplamTutar: 616000,
      kar: 194350,
      odemeTuru: OdemeTuru.krediKarti,
      odenenTutar: 250000,
      kalanTutar: 366000,
      durum: SiparisDurumu.bitti,
      kalemler: [
        SiparisKalemi(
          kapiTuru: KapiTuru.normal,
          adet: 81,
          birimFiyat: 6000,
          tutar: 486000,
          pressiKimYapiyor: IslemYapan.disariya,
          kilidiKimDeliyor: IslemYapan.disariya,
          boyaTipi: BoyaTipi.normal,
          cncMaliyeti: 100,
          maliyet: 4150,
          toplamMaliyet: 336150,
        ),
        SiparisKalemi(
          kapiTuru: KapiTuru.camli,
          adet: 20,
          birimFiyat: 6500,
          tutar: 130000,
          pressiKimYapiyor: IslemYapan.disariya,
          kilidiKimDeliyor: IslemYapan.disariya,
          boyaTipi: BoyaTipi.normal,
          cncMaliyeti: 100,
          maliyet: 4275,
          toplamMaliyet: 85500,
        ),
      ],
    ),
    Siparis(
      id: 2,
      siparisTarihi: DateTime(2025, 12, 16),
      deadline: DateTime(2025, 12, 16),
      musteriAdi: '102 Kapı Sahibi',
      toplamAdet: 40,
      toplamTutar: 282000,
      kar: 114700,
      odemeTuru: OdemeTuru.krediKarti,
      odenenTutar: 250001,
      kalanTutar: 31999,
      durum: SiparisDurumu.bitti,
      kalemler: [
        SiparisKalemi(
          kapiTuru: KapiTuru.normal,
          adet: 30,
          birimFiyat: 7000,
          tutar: 210000,
          pressiKimYapiyor: IslemYapan.biz,
          kilidiKimDeliyor: IslemYapan.disariya,
          boyaTipi: BoyaTipi.normal,
          cncMaliyeti: 100,
          maliyet: 4000,
          toplamMaliyet: 120000,
        ),
        SiparisKalemi(
          kapiTuru: KapiTuru.camli,
          adet: 10,
          birimFiyat: 7200,
          tutar: 72000,
          pressiKimYapiyor: IslemYapan.disariya,
          kilidiKimDeliyor: IslemYapan.biz,
          boyaTipi: BoyaTipi.parlak,
          cncMaliyeti: 100,
          maliyet: 4730,
          toplamMaliyet: 47300,
        ),
      ],
    ),
  ];
}
