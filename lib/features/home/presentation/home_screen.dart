import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_again_flutter/core/enums/app_enums.dart';
import 'package:learn_again_flutter/core/theme/app_colors.dart';
import 'package:learn_again_flutter/core/utils/app_formaters.dart';
import 'package:learn_again_flutter/features/orders/domain/order_model.dart';
import 'package:learn_again_flutter/features/orders/presentation/order_provider.dart';
import 'package:learn_again_flutter/features/orders/presentation/order_screen.dart';
import 'package:learn_again_flutter/features/outcomes/presentation/outcome_provider.dart';
import 'package:learn_again_flutter/features/outcomes/presentation/outcome_screen.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _animateIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _animateIn = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final siparisState = ref.watch(siparisProvider);
    final giderState = ref.watch(giderProvider);
    final aktifSiparisler =
        siparisState.siparisler
            .where((siparis) => siparis.durum != SiparisDurumu.bitti)
            .toList()
          ..sort((a, b) => a.deadline.compareTo(b.deadline));
    final bugun = DateTime.now();

    final toplamCiro = siparisState.siparisler.fold<double>(
      0,
      (sum, siparis) => sum + siparis.toplamTutar,
    );
    final toplamTahsilat = siparisState.siparisler.fold<double>(
      0,
      (sum, siparis) => sum + siparis.odenenTutar,
    );
    final toplamGider = giderState.toplamTutar;
    final netNakit = toplamTahsilat - toplamGider;
    final bekleyenTahsilat = siparisState.toplamKalan;
    final aylikSiparisler = siparisState.siparisler
        .where(
          (siparis) =>
              siparis.siparisTarihi.year == bugun.year &&
              siparis.siparisTarihi.month == bugun.month,
        )
        .length;
    final odenmeyenGiderAdedi = giderState.giderler
        .where((gider) => !gider.odendi)
        .length;

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF4F7FB),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _sayfayaGit(context, const SiparislerScreen()),
        backgroundColor: const Color(0xFF1B2436),
        foregroundColor: Colors.white,
        elevation: 10,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Yeni Sipariş',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _AnimatedEntrance(
                  delay: 0,
                  animate: _animateIn,
                  child: _DashboardHero(
                    bugunLabel: AppFormatters.ay.format(bugun),
                    netNakit: netNakit,
                    bekleyenTahsilat: bekleyenTahsilat,
                    aktifSiparisSayisi: siparisState.aktifSayisi,
                    odenmeyenGiderAdedi: odenmeyenGiderAdedi,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _AnimatedEntrance(
                  delay: 90,
                  animate: _animateIn,
                  child: _SectionTitle(
                    title: 'Genel Durum',
                    subtitle: 'Bugün neye bakman gerektiğini tek ekranda gör.',
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              sliver: SliverGrid(
                delegate: SliverChildListDelegate([
                  _AnimatedEntrance(
                    delay: 140,
                    animate: _animateIn,
                    child: _MetricCard(
                      title: 'Toplam Ciro',
                      value: AppFormatters.paraBirimi(toplamCiro),
                      caption: '$aylikSiparisler yeni sipariş bu ay',
                      icon: Icons.payments_rounded,
                      colors: const [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
                    ),
                  ),
                  _AnimatedEntrance(
                    delay: 220,
                    animate: _animateIn,
                    child: _MetricCard(
                      title: 'Tahsil Edilen',
                      value: AppFormatters.paraBirimi(toplamTahsilat),
                      caption:
                          'Bekleyen ${AppFormatters.paraBirimi(bekleyenTahsilat)}',
                      icon: Icons.savings_rounded,
                      colors: const [Color(0xFF059669), Color(0xFF34D399)],
                    ),
                  ),
                  _AnimatedEntrance(
                    delay: 300,
                    animate: _animateIn,
                    child: _MetricCard(
                      title: 'Toplam Gider',
                      value: AppFormatters.paraBirimi(toplamGider),
                      caption: '$odenmeyenGiderAdedi ödeme bekliyor',
                      icon: Icons.receipt_long_rounded,
                      colors: const [Color(0xFFE11D48), Color(0xFFFB7185)],
                    ),
                  ),
                  _AnimatedEntrance(
                    delay: 380,
                    animate: _animateIn,
                    child: _MetricCard(
                      title: 'Toplam Kar',
                      value: AppFormatters.paraBirimi(siparisState.toplamKar),
                      caption:
                          '${siparisState.siparisler.length} siparişten hesaplandı',
                      icon: Icons.auto_graph_rounded,
                      colors: const [Color(0xFF7C3AED), Color(0xFFA78BFA)],
                    ),
                  ),
                ]),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: 196,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _AnimatedEntrance(
                  delay: 460,
                  animate: _animateIn,
                  child: _QuickActionsRow(
                    onSiparisTap: () =>
                        _sayfayaGit(context, const SiparislerScreen()),
                    onGiderTap: () =>
                        _sayfayaGit(context, const GiderlerScreen()),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _AnimatedEntrance(
                  delay: 540,
                  animate: _animateIn,
                  child: _SectionTitle(
                    title: 'Aktif Siparişler',
                    subtitle: 'Yaklaşan teslimleri ve tahsilat riskini izle.',
                    trailing: TextButton(
                      onPressed: () =>
                          _sayfayaGit(context, const SiparislerScreen()),
                      child: const Text('Tümünü Gör'),
                    ),
                  ),
                ),
              ),
            ),
            if (siparisState.isLoading || giderState.isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (siparisState.error != null || giderState.error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _DashboardError(
                  message: siparisState.error ?? giderState.error!,
                ),
              )
            else if (aktifSiparisler.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyDashboardState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final siparis = aktifSiparisler[index];
                    return _AnimatedEntrance(
                      delay: 620 + (index * 70),
                      animate: _animateIn,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _ActiveOrderCard(siparis: siparis),
                      ),
                    );
                  }, childCount: aktifSiparisler.length),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _sayfayaGit(BuildContext context, Widget page) {
    return Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({
    required this.bugunLabel,
    required this.netNakit,
    required this.bekleyenTahsilat,
    required this.aktifSiparisSayisi,
    required this.odenmeyenGiderAdedi,
  });

  final String bugunLabel;
  final double netNakit;
  final double bekleyenTahsilat;
  final int aktifSiparisSayisi;
  final int odenmeyenGiderAdedi;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF111827), Color(0xFF1E3A8A), Color(0xFF0EA5E9)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.24),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: -16,
            child: Container(
              width: 122,
              height: 122,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 90,
            bottom: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.16),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wb_sunny_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Atölye Özeti',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      bugunLabel,
                      textAlign: TextAlign.end,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Text(
                'Net nakit akışının kontrolü sende.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppFormatters.paraBirimi(netNakit),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _GlassStatPill(
                      label: 'Bekleyen Tahsilat',
                      value: AppFormatters.paraBirimi(bekleyenTahsilat),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _GlassStatPill(
                      label: 'Aktif İş',
                      value: '$aktifSiparisSayisi sipariş',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _GlassStatPill(
                label: 'Ödeme Bekleyen Gider',
                value: '$odenmeyenGiderAdedi kalem',
                compact: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlassStatPill extends StatelessWidget {
  const _GlassStatPill({
    required this.label,
    required this.value,
    this.compact = false,
  });

  final String label;
  final String value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: compact ? 12 : 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: compact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF162033),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.9),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          Flexible(child: trailing!),
        ],
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.caption,
    required this.icon,
    required this.colors,
  });

  final String title;
  final String value;
  final String caption;
  final IconData icon;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.first.withValues(alpha: 0.14),
            colors.last.withValues(alpha: 0.18),
          ],
        ),
        border: Border.all(color: colors.last.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: colors.first,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colors.first.withValues(alpha: 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({
    required this.onSiparisTap,
    required this.onGiderTap,
  });

  final VoidCallback onSiparisTap;
  final VoidCallback onGiderTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionTile(
            title: 'Siparişler',
            subtitle: 'Teslim, durum ve detay takibi',
            icon: Icons.inventory_2_rounded,
            accent: const Color(0xFF2563EB),
            onTap: onSiparisTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionTile(
            title: 'Giderler',
            subtitle: 'Ödeme çıkışları ve notlar',
            icon: Icons.account_balance_wallet_rounded,
            accent: const Color(0xFFE11D48),
            onTap: onGiderTap,
          ),
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary.withValues(alpha: 0.92),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveOrderCard extends StatelessWidget {
  const _ActiveOrderCard({required this.siparis});

  final Siparis siparis;

  @override
  Widget build(BuildContext context) {
    final deadlineFarki = siparis.deadline.difference(DateTime.now()).inDays;
    final gecikti = deadlineFarki < 0;
    final kalanLabel = gecikti
        ? '${deadlineFarki.abs()} gün gecikti'
        : (deadlineFarki == 0 ? 'Bugün teslim' : '$deadlineFarki gün kaldı');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [siparis.durum.bgRenk, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.door_front_door_rounded,
                  color: siparis.durum.renk,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      siparis.musteriAdi,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${siparis.toplamAdet} adet • ${siparis.odemeTuru.label}',
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: siparis.durum.bgRenk,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  siparis.durum.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: siparis.durum.renk,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _InlineMetric(
                  title: 'Toplam',
                  value: AppFormatters.paraBirimi(siparis.toplamTutar),
                ),
              ),
              Expanded(
                child: _InlineMetric(
                  title: 'Kalan',
                  value: AppFormatters.paraBirimi(siparis.kalanTutar),
                  valueColor: siparis.kalanTutar > 0
                      ? const Color(0xFFE11D48)
                      : AppColors.success,
                ),
              ),
              Expanded(
                child: _InlineMetric(
                  title: 'Kar',
                  value: AppFormatters.paraBirimi(siparis.kar),
                  valueColor: const Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tahsilat ilerlemesi',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.9,
                            ),
                          ),
                        ),
                        Text(
                          '%${(siparis.odemeYuzdesi * 100).toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: siparis.odemeYuzdesi.clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          siparis.odemeYuzdesi >= 1
                              ? AppColors.success
                              : const Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: gecikti
                  ? const Color(0xFFFFF1F2)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(
                  gecikti
                      ? Icons.warning_amber_rounded
                      : Icons.schedule_rounded,
                  color: gecikti
                      ? const Color(0xFFE11D48)
                      : const Color(0xFF475569),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Teslim: ${AppFormatters.tarihFormat(siparis.deadline)} • $kalanLabel',
                    style: TextStyle(
                      color: gecikti
                          ? const Color(0xFFBE123C)
                          : const Color(0xFF334155),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineMetric extends StatelessWidget {
  const _InlineMetric({
    required this.title,
    required this.value,
    this.valueColor,
  });

  final String title;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.9),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? const Color(0xFF0F172A),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 54,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDashboardState extends StatelessWidget {
  const _EmptyDashboardState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.dashboard_customize_rounded,
                size: 42,
                color: Color(0xFF0284C7),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Ana ekranı dolduracak aktif veri bulunamadı',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Siparis veya gider ekledikce burada operasyon ozeti belirecek.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary.withValues(alpha: 0.92),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedEntrance extends StatelessWidget {
  const _AnimatedEntrance({
    required this.child,
    required this.delay,
    required this.animate,
  });

  final Widget child;
  final int delay;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final effectiveDuration = Duration(milliseconds: 500 + delay);

    return AnimatedSlide(
      duration: effectiveDuration,
      curve: Curves.easeOutCubic,
      offset: animate ? Offset.zero : const Offset(0, 0.08),
      child: AnimatedOpacity(
        duration: effectiveDuration,
        curve: Curves.easeOut,
        opacity: animate ? 1 : 0,
        child: child,
      ),
    );
  }
}
