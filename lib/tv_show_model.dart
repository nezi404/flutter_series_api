import 'dart:convert';

import 'package:app3_series_api/fav_tv_show_screen.dart';
import 'package:app3_series_api/tv_show_service.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class TvShow {
  int id;
  String imageUrl;
  String name;
  String webChannel;
  double rating;
  String summary;

  TvShow({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.webChannel,
    required this.rating,
    required this.summary,
  });

  factory TvShow.fromJson(Map<String, dynamic> json) {
    return TvShow(
      id: json["id"],
      imageUrl: json["image"]?["medium"] ?? "",
      name: json["name"],
      webChannel: json["webChannel"]?["name"] ?? "N/A",
      rating: json["rating"]?["average"]?.toDouble() ?? 0.0,
      summary: json["summary"] ?? "Sem resumo disponível para essa série ❌"
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "imageUrl": imageUrl,
      "name": name,
      "webChannel": webChannel,
      "rating": rating,
      "summary": summary
    };
  }
}

class TvShowModel extends ChangeNotifier {

  late TvShowService _tvShowService = TvShowService();

  bool _isLoading = false;
  String? _errorMessage;

  List<TvShow> _tvShows = [];
  List<TvShow> get tvShows => _tvShows;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasFavourites => _tvShows.isNotEmpty;

  TvShowModel() {
    _tvShowService = TvShowService();
    initialize();
  }

  Future<void> initialize() async {
    await load();
  }

  Future<void> initializeAsc() async {
    await loadAsc();
  }

  Future<void> initializeDes() async {
    await loadDesc();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> load() async {
    try {
      _setLoading(true);
      _setError(null);
      _tvShows = await _tvShowService.getAll();

    } catch (e) {
      _setError("Falha ao carregar séries favoritas do banco: ${e.toString()}");
    } finally {
      _setLoading(false);
    }
  }

    Future<void> loadAsc() async {
      try {
      _setLoading(true);
      _setError(null);
      _tvShows = await _tvShowService.getAllOrdered();

    } catch (e) {
      _setError("Falha ao carregar séries favoritas do banco ordenadas: ${e.toString()}");
    } finally {
      _setLoading(false);
    }
    }

    Future<void> loadDesc() async {
      try {
      _setLoading(true);
      _setError(null);
      _tvShows = await _tvShowService.getAllDesc();

      } catch (e) {
        _setError("Falha ao carregar séries favoritas do banco ordenadas: ${e.toString()}");
      } finally {
        _setLoading(false);
      }
    }

  Future<bool> isFavourite (TvShow tvShow) async {
    try {
      return await _tvShowService.isFavourite(tvShow);
    } catch (e) {
      _setError("Falha ao verificar se a série é séries favoritas: ${e.toString()}");
      return false;
    } 
  }
  // adicionando ao banco de dados
  Future<void> addToFavourites(TvShow tvShow) async {
    await _tvShowService.insert(tvShow);
    notifyListeners();
  }

  // removendo do banco de dados
  Future<void> removeFromFavourites(TvShow tvShow) async {
    await _tvShowService.delete(tvShow.id);
    notifyListeners();
  }

  Future<TvShow> getTvShowById(int id) async {
    try {
      return await _tvShowService.fetchTvShowById(id);
    } catch (e) {
      throw Exception("Falha em carregar série: ${e.toString()}❌");
    }
  }

  Future<List<TvShow>> searchTvShows(String query) async {
    try {
      return await _tvShowService.fetchTvShow(query);
    } catch (e) {
      throw Exception("Falha em buscar séries: ${e.toString()}❌");
    }
  }

  void addTvShow(TvShow tvShow, BuildContext context) {
    tvShows.add(tvShow);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Série adicionada aos favoritos!',
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 2),
      ),
    );
    notifyListeners();
  }

  void removeTvShow(TvShow tvShow, BuildContext context) {
    final index = tvShows.indexWhere(
      (show) => show.name.toLowerCase() == tvShow.name.toLowerCase(),
    );
    tvShows.removeAt(index);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${tvShow.name} removida dos favoritos!'),
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: 'DESFAZER',
          onPressed: () {
            tvShows.insert(index, tvShow);
            notifyListeners();
          },
        ),
      ),
    );
    notifyListeners();
  }

  void editTvShow(TvShow oldTvShow, TvShow newTvShow, BuildContext context) {
    final index = tvShows.indexOf(oldTvShow);
    tvShows[index] = newTvShow;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Série ${index + 1} atualizada!'),
        duration: Duration(seconds: 2),
      ),
    );
    notifyListeners();
  }
}