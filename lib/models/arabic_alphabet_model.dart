class ArabicLetter {
  final String arabic;
  final String name;
  final String transliteration;
  final String pronunciation;
  final List<String> examples;

  ArabicLetter({
    required this.arabic,
    required this.name,
    required this.transliteration,
    required this.pronunciation,
    required this.examples,
  });
}

class Harakat {
  final String name;
  final String symbol;
  final String description;
  final String example;
  final String sound;

  Harakat({
    required this.name,
    required this.symbol,
    required this.description,
    required this.example,
    required this.sound,
  });
}

class LetterForms {
  final String name;
  final String isolated;
  final String initial;
  final String medial;
  final String final_;
  final String transliteration;
  final bool joinsNext;

  const LetterForms({
    required this.name,
    required this.isolated,
    required this.initial,
    required this.medial,
    required this.final_,
    required this.transliteration,
    required this.joinsNext,
  });
}

class QuranicWord {
  final String arabic;
  final String transliteration;
  final String meaning;
  final String urdu;

  const QuranicWord({
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.urdu,
  });
}

class QuranicLesson {
  final String surahName;
  final String surahNameUrdu;
  final int ayahNumber;
  final String fullArabic;
  final String transliteration;
  final String translation;
  final String urdu;
  final List<QuranicWord> words;

  const QuranicLesson({
    required this.surahName,
    required this.surahNameUrdu,
    required this.ayahNumber,
    required this.fullArabic,
    required this.transliteration,
    required this.translation,
    required this.urdu,
    required this.words,
  });
}

// Letter in 4 positions
class LetterForms {
  final String name;
  final String isolated;   // alone: ب
  final String initial;    // start: بـ
  final String medial;     // middle: ـبـ
  final String final_;     // end: ـب
  final String transliteration;
  final bool joinsNext;    // does it join next letter?

  const LetterForms({
    required this.name,
    required this.isolated,
    required this.initial,
    required this.medial,
    required this.final_,
    required this.transliteration,
    required this.joinsNext,
  });
}

// A Quranic word with breakdown
class QuranicWord {
  final String arabic;
  final String transliteration;
  final String meaning;
  final String urdu;
  final List<String> letterBreakdown; // each letter separately

  const QuranicWord({
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.urdu,
    required this.letterBreakdown,
  });
}

// A verse with word-by-word breakdown
class QuranicLesson {
  final String surahName;
  final String surahNameUrdu;
  final int surahNumber;
  final int ayahNumber;
  final String fullArabic;
  final String transliteration;
  final String translation;
  final String urdu;
  final List<QuranicWord> words;

  const QuranicLesson({
    required this.surahName,
    required this.surahNameUrdu,
    required this.surahNumber,
    required this.ayahNumber,
    required this.fullArabic,
    required this.transliteration,
    required this.translation,
    required this.urdu,
    required this.words,
  });
}

class ArabicAlphabetData {
  static final List<ArabicLetter> letters = [
    ArabicLetter(arabic: 'ا', name: 'Alif', transliteration: 'A', pronunciation: 'aa', examples: ['أَسَد', 'إِبْرَة']),
    ArabicLetter(arabic: 'ب', name: 'Ba', transliteration: 'B', pronunciation: 'ba', examples: ['بَيْت', 'كِتَاب']),
    ArabicLetter(arabic: 'ت', name: 'Ta', transliteration: 'T', pronunciation: 'ta', examples: ['تُفَّاح', 'بِنْت']),
    ArabicLetter(arabic: 'ث', name: 'Tha', transliteration: 'Th', pronunciation: 'tha', examples: ['ثَوْب', 'ثَلَاثَة']),
    ArabicLetter(arabic: 'ج', name: 'Jeem', transliteration: 'J', pronunciation: 'ja', examples: ['جَمَل', 'مَسْجِد']),
    ArabicLetter(arabic: 'ح', name: 'Ha', transliteration: 'H', pronunciation: 'ha', examples: ['حَمَام', 'صَبَاح']),
    ArabicLetter(arabic: 'خ', name: 'Kha', transliteration: 'Kh', pronunciation: 'kha', examples: ['خُبْز', 'تَارِيخ']),
    ArabicLetter(arabic: 'د', name: 'Dal', transliteration: 'D', pronunciation: 'da', examples: ['دَجَاج', 'أَحَد']),
    ArabicLetter(arabic: 'ذ', name: 'Dhal', transliteration: 'Dh', pronunciation: 'dha', examples: ['ذَهَب', 'أُسْتَاذ']),
    ArabicLetter(arabic: 'ر', name: 'Ra', transliteration: 'R', pronunciation: 'ra', examples: ['رَجُل', 'نَهْر']),
    ArabicLetter(arabic: 'ز', name: 'Zay', transliteration: 'Z', pronunciation: 'za', examples: ['زَيْت', 'خُبْز']),
    ArabicLetter(arabic: 'س', name: 'Seen', transliteration: 'S', pronunciation: 'sa', examples: ['سَمَك', 'شَمْس']),
    ArabicLetter(arabic: 'ش', name: 'Sheen', transliteration: 'Sh', pronunciation: 'sha', examples: ['شَجَر', 'عَيْش']),
    ArabicLetter(arabic: 'ص', name: 'Sad', transliteration: 'S', pronunciation: 'sa', examples: ['صَبَاح', 'قَصْر']),
    ArabicLetter(arabic: 'ض', name: 'Dad', transliteration: 'D', pronunciation: 'da', examples: ['ضَوْء', 'أَرْض']),
    ArabicLetter(arabic: 'ط', name: 'Ta', transliteration: 'T', pronunciation: 'ta', examples: ['طَعَام', 'خَطّ']),
    ArabicLetter(arabic: 'ظ', name: 'Dha', transliteration: 'Dh', pronunciation: 'dha', examples: ['ظُهْر', 'حَظّ']),
    ArabicLetter(arabic: 'ع', name: 'Ain', transliteration: 'A', pronunciation: 'aa', examples: ['عَيْن', 'جَمِيع']),
    ArabicLetter(arabic: 'غ', name: 'Ghain', transliteration: 'Gh', pronunciation: 'gha', examples: ['غُرَاب', 'بَلَاغ']),
    ArabicLetter(arabic: 'ف', name: 'Fa', transliteration: 'F', pronunciation: 'fa', examples: ['فِيل', 'صَيْف']),
    ArabicLetter(arabic: 'ق', name: 'Qaf', transliteration: 'Q', pronunciation: 'qa', examples: ['قَلَم', 'حَقّ']),
    ArabicLetter(arabic: 'ك', name: 'Kaf', transliteration: 'K', pronunciation: 'ka', examples: ['كَلْب', 'مَلِك']),
    ArabicLetter(arabic: 'ل', name: 'Lam', transliteration: 'L', pronunciation: 'la', examples: ['لَيْل', 'جَمَل']),
    ArabicLetter(arabic: 'م', name: 'Meem', transliteration: 'M', pronunciation: 'ma', examples: ['مَاء', 'قَلَم']),
    ArabicLetter(arabic: 'ن', name: 'Noon', transliteration: 'N', pronunciation: 'na', examples: ['نَار', 'عَيْن']),
    ArabicLetter(arabic: 'ه', name: 'Ha', transliteration: 'H', pronunciation: 'ha', examples: ['هِلَال', 'اللّٰه']),
    ArabicLetter(arabic: 'و', name: 'Waw', transliteration: 'W', pronunciation: 'wa', examples: ['وَرْد', 'نُور']),
    ArabicLetter(arabic: 'ي', name: 'Ya', transliteration: 'Y', pronunciation: 'ya', examples: ['يَد', 'عَلِي']),
  ];

  static final List<Harakat> harakat = [
    Harakat(
      name: 'Fatha (Zabar)',
      symbol: 'َ',
      description: 'Short "a" sound',
      example: 'بَ',
      sound: 'ba',
    ),
    Harakat(
      name: 'Kasra (Zer)',
      symbol: 'ِ',
      description: 'Short "i" sound',
      example: 'بِ',
      sound: 'bi',
    ),
    Harakat(
      name: 'Damma (Pesh)',
      symbol: 'ُ',
      description: 'Short "u" sound',
      example: 'بُ',
      sound: 'bu',
    ),
    Harakat(
      name: 'Sukoon (Jazm)',
      symbol: 'ْ',
      description: 'No vowel sound',
      example: 'بْ',
      sound: 'b',
    ),
    Harakat(
      name: 'Tanween Fath',
      symbol: 'ً',
      description: 'Double fatha - "an"',
      example: 'بً',
      sound: 'ban',
    ),
    Harakat(
      name: 'Tanween Kasr',
      symbol: 'ٍ',
      description: 'Double kasra - "in"',
      example: 'بٍ',
      sound: 'bin',
    ),
    Harakat(
      name: 'Tanween Damm',
      symbol: 'ٌ',
      description: 'Double damma - "un"',
      example: 'بٌ',
      sound: 'bun',
    ),
    Harakat(
      name: 'Shadda (Tashdeed)',
      symbol: 'ّ',
      description: 'Double letter',
      example: 'بَّ',
      sound: 'bba',
    ),
    Harakat(
      name: 'Madd',
      symbol: 'ٰ',
      description: 'Long vowel',
      example: 'بَا',
      sound: 'baa',
    ),
  ];

  static const List<LetterForms> letterForms = [
    LetterForms(name: 'Alif', isolated: 'ا', initial: 'ا', medial: 'ا', final_: 'ا', transliteration: 'aa', joinsNext: false),
    LetterForms(name: 'Ba', isolated: 'ب', initial: 'بـ', medial: 'ـبـ', final_: 'ـب', transliteration: 'b', joinsNext: true),
    LetterForms(name: 'Ta', isolated: 'ت', initial: 'تـ', medial: 'ـتـ', final_: 'ـت', transliteration: 't', joinsNext: true),
    LetterForms(name: 'Tha', isolated: 'ث', initial: 'ثـ', medial: 'ـثـ', final_: 'ـث', transliteration: 'th', joinsNext: true),
    LetterForms(name: 'Jeem', isolated: 'ج', initial: 'جـ', medial: 'ـجـ', final_: 'ـج', transliteration: 'j', joinsNext: true),
    LetterForms(name: 'Ha', isolated: 'ح', initial: 'حـ', medial: 'ـحـ', final_: 'ـح', transliteration: 'h', joinsNext: true),
    LetterForms(name: 'Kha', isolated: 'خ', initial: 'خـ', medial: 'ـخـ', final_: 'ـخ', transliteration: 'kh', joinsNext: true),
    LetterForms(name: 'Dal', isolated: 'د', initial: 'د', medial: 'ـد', final_: 'ـد', transliteration: 'd', joinsNext: false),
    LetterForms(name: 'Dhal', isolated: 'ذ', initial: 'ذ', medial: 'ـذ', final_: 'ـذ', transliteration: 'dh', joinsNext: false),
    LetterForms(name: 'Ra', isolated: 'ر', initial: 'ر', medial: 'ـر', final_: 'ـر', transliteration: 'r', joinsNext: false),
    LetterForms(name: 'Zay', isolated: 'ز', initial: 'ز', medial: 'ـز', final_: 'ـز', transliteration: 'z', joinsNext: false),
    LetterForms(name: 'Seen', isolated: 'س', initial: 'سـ', medial: 'ـسـ', final_: 'ـس', transliteration: 's', joinsNext: true),
    LetterForms(name: 'Sheen', isolated: 'ش', initial: 'شـ', medial: 'ـشـ', final_: 'ـش', transliteration: 'sh', joinsNext: true),
    LetterForms(name: 'Sad', isolated: 'ص', initial: 'صـ', medial: 'ـصـ', final_: 'ـص', transliteration: 's', joinsNext: true),
    LetterForms(name: 'Dad', isolated: 'ض', initial: 'ضـ', medial: 'ـضـ', final_: 'ـض', transliteration: 'd', joinsNext: true),
    LetterForms(name: 'Ta', isolated: 'ط', initial: 'طـ', medial: 'ـطـ', final_: 'ـط', transliteration: 't', joinsNext: true),
    LetterForms(name: 'Dha', isolated: 'ظ', initial: 'ظـ', medial: 'ـظـ', final_: 'ـظ', transliteration: 'dh', joinsNext: true),
    LetterForms(name: 'Ain', isolated: 'ع', initial: 'عـ', medial: 'ـعـ', final_: 'ـع', transliteration: 'aa', joinsNext: true),
    LetterForms(name: 'Ghain', isolated: 'غ', initial: 'غـ', medial: 'ـغـ', final_: 'ـغ', transliteration: 'gh', joinsNext: true),
    LetterForms(name: 'Fa', isolated: 'ف', initial: 'فـ', medial: 'ـفـ', final_: 'ـف', transliteration: 'f', joinsNext: true),
    LetterForms(name: 'Qaf', isolated: 'ق', initial: 'قـ', medial: 'ـقـ', final_: 'ـق', transliteration: 'q', joinsNext: true),
    LetterForms(name: 'Kaf', isolated: 'ك', initial: 'كـ', medial: 'ـكـ', final_: 'ـك', transliteration: 'k', joinsNext: true),
    LetterForms(name: 'Lam', isolated: 'ل', initial: 'لـ', medial: 'ـلـ', final_: 'ـل', transliteration: 'l', joinsNext: true),
    LetterForms(name: 'Meem', isolated: 'م', initial: 'مـ', medial: 'ـمـ', final_: 'ـم', transliteration: 'm', joinsNext: true),
    LetterForms(name: 'Noon', isolated: 'ن', initial: 'نـ', medial: 'ـنـ', final_: 'ـن', transliteration: 'n', joinsNext: true),
    LetterForms(name: 'Ha', isolated: 'ه', initial: 'هـ', medial: 'ـهـ', final_: 'ـه', transliteration: 'h', joinsNext: true),
    LetterForms(name: 'Waw', isolated: 'و', initial: 'و', medial: 'ـو', final_: 'ـو', transliteration: 'w', joinsNext: false),
    LetterForms(name: 'Ya', isolated: 'ي', initial: 'يـ', medial: 'ـيـ', final_: 'ـي', transliteration: 'y', joinsNext: true),
  ];

  static const List<QuranicLesson> fatihaLessons = [
    QuranicLesson(
      surahName: 'Al-Fatiha', surahNameUrdu: 'سورۃ الفاتحہ',
      ayahNumber: 1,
      fullArabic: 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
      transliteration: 'Bismillahir rahmanir raheem',
      translation: 'In the name of Allah, the Most Gracious, the Most Merciful',
      urdu: 'اللہ کے نام سے جو بڑا مہربان نہایت رحم والا ہے',
      words: [
        QuranicWord(arabic: 'بِسْمِ', transliteration: 'Bismi', meaning: 'In the name of', urdu: 'نام سے'),
        QuranicWord(arabic: 'اللَّهِ', transliteration: 'Allah', meaning: 'Allah', urdu: 'اللہ'),
        QuranicWord(arabic: 'الرَّحْمَنِ', transliteration: 'ar-Rahman', meaning: 'the Most Gracious', urdu: 'بڑا مہربان'),
        QuranicWord(arabic: 'الرَّحِيمِ', transliteration: 'ar-Raheem', meaning: 'the Most Merciful', urdu: 'نہایت رحم والا'),
      ],
    ),
    QuranicLesson(
      surahName: 'Al-Fatiha', surahNameUrdu: 'سورۃ الفاتحہ',
      ayahNumber: 2,
      fullArabic: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
      transliteration: 'Alhamdu lillahi rabbil aalameen',
      translation: 'All praise is for Allah, Lord of all worlds',
      urdu: 'سب تعریف اللہ کے لیے جو تمام جہانوں کا پالنہار ہے',
      words: [
        QuranicWord(arabic: 'الْحَمْدُ', transliteration: 'Al-hamdu', meaning: 'All praise', urdu: 'سب تعریف'),
        QuranicWord(arabic: 'لِلَّهِ', transliteration: 'lillahi', meaning: 'is for Allah', urdu: 'اللہ کے لیے'),
        QuranicWord(arabic: 'رَبِّ', transliteration: 'rabbi', meaning: 'Lord of', urdu: 'پالنہار'),
        QuranicWord(arabic: 'الْعَالَمِينَ', transliteration: 'al-aalameen', meaning: 'all worlds', urdu: 'تمام جہانوں کا'),
      ],
    ),
    QuranicLesson(
      surahName: 'Al-Fatiha', surahNameUrdu: 'سورۃ الفاتحہ',
      ayahNumber: 3,
      fullArabic: 'الرَّحْمَنِ الرَّحِيمِ',
      transliteration: 'Ar-rahmanir raheem',
      translation: 'The Most Gracious, the Most Merciful',
      urdu: 'بڑا مہربان، نہایت رحم والا',
      words: [
        QuranicWord(arabic: 'الرَّحْمَنِ', transliteration: 'Ar-Rahman', meaning: 'The Most Gracious', urdu: 'بڑا مہربان'),
        QuranicWord(arabic: 'الرَّحِيمِ', transliteration: 'Ar-Raheem', meaning: 'The Most Merciful', urdu: 'نہایت رحم والا'),
      ],
    ),
    QuranicLesson(
      surahName: 'Al-Fatiha', surahNameUrdu: 'سورۃ الفاتحہ',
      ayahNumber: 4,
      fullArabic: 'مَالِكِ يَوْمِ الدِّينِ',
      transliteration: 'Maliki yawmid deen',
      translation: 'Master of the Day of Judgment',
      urdu: 'روزِ جزا کے مالک',
      words: [
        QuranicWord(arabic: 'مَالِكِ', transliteration: 'Maliki', meaning: 'Master of', urdu: 'مالک'),
        QuranicWord(arabic: 'يَوْمِ', transliteration: 'yawmi', meaning: 'Day of', urdu: 'دن'),
        QuranicWord(arabic: 'الدِّينِ', transliteration: 'ad-deen', meaning: 'Judgment', urdu: 'جزا'),
      ],
    ),
    QuranicLesson(
      surahName: 'Al-Fatiha', surahNameUrdu: 'سورۃ الفاتحہ',
      ayahNumber: 5,
      fullArabic: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
      transliteration: 'Iyyaka nabudu wa iyyaka nastaeen',
      translation: 'You alone we worship, and You alone we ask for help',
      urdu: 'ہم صرف تیری عبادت کرتے ہیں اور صرف تجھ سے مدد مانگتے ہیں',
      words: [
        QuranicWord(arabic: 'إِيَّاكَ', transliteration: 'Iyyaka', meaning: 'You alone', urdu: 'صرف تجھے'),
        QuranicWord(arabic: 'نَعْبُدُ', transliteration: 'nabudu', meaning: 'we worship', urdu: 'عبادت کرتے ہیں'),
        QuranicWord(arabic: 'وَإِيَّاكَ', transliteration: 'wa iyyaka', meaning: 'and You alone', urdu: 'اور صرف تجھ سے'),
        QuranicWord(arabic: 'نَسْتَعِينُ', transliteration: 'nastaeen', meaning: 'we ask for help', urdu: 'مدد مانگتے ہیں'),
      ],
    ),
    QuranicLesson(
      surahName: 'Al-Fatiha', surahNameUrdu: 'سورۃ الفاتحہ',
      ayahNumber: 6,
      fullArabic: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
      transliteration: 'Ihdinas siratal mustaqeem',
      translation: 'Guide us to the straight path',
      urdu: 'ہمیں سیدھے راستے پر چلا',
      words: [
        QuranicWord(arabic: 'اهْدِنَا', transliteration: 'Ihdina', meaning: 'Guide us', urdu: 'ہمیں ہدایت دے'),
        QuranicWord(arabic: 'الصِّرَاطَ', transliteration: 'as-sirata', meaning: 'the path', urdu: 'راستہ'),
        QuranicWord(arabic: 'الْمُسْتَقِيمَ', transliteration: 'al-mustaqeem', meaning: 'the straight', urdu: 'سیدھا'),
      ],
    ),
    QuranicLesson(
      surahName: 'Al-Fatiha', surahNameUrdu: 'سورۃ الفاتحہ',
      ayahNumber: 7,
      fullArabic: 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
      transliteration: 'Siratal ladhina anamta alayhim ghayril maghdubi alayhim wa lad daalleen',
      translation: 'The path of those You blessed, not of those who earned anger, nor of those who went astray',
      urdu: 'ان لوگوں کا راستہ جن پر تو نے انعام کیا، نہ ان کا جن پر غضب ہوا، نہ گمراہوں کا',
      words: [
        QuranicWord(arabic: 'صِرَاطَ', transliteration: 'Sirata', meaning: 'Path of', urdu: 'راستہ'),
        QuranicWord(arabic: 'الَّذِينَ', transliteration: 'alladhina', meaning: 'those who', urdu: 'جن لوگوں'),
        QuranicWord(arabic: 'أَنْعَمْتَ', transliteration: 'anamta', meaning: 'You blessed', urdu: 'تو نے انعام کیا'),
        QuranicWord(arabic: 'عَلَيْهِمْ', transliteration: 'alayhim', meaning: 'upon them', urdu: 'ان پر'),
        QuranicWord(arabic: 'غَيْرِ', transliteration: 'ghayri', meaning: 'not of', urdu: 'نہ'),
        QuranicWord(arabic: 'الْمَغْضُوبِ', transliteration: 'al-maghdubi', meaning: 'those who earned anger', urdu: 'غضب والے'),
        QuranicWord(arabic: 'وَلَا', transliteration: 'wa la', meaning: 'and not', urdu: 'اور نہ'),
        QuranicWord(arabic: 'الضَّالِّينَ', transliteration: 'ad-daalleen', meaning: 'those who went astray', urdu: 'گمراہ'),
      ],
    ),
  ];

  static const List<QuranicLesson> shortSurahLessons = [
    QuranicLesson(
      surahName: 'Al-Ikhlas', surahNameUrdu: 'سورۃ الاخلاص',
      ayahNumber: 1,
      fullArabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
      transliteration: 'Qul huwallahu ahad',
      translation: 'Say: He is Allah, the One',
      urdu: 'کہو: وہ اللہ ایک ہے',
      words: [
        QuranicWord(arabic: 'قُلْ', transliteration: 'Qul', meaning: 'Say', urdu: 'کہو'),
        QuranicWord(arabic: 'هُوَ', transliteration: 'huwa', meaning: 'He is', urdu: 'وہ'),
        QuranicWord(arabic: 'اللَّهُ', transliteration: 'Allah', meaning: 'Allah', urdu: 'اللہ'),
        QuranicWord(arabic: 'أَحَدٌ', transliteration: 'ahad', meaning: 'the One', urdu: 'ایک'),
      ],
    ),
    QuranicLesson(
      surahName: 'Al-Ikhlas', surahNameUrdu: 'سورۃ الاخلاص',
      ayahNumber: 2,
      fullArabic: 'اللَّهُ الصَّمَدُ',
      transliteration: 'Allahus samad',
      translation: 'Allah, the Eternal Refuge',
      urdu: 'اللہ بے نیاز ہے',
      words: [
        QuranicWord(arabic: 'اللَّهُ', transliteration: 'Allah', meaning: 'Allah', urdu: 'اللہ'),
        QuranicWord(arabic: 'الصَّمَدُ', transliteration: 'as-Samad', meaning: 'the Eternal Refuge', urdu: 'بے نیاز'),
      ],
    ),
    QuranicLesson(
      surahName: 'Al-Ikhlas', surahNameUrdu: 'سورۃ الاخلاص',
      ayahNumber: 3,
      fullArabic: 'لَمْ يَلِدْ وَلَمْ يُولَدْ',
      transliteration: 'Lam yalid wa lam yoolad',
      translation: 'He neither begets nor is born',
      urdu: 'نہ اس نے کسی کو جنا نہ وہ کسی سے جنا',
      words: [
        QuranicWord(arabic: 'لَمْ', transliteration: 'Lam', meaning: 'He did not', urdu: 'نہیں'),
        QuranicWord(arabic: 'يَلِدْ', transliteration: 'yalid', meaning: 'beget', urdu: 'جنا'),
        QuranicWord(arabic: 'وَلَمْ', transliteration: 'wa lam', meaning: 'and not', urdu: 'اور نہ'),
        QuranicWord(arabic: 'يُولَدْ', transliteration: 'yoolad', meaning: 'was born', urdu: 'پیدا ہوا'),
      ],
    ),
    QuranicLesson(
      surahName: 'Al-Ikhlas', surahNameUrdu: 'سورۃ الاخلاص',
      ayahNumber: 4,
      fullArabic: 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
      transliteration: 'Wa lam yakun lahu kufuwan ahad',
      translation: 'And there is none comparable to Him',
      urdu: 'اور کوئی اس کا ہمسر نہیں',
      words: [
        QuranicWord(arabic: 'وَلَمْ', transliteration: 'Wa lam', meaning: 'And not', urdu: 'اور نہ'),
        QuranicWord(arabic: 'يَكُن', transliteration: 'yakun', meaning: 'is there', urdu: 'ہے'),
        QuranicWord(arabic: 'لَّهُ', transliteration: 'lahu', meaning: 'for Him', urdu: 'اس کا'),
        QuranicWord(arabic: 'كُفُوًا', transliteration: 'kufuwan', meaning: 'comparable', urdu: 'ہمسر'),
        QuranicWord(arabic: 'أَحَدٌ', transliteration: 'ahad', meaning: 'anyone', urdu: 'کوئی'),
      ],
    ),
  ];
}
