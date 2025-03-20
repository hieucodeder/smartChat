import 'package:flutter/material.dart';

class ServicePackagePage extends StatefulWidget {
  const ServicePackagePage({super.key});

  @override
  State<ServicePackagePage> createState() => _ServicePackagePageState();
}

class _ServicePackagePageState extends State<ServicePackagePage> {
  int selectedDuration = 2;
  List<Map<String, String>> plans = [
    {"title": "Cơ bản", "price": "499,000 VND / Tháng"},
    {"title": "Nâng cao", "price": "999,000 VND / Tháng"},
    {"title": "Doanh nghiệp", "price": "1,499,000 VND / Tháng"},
  ];
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.rocket_launch, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  "Cơ bản",
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              "499,000 VND / Tháng",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Colors.black38),
                ),
              ),
              onPressed: () {},
              child: const Text("Nâng cấp", style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildRadioButton(1, "1 tháng"),
                buildRadioButton(6, "6 tháng"),
                buildRadioButton(12, "12 tháng"),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            buildFeatureItem("2 Số lượng BOT"),
            buildFeatureItem("2,000 Số lượng thông điệp hồi/tháng"),
            buildFeatureItem("11,000,000 Số lượng ký tự/bot"),
            buildFeatureItem("32 tính năng thêm", showInfoIcon: true),
          ],
        ),
      ),
    );
  }

  Widget buildRadioButton(int value, String text) {
    return Row(
      children: [
        Radio<int>(
          value: value,
          groupValue: selectedDuration,
          activeColor: Colors.orange,
          onChanged: (int? newValue) {
            setState(() {
              selectedDuration = newValue!;
            });
          },
        ),
        Text(text),
      ],
    );
  }

  Widget buildFeatureItem(String text, {bool showInfoIcon = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.black),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
          if (showInfoIcon) const Icon(Icons.info_outline, size: 18),
        ],
      ),
    );
  }
}
