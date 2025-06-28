// import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xo_game_v2/start_symbol.dart';
import 'package:list_tile_switch/list_tile_switch.dart';

class WelcomeScreen extends StatefulWidget {
  static const String routeName = '/welcome';

  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String? userName;
  String? userName2;
  String? selectedSymbol;
  String? selectedMode;
  String? selectedModeLevel;

  final clickplayer = AudioPlayer();
  final backgroundplayer = AudioPlayer();

  bool isMusicOn = true;
  bool isSoundOn = true;

  @override
  void initState() {
    super.initState();
    backgroundplayer.setAudioContext(
      AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
      ),
    );
    clickplayer.setAudioContext(
      AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.assistanceSonification,
          audioFocus: AndroidAudioFocus.none,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
      ),
    );
    _playBackgroundMusic();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('player1Name');
    });
  }

  Future<void> _playBackgroundMusic() async {
    await backgroundplayer.setReleaseMode(ReleaseMode.loop);
    await backgroundplayer.play(
      AssetSource('sounds/background.wav'),
      volume: 0.5,
    );
  }

  Future<void> _showUserNameDialog({bool fromSettings = false}) async {
    GlobalKey<FormState> formState = GlobalKey();

    final name = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: Text(
              'Your Name',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: SingleChildScrollView(
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: formState,
                child: TextFormField(
                  keyboardType: TextInputType.name,
                  onSaved: (newValue) {
                    userName = newValue;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'This Field Can\'t be Empty';
                    }

                    if (value.length < 6 || value.length > 15) {
                      return 'The User Name Must Be (6 ~ 15)';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),

                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.grey.shade800,
                      ),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        width: 2,
                        color: Color(0xFF3A7BD5),
                      ),
                    ),

                    label: Text(
                      'UserName',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    prefixIcon: Icon(CupertinoIcons.person_solid),
                  ),
                ),
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 10,
                    backgroundColor: Color(0xFF27548A),
                  ),
                  onPressed: () {
                    if (formState.currentState!.validate()) {
                      formState.currentState!.save();
                      Navigator.pop(context, userName);
                    }
                  },
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
    if (name != null && name.trim().isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('player1Name', name.trim());
      setState(() {
        userName = name.trim();
      });
      if (!fromSettings) {
        _showSymbolDialog();
      }
    }
  }

  Future<void> _showSymbolDialog() async {
    final symbol = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: Center(
              child: Text(
                'Pick who goes first',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context, 'x'),
                  child: StartSymbol(symbol: 'x'),
                ),
                SizedBox(width: 16),
                GestureDetector(
                  onTap: () => Navigator.pop(context, 'o'),
                  child: StartSymbol(symbol: 'o'),
                ),
              ],
            ),
          ),
    );
    if (symbol != null) {
      setState(() {
        selectedSymbol = symbol;
      });
      _showModeDialog();
    }
  }

  Future<void> _showModeDialog() async {
    final mode = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: Center(
              child: Text(
                'Choose game mode',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, 'friend'),
                    child: StartSymbol(text: 'FRIEND'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, 'bot'),
                    child: StartSymbol(text: 'BOT'),
                  ),
                ),
              ],
            ),
          ),
    );
    if (mode != null) {
      setState(() {
        selectedMode = mode;
      });
      if (mode == 'friend') {
        _showUserName2Dialog();
      } else {
        userName2 = 'bot';
        _showModeLevelDialog();
      }
    }
  }

  Future<void> _showUserName2Dialog() async {
    GlobalKey<FormState> formState = GlobalKey();

    final name2 = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: Text(
              'Player 2 Name',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: SingleChildScrollView(
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: formState,
                child: TextFormField(
                  keyboardType: TextInputType.name,
                  onSaved: (newValue) {
                    userName2 = newValue;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'This Field Can\'t be Empty';
                    }

                    if (value.length < 6 || value.length > 15) {
                      return 'The User Name Must Be (6 ~ 15)';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),

                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.grey.shade800,
                      ),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        width: 2,
                        color: Color(0xFF3A7BD5),
                      ),
                    ),

                    label: Text(
                      'UserName',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    prefixIcon: Icon(CupertinoIcons.person_solid),
                  ),
                ),
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 10,
                    backgroundColor: Color(0xFF27548A),
                  ),
                  onPressed: () {
                    if (formState.currentState!.validate()) {
                      formState.currentState!.save();
                      Navigator.pop(context, userName2);
                    }
                  },
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
    if (name2 != null && name2.trim().isNotEmpty) {
      setState(() {
        userName2 = name2.trim();
      });
      _navigateToGame();
    }
  }

  Future<void> _showModeLevelDialog() async {
    final level = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: Center(
              child: Text(
                'Choose Difficulty',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context, 'easy'),
                  child: StartSymbol(text: 'EASY'),
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.pop(context, 'hard'),
                  child: StartSymbol(text: 'HARD'),
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.pop(context, 'extreme'),
                  child: StartSymbol(text: 'EXTREME'),
                ),
              ],
            ),
          ),
    );
    if (level != null) {
      setState(() {
        selectedModeLevel = level;
      });
      _navigateToGame();
    }
  }

  void _navigateToGame() {
    Navigator.pushNamed(
      context,
      '/main',
      arguments: {
        'symbol': selectedSymbol,
        'mode': selectedMode,
        'level': selectedModeLevel,
        'player1Name': userName,
        'player2Name': userName2,
        'isSoundOn': isSoundOn,
        'isMusicOn': isMusicOn,
      },
    );
  }

  void _startGameFlow() {
    if (userName == null || userName!.isEmpty) {
      _showUserNameDialog();
    } else {
      _showSymbolDialog();
    }
  }

  Future<void> _saveSoundSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isMusicOn', isMusicOn);
    await prefs.setBool('isSoundOn', isSoundOn);
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(CupertinoIcons.arrow_left),
                ),
                Text('Sound Settings'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTileSwitch(
                  title: Text('Music'),
                  visualDensity: VisualDensity.comfortable,
                  switchType: SwitchType.cupertino,
                  switchScale: 1,
                  switchActiveColor: Colors.green,
                  value: isMusicOn,
                  onChanged: (val) async {
                    setState(() {
                      isMusicOn = val;
                    });
                    await _saveSoundSettings();
                    if (isMusicOn) {
                      _playBackgroundMusic();
                    } else {
                      backgroundplayer.pause();
                    }
                    Navigator.pop(context);
                  },
                ),

                ListTileSwitch(
                  title: Text('Sound Effects'),
                  visualDensity: VisualDensity.comfortable,
                  switchType: SwitchType.cupertino,
                  switchScale: 1,
                  switchActiveColor: Colors.green,
                  value: isSoundOn,
                  onChanged: (val) async {
                    setState(() {
                      isSoundOn = val;
                    });
                    await _saveSoundSettings();
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: 16),

                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 10,
                      backgroundColor: Color(0xFF27548A),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      await _showUserNameDialog(fromSettings: true);
                      _showSettingsDialog();
                    },
                    child: Text(
                      'Change Your Name',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                Center(
                  child: Text(
                    'Version 1.1',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00D2FF), Color(0xFF3A7BD5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Image.asset(
                'assets/images/tic_tac_toe.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Spacer(),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                width: double.infinity,
                height: MediaQuery.sizeOf(context).height * 0.08,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 10,
                    backgroundColor: Color(0xFF27548A),
                  ),
                  onPressed: () async {
                    if (isSoundOn) {
                      await clickplayer.play(AssetSource('sounds/click.wav'));
                    }
                    _startGameFlow();
                  },
                  child: Text(
                    'Start',
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 50),
                width: double.infinity,
                height: MediaQuery.sizeOf(context).height * 0.08,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 10,
                    backgroundColor: Color(0xFF3674B5),
                  ),
                  onPressed: () async {
                    if (isSoundOn) {
                      await clickplayer.play(AssetSource('sounds/click.wav'));
                    }
                    _showSettingsDialog();
                  },
                  child: Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
