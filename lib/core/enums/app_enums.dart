import 'package:flutter/material.dart';

// Tüm uygulamada kullanılan ortak enum'lar buradan yönetilir.

enum OdemeTuru {
  nakit('Nakit'),
  krediKarti('Kredi Kartı'),
  cek('Çek'),
  senet('Senet');

  final String label;
  const OdemeTuru(this.label);
}

enum KapiTuru {
  normal('Normal'),
  camli('Camlı'),
  surgulu('Sürgülü'),
  yavruKanat('Yavru Kanat');

  final String label;
  const KapiTuru(this.label);
}

enum BoyaTipi {
  normal('Normal'),
  parlak('Parlak');

  final String label;
  const BoyaTipi(this.label);
}

enum IslemYapan {
  biz('Biz'),
  disariya('Dışarıya');

  final String label;
  const IslemYapan(this.label);
}

enum SiparisDurumu {
  baslanmadi('Başlanmadı'),
  yapilmayaBaslandi('Yapılmaya Başlandı'),
  bitti('Bitti'),
  iptalOldu('İptal Oldu');

  final String label;
  const SiparisDurumu(this.label);

  Color get renk {
    switch (this) {
      case SiparisDurumu.baslanmadi:
        return const Color(0xFFEF9F27);
      case SiparisDurumu.yapilmayaBaslandi:
        return const Color(0xFF378ADD);
      case SiparisDurumu.bitti:
        return const Color(0xFF639922);
      case SiparisDurumu.iptalOldu:
        return const Color(0xFFE24B4A);
    }
  }

  Color get bgRenk {
    switch (this) {
      case SiparisDurumu.baslanmadi:
        return const Color(0xFFFAEEDA);
      case SiparisDurumu.yapilmayaBaslandi:
        return const Color(0xFFE6F1FB);
      case SiparisDurumu.bitti:
        return const Color(0xFFEAF3DE);
      case SiparisDurumu.iptalOldu:
        return const Color(0xFFFCEBEB);
    }
  }
}
