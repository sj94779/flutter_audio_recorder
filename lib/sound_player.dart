import 'package:flutter/cupertino.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';

class SoundPlayer {

  FlutterSoundPlayer? audioPlayer;

  bool get isPlaying => audioPlayer!.isPlaying;

  Future init() async {
    audioPlayer = FlutterSoundPlayer();

    await audioPlayer!.openPlayer();
  }

  void dispose(){
    audioPlayer!.closePlayer();
    audioPlayer = null;

  }

  Future play(VoidCallback whenFinished, String filePath) async{
    await audioPlayer!.startPlayer(fromURI: filePath, whenFinished: whenFinished);
  }

  Future stop() async {
    await audioPlayer!.stopPlayer();
    print('player stopped');
  }

  Future togglePlaying({required VoidCallback whenFinished, required String filePath}) async{

    if(audioPlayer!.isStopped){
      await play(whenFinished, filePath);
    } else{
      await stop();

    }
  }

}