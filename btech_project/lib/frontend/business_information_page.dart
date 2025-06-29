import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'business_profile_page.dart';
import 'package:btech_project/backend/business_authservice.dart';

// Translations Map
const Map<String, Map<String, String>> translations = {
  'en': {
    'title': 'Business Information',
    'businessName': 'Business Name',
    'businessLocation': 'Business Location',
    'businessDescription': 'Business Description',
    'ownerName': 'Owner Name',
    'email': 'Email',
    'contact': 'Contact',
    'tapToSelectProfilePicture': 'Tap to select profile picture',
    'submit': 'Submit',
    'fieldRequired': 'This field cannot be empty',
    'infoSaved': 'Information Saved Successfully!',
  },
  'mr': {
    'title': 'व्यवसाय माहिती',
    'businessName': 'व्यवसायाचे नाव',
    'businessLocation': 'व्यवसायाचे ठिकाण',
    'businessDescription': 'व्यवसायाचे वर्णन',
    'ownerName': 'मालकाचे नाव',
    'email': 'ईमेल',
    'contact': 'संपर्क',
    'tapToSelectProfilePicture': 'प्रोफाइल फोटो निवडण्यासाठी टॅप करा',
    'submit': 'सबमिट करा',
    'fieldRequired': 'हे फील्ड रिक्त असू शकत नाही',
    'infoSaved': 'माहिती यशस्वीरित्या जतन केली गेली!',
  },
};

class BusinessInformationForm extends StatefulWidget {
  final String userUid;
  final String category;
  final String language;

  const BusinessInformationForm({
    Key? key,
    required this.userUid,
    required this.category,
    required this.language,
  }) : super(key: key);

  @override
  _BusinessInformationFormState createState() =>
      _BusinessInformationFormState();
}

class _BusinessInformationFormState extends State<BusinessInformationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();

  File? _profilePicture;
  String profilePicUrl = '';
  final ImagePicker _picker = ImagePicker();

  // Translation getter
  String tr(String key) {
    return translations[widget.language]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    try {
      await AuthService().loadBusinessData(
        widget.userUid,
        widget.category,
        context,
        setState,
      );
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profilePicture = File(image.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String uploadedProfilePicUrl = profilePicUrl;
      if (_profilePicture != null) {
        uploadedProfilePicUrl =
            await AuthService().uploadImage(_profilePicture!);
      }

      final businessData = {
        'userUid': widget.userUid,
        'category': widget.category,
        'businessName': _businessNameController.text,
        'location': _locationController.text,
        'description': _descriptionController.text,
        'email': _emailController.text,
        'contact': _contactController.text,
        'businessOwner': _ownerNameController.text,
        'profilePicUrl': uploadedProfilePicUrl,
      };

      await AuthService().saveBusinessData(businessData, widget.userUid);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('infoSaved'))),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BusinessProfilePage(
            userUid: widget.userUid,
            language: widget.language,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('title')),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(tr('businessName'), _businessNameController),
              _buildTextField(tr('businessLocation'), _locationController),
              _buildTextField(
                  tr('businessDescription'), _descriptionController),
              _buildTextField(tr('ownerName'), _ownerNameController),
              _buildTextField(tr('email'), _emailController),
              _buildTextField(tr('contact'), _contactController),
              const SizedBox(height: 20),
              _buildImagePicker(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.teal,
                ),
                child: Text(tr('submit'), style: const TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.teal[50],
        ),
        validator: (val) =>
            val == null || val.isEmpty ? tr('fieldRequired') : null,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[200],
            backgroundImage: _profilePicture != null
                ? FileImage(_profilePicture!)
                : (profilePicUrl.isNotEmpty
                    ? NetworkImage(profilePicUrl)
                    : null) as ImageProvider<Object>?,
            child: _profilePicture == null && profilePicUrl.isEmpty
                ? const Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                : null,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          tr('tapToSelectProfilePicture'),
          style: const TextStyle(fontSize: 16, color: Colors.teal),
        ),
      ],
    );
  }
}
