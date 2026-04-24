import 'package:learn_again_flutter/features/outcomes/domain/outcome_model.dart';
import '../../../core/enums/app_enums.dart';

class GiderRepository {
  final List<Gider> _giderler = [
    Gider(
      id: 1,
      tarih: DateTime(2026, 2, 14),
      aciklama: 'Depozito',
      odemeTuru: OdemeTuru.nakit,
      tutar: 40000,
      tekrarliMi: false,
      odendi: true,
      not_: 'Depozito 35.000 idi. 5.000 Kira ödendi. Kalan 30.000 TL oldu.',
    ),
    Gider(
      id: 2,
      tarih: DateTime(2025, 11, 16),
      aciklama: 'Depozito',
      odemeTuru: OdemeTuru.nakit,
      tutar: 19000,
      tekrarliMi: false,
      odendi: true,
      not_: 'Depozito 35.000 idi. 5.000 Kira ödendi. Kalan 30.000 TL oldu.',
    ),
  ];

  Future<List<Gider>> getGiderler() async => _giderler;

  Future<void> ekle(Gider gider) async => _giderler.add(gider);

  Future<void> guncelle(Gider gider) async {
    final i = _giderler.indexWhere((g) => g.id == gider.id);
    if (i != -1) _giderler[i] = gider;
  }

  Future<void> sil(int id) async => _giderler.removeWhere((g) => g.id == id);
}
