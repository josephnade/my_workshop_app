import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:learn_again_flutter/core/enums/app_enums.dart';
import 'package:learn_again_flutter/core/utils/app_formaters.dart';
import '../domain/order_model.dart';
import 'order_provider.dart';
import 'order_detail_screen.dart';

class SiparislerScreen extends ConsumerWidget {
  const SiparislerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(siparisProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Siparişler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Sipariş ekleme sayfasına git
            },
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? _HataWidget(mesaj: state.error!)
          : CustomScrollView(
              slivers: [
                // Özet kartlar
                SliverToBoxAdapter(child: _OzetKartlar(state: state)),
                // Filtre chips
                SliverToBoxAdapter(
                  child: _FiltreSatiri(state: state, ref: ref),
                ),
                // Sipariş listesi
                state.filtrelenmis.isEmpty
                    ? const SliverFillRemaining(child: _BosListe())
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final siparis = state.filtrelenmis[index];
                          return _SiparisKarti(
                            siparis: siparis,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    SiparisDetayScreen(siparisId: siparis.id),
                              ),
                            ),
                          );
                        }, childCount: state.filtrelenmis.length),
                      ),
              ],
            ),
    );
  }
}

// Özet metrik kartları
class _OzetKartlar extends StatelessWidget {
  final SiparisState state;
  const _OzetKartlar({required this.state});

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat('#,###', 'tr_TR');
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _MetrikKart(
            baslik: 'Toplam Kâr',
            deger: '${format.format(state.toplamKar)} ₺',
            renk: const Color(0xFF639922),
            bgRenk: const Color(0xFFEAF3DE),
            icon: Icons.trending_up,
          ),
          const SizedBox(width: 10),
          _MetrikKart(
            baslik: 'Kalan Tahsilat',
            deger: '${format.format(state.toplamKalan)} ₺',
            renk: const Color(0xFFE24B4A),
            bgRenk: const Color(0xFFFCEBEB),
            icon: Icons.account_balance_wallet_outlined,
          ),
          const SizedBox(width: 10),
          _MetrikKart(
            baslik: 'Sipariş',
            deger: '${state.siparisler.length}',
            renk: const Color(0xFF185FA5),
            bgRenk: const Color(0xFFE6F1FB),
            icon: Icons.door_front_door_outlined,
          ),
        ],
      ),
    );
  }
}

class _MetrikKart extends StatelessWidget {
  final String baslik;
  final String deger;
  final Color renk;
  final Color bgRenk;
  final IconData icon;

  const _MetrikKart({
    required this.baslik,
    required this.deger,
    required this.renk,
    required this.bgRenk,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgRenk,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: renk, size: 18),
            const SizedBox(height: 6),
            Text(
              deger,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: renk,
              ),
            ),
            Text(
              baslik,
              style: TextStyle(fontSize: 11, color: renk.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }
}

// Filtre chips
class _FiltreSatiri extends StatelessWidget {
  final SiparisState state;
  final WidgetRef ref;
  const _FiltreSatiri({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // "Tümü" chip
          _FiltreChip(
            label: 'Tümü',
            secili: state.aktifFiltre == null,
            onTap: () => ref.read(siparisProvider.notifier).filtreUygula(null),
          ),
          const SizedBox(width: 8),
          // Durum filtreleri
          ...SiparisDurumu.values.map(
            (durum) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FiltreChip(
                label: durum.label,
                secili: state.aktifFiltre == durum,
                renk: durum.renk,
                bgRenk: durum.bgRenk,
                onTap: () =>
                    ref.read(siparisProvider.notifier).filtreUygula(durum),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltreChip extends StatelessWidget {
  final String label;
  final bool secili;
  final Color? renk;
  final Color? bgRenk;
  final VoidCallback onTap;

  const _FiltreChip({
    required this.label,
    required this.secili,
    required this.onTap,
    this.renk,
    this.bgRenk,
  });

  @override
  Widget build(BuildContext context) {
    final aktifRenk = renk ?? Theme.of(context).colorScheme.primary;
    final aktifBg = bgRenk ?? Theme.of(context).colorScheme.primaryContainer;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: secili ? aktifBg : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: secili ? aktifRenk : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: secili ? FontWeight.w600 : FontWeight.normal,
            color: secili ? aktifRenk : Colors.grey,
          ),
        ),
      ),
    );
  }
}

// Sipariş kartı
class _SiparisKarti extends StatelessWidget {
  final Siparis siparis;
  final VoidCallback onTap;

  const _SiparisKarti({required this.siparis, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst satır — müşteri + durum badge
            Row(
              children: [
                // Müşteri avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F1FB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.door_front_door_outlined,
                      color: Color(0xFF185FA5),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        siparis.musteriAdi,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Sipariş #${siparis.id} • ${siparis.toplamAdet} adet',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // Durum badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: siparis.durum.bgRenk,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    siparis.durum.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: siparis.durum.renk,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 12),

            // Finansal bilgiler
            Row(
              children: [
                _BilgiKolonu(
                  baslik: 'Toplam Tutar',
                  deger: '${AppFormatters.paraBirimi(siparis.toplamTutar)} ₺',
                ),
                _BilgiKolonu(
                  baslik: 'Kâr',
                  deger: '${AppFormatters.paraBirimi(siparis.kar)} ₺',
                  degerRenk: const Color(0xFF639922),
                ),
                _BilgiKolonu(
                  baslik: 'Kalan',
                  deger: '${AppFormatters.paraBirimi(siparis.kalanTutar)} ₺',
                  degerRenk: siparis.kalanTutar > 0
                      ? const Color(0xFFE24B4A)
                      : const Color(0xFF639922),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Ödeme progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ödeme durumu',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '%${(siparis.odemeYuzdesi * 100).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: siparis.odemeYuzdesi,
                    minHeight: 6,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      siparis.odemeYuzdesi >= 1
                          ? const Color(0xFF639922)
                          : const Color(0xFF378ADD),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Alt satır — tarih + ödeme türü
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  'Deadline: ${AppFormatters.tarihFormat(siparis.deadline)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const Spacer(),
                Icon(
                  Icons.credit_card_outlined,
                  size: 13,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  siparis.odemeTuru.label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BilgiKolonu extends StatelessWidget {
  final String baslik;
  final String deger;
  final Color? degerRenk;

  const _BilgiKolonu({
    required this.baslik,
    required this.deger,
    this.degerRenk,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(baslik, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          const SizedBox(height: 2),
          Text(
            deger,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: degerRenk ?? Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _HataWidget extends StatelessWidget {
  final String mesaj;
  const _HataWidget({required this.mesaj});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Color(0xFFE24B4A)),
          const SizedBox(height: 12),
          Text(mesaj, style: const TextStyle(color: Color(0xFFE24B4A))),
        ],
      ),
    );
  }
}

class _BosListe extends StatelessWidget {
  const _BosListe();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.door_front_door_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 12),
          Text(
            'Sipariş bulunamadı',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
