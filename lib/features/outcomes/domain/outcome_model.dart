import '../../../core/enums/app_enums.dart';

class Gider {
  final int id;
  final DateTime tarih;
  final String aciklama;
  final OdemeTuru odemeTuru;
  final double tutar;
  final bool tekrarliMi;
  final bool odendi;
  final String? not_;

  const Gider({
    required this.id,
    required this.tarih,
    required this.aciklama,
    required this.odemeTuru,
    required this.tutar,
    required this.tekrarliMi,
    required this.odendi,
    this.not_,
  });
}
