import 'package:flutter/material.dart';

class RealEstateApp extends StatefulWidget {
  const RealEstateApp({super.key});

  @override
  State<RealEstateApp> createState() => _RealEstateAppState();
}

class _RealEstateAppState extends State<RealEstateApp> {
  String selectedProperty = 'House';
  RangeValues sizeRange = const RangeValues(0, 5000);
  RangeValues priceRange = const RangeValues(5000, 15000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Changed background color to a different shade
      backgroundColor: const Color(0xFF2D3250),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildSearchAndFilter(),
              const SizedBox(height: 16),
              _buildPropertyTypes(),
              const SizedBox(height: 16),
              _buildAllPropertySection(),
              const SizedBox(height: 24),
              // Removed the filter panel from the main layout
              Expanded(
                child: Center(
                  child: Text(
                    'Property listings will appear here',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Hello!',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.person, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.indigo.shade200),
                const SizedBox(width: 8),
                Text(
                  'Search...',
                  style: TextStyle(color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Modified filter button to show modal bottom sheet
        GestureDetector(
          onTap: () {
            _showFilterBottomSheet(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF5D5FEF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.filter_list, color: Colors.grey.shade200),
                const SizedBox(width: 8),
                Text(
                  'Filters',
                  style: TextStyle(color: Colors.grey.shade200),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Added method to show modal bottom sheet with filters
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Color(0xFF1A1F33),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Property types',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Property Size',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Up to ${sizeRange.end.toInt()} sqft',
                          style: TextStyle(
                            color: Colors.cyan.shade300,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderThemeData(
                        thumbColor: Colors.cyan.shade300,
                        activeTrackColor: Colors.cyan.shade300,
                        inactiveTrackColor: Colors.grey.shade800,
                      ),
                      child: RangeSlider(
                        values: sizeRange,
                        min: 0,
                        max: 10000,
                        onChanged: (RangeValues values) {
                          setState(() {
                            sizeRange = values;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Property Price',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 8),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Low',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'High',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderThemeData(
                        thumbColor: Colors.cyan.shade300,
                        activeTrackColor: Colors.cyan.shade300,
                        inactiveTrackColor: Colors.grey.shade800,
                      ),
                      child: RangeSlider(
                        values: priceRange,
                        min: 0,
                        max: 30000,
                        onChanged: (RangeValues values) {
                          setState(() {
                            priceRange = values;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.cyan.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '\$${priceRange.start.toInt()}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.cyan.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '\$${priceRange.end.toInt()}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () {
                          // Reset logic would go here
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.indigo.shade300),
                          ),
                          child: Center(
                            child: Text(
                              'Reset',
                              style: TextStyle(
                                color: Colors.indigo.shade300,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: () {
                          // Apply filter logic would go here
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF5D5FEF),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text(
                              'Check availability',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPropertyTypes() {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _propertyTypeChip('House', true),
          _propertyTypeChip('Apartment', false),
          _propertyTypeChip('Office', false),
          _propertyTypeChip('Land', false),
        ],
      ),
    );
  }

  Widget _propertyTypeChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF7B92) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: !isSelected
              ? Border.all(color: Colors.white.withOpacity(0.3))
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAllPropertySection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'All Property',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Row(
            children: [
              Text(
                'See All',
                style: TextStyle(
                  color: Colors.cyan.shade300,
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.cyan.shade300, size: 16),
            ],
          ),
        ),
      ],
    );
  }
}
