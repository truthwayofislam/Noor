import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/user_provider.dart';

class DuaScreen extends StatefulWidget {
  const DuaScreen({super.key});

  @override
  State<DuaScreen> createState() => _DuaScreenState();
}

class _DuaScreenState extends State<DuaScreen> {
  Set<String> _memorizedDuas = {};

  @override
  void initState() {
    super.initState();
    _loadMemorizedDuas();
  }

  Future<void> _loadMemorizedDuas() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _memorizedDuas = (prefs.getStringList('memorized_duas') ?? []).toSet();
    });
  }

  Future<void> _toggleMemorized(String duaTitle) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isAdding = !_memorizedDuas.contains(duaTitle);

    if (isAdding) {
      _memorizedDuas.add(duaTitle);
      if (userProvider.isAuthenticated) {
        await userProvider.logActivity(
          activityType: 'dua_memorized',
          points: 15,
          metadata: {'dua_title': duaTitle},
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dua memorized! +15 points'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } else {
      _memorizedDuas.remove(duaTitle);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('memorized_duas', _memorizedDuas.toList());
    setState(() {});
  }

  // Categories in desired order
  static const List<String> _categoryOrder = [
    'Morning', 'Evening', 'Daily', 'Travel', 'Distress', 'Forgiveness'
  ];

  static const List<Map<String, String>> duas = [
    // ── Morning ──────────────────────────────────────────────────────────────
    {
      'title': 'Waking Up',
      'arabic': 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
      'transliteration': 'Alhamdulillahil ladhi ahyana ba\'da ma amatana wa ilayhin nushur',
      'translation': 'Praise be to Allah who gave us life after death and to Him is the resurrection',
      'category': 'Morning',
    },
    {
      'title': 'Morning Dua',
      'arabic': 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ',
      'transliteration': 'Asbahna wa asbahal mulku lillahi walhamdulillah',
      'translation': 'We have entered morning and the kingdom belongs to Allah, all praise is for Allah',
      'category': 'Morning',
    },
    {
      'title': 'Morning Protection',
      'arabic': 'اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ',
      'transliteration': 'Allahumma bika asbahna wa bika amsayna wa bika nahya wa bika namutu',
      'translation': 'O Allah, by You we enter morning, by You we enter evening, by You we live and by You we die',
      'category': 'Morning',
    },
    // ── Evening ───────────────────────────────────────────────────────────────
    {
      'title': 'Evening Dua',
      'arabic': 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ',
      'transliteration': 'Amsayna wa amsal mulku lillahi walhamdulillah',
      'translation': 'We have entered evening and the kingdom belongs to Allah, all praise is for Allah',
      'category': 'Evening',
    },
    {
      'title': 'Evening Protection',
      'arabic': 'اللَّهُمَّ بِكَ أَمْسَيْنَا وَبِكَ أَصْبَحْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ الْمَصِيرُ',
      'transliteration': 'Allahumma bika amsayna wa bika asbahna wa bika nahya wa bika namutu wa ilaykal masir',
      'translation': 'O Allah, by You we enter evening, by You we enter morning, by You we live, by You we die, and to You is the return',
      'category': 'Evening',
    },
    // ── Daily ─────────────────────────────────────────────────────────────────
    {
      'title': 'Before Eating',
      'arabic': 'بِسْمِ اللَّهِ',
      'transliteration': 'Bismillah',
      'translation': 'In the name of Allah',
      'category': 'Daily',
    },
    {
      'title': 'After Eating',
      'arabic': 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ',
      'transliteration': 'Alhamdulillahil ladhi at\'amana wa saqana wa ja\'alana muslimin',
      'translation': 'Praise be to Allah who has fed us, given us drink, and made us Muslims',
      'category': 'Daily',
    },
    {
      'title': 'Before Sleeping',
      'arabic': 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      'transliteration': 'Bismika Allahumma amutu wa ahya',
      'translation': 'In Your name O Allah, I die and I live',
      'category': 'Daily',
    },
    {
      'title': 'Entering Toilet',
      'arabic': 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبُثِ وَالْخَبَائِثِ',
      'transliteration': 'Allahumma inni a\'udhu bika minal khubuthi wal khaba\'ith',
      'translation': 'O Allah, I seek refuge in You from male and female devils',
      'category': 'Daily',
    },
    {
      'title': 'Entering Mosque',
      'arabic': 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
      'transliteration': 'Allahummaf tah li abwaba rahmatik',
      'translation': 'O Allah, open for me the doors of Your mercy',
      'category': 'Daily',
    },
    {
      'title': 'Leaving Mosque',
      'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
      'transliteration': 'Allahumma inni as\'aluka min fadlik',
      'translation': 'O Allah, I ask You from Your bounty',
      'category': 'Daily',
    },
    {
      'title': 'When Looking in Mirror',
      'arabic': 'اللَّهُمَّ أَنْتَ حَسَّنْتَ خَلْقِي فَحَسِّنْ خُلُقِي',
      'transliteration': 'Allahumma anta hassanta khalqi fahassin khuluqi',
      'translation': 'O Allah, You have made my physical form beautiful, so make my character beautiful too',
      'category': 'Daily',
    },
    // ── Travel ────────────────────────────────────────────────────────────────
    {
      'title': 'Leaving Home',
      'arabic': 'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      'transliteration': 'Bismillah, tawakkaltu \'alallah, wa la hawla wa la quwwata illa billah',
      'translation': 'In the name of Allah, I place my trust in Allah, there is no power except with Allah',
      'category': 'Travel',
    },
    {
      'title': 'Entering Home',
      'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ الْمَوْلِجِ وَخَيْرَ الْمَخْرَجِ',
      'transliteration': 'Allahumma inni as\'aluka khayral mawliji wa khayral makhraj',
      'translation': 'O Allah, I ask You for the best entrance and the best exit',
      'category': 'Travel',
    },
    {
      'title': 'Before Journey',
      'arabic': 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَى رَبِّنَا لَمُنقَلِبُونَ',
      'transliteration': 'Subhanal ladhi sakhkhara lana hadha wa ma kunna lahu muqrinin wa inna ila rabbina lamunqalibun',
      'translation': 'Glory to Him who has subjected this to us, we could never have done it ourselves, and indeed to our Lord we shall return',
      'category': 'Travel',
    },
    {
      'title': 'Entering New City',
      'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَهَا وَخَيْرَ أَهْلِهَا وَأَعُوذُ بِكَ مِنْ شَرِّهَا',
      'transliteration': 'Allahumma inni as\'aluka khairaha wa khaira ahliha wa a\'udhu bika min sharriha',
      'translation': 'O Allah, I ask You for its goodness and the goodness of its people, and I seek refuge from its evil',
      'category': 'Travel',
    },
    // ── Distress ──────────────────────────────────────────────────────────────
    {
      'title': 'Dua of Yunus (AS)',
      'arabic': 'لَا إِلَهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
      'transliteration': 'La ilaha illa anta subhanaka inni kuntu minaz zalimin',
      'translation': 'There is no god but You, glory be to You, I was indeed among the wrongdoers',
      'category': 'Distress',
    },
    {
      'title': 'For Hardship',
      'arabic': 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
      'transliteration': 'Hasbunallahu wa ni\'mal wakeel',
      'translation': 'Allah is sufficient for us and He is the best Disposer of affairs',
      'category': 'Distress',
    },
    {
      'title': 'For Anxiety & Grief',
      'arabic': 'اللَّهُمَّ إِنِّي عَبْدُكَ وَابْنُ عَبْدِكَ أَنْتَ رَبِّي نَاصِيَتِي بِيَدِكَ',
      'transliteration': 'Allahumma inni abduka wabnu abdika, anta rabbi, nasiyati biyadik',
      'translation': 'O Allah, I am Your servant, son of Your servant, You are my Lord, my forelock is in Your hand',
      'category': 'Distress',
    },
    {
      'title': 'Istikhara Dua',
      'arabic': 'اللَّهُمَّ إِنِّي أَسْتَخِيرُكَ بِعِلْمِكَ وَأَسْتَقْدِرُكَ بِقُدْرَتِكَ',
      'transliteration': 'Allahumma inni astakhiruka bi\'ilmika wa astaqdiruka biqudratik',
      'translation': 'O Allah, I seek Your guidance by Your knowledge and seek ability by Your power',
      'category': 'Distress',
    },
    {
      'title': 'When Sick',
      'arabic': 'اللَّهُمَّ رَبَّ النَّاسِ أَذْهِبِ الْبَأْسَ اشْفِ أَنْتَ الشَّافِي',
      'transliteration': 'Allahumma rabban nasi adhibil ba\'sa ishfi, anta ash-shafi',
      'translation': 'O Allah, Lord of people, remove the hardship and heal, You are the Healer',
      'category': 'Distress',
    },
    // ── Forgiveness ───────────────────────────────────────────────────────────
    {
      'title': 'Sayyidul Istighfar',
      'arabic': 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ خَلَقْتَنِي وَأَنَا عَبْدُكَ',
      'transliteration': 'Allahumma anta rabbi la ilaha illa anta, khalaqtani wa ana abduk',
      'translation': 'O Allah, You are my Lord, there is no god but You, You created me and I am Your servant',
      'category': 'Forgiveness',
    },
    {
      'title': 'Simple Istighfar',
      'arabic': 'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ الَّذِي لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
      'transliteration': 'Astaghfirullahal azeemal ladhi la ilaha illa huwal hayyul qayyum',
      'translation': 'I seek forgiveness from Allah the Magnificent, there is no god but He, the Ever-Living',
      'category': 'Forgiveness',
    },
    {
      'title': 'Dua for Parents',
      'arabic': 'رَّبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
      'transliteration': 'Rabbi irhamhuma kama rabbayani saghira',
      'translation': 'My Lord, have mercy on them as they raised me when I was small',
      'category': 'Forgiveness',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Keep categories in defined order
    final categories = _categoryOrder
        .where((cat) => duas.any((d) => d['category'] == cat))
        .toList();

    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Duas - دعائیں'),
          bottom: TabBar(
            isScrollable: true,
            tabs: categories.map((cat) => Tab(text: cat)).toList(),
          ),
        ),
        body: TabBarView(
          children: categories.map((category) {
            final categoryDuas =
                duas.where((d) => d['category'] == category).toList();
            return ListView.builder(
              itemCount: categoryDuas.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final dua = categoryDuas[index];
                final isMemorized = _memorizedDuas.contains(dua['title']);
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                dua['title']!,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isMemorized
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color: isMemorized
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              onPressed: () =>
                                  _toggleMemorized(dua['title']!),
                              tooltip: 'Mark as memorized',
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            dua['arabic']!,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                                fontSize: 22, height: 1.8),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          dua['transliteration']!,
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Divider(height: 20),
                        Text(
                          dua['translation']!,
                          style: const TextStyle(
                              fontSize: 15, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
