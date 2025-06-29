  import 'package:btech_project/frontend/marketmate_ai_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:btech_project/frontend/signup_page.dart';
import '../firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  String _language = 'en';

  void _changeLanguage(String? langCode) {
    if (langCode != null) {
      setState(() {
        _language = langCode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Marketmate',
      theme: _isDarkMode
          ? ThemeData.dark().copyWith(
              primaryColor: const Color.fromARGB(255, 108, 42, 214),
              scaffoldBackgroundColor: const Color.fromARGB(255, 5, 5, 5),
            )
          : ThemeData.light().copyWith(
              primaryColor: const Color.fromARGB(255, 161, 66, 216),
              scaffoldBackgroundColor: const Color.fromARGB(255, 243, 241, 246),
            ),
      home: HomePage(
        isDarkMode: _isDarkMode,
        onThemeChange: (bool value) {
          setState(() {
            _isDarkMode = value;
          });
        },
        language: _language,
        onLanguageChange: _changeLanguage,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChange;
  final String language;
  final ValueChanged<String?> onLanguageChange;

  const HomePage({
    Key? key,
    required this.isDarkMode,
    required this.onThemeChange,
    required this.language,
    required this.onLanguageChange,
  }) : super(key: key);

  PopupMenuItem<String> _buildLanguageItem(
      String code, String name, IconData icon) {
    return PopupMenuItem<String>(
      value: code,
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 10),
          Text(name, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  IconData _getLanguageIcon(String code) {
    switch (code) {
      case 'hi':
        return Icons.translate;
      case 'mr':
        return Icons.g_translate;
      case 'gu':
        return Icons.language_outlined;
      case 'kn':
        return Icons.language;
      case 'ta':
        return Icons.text_fields;
      default:
        return Icons.language;
    }
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'hi':
        return 'हिंदी';
      case 'mr':
        return 'मराठी';
      case 'gu':
        return 'ગુજરાતી';
      case 'kn':
        return 'ಕನ್ನಡ';
      case 'ta':
        return 'தமிழ்';
      default:
        return 'English';
    }
  }

  @override
  Widget build(BuildContext context) {
    final translations = {
      'en': {
        'title': 'Marketmate',
        'welcome': 'Welcome to Marketmate!',
        'description':
            'Instantly connect with larger markets and grow your business. Sign up, create your profile, explore opportunities, and secure transactions all in one place. Your journey to business success starts here!',
        'button': 'Get Started',
      },
      'hi': {
        'title': 'मार्केटमेट',
        'welcome': 'मार्केटमेट में आपका स्वागत है!',
        'description':
            'बड़े बाजारों से तुरंत जुड़ें और अपने व्यवसाय को बढ़ाएं। साइन अप करें, प्रोफ़ाइल बनाएं, अवसर खोजें और एक ही जगह सभी लेनदेन सुरक्षित करें। आपकी सफलता की यात्रा यहीं से शुरू होती है!',
        'button': 'शुरू करें',
      },
      'mr': {
        'title': 'मार्केटमेट',
        'welcome': 'मार्केटमेट मध्ये तुमचे स्वागत आहे!',
        'description':
            'मोठ्या बाजारांशी त्वरित संपर्क साधा आणि तुमचा व्यवसाय वाढवा. साइन अप करा, प्रोफाइल तयार करा, संधी शोधा आणि व्यवहार सुरक्षित करा. तुमचा यशाचा प्रवास इथून सुरू होतो!',
        'button': 'सुरू करा',
      },
      'gu': {
        'title': 'માર્કેટમેટ',
        'welcome': 'માર્કેટમેટમાં આપનું સ્વાગત છે!',
        'description':
            'મોટા બજારો સાથે તરત જોડાઓ અને તમારું વ્યવસાય વિકસાવો. સાઇન અપ કરો, પ્રોફાઇલ બનાવો, તકો શોધો અને તમામ લેવડદેવડને સુરક્ષિત કરો. સફળતા તરફની યાત્રા અહીંથી શરૂ થાય છે!',
        'button': 'પ્રારંભ કરો',
      },
      'kn': {
        'title': 'ಮಾರ್ಕೆಟ್ಮೇಟ್',
        'welcome': 'ಮಾರ್ಕೆಟ್ಮೇಟ್‌ಗೆ ಸ್ವಾಗತ!',
        'description':
            'ದೊಡ್ಡ ಮಾರುಕಟ್ಟೆಗಳಿಗೆ ತಕ್ಷಣ ಸಂಪರ್ಕ ಸಾಧಿಸಿ ಮತ್ತು ನಿಮ್ಮ ವ್ಯವಹಾರವನ್ನು ಬೆಳೆಸಿಕೊಳ್ಳಿ. ಸೈನ್ ಅಪ್ ಮಾಡಿ, ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ಅನ್ನು ರಚಿಸಿ, ಅವಕಾಶಗಳನ್ನು ಅನ್ವೇಷಿಸಿ ಮತ್ತು ವ್ಯವಹಾರಗಳನ್ನು ಸುರಕ್ಷಿತಗೊಳಿಸಿ. ನಿಮ್ಮ ಯಶಸ್ಸಿನ ಪ್ರಯಾಣ ಇಲ್ಲಿ ಆರಂಭವಾಗುತ್ತದೆ!',
        'button': 'ಆರಂಭಿಸಿ',
      },
      'ta': {
        'title': 'மார்கெட்மேட்',
        'welcome': 'மார்கெட்மேடில் வரவேற்கிறோம்!',
        'description':
            'பெரிய சந்தைகளுடன் உடனடியாக இணைந்து உங்கள் வணிகத்தை வளருங்கள். பதிவு செய்யவும், உங்கள் சுயவிவரத்தை உருவாக்கவும், வாய்ப்புகளை தேடவும் மற்றும் பரிவர்த்தனைகளை பாதுகாப்பாகச் செய்யவும். உங்கள் வெற்றிப் பயணம் இங்கே தொடங்குகிறது!',
        'button': 'தொடங்குங்கள்',
      },
    };

    final lang = translations[language]!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [Colors.black, Colors.deepPurple.shade900]
                : [Colors.white, Colors.purple.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        lang['title']!,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.deepPurple,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isDarkMode ? Icons.wb_sunny : Icons.nights_stay,
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.deepPurple,
                            ),
                            onPressed: () => onThemeChange(!isDarkMode),
                          ),
                          PopupMenuButton<String>(
                            tooltip: 'Change Language',
                            onSelected: onLanguageChange,
                            icon: Icon(
                              _getLanguageIcon(language),
                              color: isDarkMode
                                  ? Colors.amberAccent
                                  : Colors.deepPurple,
                            ),
                            itemBuilder: (BuildContext context) => [
                              _buildLanguageItem(
                                  'en', 'English', Icons.language),
                              _buildLanguageItem(
                                  'hi', 'हिंदी', Icons.translate),
                              _buildLanguageItem(
                                  'mr', 'मराठी', Icons.g_translate),
                              _buildLanguageItem(
                                  'gu', 'ગુજરાતી', Icons.language_outlined),
                              _buildLanguageItem('kn', 'ಕನ್ನಡ', Icons.language),
                              _buildLanguageItem(
                                  'ta', 'தமிழ்', Icons.text_fields),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 60),
                  Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    color:
                        isDarkMode ? Colors.deepPurple.shade800 : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images.jpg',
                            height: 200,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            lang['welcome']!,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? Colors.white
                                  : Colors.deepPurple.shade800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            lang['description']!,
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SignUpPage(language: language),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 203, 86, 238),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                            ),
                            child: Text(
                              lang['button']!,
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Replace with your AI assistant action
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    MarketMateAIPage()), // replace with your AI chat screen widget
          );
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(
          Icons.smart_toy_rounded,
          color: Colors.white, // <-- set icon color to white here
        ), // Use any icon you prefer
      ),
    );
  }
}
