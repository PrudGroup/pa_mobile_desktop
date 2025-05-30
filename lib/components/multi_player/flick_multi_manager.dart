import 'package:flick_video_player/flick_video_player.dart';

class FlickMultiManager {
  // ignore: prefer_final_fields
  List<FlickManager> _flickManagers = [];
  FlickManager? _activeManager;
  bool _isMute = true;

  init(FlickManager flickManager) {
    _flickManagers.add(flickManager);
    if (_isMute) {
      flickManager.flickControlManager?.mute();
    } else {
      flickManager.flickControlManager?.unmute();
    }
    if (_flickManagers.length == 1) {
      play(flickManager);
    }
  }

  remove(FlickManager flickManager) {
    if (_activeManager == flickManager) {
      _activeManager = null;
    }
    flickManager.dispose();
    _flickManagers.remove(flickManager);
  }

  togglePlay(FlickManager flickManager) {
    if (_activeManager?.flickVideoManager?.isPlaying == true &&
        flickManager == _activeManager) {
      pause();
    } else {
      play(flickManager);
    }
  }

  pause() {
    _activeManager?.flickControlManager?.pause();
  }

  play([FlickManager? flickManager]) {
    if (flickManager != null) {
      _activeManager?.flickControlManager?.pause();
      _activeManager = flickManager;
    }

    if (_isMute) {
      _activeManager?.flickControlManager?.mute();
    } else {
      _activeManager?.flickControlManager?.unmute();
    }

    _activeManager?.flickControlManager?.play();
  }

  toggleMute() {
    _activeManager?.flickControlManager?.toggleMute();
    _isMute = _activeManager?.flickControlManager?.isMute ?? false;
    if (_isMute) {
      for (var manager in _flickManagers) {
        manager.flickControlManager?.mute();
      }
    } else {
      for (var manager in _flickManagers) {
        manager.flickControlManager?.unmute();
      }
    }
  }
}
