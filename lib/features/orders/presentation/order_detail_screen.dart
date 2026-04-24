import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:learn_again_flutter/core/enums/app_enums.dart';
import '../domain/order_model.dart';
import 'order_provider.dart';

class SiparisDetayScreen extends ConsumerWidget {
  final int siparisId;
  const SiparisDetayScreen({super.key, required this.siparisId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(siparisProvider);
    final siparis = state.siparisler.firstWhere((s) => s.id == siparisId);
    final format = NumberFormat('#,###', 'tr_TR');
    final tarihFormat = DateFormat('dd MMM yyyy', 'tr_TR');

    return Scaffold(
      appBar: AppBar(
        title: Text(siparis.musteriAdi),
        actions: [
          // Durum değiştirme menüsü
          PopupMenuButton<SiparisDurumu>(
            icon: const Icon(Icons.more_vert),
            onSelected: (durum) => ref
                .read(siparisProvider.notifier)
                .durumGuncelle(siparisId, durum),
            itemBuilder: (_) => SiparisDurumu.values
                .map(
                  (d) => PopupMenuItem(
                    value: d,
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: d.renk,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(d.label),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Genel bilgiler kartı
          _DetayKart(
            baslik: 'Genel Bilgiler',
            child: Column(
              children: [
                _DetaySatir('Müşteri', siparis.musteriAdi),
                _DetaySatir('Sipariş No', '#${siparis.id}'),
                _DetaySatir('Tarih', tarihFormat.format(siparis.siparisTarihi)),
                _DetaySatir('Deadline', tarihFormat.format(siparis.deadline)),
                _DetaySatir('Toplam Adet', '${siparis.toplamAdet} adet'),
                _DetaySatir('Ödeme Türü', siparis.odemeTuru.label),
                _DetaySatir(
                  'Durum',
                  siparis.durum.label,
                  degerRenk: siparis.durum.renk,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Finansal özet kartı
          _DetayKart(
            baslik: 'Finansal Özet',
            child: Column(
              children: [
                _DetaySatir(
                  'Toplam Tutar',
                  '${format.format(siparis.toplamTutar)} ₺',
                ),
                _DetaySatir(
                  'Ödenen',
                  '${format.format(siparis.odenenTutar)} ₺',
                  degerRenk: const Color(0xFF639922),
                ),
                _DetaySatir(
                  'Kalan',
                  '${format.format(siparis.kalanTutar)} ₺',
                  degerRenk: siparis.kalanTutar > 0
                      ? const Color(0xFFE24B4A)
                      : const Color(0xFF639922),
                ),
                _DetaySatir(
                  'Kâr',
                  '${format.format(siparis.kar)} ₺',
                  degerRenk: const Color(0xFF639922),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: siparis.odemeYuzdesi,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF378ADD)),
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '%${(siparis.odemeYuzdesi * 100).toStringAsFixed(0)} ödendi',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Sipariş kalemleri
          _DetayKart(
            baslik: 'Sipariş Kalemleri',
            child: Column(
              children: siparis.kalemler
                  .map((kalem) => _KalemKarti(kalem: kalem, format: format))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetayKart extends StatelessWidget {
  final String baslik;
  final Widget child;
  const _DetayKart({required this.baslik, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            baslik,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DetaySatir extends StatelessWidget {
  final String baslik;
  final String deger;
  final Color? degerRenk;
  const _DetaySatir(this.baslik, this.deger, {this.degerRenk});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(baslik, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Text(
            deger,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: degerRenk,
            ),
          ),
        ],
      ),
    );
  }
}

class _KalemKarti extends StatelessWidget {
  final SiparisKalemi kalem;
  final NumberFormat format;
  const _KalemKarti({required this.kalem, required this.format});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                kalem.kapiTuru.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${kalem.adet} adet',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _KalemBilgi('Birim', '${format.format(kalem.birimFiyat)} ₺'),
              _KalemBilgi('Tutar', '${format.format(kalem.tutar)} ₺'),
              _KalemBilgi(
                'Kâr',
                '${format.format(kalem.kar)} ₺',
                renk: const Color(0xFF639922),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: [
              _MiniChip('Pressi: ${kalem.pressiKimYapiyor.label}'),
              _MiniChip('Kilit: ${kalem.kilidiKimDeliyor.label}'),
              _MiniChip('Boya: ${kalem.boyaTipi.label}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _KalemBilgi extends StatelessWidget {
  final String baslik;
  final String deger;
  final Color? renk;
  const _KalemBilgi(this.baslik, this.deger, {this.renk});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(baslik, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          Text(
            deger,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: renk,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  const _MiniChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: Colors.grey[700]),
      ),
    );
  }
}
