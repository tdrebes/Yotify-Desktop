import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yotifiy/core/api/playlist_importer.dart';
import 'package:yotifiy/core/api/spotify_api.dart';
import 'package:yotifiy/core/logger.dart';
import 'package:yotifiy/playlist/playlist_model.dart';

part 'import_playlist_cubit.g.dart';

@CopyWith()
class YFImportPlaylistState {
  final YFPlaylist? data;
  final bool isLoading;
  final dynamic error;

  bool get hasError => error != null;

  YFImportPlaylistState({
    this.data,
    this.isLoading = false,
    this.error,
  });
}

class YFImportPlaylistCubit extends Cubit<YFImportPlaylistState> with Logger {
  final YFSpotifyApi _spotifyApi;
  final YFPlaylistImporter _playlistImporter;

  YFImportPlaylistCubit(this._spotifyApi, this._playlistImporter)
      : super(YFImportPlaylistState());

  Future<void> createPlaylist(String id) async {
    emit(state.copyWith(isLoading: true));
    try {
      final playlistId = id.substring(
        id.indexOf('playlist/') + 'playlist/'.length,
        id.indexOf('?'),
      );
      final r = await _spotifyApi.fetchPlaylist(playlistId);
      print('${r.name} - ${r.description} - ${r.mediaItems.length}');

      emit(state.copyWith(data: r, isLoading: false));
    } catch (e, stack) {
      print('ERROOOOOOOOOOOOOOOOOOOOOR');
      emit(state.copyWith(isLoading: false));
      logError(e, stack);
    }
  }

  Future<void> importPlaylist(YFPlaylist playlist) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _playlistImporter.import(playlist);
      emit(state.copyWith(isLoading: false));
    } catch (e, stack) {
      print('ERROOOOOOOOOOOOOOOOOOOOOR (Import)');
      emit(state.copyWith(isLoading: false));
      logError(e, stack);
    }
  }
}
