import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder/sound_player.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    initRecorder();
    player.init();
    super.initState();
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    player.dispose();
    super.dispose();
  }

  final recorder = FlutterSoundRecorder();

  final player = SoundPlayer();

  var filePath = '';

  Future initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Permission not granted';
    }
    await recorder.openRecorder();
    recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  Future startRecord() async {
    await recorder.startRecorder(toFile: "audio");
  }

  Future stopRecorder() async {
    setState(() async {
      filePath = (await recorder.stopRecorder())!;
    });

    print('Recorded file path: $filePath');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.teal.shade700,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder<RecordingDisposition>(
                builder: (context, snapshot) {
                  final duration = snapshot.hasData
                      ? snapshot.data!.duration
                      : Duration.zero;

                  String twoDigits(int n) => n.toString().padLeft(2, '0');

                  final twoDigitMinutes =
                      twoDigits(duration.inMinutes.remainder(60));
                  final twoDigitSeconds =
                      twoDigits(duration.inSeconds.remainder(60));

                  return Text(
                    '$twoDigitMinutes:$twoDigitSeconds',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
                stream: recorder.onProgress,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () async {
                    if (recorder.isRecording) {
                      await stopRecorder();
                      setState(() {});
                    } else {
                      await startRecord();
                      setState(() {});
                    }
                    setState(() {});
                  },
                  child: recorder.isRecording
                      ? const Text('Stop')
                      : const Text('Record')),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () async {
                    await player.togglePlaying(
                        whenFinished: () => setState(() {}),
                        filePath: filePath);
                    setState(() {});
                  },
                  child: player.isPlaying
                      ? const Text('Stop')
                      : const Text('Play')),
            ],
          ),
        ));
  }
}
