import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_again_flutter/core/utils/app_formaters.dart';
import 'package:learn_again_flutter/features/outcomes/domain/outcome_model.dart';
import 'package:learn_again_flutter/features/outcomes/presentation/outcome_provider.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/theme/app_colors.dart';

class GiderlerScreen extends ConsumerWidget {
  const GiderlerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(giderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giderler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _giderEkleDialog(context, ref),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? _HataWidget(mesaj: state.error!)
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _OzetKartlar(state: state)),
                SliverToBoxAdapter(
                  child: _FiltreSatiri(state: state, ref: ref),
                ),
                state.filtrelenmis.isEmpty
                    ? const SliverFillRemaining(child: _BosListe())
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _GiderKarti(
                            gider: state.filtrelenmis[index],
                            onOdemeDegistir: () => ref
                                .read(giderProvider.notifier)
                                .odemeDurumDegistir(
                                  state.filtrelenmis[index].id,
                                ),
                            onSil: () => ref
                                .read(giderProvider.notifier)
                                .sil(state.filtrelenmis[index].id),
                          ),
                          childCount: state.filtrelenmis.length,
                        ),
                      ),
              ],
            ),
    );
  }

  void _giderEkleDialog(BuildContext context, WidgetRef ref) {
    final aciklamaController = TextEditingController();
    final tutarController = TextEditingController();
    final notController = TextEditingController();
    OdemeTuru secilenOdeme = OdemeTuru.nakit;
    bool tekrarli = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Yeni Gider',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: aciklamaController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tutarController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Tutar (₺)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<OdemeTuru>(
                value: secilenOdeme,
                decoration: const InputDecoration(
                  labelText: 'Ödeme Türü',
                  border: OutlineInputBorder(),
                ),
                items: OdemeTuru.values
                    .map(
                      (o) => DropdownMenuItem(value: o, child: Text(o.label)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => secilenOdeme = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notController,
                decoration: const InputDecoration(
                  labelText: 'Not (opsiyonel)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: tekrarli,
                onChanged: (v) => setState(() => tekrarli = v),
                title: const Text('Tekrarlı mı?'),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (aciklamaController.text.isEmpty ||
                        tutarController.text.isEmpty)
                      return;
                    ref
                        .read(giderProvider.notifier)
                        .ekle(
                          Gider(
                            id: DateTime.now().millisecondsSinceEpoch,
                            tarih: DateTime.now(),
                            aciklama: aciklamaController.text,
                            odemeTuru: secilenOdeme,
                            tutar: double.tryParse(tutarController.text) ?? 0,
                            tekrarliMi: tekrarli,
                            odendi: false,
                            not_: notController.text.isEmpty
                                ? null
                                : notController.text,
                          ),
                        );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Özet kartlar
class _OzetKartlar extends StatelessWidget {
  final GiderState state;
  const _OzetKartlar({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _MetrikKart(
            baslik: 'Toplam',
            deger: AppFormatters.paraBirimi(state.toplamTutar),
            renk: AppColors.primary,
            bgRenk: const Color(0xFFEEEDFE),
            icon: Icons.receipt_long_outlined,
          ),
          const SizedBox(width: 10),
          _MetrikKart(
            baslik: 'Ödenen',
            deger: AppFormatters.paraBirimi(state.odenenTutar),
            renk: AppColors.success,
            bgRenk: const Color(0xFFEAF3DE),
            icon: Icons.check_circle_outline,
          ),
          const SizedBox(width: 10),
          _MetrikKart(
            baslik: 'Ödenmedi',
            deger: AppFormatters.paraBirimi(state.odenmeyenTutar),
            renk: AppColors.error,
            bgRenk: const Color(0xFFFCEBEB),
            icon: Icons.pending_outlined,
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
                fontSize: 13,
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

// Filtre satırı
class _FiltreSatiri extends StatelessWidget {
  final GiderState state;
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
          _FiltreChip(
            label: 'Tümü',
            secili: state.odendiFiltre == null,
            onTap: () => ref.read(giderProvider.notifier).filtreUygula(null),
          ),
          const SizedBox(width: 8),
          _FiltreChip(
            label: 'Ödendi',
            secili: state.odendiFiltre == true,
            renk: AppColors.success,
            bgRenk: const Color(0xFFEAF3DE),
            onTap: () => ref.read(giderProvider.notifier).filtreUygula(true),
          ),
          const SizedBox(width: 8),
          _FiltreChip(
            label: 'Ödenmedi',
            secili: state.odendiFiltre == false,
            renk: AppColors.error,
            bgRenk: const Color(0xFFFCEBEB),
            onTap: () => ref.read(giderProvider.notifier).filtreUygula(false),
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

// Gider kartı
class _GiderKarti extends StatelessWidget {
  final Gider gider;
  final VoidCallback onOdemeDegistir;
  final VoidCallback onSil;

  const _GiderKarti({
    required this.gider,
    required this.onOdemeDegistir,
    required this.onSil,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('gider_${gider.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Gideri Sil'),
            content: Text('${gider.aciklama} silinecek. Emin misin?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('İptal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Sil', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onSil(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // İkon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: gider.odendi
                        ? const Color(0xFFEAF3DE)
                        : const Color(0xFFFCEBEB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    gider.odendi
                        ? Icons.check_circle_outline
                        : Icons.pending_outlined,
                    color: gider.odendi ? AppColors.success : AppColors.error,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gider.aciklama,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        AppFormatters.tarihFormat(gider.tarih),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // Tutar
                Text(
                  AppFormatters.paraBirimi(gider.tutar),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            // Not varsa göster
            if (gider.not_ != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.15)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        gider.not_!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Alt satır — chip'ler + ödeme toggle
            Row(
              children: [
                _MiniChip(gider.odemeTuru.label),
                const SizedBox(width: 6),
                if (gider.tekrarliMi) const _MiniChip('Tekrarlı'),
                const Spacer(),
                // Ödeme durumu toggle
                GestureDetector(
                  onTap: onOdemeDegistir,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: gider.odendi
                          ? const Color(0xFFEAF3DE)
                          : const Color(0xFFFCEBEB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      gider.odendi ? 'Ödendi' : 'Ödenmedi',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: gider.odendi
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: Colors.grey[700]),
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
          Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text(mesaj, style: TextStyle(color: AppColors.error)),
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
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'Gider bulunamadı',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
