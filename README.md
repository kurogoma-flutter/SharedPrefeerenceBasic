# shared_preference_basic

SharedPreferenceの基礎学習用アプリ

## 仕様

<img src="https://user-images.githubusercontent.com/67848399/159208147-c863013c-794f-4792-a9dc-d6f5d1c150d5.png" width="200">

1. シャッフルボタンでパネルが入れ替わる。（空白も存在する）
2. 右上の保存ボタンで現在の状態をローカルに保存する
3. 再生ボタンを押せばローカル保存したデータを参照できる

## 参照結果
<img src="https://user-images.githubusercontent.com/67848399/159208158-f6ca978e-dfb6-45b2-b8fb-bf12449f4827.png" width="200">

## コードの該当部分
### ローカル端末に保存
一度json化して保存する。Webでいうセッションに保存する感覚と近い
```dart
void savePuzzleNumbers() async {
  final value = jsonEncode(puzzleNumbers);
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('Puzzle_NUMBERS', value);
}
```
### ローカルデータを参照
jsonDecodeして配列化する

```dart
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
```
