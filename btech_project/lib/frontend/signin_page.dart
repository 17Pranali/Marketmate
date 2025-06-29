import 'package:flutter/material.dart';
import 'package:btech_project/backend/signin_auth_services.dart';

class SignInPage extends StatefulWidget {
  final String language;

  const SignInPage({Key? key, required this.language}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  Map<String, Map<String, String>> localizedStrings = {
    'en': {
      'signIn': 'Sign In',
      'email': 'Email',
      'password': 'Password',
      'login': 'Login',
      'forgotPassword': 'Forgot Password?',
      'enterEmail': 'Enter your email',
      'enterPassword': 'Enter your password',
      'resetPrompt': 'Please enter your email to reset password.',
      'resetFail': 'Failed to send password reset email',
      'loginFail': 'Failed to login'
    },
    'hi': {
      'signIn': 'साइन इन करें',
      'email': 'ईमेल',
      'password': 'पासवर्ड',
      'login': 'लॉगिन',
      'forgotPassword': 'पासवर्ड भूल गए?',
      'enterEmail': 'अपना ईमेल दर्ज करें',
      'enterPassword': 'अपना पासवर्ड दर्ज करें',
      'resetPrompt': 'पासवर्ड रीसेट करने के लिए अपना ईमेल दर्ज करें।',
      'resetFail': 'पासवर्ड रीसेट ईमेल भेजने में विफल',
      'loginFail': 'लॉगिन विफल रहा'
    },
    'mr': {
      'signIn': 'साइन इन करा',
      'email': 'ईमेल',
      'password': 'पासवर्ड',
      'login': 'लॉगिन',
      'forgotPassword': 'पासवर्ड विसरलात का?',
      'enterEmail': 'तुमचा ईमेल टाका',
      'enterPassword': 'तुमचा पासवर्ड टाका',
      'resetPrompt': 'पासवर्ड रीसेट करण्यासाठी ईमेल प्रविष्ट करा.',
      'resetFail': 'पासवर्ड रीसेट ईमेल पाठवण्यात अयशस्वी',
      'loginFail': 'लॉगिन अयशस्वी'
    },
    'gu': {
      'signIn': 'સાઇન ઇન કરો',
      'email': 'ઇમેઇલ',
      'password': 'પાસવર્ડ',
      'login': 'લોગિન',
      'forgotPassword': 'પાસવર્ડ ભૂલી ગયા?',
      'enterEmail': 'તમારું ઇમેઇલ દાખલ કરો',
      'enterPassword': 'તમારું પાસવર્ડ દાખલ કરો',
      'resetPrompt': 'પાસવર્ડ રીસેટ કરવા માટે તમારું ઇમેઇલ દાખલ કરો.',
      'resetFail': 'પાસવર્ડ રીસેટ ઇમેઇલ મોકલવામાં નિષ્ફળ',
      'loginFail': 'લોગિન નિષ્ફળ ગયું'
    },
    'kn': {
      'signIn': 'ಸೈನ್ ಇನ್',
      'email': 'ಇಮೇಲ್',
      'password': 'ಪಾಸ್ವರ್ಡ್',
      'login': 'ಲಾಗಿನ್',
      'forgotPassword': 'ಪಾಸ್ವರ್ಡ್ ಮರೆತಿರಾ?',
      'enterEmail': 'ನಿಮ್ಮ ಇಮೇಲ್ ನಮೂದಿಸಿ',
      'enterPassword': 'ನಿಮ್ಮ ಪಾಸ್ವರ್ಡ್ ನಮೂದಿಸಿ',
      'resetPrompt': 'ಪಾಸ್ವರ್ಡ್ ಮರುಹೊಂದಿಸಲು ನಿಮ್ಮ ಇಮೇಲ್ ನಮೂದಿಸಿ.',
      'resetFail': 'ಪಾಸ್ವರ್ಡ್ ಮರುಹೊಂದಿಸುವ ಇಮೇಲ್ ಕಳುಹಿಸಲು ವಿಫಲವಾಯಿತು',
      'loginFail': 'ಲಾಗಿನ್ ವಿಫಲವಾಯಿತು'
    },
    'ta': {
      'signIn': 'உள்நுழைய',
      'email': 'மின்னஞ்சல்',
      'password': 'கடவுச்சொல்',
      'login': 'உள்நுழைய',
      'forgotPassword': 'கடவுச்சொல்லை மறந்துவிட்டீர்களா?',
      'enterEmail': 'உங்கள் மின்னஞ்சலை உள்ளிடவும்',
      'enterPassword': 'உங்கள் கடவுச்சொல்லை உள்ளிடவும்',
      'resetPrompt': 'கடவுச்சொல்லை மீட்டமைக்க மின்னஞ்சலை உள்ளிடவும்.',
      'resetFail': 'மீட்டமைக்க மின்னஞ்சல் அனுப்ப முடியவில்லை',
      'loginFail': 'உள்நுழைய முடியவில்லை'
    }
  };

  @override
  Widget build(BuildContext context) {
    final lang = localizedStrings[widget.language] ?? localizedStrings['en']!;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 241, 246),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.15),
                      blurRadius: 15,
                      spreadRadius: 5,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(Icons.lock_outline,
                          size: 80, color: Colors.deepPurple),
                      const SizedBox(height: 20),
                      Text(
                        lang['signIn']!,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 108, 42, 214),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        label: lang['email']!,
                        onChanged: (val) => email = val,
                        validator: (val) => val == null || val.isEmpty
                            ? lang['enterEmail']!
                            : null,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        label: lang['password']!,
                        obscureText: true,
                        onChanged: (val) => password = val,
                        validator: (val) => val == null || val.isEmpty
                            ? lang['enterPassword']!
                            : null,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 161, 66, 216),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          lang['login']!,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _forgotPassword,
                        child: Text(
                          lang['forgotPassword']!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.deepPurple,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required Function(String) onChanged,
    required String? Function(String?) validator,
    bool obscureText = false,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black87),
        filled: true,
        fillColor: const Color.fromARGB(255, 240, 235, 248),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      obscureText: obscureText,
      onChanged: onChanged,
      validator: validator,
    );
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        await SignInAuthService().signIn(
          email: email,
          password: password,
          context: context,
          language: widget.language, // Pass the language argument here
        );
      } catch (e) {
        _showError(
            "${localizedStrings[widget.language]?['loginFail'] ?? 'Login failed'}: $e");
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _forgotPassword() async {
    final lang = localizedStrings[widget.language] ?? localizedStrings['en']!;
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lang['resetPrompt']!)),
      );
      return;
    }

    try {
      await SignInAuthService().forgotPassword(email, context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${lang['resetFail']!}: $e")),
      );
    }
  }
}
