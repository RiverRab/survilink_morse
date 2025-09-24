import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class MorseScreen extends StatefulWidget {
  const MorseScreen({super.key});
  @override
  State<MorseScreen> createState() => _MorseScreenState();
}

class _MorseScreenState extends State<MorseScreen> {
  static const int unitMs = 150;
  static const int letterGap = 3, wordGap = 7;

  String buffer = "";
  String textOut = "";
  Timer? _tLetter, _tWord;

  final AudioPlayer _dot = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _dash = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  late final Map<String, String> morseToChar;

  @override
  void initState() {
    super.initState();
    morseToChar = {
      '.-':'A','-...':'B','-.-.':'C','-..':'D','.':'E','..-.':'F','--.':'G',
      '....':'H','..':'I','.---':'J','-.-':'K','.-..':'L','--':'M','-.':'N',
      '---':'O','.--.':'P','--.-':'Q','.-.':'R','...':'S','-':'T','..-':'U',
      '...-':'V','.--':'W','-..-':'X','-.--':'Y','--..':'Z',
      '-----':'0','.----':'1','..---':'2','...--':'3','....-':'4',
      '.....':'5','-....':'6','--...':'7','---..':'8','----.':'9'
    };
    _preload();
  }

  Future<void> _preload() async {
    await _dot.setSource(AssetSource('sounds/dot.mp3'));
    await _dash.setSource(AssetSource('sounds/dash.mp3'));
  }

  Future<void> _tap(bool dot) async {
    setState(() => buffer += dot ? '.' : '-');
    final p = dot ? _dot : _dash;
    await p.seek(Duration.zero);
    await p.resume();
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: dot ? unitMs : unitMs*3, amplitude: 128);
    }
    _schedule();
  }

  void _schedule() {
    _tLetter?.cancel();
    _tWord?.cancel();
    _tLetter = Timer(Duration(milliseconds: unitMs*letterGap), _commitLetter);
    _tWord   = Timer(Duration(milliseconds: unitMs*wordGap), _insertSpace);
  }

  void _commitLetter() {
    if (buffer.isEmpty) return;
    setState(() {
      textOut += morseToChar[buffer] ?? '?';
      buffer = "";
    });
  }

  void _insertSpace() {
    if (buffer.isNotEmpty || textOut.isEmpty || textOut.endsWith(' ')) return;
    setState(() => textOut += ' ');
  }

  void _clear() {
    _tLetter?.cancel(); _tWord?.cancel();
    setState(() { buffer = ""; textOut = ""; });
  }

  @override
  void dispose() {
    _tLetter?.cancel(); _tWord?.cancel();
    _dot.dispose(); _dash.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Clavier Morse')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF12161A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Texte décodé', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 6),
                  Text(textOut.isEmpty ? '—' : textOut,
                      style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Buffer: ', style: TextStyle(color: Colors.white70)),
                      Text(buffer.isEmpty ? '…' : buffer,
                          style: TextStyle(color: cs.primary, fontSize: 18)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(child: _Pad(label: '•', sub: 'POINT', color: const Color(0xFF1D3F2B), onTap: () => _tap(true))),
                  const SizedBox(width: 12),
                  Expanded(child: _Pad(label: '—', sub: 'TRAIT', color: const Color(0xFF16283D), onTap: () => _tap(false))),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
            child: Wrap(
              spacing: 10,
              children: [
                ElevatedButton.icon(onPressed: _commitLetter, icon: const Icon(Icons.check), label: const Text('Valider')),
                ElevatedButton.icon(onPressed: _clear, icon: const Icon(Icons.delete_sweep), label: const Text('Tout effacer')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pad extends StatefulWidget {
  final String label; final String sub; final Color color; final VoidCallback onTap;
  const _Pad({required this.label, required this.sub, required this.color, required this.onTap, super.key});
  @override State<_Pad> createState() => _PadState();
}
class _PadState extends State<_Pad> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(_pressed ? .85 : 1),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(_pressed? .1:.3), blurRadius: _pressed?4:14, offset: const Offset(0,6))],
        ),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(widget.label, style: const TextStyle(fontSize: 72, height: .9)),
            const SizedBox(height: 8),
            Text(widget.sub, style: const TextStyle(color: Colors.white70, letterSpacing: 1.2)),
          ]),
        ),
      ),
    );
  }
}
