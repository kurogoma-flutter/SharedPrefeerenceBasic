import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyFirstApp());
}

class MyFirstApp extends StatelessWidget {
  const MyFirstApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My First App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // スタート画面を表示
      home: const StartPage(),
    );
  }
}

class StartPage extends StatelessWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'スライドパズル',
              style: TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => showPuzzlePage(context), // 処理を追加
              child: const Text('スタート'),
            ),
          ],
        ),
      ),
    );
  }

  void showPuzzlePage(BuildContext context) {
    // パズル画面へと遷移
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PuzzlePage()),
    );
  }
}

class PuzzlePage extends StatefulWidget {
  const PuzzlePage({Key? key}) : super(key: key);

  @override
  _PuzzlePageState createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> {
  // 現在のタイルの状態
  List<int> puzzleNumbers = [1, 2, 3, 4, 5, 6, 7, 8, 0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('スライドパズル'),
        actions: [
          // 保存したタイルの状態を読み込むボタン
          IconButton(
            onPressed: () => loadPuzzleNumbers(),
            icon: const Icon(Icons.play_arrow),
          ),
          // 現在のタイルの状態を保存するボタン
          IconButton(
            onPressed: () => savePuzzleNumbers(),
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // タイル一覧
            Expanded(
              child: Center(
                child: PuzzlesView(
                  numbers: puzzleNumbers,
                  isCorrect: calcIsCorrect(puzzleNumbers),
                  // タップしたら入れ替える
                  onPressed: (number) => swapPuzzle(number),
                ),
              ),
            ),
            // シャッフルボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => shufflePuzzles(),
                icon: const Icon(Icons.shuffle),
                label: const Text('シャッフル'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // タイルが正解であるか
  bool calcIsCorrect(List<int> numbers) {
    final correctNumbers = [1, 2, 3, 4, 5, 6, 7, 8, 0];
    for (int i = 0; i < correctNumbers.length; i++) {
      if (numbers[i] != correctNumbers[i]) {
        return false;
      }
    }
    return true;
  }

  // タップしたタイルと空白を入れ替える
  void swapPuzzle(int number) {
    // タップしたタイルと空白が隣り合っている場合のみ入れ替える
    if (canSwapPuzzle(number)) {
      setState(() {
        final indexOfPuzzle = puzzleNumbers.indexOf(number);
        final indexOfEmpty = puzzleNumbers.indexOf(0);
        puzzleNumbers[indexOfPuzzle] = 0;
        puzzleNumbers[indexOfEmpty] = number;
      });
    }
  }

  // タップしたタイルが空白と入れ替え可能であるか
  bool canSwapPuzzle(int number) {
    final indexOfPuzzle = puzzleNumbers.indexOf(number);
    final indexOfEmpty = puzzleNumbers.indexOf(0);
    switch (indexOfEmpty) {
      case 0:
        return [1, 3].contains(indexOfPuzzle);
      case 1:
        return [0, 2, 4].contains(indexOfPuzzle);
      case 2:
        return [1, 5].contains(indexOfPuzzle);
      case 3:
        return [0, 4, 6].contains(indexOfPuzzle);
      case 4:
        return [1, 3, 5, 7].contains(indexOfPuzzle);
      case 5:
        return [2, 4, 8].contains(indexOfPuzzle);
      case 6:
        return [3, 7].contains(indexOfPuzzle);
      case 7:
        return [4, 6, 8].contains(indexOfPuzzle);
      case 8:
        return [5, 7].contains(indexOfPuzzle);
      default:
        return false;
    }
  }

  // タイルをシャッフルする
  void shufflePuzzles() {
    setState(() {
      puzzleNumbers.shuffle();
    });
  }

  // 現在のタイルの状態を保存する
  void savePuzzleNumbers() async {
    final value = jsonEncode(puzzleNumbers);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('Puzzle_NUMBERS', value);
  }

  // 保存したタイルの状態を読み込む
  void loadPuzzleNumbers() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('Puzzle_NUMBERS');
    if (value != null) {
      final numbers = (jsonDecode(value) as List<dynamic>).map((v) => v as int).toList();
      setState(() {
        puzzleNumbers = numbers;
      });
    }
  }
}

class PuzzlesView extends StatelessWidget {
  final List<int> numbers;
  final bool isCorrect;
  final void Function(int number) onPressed;

  const PuzzlesView({
    Key? key,
    required this.numbers,
    required this.isCorrect,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // グリッド状にWidgetを並べる
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      crossAxisSpacing: 24,
      mainAxisSpacing: 24,
      padding: const EdgeInsets.symmetric(vertical: 24),
      children: numbers // 受け取ったデータを元に表示する
          .map((number) {
        if (number == 0) {
          return Container();
        }
        return PuzzleView(
          number: number,
          // 正解の場合は色を変える
          color: isCorrect ? Colors.green : Colors.blue,
          // コールバックでタップされたことを伝える
          onPressed: () => onPressed(number),
        );
      }).toList(),
    );
  }
}

class PuzzleView extends StatelessWidget {
  final int number;
  final Color color;
  final void Function() onPressed;

  const PuzzleView({
    Key? key,
    required this.number,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: color,
        textStyle: const TextStyle(fontSize: 32),
      ),
      child: Center(
        child: Text(number.toString()),
      ),
    );
  }
}
