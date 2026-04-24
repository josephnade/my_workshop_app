import 'package:intl/intl.dart';

/// Tüm format işlemleri tek yerden yönetilir.
/// Widget içinde asla NumberFormat() veya DateFormat() oluşturma!
abstract class AppFormatters {
  static final para = NumberFormat('#,###', 'tr_TR');
  static final tarih = DateFormat('dd MMM yyyy', 'tr_TR');
  static final tarihKisa = DateFormat('dd.MM.yyyy', 'tr_TR');
  static final ay = DateFormat('MMMM yyyy', 'tr_TR');

  /// 616000 → "616.000 ₺"
  static String paraBirimi(double tutar) => '${para.format(tutar)} ₺';

  /// DateTime → "20 Kas 2025"
  static String tarihFormat(DateTime dt) => tarih.format(dt);
}
