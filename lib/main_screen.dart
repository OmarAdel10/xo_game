import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xo_game_v2/board_item.dart';
import 'package:xo_game_v2/welcome_screen.dart';

class MainScreen extends StatefulWidget {
  static const String routeName = '/main';

  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int player1Score = 0;
  int player2Score = 0;
  late String player1Symbol;
  late String player2Symbol;
  late String player1Name;
  late String player2Name;
  late bool isSoundOn;
  late bool isMusicOn;

  String text = '';
  String smallText = '';

  List<String> board = List.filled(9, '');

  late bool isUserFirst; // true if user goes first

  final player = AudioPlayer();
  final backgroundplayer = AudioPlayer();

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // You can still initialize your audio players here
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
    player.setAudioContext(
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)!.settings.arguments as Map;
      player1Symbol = args['symbol'];
      player2Symbol = player1Symbol == 'x' ? 'o' : 'x';
      player1Name = args['player1Name'] ?? 'Player 1';
      player2Name = args['player2Name'] ?? 'Player 2';
      isUserFirst = player1Symbol == 'x';
      isMusicOn = args['isMusicOn'] ?? true;
      isSoundOn = args['isSoundOn'] ?? true;
      _playBackgroundMusic();
      // If bot goes first, let it play
      if (args['mode'] == 'bot' && !isUserFirst) {
        _botPlayIfNeeded();
      }
      _initialized = true;
    }
  }

  Future<void> _playBackgroundMusic() async {
    if (isMusicOn) {  
    await backgroundplayer.setReleaseMode(ReleaseMode.loop);
    await backgroundplayer.play(
      AssetSource('sounds/background.wav'),
      volume: 0.5,
    );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    player1Symbol = args['symbol'];
    player2Symbol = player1Symbol == 'x' ? 'o' : 'x';
    player1Name = args['player1Name'] ?? 'Player 1';
    player2Name = args['player2Name'] ?? 'Player 2';

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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: double.infinity,
                  height: MediaQuery.sizeOf(context).height * 0.1,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(44),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        '$player1Name : $player1Score',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      Text(
                        '$player2Name : $player2Score',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),

                Text(
                  round == 1 ? '$player1Name\'s Turn' : text,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  round == 1
                      ? '(${player1Symbol.toUpperCase()}\'s Turn)'
                      : smallText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Spacer(),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  height: MediaQuery.sizeOf(context).height * 0.60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(44),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(44),
                      color: Colors.black,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisExtent:
                            MediaQuery.sizeOf(context).height * 0.19,
                        mainAxisSpacing: 1,
                        crossAxisSpacing: 1,
                      ),
                      itemBuilder:
                          (_, index) => BoardItem(
                            text: board[index],
                            onPressed: onItemClicked,
                            index: index,
                            highlighted:
                                winningIndices?.contains(index) ?? false,
                          ),
                      itemCount: board.length,
                    ),
                  ),
                ),
                Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.sizeOf(context).height * 0.08,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 10,
                      backgroundColor: Color(0xFF27548A),
                    ),
                    onPressed: () async {
                      if (isSoundOn) {
                        if (isSoundOn) {
                          await player.play(AssetSource('sounds/click.wav'));
                        }
                      }
                      Navigator.pushReplacementNamed(
                        context,
                        WelcomeScreen.routeName,
                      );
                    },
                    child: Text(
                      'Replay ?',
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
      ),
    );
  }

  int round = 1;

  void onItemClicked(int index) async {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final mode = args['mode'];
    if (board[index].isNotEmpty) return;

    bool isUserTurn =
        (isUserFirst && round.isOdd) || (!isUserFirst && round.isEven);

    if (isUserTurn) {
      // User's move
      text = '$player1Name\'s Turn';
      smallText = '${player1Symbol.toUpperCase()}\'s Turn';
      board[index] = player1Symbol;
      if (isSoundOn) {
        await player.play(AssetSource('sounds/click.wav'));
      }
      setState(() {});
      winningIndices = getWinningIndices(player1Symbol);
      if (checkWinner(player1Symbol)) {
        text = '$player1Name Wins';
        smallText = '${player1Symbol.toUpperCase()} Wins';
        player1Score++;
        if (isSoundOn) {
          await player.play(AssetSource('sounds/win.wav'));
        }
        await Future.delayed(Duration(seconds: 1));
        clearBoard();
        return;
      }
      round++;
      text =
          ((isUserFirst && round.isOdd) || (!isUserFirst && round.isEven))
              ? '$player1Name\'s Turn'
              : '$player2Name\'s Turn';
      smallText =
          ((isUserFirst && round.isOdd) || (!isUserFirst && round.isEven))
              ? '${player1Symbol.toUpperCase()}\'s Turn'
              : '${player2Symbol.toUpperCase()}\'s Turn';
      if (round == 10) {
        text = 'Draw';
        smallText = '';
        if (isSoundOn) {
          await player.play(AssetSource('sounds/draw.wav'));
        }
        await Future.delayed(Duration(seconds: 1));
        clearBoard();
        return;
      }
      // If it's bot mode and now it's bot's turn, let the bot play
      if (mode == 'bot' &&
          !((isUserFirst && round.isOdd) || (!isUserFirst && round.isEven))) {
        _botPlayIfNeeded();
      }
    } else {
      // Player 2's move (friend mode only)
      if (mode == 'friend') {
        text = '$player2Name\'s Turn';
        smallText = '${player2Symbol.toUpperCase()}\'s Turn';
        board[index] = player2Symbol;
        if (isSoundOn) {
          await player.play(AssetSource('sounds/click.wav'));
        }
        setState(() {});
        winningIndices = getWinningIndices(player2Symbol);
        if (checkWinner(player2Symbol)) {
          text = '$player2Name Wins';
          smallText = '${player2Symbol.toUpperCase()} Wins';
          player2Score++;
          if (isSoundOn) {
            await player.play(AssetSource('sounds/win.wav'));
          }
          await Future.delayed(Duration(seconds: 1));
          clearBoard();
          return;
        }
        round++;
        text =
            ((isUserFirst && round.isOdd) || (!isUserFirst && round.isEven))
                ? '$player1Name\'s Turn'
                : '$player2Name\'s Turn';
        smallText =
            ((isUserFirst && round.isOdd) || (!isUserFirst && round.isEven))
                ? '${player1Symbol.toUpperCase()}\'s Turn'
                : '${player2Symbol.toUpperCase()}\'s Turn';
        if (round == 10) {
          text = 'Draw';
          smallText = '';
          if (isSoundOn) {
            await player.play(AssetSource('sounds/draw.wav'));
          }
          await Future.delayed(Duration(seconds: 1));
          clearBoard();
          return;
        }
      }
    }
  }

  bool checkWinner(String symbol) {
    if (round < 5) return false;

    // 0 4 8
    // 2 4 6
    if (board[0] == symbol && board[4] == symbol && board[8] == symbol) {
      return true;
    }

    if (board[2] == symbol && board[4] == symbol && board[6] == symbol) {
      return true;
    }

    // 0 1 2
    // 3 4 5
    // 6 7 8
    for (int i = 0; i <= 6; i += 3) {
      if (board[i] == symbol &&
          board[i + 1] == symbol &&
          board[i + 2] == symbol) {
        return true;
      }
    }

    // 0 3 6
    // 1 4 7
    // 2 5 8
    for (int i = 0; i <= 2; i++) {
      if (board[i] == symbol &&
          board[i + 3] == symbol &&
          board[i + 6] == symbol) {
        return true;
      }
    }

    return false;
  }

  List<int>? winningIndices;

  List<int>? getWinningIndices(String symbol) {
    List<List<int>> winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
      [0, 4, 8], [2, 4, 6], // diagonals
    ];
    for (var pattern in winPatterns) {
      if (board[pattern[0]] == symbol &&
          board[pattern[1]] == symbol &&
          board[pattern[2]] == symbol) {
        return pattern;
      }
    }
    return null;
  }

  void clearBoard() {
    board = List.filled(9, '');
    round = 1;
    winningIndices = null;
    setState(() {});
    // If bot should go first, trigger bot move after clearing
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    if (args['mode'] == 'bot' && !isUserFirst) {
      _botPlayIfNeeded();
    }
  }

  int getBotMove(String level, String botSymbol, String playerSymbol) {
    List<int> emptyCells = [];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == '') emptyCells.add(i);
    }

    if (level == 'easy') {
      // Random move
      return emptyCells[Random().nextInt(emptyCells.length)];
    } else if (level == 'hard') {
      // Try to win or block, else random
      for (int i in emptyCells) {
        board[i] = botSymbol;
        if (checkWinner(botSymbol)) {
          board[i] = '';
          return i;
        }
        board[i] = '';
      }
      for (int i in emptyCells) {
        board[i] = playerSymbol;
        if (checkWinner(playerSymbol)) {
          board[i] = '';
          return i;
        }
        board[i] = '';
      }
      return emptyCells[Random().nextInt(emptyCells.length)];
    } else if (level == 'extreme') {
      // Minimax
      int bestScore = -999;
      int move = emptyCells[0];
      for (int i in emptyCells) {
        List<String> boardCopy = List.from(board);
        boardCopy[i] = botSymbol;
        int score = minimax(boardCopy, 0, false, botSymbol, playerSymbol);
        if (score > bestScore) {
          bestScore = score;
          move = i;
        }
      }
      return move;
    }
    // Default fallback
    return emptyCells[Random().nextInt(emptyCells.length)];
  }

  int minimax(
    List<String> newBoard,
    int depth,
    bool isMax,
    String botSymbol,
    String playerSymbol,
  ) {
    if (checkWinnerOnBoard(newBoard, botSymbol)) return 10 - depth;
    if (checkWinnerOnBoard(newBoard, playerSymbol)) return depth - 10;
    if (!newBoard.contains('')) return 0;

    List<int> emptyCells = [];
    for (int i = 0; i < newBoard.length; i++) {
      if (newBoard[i] == '') emptyCells.add(i);
    }

    if (isMax) {
      int bestScore = -999;
      for (int i in emptyCells) {
        newBoard[i] = botSymbol;
        int score = minimax(
          newBoard,
          depth + 1,
          false,
          botSymbol,
          playerSymbol,
        );
        newBoard[i] = '';
        bestScore = max(score, bestScore);
      }
      return bestScore;
    } else {
      int bestScore = 999;
      for (int i in emptyCells) {
        newBoard[i] = playerSymbol;
        int score = minimax(newBoard, depth + 1, true, botSymbol, playerSymbol);
        newBoard[i] = '';
        bestScore = min(score, bestScore);
      }
      return bestScore;
    }
  }

  void _botPlayIfNeeded() async {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final mode = args['mode'];
    final level = args['level'];

    // Determine if it's bot's turn based on isUserFirst and round
    bool isBotTurn =
        (!isUserFirst && round.isOdd) || (isUserFirst && round.isEven);

    if (mode == 'bot' && isBotTurn) {
      await Future.delayed(Duration(milliseconds: 400));
      int botMove = getBotMove(level, player2Symbol, player1Symbol);
      if (board[botMove] == '') {
        board[botMove] = player2Symbol;
        if (isSoundOn) {
          await player.play(AssetSource('sounds/click.wav'));
        }
        setState(() {});
        if (checkWinner(player2Symbol)) {
          text = '$player2Name Wins';
          smallText = '${player2Symbol.toUpperCase()} Wins';
          player2Score++;
          if (isSoundOn) {
            await player.play(AssetSource('sounds/win.wav'));
          }
          await Future.delayed(Duration(seconds: 1));
          clearBoard();
          return;
        }
        round++;
        text =
            ((isUserFirst && round.isOdd) || (!isUserFirst && round.isEven))
                ? '$player1Name\'s Turn'
                : '$player2Name\'s Turn';
        smallText =
            ((isUserFirst && round.isOdd) || (!isUserFirst && round.isEven))
                ? '${player1Symbol.toUpperCase()}\'s Turn'
                : '${player2Symbol.toUpperCase()}\'s Turn';
        if (round == 10) {
          text = 'Draw';
          smallText = '';
          if (isSoundOn) {
            await player.play(AssetSource('sounds/draw.wav'));
          }
          await Future.delayed(Duration(seconds: 1));
          clearBoard();
          return;
        }
      }
    }
  }

  bool checkWinnerOnBoard(List<String> boardToCheck, String symbol) {
    // 0 4 8
    // 2 4 6
    if (boardToCheck[0] == symbol &&
        boardToCheck[4] == symbol &&
        boardToCheck[8] == symbol) {
      return true;
    }
    if (boardToCheck[2] == symbol &&
        boardToCheck[4] == symbol &&
        boardToCheck[6] == symbol) {
      return true;
    }
    for (int i = 0; i <= 6; i += 3) {
      if (boardToCheck[i] == symbol &&
          boardToCheck[i + 1] == symbol &&
          boardToCheck[i + 2] == symbol) {
        return true;
      }
    }
    for (int i = 0; i <= 2; i++) {
      if (boardToCheck[i] == symbol &&
          boardToCheck[i + 3] == symbol &&
          boardToCheck[i + 6] == symbol) {
        return true;
      }
    }
    return false;
  }
}
