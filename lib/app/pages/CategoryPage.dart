// category_page.dart
import 'package:flutter/material.dart';
import 'package:for_you/app/pages/BusinessDetailsPage.dart';
import 'package:for_you/app/utils/app_themes.dart';

class CategoryPage extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> businesses;

  const CategoryPage({
    super.key,
    required this.title,
    required this.businesses,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
        backgroundColor: AppColors.splashBackgroundColor,

        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _logoHeader(),
              const SizedBox(height: 20),
              _spotlightAd(context),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Businesses in $title",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _businessGrid(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logoHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(child: Image.asset("assets/logo.png", height: 80)),
    );
  }

  Widget _spotlightAd(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Spotlight Your Business",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Click here to learn more",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _businessGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: businesses.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 180,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemBuilder: (context, index) {
          final item = businesses[index];
          return _businessCard(item, context);
        },
      ),
    );
  }

  Widget _businessCard(Map<String, dynamic> item, BuildContext context) {
    final name = item['name'] ?? 'Unknown Business';
    final image = item['image'] ?? '';
    final rating = item['rating'] ?? '';
    final address = item['address'] ?? '';

    return InkWell(
      onTap: () {
        // Expecting BusinessDetailsPage to accept Map<String, dynamic>.
        final data = <String, dynamic>{
          "name": item['name'] ?? '',
          "image": item['image'] ?? '',
          "logo": item['logo'], // optional
          "rating": item['rating'] ?? '0.0',
          "address": item['address'] ?? '',
          "description": item['description'] ?? 'No description available.',
          "phone": item['phone'] ?? '',
          "website": item['website'] ?? '',
          "services": item['services'] ?? [],
          "coupons": item['coupons'] ?? [], // FIXED KEY
          "reviews": item['reviews'] ?? [], // SAFE
        };
        print("---- BUSINESS DATA AFTER NULL CHECK ----");
        data.forEach((key, value) {
          print("$key : $value");
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BusinessLayoutPage(business: data)),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: Image.network(
                image,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 100,
                  color: Colors.grey[300],
                  child: const Icon(Icons.store, size: 40, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 6),
            if (rating.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(rating, style: const TextStyle(fontSize: 13)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
