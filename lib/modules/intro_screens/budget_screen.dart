/* import 'package:flutter/material.dart';
import 'package:darlink/constants/colors/app_color.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late double start;
  late double end;

  @override
  void initState() {
    super.initState();
    start = 300; // Initial start value
    end = 10000; // Initial end value
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      body: Column(
        children: [
          const SizedBox(height: 125),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              "What is your budget",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          Card(
            color: cardBackGroundColor,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        "Price Range",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const Spacer(),
                      Text(
                        "\$${start.toInt()} - \$${end.toInt()}",
                        style: const TextStyle(
                          color: Colors.lightBlueAccent,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),
                  MouseRegion(
                    cursor: SystemMouseCursors.copy, // Custom mouse cursor
                    child: RangeSlider(
                      values: RangeValues(start, end),
                      labels: RangeLabels(
                        "\$${start.toInt()}",
                        "\$${end.toInt()}",
                      ),
                      onChanged: (value) {
                        setState(() {
                          start = value.start;
                          end = value.end;
                        });
                      },
                      min: 300,
                      max: 10000,
                      divisions: 100,
                      activeColor: Colors.blue,
                      inactiveColor: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 45,
          ),
          Text(
            "Where do you want to buy ?",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              color: cardBackGroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // "Near" Button with Purple Border
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.transparent, // Transparent background
                        side: const BorderSide(
                            color: Colors.deepPurple,
                            width: 2), // Purple border
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                        child: Text(
                          "Near",
                          style: TextStyle(
                              color: Colors.deepPurple), // Purple text
                        ),
                      ),
                    ),
                  ),
                  // Other Button with Red Background and White Text
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Red background
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      child: Text(
                        "Outside",
                        style: TextStyle(color: Colors.white), // White text
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Additional Card with "Show Property" Button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Card(
              color: Colors.deepPurple, // Purple background
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    "Show Property",
                    style: const TextStyle(
                      color: Colors.white, // White text
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Text(
            "Skip",
            style: TextStyle(color: Colors.blue),
          )
        ],
      ),
    );
  }
}
 */
