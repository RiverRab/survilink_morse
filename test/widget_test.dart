import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class MorseScreen extends StatefulWidget {
  const MorseScreen({super.key});
  @override
  State<MorseScreen> createState() => _MorseScreenState();
}

class _MorseScreenState extends State<MorseScreen> {
  // État
  String morseLine = "";       // la ligne que TU saisis (affichée en bas)
  String translatedText = "";  // résultat après "Traduire"
  bool audioOn = true;
  bool hapticOn = true;

  // Audio
  final AudioPlayer _dot = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _dash = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  // Dico Morse
  late final Map<String, String> morseToChar;
  late final Map<String, String> charToMorse;

  @override
  void initState() {
    super.initState();
    _initMaps();
    _preload();
  }

  void _initMaps() {
    charToMorse = {
      'A': '.-','B': '-...','C': '-.-.','D': '-..','E': '.','F': '..-.',
      'G': '--.','H': '....','I': '..','J': '.---','K': '-.-','L': '.-..',
      'M': '--','N': '-.','O': '---','P': '.--.','Q': '--.-','R': '.-.',
      'S': '...','T': '-','U': '..-','V': '...-','W': '.--','X': '-..-',
      'Y': '-.--','Z': '--..',
      '0': '-----','1': '.----','2': '..---','3': '...--','4': '....-',
      '5': '.....','6': '-....','7': '--...','8': '---..','9': '----.',
      '.': '.-.-.-', ',': '--..--', '?': '..--..', '\'': '.----.',
      '!': '-.-.--', '/': '-..-.', '(': '-.--.', ')': '-.--.-', '&': '.-...',
      ':': '---...', ';': '-.-.-.', '=': '-...-', '+': '.-.-.', '-': '-....-',
      '_': '..--.-', '"': '.-..-.', '@': '.--.-.'
    };
    morseToChar = { for (final e in charToMorse.entries) e.value : e.key };
  }

  Future<void> _preload() async {
    await _dot.setSource(AssetSource('sounds/dot.mp3'));
    await _dash.setSource(AssetSource('sounds/dash.mp3'));
  }

  // --- Saisie ---
  Future<void> _addDot() async {
    setState(() => morseLine += ".");
    await _beep(dot: true);
  }

  Future<void> _addDash() async {
    setState(() => morseLine += "-");
    await _beep(dot: false);
  }

  Future<void> _beep({required bool dot}) async {
    if (audioOn) {
      final p = dot ? _dot : _dash;
      await p.seek(Duration.zero);
      await p.resume();
    }
    if (hapticOn && (await Vibration.hasVibrator() ?? false)) {
      Vibration.vibrate(duration: dot ? 120 : 360, amplitude: 128);
    }
  }

  void _spaceLetter() {
    // espace = séparation de lettre
    if (morseLine.isEmpty) return;
    if (!morseLine.endsWith(' ') && !morseLine.endsWith(' / ')) {
      setState(() => morseLine += " ");
    }
  }

  void _spaceWord() {
    // " / " = séparation de mot
    if (morseLine.isEmpty) return;
    if (!morseLine.endsWith(' / ')) {
      // Si un espace lettre est déjà là, on le remplace par " / "
      if (morseLine.endsWith(' ')) {
        setState(() => morseLine = morseLine.trimRight() + " / ");
      } else {
        setState(() => morseLine += " / ");
      }
    }
  }

  void _backspace() {
    if (morseLine.isEmpty) return;
    // Gérer le cas " / "
    if (morseLine.endsWith(" / ")) {
      setState(() => morseLine = morseLine.substring(0, morseLine.length - 3));
      return;
    }
    // Gérer espace simple
    if (morseLine.endsWith(" ")) {
      setState(() => morseLine = morseLine.substring(0, morseLine.length - 1));
      return;
    }
    // Sinon enlever le dernier caractère (point/trait)
    setState(() => morseLine = morseLine.substring(0, morseLine.length - 1));
  }

  void _clearAll() {
    setState(() {
      morseLine = "";
      translatedText = "";
    });
  }

  // --- Traduction ---
  void _translate() {
    // Exemple: "... --- ... / .-" -> ["... --- ...", ".-"]
    final words = morseLine.trim().split(RegExp(r'\s*/\s*'));
    final buffer = StringBuffer();

    for (int w = 0; w < words.length; w++) {
      final word = words[w].trim();
      if (word.isEmpty) continue;

      // lettres séparées par espace
      final letters = word.split(RegExp(r'\s+'));
      for (final l in letters) {
        if (l.isEmpty) continue;
        buffer.write(morseToChar[l] ?? '?');
      }
      if (w != words.length - 1) buffer.write(' ');
    }

    setState(() => translatedText = buffer.toString());
  }

  @override
  void dispose() {
    _dot.dispose();
    _dash.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clavier Morse'),
        actions: [
          IconButton(
            tooltip: audioOn ? 'Beep ON' : 'Beep OFF',
            onPressed: () => setState(() => audioOn = !audioOn),
            icon: Icon(audioOn ? Icons.volume_up : Icons.volume_off),
          ),
          IconButton(
            tooltip: hapticOn ? 'Vibration ON' : 'Vibration OFF',
            onPressed: () => setState(() => hapticOn = !hapticOn),
            icon: Icon(hapticOn ? Icons.vibration : Icons.do_not_disturb_on),
          ),
        ],
      ),
      body: Column(
        children: [
          // Résultat texte (après traduction)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF12161A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("Texte traduit",
                      style: TextStyle(color: cs.primary, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(
                    translatedText.isEmpty ? "—" : translatedText,
                    style: const TextStyle(fontSize: 22),
                  ),
                ],
              ),
            ),
          ),

          // Deux grandes zones: DOT & DASH (même thème)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: _Pad(
                      label: '•',
                      sub: 'POINT',
                      color: const Color(0xFF1A1F24),
                      onTap: _addDot,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Pad(
                      label: '—',
                      sub: 'TRAIT',
                      color: const Color(0xFF1A1F24),
                      onTap: _addDash,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Ligne Morse (toujours en bas)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF12161A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                morseLine.isEmpty ? 'Tapez votre code…  (espace lettre = " "  |  espace mot = "/")'
                                   : morseLine,
                style: TextStyle(
                  color: cs.primary,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          // Boutons d’actions (cohérents avec le thème)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton.icon(
                  onPressed: _spaceLetter,
                  icon: const Icon(Icons.space_bar),
                  label: const Text('Espace lettre'),
                ),
                ElevatedButton.icon(
                  onPressed: _spaceWord,
                  icon: const Icon(Icons.space_bar),
                  label: const Text('Espace mot'),
                ),
                ElevatedButton.icon(
                  onPressed: _backspace,
                  icon: const Icon(Icons.backspace),
                  label: const Text('Effacer'),
                ),
                ElevatedButton.icon(
                  onPressed: _clearAll,
                  icon: const Icon(Icons.delete_sweep),
                  label: const Text('Tout effacer'),
                ),
                ElevatedButton.icon(
                  onPressed: _translate,
                  icon: const Icon(Icons.translate),
                  label: const Text('Traduire'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pad extends StatefulWidget {
  final String label;
  final String sub;
  final Color color;
  final Future<void> Function() onTap;
  const _Pad({super.key, required this.label, required this.sub, required this.color, required this.onTap});

  @override
  State<_Pad> createState() => _PadState();
}

class _PadState extends State<_Pad> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () async => widget.onTap(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 110),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(_pressed ? 0.86 : 1),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_pressed ? 0.08 : 0.28),
              blurRadius: _pressed ? 4 : 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 2),
            Text(widget.label, style: const TextStyle(fontSize: 72, height: 0.9)),
            const SizedBox(height: 6),
            Text(widget.sub, style: const TextStyle(color: Colors.white70, letterSpacing: 1.1)),
          ]),
        ),
      ),
    );
  }
}
