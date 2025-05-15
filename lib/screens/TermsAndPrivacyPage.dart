import 'package:flutter/material.dart';
import 'package:food_recipe_app/screens/HomePage.dart';
import 'package:food_recipe_app/screens/ProfilePage.dart';
import 'package:shared_preferences/shared_preferences.dart';


class TermsAndPrivacyPage extends StatefulWidget {
  const TermsAndPrivacyPage({super.key});

  @override
  _TermsAndPrivacyPageState createState() => _TermsAndPrivacyPageState();
}

class _TermsAndPrivacyPageState extends State<TermsAndPrivacyPage> {
  bool isTermsSelected = true;
  bool isAgreed = false;

  @override
  void initState() {
    super.initState();
    _checkAgreementStatus();
  }

  Future<void> _checkAgreementStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool agreed = prefs.getBool('agreedToTerms') ?? false;
    if (agreed) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  Future<void> _agreeAndContinue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('agreedToTerms', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isTermsSelected ? "Terms & Conditions" : "Privacy Policy"),
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: isTermsSelected
                  ? _buildTermsContent()
                  : _buildPrivacyContent(),
            ),
          ),
          _buildAgreeSection(),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTab("Terms & Conditions", isTermsSelected, () {
          setState(() {
            isTermsSelected = true;
          });
        }),
        _buildTab("Privacy Policy", !isTermsSelected, () {
          setState(() {
            isTermsSelected = false;
          });
        }),
      ],
    );
  }

  Widget _buildTab(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTermsContent() {
    return SingleChildScrollView(
      key: ValueKey("Terms"),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("1. Introduction"),
          _sectionText("Welcome to the Food Recipe App! By using the app, you agree to these terms."),
          _sectionTitle("2. User Responsibility"),
          _sectionText("Make sure the recipes and ingredients you use suit your dietary needs."),
          _sectionTitle("3. Content Usage"),
          _sectionText("All content is for personal use only. Don’t redistribute."),
          _sectionTitle("4. Account Security"),
          _sectionText("Keep your login information safe. We’re not liable for misuse."),
          _sectionTitle("5. Updates"),
          _sectionText("Terms may be updated over time. Continued use means acceptance."),
        ],
      ),
    );
  }

  Widget _buildPrivacyContent() {
    return SingleChildScrollView(
      key: ValueKey("Privacy"),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("1. Data Collection"),
          _sectionText("We collect information like your name, email, and recipe preferences."),
          _sectionTitle("2. Use of Information"),
          _sectionText("Your data is used to personalize content and improve app experience."),
          _sectionTitle("3. Data Sharing"),
          _sectionText("We don’t share your data with third parties without consent."),
          _sectionTitle("4. Security"),
          _sectionText("We implement security measures to protect your data."),
          _sectionTitle("5. Changes to Policy"),
          _sectionText("We may update this policy, and you’ll be notified of changes."),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
    );
  }

  Widget _sectionText(String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        content,
        style: TextStyle(fontSize: 16, height: 1.5),
      ),
    );
  }

  Widget _buildAgreeSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: isAgreed,
                onChanged: (value) {
                  setState(() {
                    isAgreed = value!;
                  });
                },
                activeColor: Colors.red,
              ),
              Expanded(
                child: Text(
                  "I have read and agree to the Terms & Conditions and Privacy Policy.",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isAgreed ? Colors.red : Colors.grey,
              minimumSize: Size(double.infinity, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: isAgreed ? _agreeAndContinue : null,
            child: Text("Continue"),
          ),
        ],
      ),
    );
  }
}
