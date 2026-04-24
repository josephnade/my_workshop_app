import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_again_flutter/core/enums/app_enums.dart';
import '../data/order_repository.dart';
import '../domain/order_model.dart';

// Repository provider — tek instance
final siparisRepositoryProvider = Provider<SiparisRepository>((ref) {
  return SiparisRepository();
});

// State sınıfı — loading/error/data durumlarını yönetir
class SiparisState {
  final List<Siparis> siparisler;
  final bool isLoading;
  final String? error;
  final SiparisDurumu? aktifFiltre; // null = hepsi

  const SiparisState({
    this.siparisler = const [],
    this.isLoading = false,
    this.error,
    this.aktifFiltre,
  });

  // Filtrelenmiş liste
  List<Siparis> get filtrelenmis {
    if (aktifFiltre == null) return siparisler;
    return siparisler.where((s) => s.durum == aktifFiltre).toList();
  }

  // Özet istatistikler — home screen metric kartları için
  double get toplamKar => siparisler.fold(0, (sum, s) => sum + s.kar);
  double get toplamKalan => siparisler.fold(0, (sum, s) => sum + s.kalanTutar);
  int get aktifSayisi => siparisler
      .where(
        (s) =>
            s.durum != SiparisDurumu.bitti &&
            s.durum != SiparisDurumu.iptalOldu,
      )
      .length;

  SiparisState copyWith({
    List<Siparis>? siparisler,
    bool? isLoading,
    String? error,
    SiparisDurumu? aktifFiltre,
    bool clearFiltre = false,
  }) {
    return SiparisState(
      siparisler: siparisler ?? this.siparisler,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      aktifFiltre: clearFiltre ? null : (aktifFiltre ?? this.aktifFiltre),
    );
  }
}

// Ana provider
final siparisProvider = StateNotifierProvider<SiparisNotifier, SiparisState>((
  ref,
) {
  final repo = ref.watch(siparisRepositoryProvider);
  return SiparisNotifier(repo);
});

class SiparisNotifier extends StateNotifier<SiparisState> {
  final SiparisRepository _repo;

  SiparisNotifier(this._repo) : super(const SiparisState()) {
    yukle(); // Başlangıçta veriyi çek
  }

  Future<void> yukle() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _repo.getSiparisler();
      state = state.copyWith(siparisler: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void filtreUygula(SiparisDurumu? durum) {
    state = state.copyWith(aktifFiltre: durum, clearFiltre: durum == null);
  }

  Future<void> siparisEkle(Siparis siparis) async {
    await _repo.ekle(siparis);
    await yukle();
  }

  Future<void> durumGuncelle(int id, SiparisDurumu yeniDurum) async {
    final siparis = state.siparisler.firstWhere((s) => s.id == id);
    final guncellenmis = Siparis(
      id: siparis.id,
      siparisTarihi: siparis.siparisTarihi,
      deadline: siparis.deadline,
      musteriAdi: siparis.musteriAdi,
      toplamAdet: siparis.toplamAdet,
      toplamTutar: siparis.toplamTutar,
      kar: siparis.kar,
      odemeTuru: siparis.odemeTuru,
      odenenTutar: siparis.odenenTutar,
      kalanTutar: siparis.kalanTutar,
      durum: yeniDurum,
      kalemler: siparis.kalemler,
    );
    await _repo.guncelle(guncellenmis);
    await yukle();
  }
}
