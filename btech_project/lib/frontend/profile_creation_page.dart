import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_page.dart';

class ProfileCreationPage extends StatefulWidget {
  final String language;

  const ProfileCreationPage({Key? key, required this.language})
      : super(key: key);

  @override
  State<ProfileCreationPage> createState() => _ProfileCreationPageState();
}

class _ProfileCreationPageState extends State<ProfileCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _bioController =
      TextEditingController(); // ✅ Replaced Area with Bio
  final TextEditingController _profileImageUrlController =
      TextEditingController();

  String? _selectedCategory;
  bool _isLoading = false;
  List<String> _categories = [];
  bool _isEditMode = false;

  Map<String, Map<String, String>> localizedStrings = {
    'en': {
      "editProfile": "Edit Profile",
      "createProfile": "Create Profile",
      "enterProfileImageUrl": "Enter Profile Image URL",
      "cancel": "Cancel",
      "upload": "Upload",
      "businessName": "Business Name",
      "enterBusinessName": "Enter business name",
      "ownerName": "Owner Name",
      "enterOwnerName": "Enter owner name",
      "email": "Email",
      "enterValidEmail": "Enter valid email",
      "contact": "Contact",
      "enterContact": "Enter contact number",
      "location": "Location",
      "enterLocation": "Enter location",
      "bio": "Bio",
      "enterBio": "Enter bio",
      "selectCategory": "Select Category",
      "selectCategoryError": "Select a category",
      "createProfileButton": "Create Profile",
      "updateProfileButton": "Update Profile",
      "skipForNow": "Skip for now",
      "loadingCategoriesError": "Failed to load categories",
      "error": "Error"
    },
    'hi': {
      "editProfile": "प्रोफ़ाइल संपादित करें",
      "createProfile": "प्रोफ़ाइल बनाएं",
      "enterProfileImageUrl": "प्रोफ़ाइल छवि URL दर्ज करें",
      "cancel": "रद्द करें",
      "upload": "अपलोड करें",
      "businessName": "व्यवसाय का नाम",
      "enterBusinessName": "व्यवसाय का नाम दर्ज करें",
      "ownerName": "मालिक का नाम",
      "enterOwnerName": "मालिक का नाम दर्ज करें",
      "email": "ईमेल",
      "enterValidEmail": "मान्य ईमेल दर्ज करें",
      "contact": "संपर्क",
      "enterContact": "संपर्क नंबर दर्ज करें",
      "location": "स्थान",
      "enterLocation": "स्थान दर्ज करें",
      "bio": "परिचय",
      "enterBio": "परिचय दर्ज करें",
      "selectCategory": "श्रेणी चुनें",
      "selectCategoryError": "कृपया श्रेणी चुनें",
      "createProfileButton": "प्रोफ़ाइल बनाएं",
      "updateProfileButton": "प्रोफ़ाइल अपडेट करें",
      "skipForNow": "अभी के लिए छोड़ें",
      "loadingCategoriesError": "श्रेणियाँ लोड करने में विफल",
      "error": "त्रुटि"
    },
    'mr': {
      "editProfile": "प्रोफाइल संपादित करा",
      "createProfile": "प्रोफाइल तयार करा",
      "enterProfileImageUrl": "प्रोफाइल प्रतिमेचा URL प्रविष्ट करा",
      "cancel": "रद्द करा",
      "upload": "अपलोड करा",
      "businessName": "व्यवसायाचे नाव",
      "enterBusinessName": "व्यवसायाचे नाव प्रविष्ट करा",
      "ownerName": "मालकाचे नाव",
      "enterOwnerName": "मालकाचे नाव प्रविष्ट करा",
      "email": "ईमेल",
      "enterValidEmail": "वैध ईमेल प्रविष्ट करा",
      "contact": "संपर्क",
      "enterContact": "संपर्क क्रमांक प्रविष्ट करा",
      "location": "स्थान",
      "enterLocation": "स्थान प्रविष्ट करा",
      "bio": "परिचय",
      "enterBio": "परिचय प्रविष्ट करा",
      "selectCategory": "श्रेणी निवडा",
      "selectCategoryError": "कृपया श्रेणी निवडा",
      "createProfileButton": "प्रोफाइल तयार करा",
      "updateProfileButton": "प्रोफाइल अद्यतनित करा",
      "skipForNow": "आत्ता वगळा",
      "loadingCategoriesError": "श्रेण्या लोड करण्यात अयशस्वी",
      "error": "त्रुटी"
    },
    'gu': {
      "editProfile": "પ્રોફાઇલ સંપાદિત કરો",
      "createProfile": "પ્રોફાઇલ બનાવો",
      "enterProfileImageUrl": "પ્રોફાઇલ છબી URL દાખલ કરો",
      "cancel": "રદ કરો",
      "upload": "અપલોડ કરો",
      "businessName": "વ્યવસાયનું નામ",
      "enterBusinessName": "વ્યવસાયનું નામ દાખલ કરો",
      "ownerName": "માલિકનું નામ",
      "enterOwnerName": "માલિકનું નામ દાખલ કરો",
      "email": "ઇમેઇલ",
      "enterValidEmail": "માન્ય ઇમેઇલ દાખલ કરો",
      "contact": "સંપર્ક",
      "enterContact": "સંપર્ક નંબર દાખલ કરો",
      "location": "સ્થાન",
      "enterLocation": "સ્થાન દાખલ કરો",
      "bio": "પરિચય",
      "enterBio": "પરિચય દાખલ કરો",
      "selectCategory": "શ્રેણી પસંદ કરો",
      "selectCategoryError": "કૃપા કરીને શ્રેણી પસંદ કરો",
      "createProfileButton": "પ્રોફાઇલ બનાવો",
      "updateProfileButton": "પ્રોફાઇલ અપડેટ કરો",
      "skipForNow": "હમણાં માટે સ્કિપ કરો",
      "loadingCategoriesError": "શ્રેણીઓ લોડ કરવામાં નિષ્ફળ",
      "error": "ભૂલ"
    },
    'kn': {
      "editProfile": "ಪ್ರೊಫೈಲ್ ತಿದ್ದುಪಡಿ",
      "createProfile": "ಪ್ರೊಫೈಲ್ ರಚಿಸಿ",
      "enterProfileImageUrl": "ಪ್ರೊಫೈಲ್ ಚಿತ್ರ URL ನಮೂದಿಸಿ",
      "cancel": "ರದ್ದುಮಾಡಿ",
      "upload": "ಅಪ್‌ಲೋಡ್ ಮಾಡಿ",
      "businessName": "ವ್ಯವಹಾರದ ಹೆಸರು",
      "enterBusinessName": "ವ್ಯವಹಾರದ ಹೆಸರು ನಮೂದಿಸಿ",
      "ownerName": "ಮಾಲೀಕನ ಹೆಸರು",
      "enterOwnerName": "ಮಾಲೀಕನ ಹೆಸರು ನಮೂದಿಸಿ",
      "email": "ಇಮೇಲ್",
      "enterValidEmail": "ಮಾನ್ಯ ಇಮೇಲ್ ನಮೂದಿಸಿ",
      "contact": "ಸಂಪರ್ಕ",
      "enterContact": "ಸಂಪರ್ಕ ಸಂಖ್ಯೆ ನಮೂದಿಸಿ",
      "location": "ಸ್ಥಳ",
      "enterLocation": "ಸ್ಥಳ ನಮೂದಿಸಿ",
      "bio": "ಪರಿಚಯ",
      "enterBio": "ಪರಿಚಯ ನಮೂದಿಸಿ",
      "selectCategory": "ವರ್ಗ ಆಯ್ಕೆಮಾಡಿ",
      "selectCategoryError": "ದಯವಿಟ್ಟು ವರ್ಗವನ್ನು ಆಯ್ಕೆಮಾಡಿ",
      "createProfileButton": "ಪ್ರೊಫೈಲ್ ರಚಿಸಿ",
      "updateProfileButton": "ಪ್ರೊಫೈಲ್ ನವೀಕರಿಸಿ",
      "skipForNow": "ಈಗದು ಬಿಟ್ಟುಬಿಡಿ",
      "loadingCategoriesError": "ವರ್ಗಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ",
      "error": "ದೋಷ"
    },
    'ta': {
      "editProfile": "ప్రొఫైల్ సవరించండి",
      "createProfile": "ప్రొఫైల్ సృష్టించండి",
      "enterProfileImageUrl": "ప్రొఫైల్ చిత్రం URL ని నమోదు చేయండి",
      "cancel": "రద్దు చేయండి",
      "upload": "అప్‌లోడ్ చేయండి",
      "businessName": "వ్యవసాయ పేరు",
      "enterBusinessName": "వ్యవసాయ పేరు నమోదు చేయండి",
      "ownerName": "యజమాని పేరు",
      "enterOwnerName": "యజమాని పేరు నమోదు చేయండి",
      "email": "ఈమెయిల్",
      "enterValidEmail": "చెల్లుబాటు అయ్యే ఈమెయిల్ నమోదు చేయండి",
      "contact": "సంప్రదించండి",
      "enterContact": "సంప్రదింపు సంఖ్య నమోదు చేయండి",
      "location": "ప్రాంతం",
      "enterLocation": "ప్రాంతం నమోదు చేయండి",
      "bio": "జీవిత చరిత్ర",
      "enterBio": "జీవిత చరిత్రను నమోదు చేయండి",
      "selectCategory": "వర్గాన్ని ఎంచుకోండి",
      "selectCategoryError": "దయచేసి వర్గాన్ని ఎంచుకోండి",
      "createProfileButton": "ప్రొఫైల్ సృష్టించండి",
      "updateProfileButton": "ప్రొఫైల్ నవీకరించండి",
      "skipForNow": "ప్రస్తుతం స్కిప్ చేయండి",
      "loadingCategoriesError": "వర్గాలను లోడ్ చేయలేకపోయింది",
      "error": "లోపం"
    }
  };

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _loadExistingProfile();
  }

  Future<void> _fetchCategories() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('categories').get();
      final catList =
          snapshot.docs.map((doc) => doc['name'].toString()).toList();
      setState(() => _categories = catList);
    } catch (e) {
      debugPrint('Error loading categories: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load categories')),
      );
    }
  }

  Future<void> _loadExistingProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _businessNameController.text = data['businessName'] ?? '';
        _ownerNameController.text = data['ownerName'] ?? '';
        _emailController.text = data['email'] ?? '';
        _contactController.text = data['contact'] ?? '';
        _locationController.text = data['location'] ?? '';
        _bioController.text = data['bio'] ?? ''; // ✅ Load bio
        _profileImageUrlController.text = data['profileImageUrl'] ?? '';
        _selectedCategory = data['category'];
        setState(() {
          _isEditMode = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  Future<void> _submitProfile({bool skip = false}) async {
    if (!skip && !_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        user = (await FirebaseAuth.instance.signInAnonymously()).user;
      }

      final uid = user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'businessName': skip ? null : _businessNameController.text.trim(),
        'ownerName': skip ? null : _ownerNameController.text.trim(),
        'email': skip ? null : _emailController.text.trim(),
        'contact': skip ? null : _contactController.text.trim(),
        'location': skip ? null : _locationController.text.trim(),
        'bio': skip ? null : _bioController.text.trim(), // ✅ Save bio
        'category': skip ? null : _selectedCategory,
        'profileImageUrl': skip ? null : _profileImageUrlController.text.trim(),
      }, SetOptions(merge: true));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(language: widget.language)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _promptForProfileImageUrl() async {
    final url = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller =
            TextEditingController(text: _profileImageUrlController.text);
        return AlertDialog(
          title: const Text('Enter Profile Image URL'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'https://...'),
            keyboardType: TextInputType.url,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Upload'),
            ),
          ],
        );
      },
    );

    if (url != null && url.isNotEmpty) {
      setState(() {
        _profileImageUrlController.text = url;
      });
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: const Color(0xFFFBEAFF),
      labelStyle: const TextStyle(color: Color(0xFF8B5FBF)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF1FB),
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Profile' : 'Create Profile'),
        backgroundColor: const Color(0xFFCE9FFC),
        centerTitle: true,
        elevation: 4,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Center(
                child: Container(
                  width: isWide ? 600 : double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _promptForProfileImageUrl,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: _profileImageUrlController
                                    .text.isNotEmpty
                                ? NetworkImage(_profileImageUrlController.text)
                                : const AssetImage(
                                        'assets/avatar_placeholder.png')
                                    as ImageProvider,
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: _businessNameController,
                          decoration: _inputDecoration(localizedStrings[
                              widget.language]!['businessName']!),
                          validator: (value) => value!.isEmpty
                              ? localizedStrings[widget.language]![
                                  'enterBusinessName']
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _ownerNameController,
                          decoration: _inputDecoration(
                              localizedStrings[widget.language]!['ownerName']!),
                          validator: (value) => value!.isEmpty
                              ? localizedStrings[widget.language]![
                                  'enterOwnerName']
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: _inputDecoration(
                              localizedStrings[widget.language]!['email']!),
                          validator: (value) =>
                              value != null && value.contains('@')
                                  ? null
                                  : localizedStrings[widget.language]![
                                      'enterValidEmail'],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _contactController,
                          decoration: _inputDecoration(
                              localizedStrings[widget.language]!['contact']!),
                          validator: (value) => value!.isEmpty
                              ? localizedStrings[widget.language]![
                                  'enterContact']
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _locationController,
                          decoration: _inputDecoration(
                              localizedStrings[widget.language]!['location']!),
                          validator: (value) => value!.isEmpty
                              ? localizedStrings[widget.language]![
                                  'enterLocation']
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _bioController,
                          decoration: _inputDecoration(
                              localizedStrings[widget.language]!['bio']!),
                          validator: (value) => value!.isEmpty
                              ? localizedStrings[widget.language]!['enterBio']
                              : null,
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: _inputDecoration(localizedStrings[
                              widget.language]!['selectCategory']!),
                          items: _categories
                              .map((cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedCategory = value),
                          validator: (value) => value == null
                              ? localizedStrings[widget.language]![
                                  'selectCategoryError']
                              : null,
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _submitProfile(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD18CE0),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                                _isEditMode
                                    ? localizedStrings[widget.language]![
                                        'updateProfileButton']!
                                    : localizedStrings[widget.language]![
                                        'createProfileButton']!,
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white)),
                          ),
                        ),
                        if (!_isEditMode) ...[
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () => _submitProfile(skip: true),
                            child: Text(
                              localizedStrings[widget.language]!['skipForNow']!,
                              style: TextStyle(color: Color(0xFF8B5FBF)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
