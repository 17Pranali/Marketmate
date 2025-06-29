import 'package:btech_project/frontend/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<DocumentSnapshot>> _getVerifiedUsers() async {
    QuerySnapshot querySnapshot =
        await _firestore.collection('verified_users').get();
    return querySnapshot.docs;
  }

  Future<List<DocumentSnapshot>> _getUnverifiedUsers() async {
    QuerySnapshot querySnapshot =
        await _firestore.collection('unverified_users').get();
    return querySnapshot.docs;
  }

  Future<List<DocumentSnapshot>> _getMSMERecords() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('msme').get();
    return querySnapshot.docs;
  }

  Future<void> _verifyUser(DocumentSnapshot user) async {
    Map<String, dynamic> userData = user.data() as Map<String, dynamic>;
    await _firestore.collection('verified_users').add(userData);
    await _firestore.collection('unverified_users').doc(user.id).delete();
    _showSuccess(
        "User ${userData['first_name']} ${userData['last_name']} verified successfully.");
  }

  Future<void> _blockUser(DocumentSnapshot user) async {
    await _firestore
        .collection('blocked_users')
        .add(user.data() as Map<String, dynamic>);
    await _firestore.collection('unverified_users').doc(user.id).delete();
    _showSuccess(
        "User ${user['first_name']} ${user['last_name']} blocked successfully.");
  }

  Future<void> _deleteUserFromFirestore(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User deleted from Firestore")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting user: $e")),
      );
    }
  }

  Future<List<DocumentSnapshot>> _getProfileCreatedUsers() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users') // your collection name
        .get();

    return snapshot.docs;
  }

  Future<void> _logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log out'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog first
                await FirebaseAuth.instance.signOut(); // Firebase sign out
                // Navigate to sign-in page
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SignUpPage(language: 'en')),
                  (route) => false,
                );
              },
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () =>
                _logout(context), // Log out when the button is clicked
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Admin Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            _buildDrawerItem(
                Icons.verified, 'View Verified Users', _showVerifiedUsers),
            _buildDrawerItem(
                Icons.error, 'View Unverified Users', _showUnverifiedUsers),
            _buildDrawerItem(Icons.add, 'Add User', _showAddUserDialog),
            _buildDrawerItem(Icons.edit, 'Modify User', _showModifyUserDialog),
            _buildDrawerItem(
                Icons.delete, 'Delete User', _showDeleteUserDialog),
            _buildDrawerItem(
                Icons.verified, 'Business Users', _showProfileCreatedUsers),
            _buildDrawerItem(Icons.verified, 'MSME Users', _showMSMERecords),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            int columns = constraints.maxWidth > 600 ? 3 : 2;
            return GridView.count(
              crossAxisCount: columns,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildCard(
                    "View Verified Users", Icons.verified, _showVerifiedUsers),
                _buildCard(
                    "View Unverified Users", Icons.error, _showUnverifiedUsers),
                _buildCard("Add User", Icons.add, _showAddUserDialog),
                _buildCard("Modify User", Icons.edit, _showModifyUserDialog),
                _buildCard("Delete User", Icons.delete, _showDeleteUserDialog),
                _buildCard(
                    "Business Users", Icons.verified, _showProfileCreatedUsers),
                _buildCard("MSMEs Users", Icons.verified, _showMSMERecords),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  Widget _buildCard(String title, IconData icon, Function onTap) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Card(
        elevation: 8,
        color: const Color.fromARGB(255, 67, 123, 236),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 60, color: Colors.white),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVerifiedUsers() async {
    List<DocumentSnapshot> verifiedUsers = await _getVerifiedUsers();
    int currentPage = 0;
    int rowsPerPage = 5; // Number of rows per page

    // Function to get paginated data
    List<DocumentSnapshot> getPaginatedData(int page) {
      int start = page * rowsPerPage;
      int end = (start + rowsPerPage) > verifiedUsers.length
          ? verifiedUsers.length
          : start + rowsPerPage;
      return verifiedUsers.sublist(start, end);
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Verified Users",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      DataTable(
                        dataRowHeight:
                            60, // Increase row height for better readability
                        headingRowHeight: 60, // Make the header row taller
                        columns: const [
                          DataColumn(
                              label: Text("S.No",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text("First Name",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text("Last Name",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text("Email",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text("Aadhar",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text("GSTIN",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: List.generate(
                          getPaginatedData(currentPage).length,
                          (index) {
                            var user = getPaginatedData(currentPage)[index]
                                .data() as Map<String, dynamic>;
                            return DataRow(
                              cells: [
                                DataCell(Text((currentPage * rowsPerPage +
                                        index +
                                        1)
                                    .toString())), // Adjusted for correct serial number
                                DataCell(Text(user['first_name'] ?? '')),
                                DataCell(Text(user['last_name'] ?? '')),
                                DataCell(Text(user['email'] ?? '')),
                                DataCell(Text(user['aadhar'] ?? '')),
                                DataCell(Text(user['gstin'] ?? '')),
                              ],
                              color: index.isEven
                                  ? MaterialStateProperty.all(Colors.grey[100])
                                  : MaterialStateProperty.all(Colors.white),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: currentPage > 0
                                ? () {
                                    setState(() {
                                      currentPage--;
                                    });
                                  }
                                : null,
                          ),
                          Text(
                              "Page ${currentPage + 1} of ${(verifiedUsers.length / rowsPerPage).ceil()}"),
                          IconButton(
                            icon: Icon(Icons.arrow_forward),
                            onPressed: currentPage <
                                    (verifiedUsers.length / rowsPerPage)
                                            .ceil() -
                                        1
                                ? () {
                                    setState(() {
                                      currentPage++;
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _showUnverifiedUsers() async {
    List<DocumentSnapshot> unverifiedUsers = await _getUnverifiedUsers();
    int currentPage = 0;
    int rowsPerPage = 5; // Number of rows per page

    // Function to get paginated data
    List<DocumentSnapshot> getPaginatedData(int page) {
      int start = page * rowsPerPage;
      int end = (start + rowsPerPage) > unverifiedUsers.length
          ? unverifiedUsers.length
          : start + rowsPerPage;
      return unverifiedUsers.sublist(start, end);
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Unverified Users",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      DataTable(
                        dataRowHeight:
                            60, // Increase row height for better readability
                        headingRowHeight: 60, // Make the header row taller
                        columns: const [
                          DataColumn(
                            label: Text(
                              "S.No",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "First Name",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Last Name",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Email",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Actions",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        rows: List.generate(
                          getPaginatedData(currentPage).length,
                          (index) {
                            var user = getPaginatedData(currentPage)[index]
                                .data() as Map<String, dynamic>;
                            return DataRow(
                              cells: [
                                DataCell(Text(
                                    (currentPage * rowsPerPage + index + 1)
                                        .toString())),
                                DataCell(Text(user['first_name'] ?? '')),
                                DataCell(Text(user['last_name'] ?? '')),
                                DataCell(Text(user['email'] ?? '')),
                                DataCell(
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                        ),
                                        child: Text("Verify"),
                                        onPressed: () {
                                          _verifyUser(unverifiedUsers[
                                              currentPage * rowsPerPage +
                                                  index]);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      SizedBox(width: 8),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: Text("Block"),
                                        onPressed: () {
                                          _blockUser(unverifiedUsers[
                                              currentPage * rowsPerPage +
                                                  index]);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              color: index.isEven
                                  ? MaterialStateProperty.all(Colors.grey[100])
                                  : MaterialStateProperty.all(Colors.white),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: currentPage > 0
                                ? () {
                                    setState(() {
                                      currentPage--;
                                    });
                                  }
                                : null,
                          ),
                          Text(
                              "Page ${currentPage + 1} of ${(unverifiedUsers.length / rowsPerPage).ceil()}"),
                          IconButton(
                            icon: Icon(Icons.arrow_forward),
                            onPressed: currentPage <
                                    (unverifiedUsers.length / rowsPerPage)
                                            .ceil() -
                                        1
                                ? () {
                                    setState(() {
                                      currentPage++;
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showAddUserDialog() {
    final _formKey = GlobalKey<FormState>();
    String firstName = '';
    String lastName = '';
    String email = '';
    String aadhar = '';
    String gstin = '';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Add User",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildResponsiveTextField(
                      "First Name",
                      Icons.person,
                      (value) => firstName = value!,
                    ),
                    _buildResponsiveTextField(
                      "Last Name",
                      Icons.person_outline,
                      (value) => lastName = value!,
                    ),
                    _buildResponsiveTextField(
                      "Email",
                      Icons.email,
                      (value) => email = value!,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return "Please enter a valid email";
                        }
                        return null;
                      },
                    ),
                    _buildResponsiveTextField(
                      "Aadhar",
                      Icons.credit_card,
                      (value) => aadhar = value!,
                    ),
                    _buildResponsiveTextField(
                      "GSTIN",
                      Icons.business,
                      (value) => gstin = value!,
                    ),
                    SizedBox(height: 20),
                    ButtonBar(
                      alignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              _addUser(
                                  firstName, lastName, email, aadhar, gstin);
                              Navigator.of(context).pop();
                            }
                          },
                          child: Text("Add"),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("Cancel"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showProfileCreatedUsers() async {
    List<DocumentSnapshot> profileUsers = await _getProfileCreatedUsers();
    int currentPage = 0;
    int rowsPerPage = 5;

    TextEditingController searchController = TextEditingController();
    String searchQuery = '';

    List<DocumentSnapshot> getFilteredData() {
      if (searchQuery.isEmpty) return profileUsers;
      return profileUsers.where((doc) {
        var data = doc.data() as Map<String, dynamic>;
        String businessName =
            data['businessName']?.toString().toLowerCase() ?? '';
        String category = data['category']?.toString().toLowerCase() ?? '';
        return businessName.contains(searchQuery.toLowerCase()) ||
            category.contains(searchQuery.toLowerCase());
      }).toList();
    }

    List<DocumentSnapshot> getPaginatedData(
        List<DocumentSnapshot> filteredData, int page) {
      int start = page * rowsPerPage;
      int end = (start + rowsPerPage > filteredData.length)
          ? filteredData.length
          : start + rowsPerPage;
      return filteredData.sublist(start, end);
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Users with Business Profiles",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: StatefulBuilder(
                builder: (context, setState) {
                  List<DocumentSnapshot> filteredData = getFilteredData();
                  List<DocumentSnapshot> paginatedData =
                      getPaginatedData(filteredData, currentPage);

                  return Column(
                    children: [
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: SizedBox(
                          width: 300,
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: 'Search by Business Name or Category',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0)),
                            ),
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value;
                                currentPage = 0; // Reset page when filtering
                              });
                            },
                          ),
                        ),
                      ),

                      // Data Table
                      DataTable(
                        dataRowHeight: 80,
                        headingRowHeight: 60,
                        columns: const [
                          DataColumn(
                              label: Text("S.No",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text("Business Name",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text("Owner",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text("Category",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text("Contact",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text("Email",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text("Location",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: List.generate(
                          paginatedData.length,
                          (index) {
                            var user = paginatedData[index].data()
                                as Map<String, dynamic>;
                            return DataRow(
                              cells: [
                                DataCell(Text(
                                    (currentPage * rowsPerPage + index + 1)
                                        .toString())),
                                DataCell(Text(user['businessName'] ?? '')),
                                DataCell(Text(user['ownerName'] ?? '')),
                                DataCell(Text(user['category'] ?? '')),
                                DataCell(Text(user['contact'] ?? '')),
                                DataCell(Text(user['email'] ?? '')),
                                DataCell(Text(user['location'] ?? '')),
                              ],
                              color: index.isEven
                                  ? MaterialStateProperty.all(Colors.grey[100])
                                  : MaterialStateProperty.all(Colors.white),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 10),

                      // Pagination
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: currentPage > 0
                                ? () {
                                    setState(() {
                                      currentPage--;
                                    });
                                  }
                                : null,
                          ),
                          Text(
                              "Page ${currentPage + 1} of ${(filteredData.length / rowsPerPage).ceil()}"),
                          IconButton(
                            icon: Icon(Icons.arrow_forward),
                            onPressed: currentPage <
                                    (filteredData.length / rowsPerPage).ceil() -
                                        1
                                ? () {
                                    setState(() {
                                      currentPage++;
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

// Helper method to build responsive TextFields
  Widget _buildResponsiveTextField(
      String label, IconData icon, Function(String?) onSaved,
      {String? Function(String?)? validator, String? initialValue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        onSaved: onSaved,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        ),
      ),
    );
  }

  TextFormField _buildTextField(String label, Function(String?) onSaved,
      {String? Function(String?)? validator, required String initialValue}) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      validator: validator,
      onSaved: onSaved,
    );
  }

  Future<void> _addUser(String firstName, String lastName, String email,
      String aadhar, String gstin) async {
    try {
      await _firestore.collection('unverified_users').add({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'aadhar': aadhar,
        'gstin': gstin,
        'created_at': FieldValue.serverTimestamp(),
      });
      _showSuccess("User added successfully!");
    } catch (e) {
      _showSuccess("Failed to add user: $e");
    }
  }

  void _showModifyUserDialog() async {
    List<DocumentSnapshot> verifiedUsers = await _getVerifiedUsers();
    List<DocumentSnapshot> filteredUsers = List.from(verifiedUsers);
    int rowsPerPage = 5;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: StatefulBuilder(
            builder: (context, setState) {
              int currentPage = 0;

              // Search function
              void filterUsers(String query) {
                query = query.toLowerCase();
                setState(() {
                  filteredUsers = verifiedUsers.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return (data['first_name'] ?? '')
                            .toLowerCase()
                            .contains(query) ||
                        (data['last_name'] ?? '')
                            .toLowerCase()
                            .contains(query) ||
                        (data['email'] ?? '').toLowerCase().contains(query);
                  }).toList();
                  currentPage = 0; // reset to first page after search
                });
              }

              // Pagination function
              List<DocumentSnapshot> getPaginatedData(int page) {
                int start = page * rowsPerPage;
                int end = (start + rowsPerPage) > filteredUsers.length
                    ? filteredUsers.length
                    : start + rowsPerPage;
                return filteredUsers.sublist(start, end);
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Select User to Modify",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Search by first name, last name, or email",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: filterUsers,
                    ),
                    SizedBox(height: 10),
                    Divider(),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: getPaginatedData(currentPage).length,
                        itemBuilder: (context, index) {
                          var user = getPaginatedData(currentPage)[index].data()
                              as Map<String, dynamic>;
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                child: Icon(Icons.person,
                                    color: Colors.blue.shade800),
                              ),
                              title: Text(
                                "${user['first_name']} ${user['last_name']}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text("Email: ${user['email']}"),
                              trailing: Icon(Icons.edit, color: Colors.blue),
                              onTap: () {
                                Navigator.of(context).pop();
                                _showEditUserDialog(filteredUsers[index]);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: currentPage > 0
                              ? () => setState(() => currentPage--)
                              : null,
                        ),
                        Text(
                            "Page ${currentPage + 1} of ${(filteredUsers.length / rowsPerPage).ceil()}"),
                        IconButton(
                          icon: Icon(Icons.arrow_forward),
                          onPressed: currentPage <
                                  (filteredUsers.length / rowsPerPage).ceil() -
                                      1
                              ? () => setState(() => currentPage++)
                              : null,
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("Close"),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showEditUserDialog(DocumentSnapshot user) {
    final _formKey = GlobalKey<FormState>();
    String firstName = user['first_name'] ?? '';
    String lastName = user['last_name'] ?? '';
    String email = user['email'] ?? '';
    String aadhar = user['aadhar'] ?? '';
    String gstin = user['gstin'] ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Edit User",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    Divider(),
                    SizedBox(height: 10),
                    _buildTextField(
                      "First Name",
                      (value) => firstName = value!,
                      initialValue: firstName, // Display existing first name
                    ),
                    SizedBox(height: 10),
                    _buildTextField(
                      "Last Name",
                      (value) => lastName = value!,
                      initialValue: lastName, // Display existing last name
                    ),
                    SizedBox(height: 10),
                    _buildTextField(
                      "Email",
                      (value) => email = value!,
                      initialValue: email, // Display existing email
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return "Please enter a valid email";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    _buildTextField(
                      "Aadhar",
                      (value) => aadhar = value!,
                      initialValue: aadhar, // Display existing aadhar number
                    ),
                    SizedBox(height: 10),
                    _buildTextField(
                      "GSTIN",
                      (value) => gstin = value!,
                      initialValue: gstin, // Display existing GSTIN
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              _updateUser(user.id, firstName, lastName, email,
                                  aadhar, gstin);
                              Navigator.of(context).pop();
                            }
                          },
                          child: Text("Update"),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("Cancel"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateUser(String userId, String firstName, String lastName,
      String email, String aadhar, String gstin) async {
    try {
      await _firestore.collection('verified_users').doc(userId).update({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'aadhar': aadhar,
        'gstin': gstin,
      });
      _showSuccess("User updated successfully!");
    } catch (e) {
      _showSuccess("Failed to update user: $e");
    }
  }

  void _showMSMERecords() async {
    List<DocumentSnapshot> msmeRecords = await _getMSMERecords();
    List<DocumentSnapshot> filteredRecords = List.from(msmeRecords);
    int currentPage = 0;
    int rowsPerPage = 5;

    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController gstinController = TextEditingController();
    final TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            List<DocumentSnapshot> getPaginatedData(int page) {
              int start = page * rowsPerPage;
              int end = (start + rowsPerPage) > filteredRecords.length
                  ? filteredRecords.length
                  : start + rowsPerPage;
              return filteredRecords.sublist(start, end);
            }

            return AlertDialog(
              title: Text("MSME Records"),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.8,
                child: Column(
                  children: [
                    // 🔍 Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          labelText: "Search by GSTIN",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (query) {
                          setState(() {
                            currentPage = 0;
                            filteredRecords = msmeRecords.where((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              return (data['gstin'] ?? '')
                                  .toString()
                                  .toLowerCase()
                                  .contains(query.toLowerCase());
                            }).toList();
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 10),

                    // 📋 MSME Data Table
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(
                                  Colors.grey.shade200),
                              columns: const [
                                DataColumn(label: Text("S.No")),
                                DataColumn(label: Text("First Name")),
                                DataColumn(label: Text("Last Name")),
                                DataColumn(label: Text("GSTIN")),
                              ],
                              rows: List.generate(
                                getPaginatedData(currentPage).length,
                                (index) {
                                  var record =
                                      getPaginatedData(currentPage)[index]
                                          .data() as Map<String, dynamic>;
                                  return DataRow(
                                    cells: [
                                      DataCell(Text((currentPage * rowsPerPage +
                                              index +
                                              1)
                                          .toString())),
                                      DataCell(
                                          Text(record['first_name'] ?? '')),
                                      DataCell(Text(record['last_name'] ?? '')),
                                      DataCell(Text(record['gstin'] ?? '')),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ⏩ Pagination Controls
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios),
                          onPressed: currentPage > 0
                              ? () {
                                  setState(() {
                                    currentPage--;
                                  });
                                }
                              : null,
                        ),
                        Text(
                          "Page ${currentPage + 1} of ${(filteredRecords.length / rowsPerPage).ceil()}",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward_ios),
                          onPressed: currentPage <
                                  (filteredRecords.length / rowsPerPage)
                                          .ceil() -
                                      1
                              ? () {
                                  setState(() {
                                    currentPage++;
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),

                    // ➕ Add Record Fields
                    Divider(thickness: 1),
                    Text("Add New MSME Record",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: firstNameController,
                            decoration: InputDecoration(
                              labelText: "First Name",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: lastNameController,
                            decoration: InputDecoration(
                              labelText: "Last Name",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: gstinController,
                            decoration: InputDecoration(
                              labelText: "GSTIN",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: Icon(Icons.add),
                      label: Text("Add Record"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        if (firstNameController.text.isEmpty ||
                            lastNameController.text.isEmpty ||
                            gstinController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("All fields are required")),
                          );
                          return;
                        }

                        await FirebaseFirestore.instance
                            .collection('msme')
                            .add({
                          'first_name': firstNameController.text.trim(),
                          'last_name': lastNameController.text.trim(),
                          'gstin': gstinController.text.trim(),
                        });

                        // Clear inputs
                        firstNameController.clear();
                        lastNameController.clear();
                        gstinController.clear();

                        // Refresh data
                        msmeRecords = await _getMSMERecords();
                        filteredRecords = List.from(msmeRecords);
                        searchController.clear();

                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteUserDialog() async {
    // Fetch verified users only
    List<DocumentSnapshot> verifiedUsers = await _getVerifiedUsers();
    int itemsPerPage = 5; // Number of users per page
    int totalPages =
        (verifiedUsers.length / itemsPerPage).ceil(); // Calculate total pages
    int currentPage = 0; // Current page index
    List<DocumentSnapshot> filteredUsers =
        List.from(verifiedUsers); // Copy to filtered list initially

    // Controller for the search input
    TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Function to filter users based on search
            void filterUsers(String query) {
              setState(() {
                filteredUsers = verifiedUsers.where((user) {
                  Map<String, dynamic> userData =
                      user.data() as Map<String, dynamic>;
                  String name =
                      "${userData['first_name']} ${userData['last_name']}"
                          .toLowerCase();
                  String email = (userData['email'] ?? "").toLowerCase();
                  return name.contains(query.toLowerCase()) ||
                      email.contains(query.toLowerCase());
                }).toList();
              });
            }

            // Paginate the filtered users
            int startIndex = currentPage * itemsPerPage;
            int endIndex =
                (startIndex + itemsPerPage).clamp(0, filteredUsers.length);
            List<DocumentSnapshot> paginatedUsers =
                filteredUsers.sublist(startIndex, endIndex);

            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 5,
              child: FractionallySizedBox(
                alignment: Alignment.center,
                widthFactor:
                    0.8, // Adjust width factor to make the dialog responsive
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dialog Title
                      Text(
                        "Delete Verified Users",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Search bar
                      TextField(
                        controller: searchController,
                        onChanged: filterUsers,
                        decoration: InputDecoration(
                          labelText: "Search by Name or Email",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                      SizedBox(height: 16),

                      // List of paginated and filtered users
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              ...paginatedUsers.map((user) {
                                Map<String, dynamic> userData =
                                    user.data() as Map<String, dynamic>;
                                return Card(
                                  elevation: 2,
                                  margin: EdgeInsets.symmetric(vertical: 6),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(12),
                                    title: Text(
                                      "${userData['first_name']} ${userData['last_name']}",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: Text(userData['email'] ?? "",
                                        style: TextStyle(fontSize: 14)),
                                    trailing: IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        // Delete the user from the 'verified_users' collection
                                        await _firestore
                                            .collection('verified_users')
                                            .doc(user.id)
                                            .delete();
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                        _showSuccess(
                                            "Verified user deleted successfully.");
                                      },
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),

                      // Pagination Controls
                      Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: currentPage > 0
                                  ? () => setState(() {
                                        currentPage--;
                                      })
                                  : null,
                              child: Text(
                                "Previous",
                                style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            Text(
                              "Page ${currentPage + 1} of $totalPages",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            TextButton(
                              onPressed: currentPage < totalPages - 1
                                  ? () => setState(() {
                                        currentPage++;
                                      })
                                  : null,
                              child: Text(
                                "Next",
                                style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
