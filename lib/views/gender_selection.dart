import 'package:flutter/material.dart';
import 'my_training_page.dart';

class GenderSelectionPage extends StatefulWidget {
  const GenderSelectionPage({super.key});

  @override
  State<GenderSelectionPage> createState() => _GenderSelectionPageState();
}

class _GenderSelectionPageState extends State<GenderSelectionPage> {
  String? selectedGender;

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFB7CC54); // Bright green color from the image
    const textColor = Color(0xFF2C2C2E); // Dark gray text color
    const lightGray = Color(0xFFF2F2F7); // Light gray for unselected state

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Progress indicator
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: lightGray,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.25, // 25% progress (1 out of 4 steps)
                  child: Container(
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),
              // Main heading
              const Text(
                'Choose your gender',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Description text
              const Text(
                'Personalized recommendations are built based on these selections.',
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              // Gender selection cards
              Row(
                children: [
                  Expanded(
                    child: _GenderCard(
                      gender: 'Male',
                      isSelected: selectedGender == 'Male',
                      onTap: () => setState(() => selectedGender = 'Male'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _GenderCard(
                      gender: 'Female',
                      isSelected: selectedGender == 'Female',
                      onTap: () => setState(() => selectedGender = 'Female'),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Action buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: selectedGender != null ? () {
                        // Navigate to training page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyTrainingPage(),
                          ),
                        );
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Next'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      // Skip gender selection
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyTrainingPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 34), // Space for home indicator
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String gender;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.gender,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFB7CC54);
    const textColor = Color(0xFF2C2C2E);
    const lightGray = Color(0xFFF2F2F7);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: lightGray,
                shape: BoxShape.circle,
              ),
              child: Icon(
                gender == 'Male' ? Icons.person : Icons.person_outline,
                color: isSelected ? accentColor : Colors.grey.shade400,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              gender,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isSelected ? accentColor : textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
