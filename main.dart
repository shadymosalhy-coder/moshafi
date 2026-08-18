import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  int lastSurah = prefs.getInt('last_surah') ?? 1;

  runApp(MyApp(initialSurah: lastSurah));
}

class MyApp extends StatelessWidget {
  final int initialSurah;
  const MyApp({super.key, required this.initialSurah});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'تطبيق القرآن الكريم',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF7F4EA),
      ),
      home: SurahDetailsPage(surahNumber: initialSurah, isHome: true),
    );
  }
}

class QuranIndexPage extends StatelessWidget {
  const QuranIndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'فهرس سور القرآن الكريم',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade800,
      ),
      body: ListView.builder(
        itemCount: 114,
        itemBuilder: (context, index) {
          int surahNumber = index + 1;
          String surahName = quran.getSurahNameArabic(surahNumber);
          int versesCount = quran.getVerseCount(surahNumber);
          String place = quran.getPlaceOfRevelation(surahNumber);
          String placeArabic = place == 'Meccan' ? 'مكية' : 'مدنية';

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green.shade700,
                child: Text(
                  '$surahNumber',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                surahName,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text(
                'عدد الآيات: $versesCount | $placeArabic',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              trailing: const Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.green),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SurahDetailsPage(
                        surahNumber: surahNumber, isHome: false),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class SurahDetailsPage extends StatefulWidget {
  final int surahNumber;
  final bool isHome;

  const SurahDetailsPage(
      {super.key, required this.surahNumber, required this.isHome});

  @override
  State<SurahDetailsPage> createState() => _SurahDetailsPageState();
}

class _SurahDetailsPageState extends State<SurahDetailsPage> {
  @override
  void initState() {
    super.initState();
    _saveBookmark(widget.surahNumber);
  }

  Future<void> _saveBookmark(int surahNum) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_surah', surahNum);
    } catch (_) {}
  }

  String _buildSurahText(int surahNum, int count) {
    StringBuffer buffer = StringBuffer();
    for (int i = 1; i <= count; i++) {
      String verse = quran.getVerse(surahNum, i);
      if (surahNum == 1 && i == 1) {
        verse = verse
            .replaceFirst('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', '')
            .trim();
      }
      buffer.write('$verse ﴿$i﴾ ');
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    String surahName = quran.getSurahNameArabic(widget.surahNumber);
    int versesCount = quran.getVerseCount(widget.surahNumber);
    bool showBismillah = widget.surahNumber != 9 && widget.surahNumber != 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('سورة $surahName'),
        centerTitle: true,
        backgroundColor: Colors.green.shade800,
        leading: widget.isHome
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book),
            tooltip: 'فهرس السور',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QuranIndexPage()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'سورة $surahName',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
            ),
          ),
          if (showBismillah || widget.surahNumber == 1)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Amiri',
                    color: Colors.brown,
                  ),
                ),
              ),
            ),
          Text(
            _buildSurahText(widget.surahNumber, versesCount),
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontSize: 22,
              height: 2.2,
              fontFamily: 'Amiri',
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
