import 'package:flutter/material.dart';
import 'package:btech_project/backend/auth_services.dart';
import 'package:btech_project/frontend/signin_page.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpPage extends StatefulWidget {
  final String language;

  const SignUpPage({required this.language});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  String firstName = '',
      lastName = '',
      gstin = '',
      phone = '',
      email = '',
      aadhar = '',
      password = '';

  Map<String, Map<String, String>> localizedStrings = {
    'en': {
      'title': 'Sign Up',
      'createAccount': 'Create Your Account',
      'firstName': 'First Name',
      'lastName': 'Last Name',
      'gstin': 'GSTIN/CIN Number',
      'phone': 'Phone Number',
      'email': 'Email',
      'aadhar': 'Aadhar Number',
      'password': 'Password',
      'signup': 'Sign Up',
      'alreadyAccount': 'Already have an account? ',
      'login': 'Login',
      'queries': 'For any queries, contact us at '
    },
    'hi': {
      'title': 'साइन अप करें',
      'createAccount': 'अपना खाता बनाएँ',
      'firstName': 'पहला नाम',
      'lastName': 'अंतिम नाम',
      'gstin': 'जीएसटीआईएन/सीआईएन नंबर',
      'phone': 'फोन नंबर',
      'email': 'ईमेल',
      'aadhar': 'आधार नंबर',
      'password': 'पासवर्ड',
      'signup': 'साइन अप करें',
      'alreadyAccount': 'पहले से खाता है? ',
      'login': 'लॉगिन',
      'queries': 'किसी भी प्रश्न के लिए, हमसे संपर्क करें '
    },
    'mr': {
      'title': 'साइन अप करा',
      'createAccount': 'तुमचे खाते तयार करा',
      'firstName': 'पहिले नाव',
      'lastName': 'आडनाव',
      'gstin': 'GSTIN/CIN क्रमांक',
      'phone': 'फोन नंबर',
      'email': 'ईमेल',
      'aadhar': 'आधार क्रमांक',
      'password': 'पासवर्ड',
      'signup': 'नोंदणी करा',
      'alreadyAccount': 'आधीच खाते आहे? ',
      'login': 'लॉगिन',
      'queries': 'कोणत्याही चौकशीसाठी, आमच्याशी संपर्क साधा '
    },
    'gu': {
      "title": "સાઇન અપ",
      "createAccount": "તમારું એકાઉન્ટ બનાવો",
      "firstName": "પ્રથમ નામ",
      "lastName": "અંતિમ નામ",
      "gstin": "GSTIN/CIN નંબર",
      "phone": "ફોન નંબર",
      "email": "ઇમેઇલ",
      "aadhar": "આધાર નંબર",
      "password": "પાસવર્ડ",
      "signup": "સાઇન અપ કરો",
      "alreadyAccount": "પહેલેથી એકાઉન્ટ છે?",
      "login": "લોગિન",
      "queries": "કોઈપણ પ્રશ્ન માટે, અમારો સંપર્ક કરો:"
    },
    'kn': {
      "title": "ಸೈನ್ ಅಪ್",
      "createAccount": "ನಿಮ್ಮ ಖಾತೆ ನಿರ್ಮಿಸಿ",
      "firstName": "ಮೊದಲ ಹೆಸರು",
      "lastName": "ಕೊನೆಯ ಹೆಸರು",
      "gstin": "GSTIN/CIN ಸಂಖ್ಯೆ",
      "phone": "ದೂರವಾಣಿ ಸಂಖ್ಯೆ",
      "email": "ಇಮೇಲ್",
      "aadhar": "ಆಧಾರ್ ಸಂಖ್ಯೆ",
      "password": "ಪಾಸ್ವರ್ಡ್",
      "signup": "ಸೈನ್ ಅಪ್ ಮಾಡಿ",
      "alreadyAccount": "ಈಗಾಗಲೇ ಖಾತೆ ಇದೆಯೇ?",
      "login": "ಲಾಗಿನ್",
      "queries": "ಯಾವುದೇ ಪ್ರಶ್ನೆಗಳಿಗಾಗಿ, ನಮ್ಮನ್ನು ಸಂಪರ್ಕಿಸಿ:"
    },
    'ta': {
      "title": "பதிவு செய்க",
      "createAccount": "உங்கள் கணக்கை உருவாக்கவும்",
      "firstName": "முதல் பெயர்",
      "lastName": "கடைசி பெயர்",
      "gstin": "GSTIN/CIN எண்",
      "phone": "தொலைபேசி எண்",
      "email": "மின்னஞ்சல்",
      "aadhar": "ஆதார் எண்",
      "password": "கடவுச்சொல்",
      "signup": "பதிவு செய்க",
      "alreadyAccount": "ஏற்கனவே கணக்கு உள்ளதா?",
      "login": "உள்நுழைய",
      "queries": "எந்தவொரு கேள்விகளுக்கும், எங்களை தொடர்புகொள்ளவும்:"
    }
  };

  @override
  Widget build(BuildContext context) {
    final lang = localizedStrings[widget.language] ?? localizedStrings['en']!;

    return Scaffold(
      backgroundColor: const LinearGradient(
        colors: [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      )
          .createShader(Rect.fromLTWH(0, 0, 800, 600))
          .transform(ColorFilter.mode(Colors.transparent, BlendMode.dst)),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          title: Text(
            lang['title']!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(1, 1),
                  blurRadius: 4,
                )
              ],
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: screenWidth > 800 ? 600 : double.infinity,
                ),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.9),
                        Colors.purple[50]!.withOpacity(0.9)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          lang['createAccount']!,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6C2AD6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 25),
                        _buildTextField(
                            lang['firstName']!,
                            (val) => firstName = val,
                            'Please enter your ${lang['firstName']}'),
                        _buildTextField(
                            lang['lastName']!,
                            (val) => lastName = val,
                            'Please enter your ${lang['lastName']}'),
                        _buildTextField(lang['gstin']!, (val) => gstin = val,
                            'Please enter your ${lang['gstin']}', 15),
                        _buildTextField(
                            lang['phone']!,
                            (val) => phone = val,
                            'Please enter your ${lang['phone']}',
                            10,
                            TextInputType.phone),
                        _buildTextField(
                            lang['email']!,
                            (val) => email = val,
                            'Please enter your ${lang['email']}',
                            null,
                            TextInputType.emailAddress),
                        _buildTextField(
                            lang['aadhar']!,
                            (val) => aadhar = val,
                            'Please enter your ${lang['aadhar']}',
                            12,
                            TextInputType.number),
                        _buildTextField(
                            lang['password']!,
                            (val) => password = val,
                            'Please enter a strong ${lang['password']}'),
                        const SizedBox(height: 25),
                        InkWell(
                          onTap: () {
  if (_formKey.currentState!.validate()) {
    _verifyDetails(); // All fields are valid
  } else {
    // Show a pop-up alert
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Incomplete Form"),
        content: const Text("Please fill all the required fields correctly."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
},

                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              lang['signup']!,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              lang['alreadyAccount']!,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SignInPage(language: widget.language),
                                ),
                              ),
                              child: Text(
                                lang['login']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              lang['queries']!,
                              style: TextStyle(fontSize: 16),
                            ),
                            GestureDetector(
                              onTap: () {
                                final Uri emailUri = Uri(
                                  scheme: 'mailto',
                                  path: 'marketmate04@gmail.com',
                                  queryParameters: {
                                    'subject': 'QueryregardingSignUp'
                                  },
                                );
                                launch(emailUri.toString());
                              },
                              child: const Text(
                                "marketmate04@gmail.com",
                                style: TextStyle(
                                  color: Colors.deepPurple,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(
    String label,
    Function(String) onChanged,
    String validatorMessage, [
    int? length,
    TextInputType? keyboardType,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black87),
          filled: true,
          fillColor: const Color.fromARGB(255, 240, 235, 248),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepPurple),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
        ),
        onChanged: onChanged,
        validator: (val) {
          if (val == null || val.isEmpty) return validatorMessage;
          if (length != null && val.length != length)
            return 'Please enter a valid $label ($length characters)';
          return null;
        },
        keyboardType: keyboardType,
      ),
    );
  }

  void _verifyDetails() {
    AuthService().verifyDetails(
      firstName,
      lastName,
      gstin,
      phone,
      email,
      aadhar,
      password,
      context,
      widget.language,
    );
  }
}

extension on Shader {
  transform(ColorFilter colorFilter) {}
}
