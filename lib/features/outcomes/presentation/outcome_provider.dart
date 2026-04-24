import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/outcome_repository.dart';
import '../domain/outcome_model.dart';

final giderRepositoryProvider = Provider<GiderRepository>(
  (_) => GiderRepository(),
);

class GiderState {
  final List<Gider> giderler;
  final bool isLoading;
  final String? error;
  final bool? odendiFiltre; // null=hepsi, true=ödendi, false=ödenmedi

  const GiderState({
    this.giderler = const [],
    this.isLoading = false,
    this.error,
    this.odendiFiltre,
  });

  List<Gider> get filtrelenmis {
    if (odendiFiltre == null) return giderler;
    return giderler.where((g) => g.odendi == odendiFiltre).toList();
  }

  double get toplamTutar => giderler.fold(0, (sum, g) => sum + g.tutar);

  double get odenenTutar =>
      giderler.where((g) => g.odendi).fold(0, (sum, g) => sum + g.tutar);

  double get odenmeyenTutar =>
      giderler.where((g) => !g.odendi).fold(0, (sum, g) => sum + g.tutar);

  GiderState copyWith({
    List<Gider>? giderler,
    bool? isLoading,
    String? error,
    bool? odendiFiltre,
    bool clearFiltre = false,
  }) => GiderState(
    giderler: giderler ?? this.giderler,
    isLoading: isLoading ?? this.isLoading,
    error: error,
    odendiFiltre: clearFiltre ? null : (odendiFiltre ?? this.odendiFiltre),
  );
}

final giderProvider = StateNotifierProvider<GiderNotifier, GiderState>((ref) {
  return GiderNotifier(ref.watch(giderRepositoryProvider));
});

class GiderNotifier extends StateNotifier<GiderState> {
  final GiderRepository _repo;

  GiderNotifier(this._repo) : super(const GiderState()) {
    yukle();
  }

  Future<void> yukle() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _repo.getGiderler();
      state = state.copyWith(giderler: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void filtreUygula(bool? odendi) =>
      state = state.copyWith(odendiFiltre: odendi, clearFiltre: odendi == null);

  Future<void> ekle(Gider gider) async {
    await _repo.ekle(gider);
    await yukle();
  }

  Future<void> odemeDurumDegistir(int id) async {
    final gider = state.giderler.firstWhere((g) => g.id == id);
    await _repo.guncelle(
      Gider(
        id: gider.id,
        tarih: gider.tarih,
        aciklama: gider.aciklama,
        odemeTuru: gider.odemeTuru,
        tutar: gider.tutar,
        tekrarliMi: gider.tekrarliMi,
        odendi: !gider.odendi,
        not_: gider.not_,
      ),
    );
    await yukle();
  }

  Future<void> sil(int id) async {
    await _repo.sil(id);
    await yukle();
  }
}
