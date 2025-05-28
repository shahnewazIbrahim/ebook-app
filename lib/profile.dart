import 'package:ebook_project/api/api_service.dart';
import 'package:ebook_project/components/app_layout.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> userData = {};
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    ApiService apiService = ApiService();
    try {
      final data = await apiService.fetchEbookData("/v1/user");
      setState(() {
        userData = data['user'];
        isLoading = false;
      });
    } catch (error) {
      print("Error fetching profile: $error");
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: "My Profile",
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
          ? const Center(child: Text("Failed to load profile data"))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Image
            CircleAvatar(
              radius: 50,
              backgroundImage: userData['photo'] != null &&
                  userData['photo'].toString().isNotEmpty
                  ? NetworkImage(userData['photo'])
                  : null,
              backgroundColor: Colors.grey.shade300,
              child: userData['photo'] == null ||
                  userData['photo'].toString().isEmpty
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              userData['name'] ?? 'N/A',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              userData['email'] ?? '',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Phone: ${userData['phone_number'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 8),
            Text(
              "Gender: ${userData['gender'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(
                userData['status'] == 1
                    ? "Active"
                    : "Inactive",
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor:
              userData['status'] == 1
                  ? Colors.green
                  : Colors.orange,
            ),
            const SizedBox(height: 16),
            // Additional Info
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRow("BMDC No", userData['bmdc_no']),
                    _buildRow("User Type", userData['type'] == 1 ? "User" : "Admin"),
                    _buildRow("Birthdate", userData['date_of_birth']),
                    _buildRow("Facebook", userData['facebook_id_link']),
                    _buildRow("Created At", userData['created_at']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value != null && value.toString().isNotEmpty
                  ? value.toString()
                  : 'N/A',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
