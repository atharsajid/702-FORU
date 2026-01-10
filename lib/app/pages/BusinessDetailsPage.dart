import 'package:flutter/material.dart';
import 'package:for_you/app/utils/app_themes.dart';

class BusinessLayoutPage extends StatelessWidget {
  final Map<String, dynamic> business;

  const BusinessLayoutPage({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    final logo = business["logo"] ?? "";
    final image = business["image"] ?? "";
    final name = business["name"] ?? "";
    final rating = business["rating"].toString();
    final address = business["address"] ?? "";
    final description = business["description"] ?? "";
    final phone = business["phone"] ?? "";
    final website = business["website"] ?? "";
    final services = business["services"] ?? [];
    final coupons = business["coupons"] ?? [];
    final reviews = business["reviews"] ?? [];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(name),
        backgroundColor: AppColors.splashBackgroundColor,

        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ⭐ Banner Image
            _bannerImage(image),

            /// ⭐ Logo (Floating)
            _logoSection(logo),

            const SizedBox(height: 20),

            /// ⭐ Title + Rating
            _titleRating(name, rating),

            /// ⭐ Address
            _addressTile(address),

            /// ⭐ Description
            _sectionTitle("About"),
            _description(description),

            /// ⭐ Services
            if (services.isNotEmpty) _sectionTitle("Services"),
            if (services.isNotEmpty) _servicesList(services),

            /// ⭐ Coupons
            if (coupons.isNotEmpty) _sectionTitle("Coupons"),
            if (coupons.isNotEmpty) _couponsList(coupons),

            /// ⭐ Reviews
            if (reviews.isNotEmpty) _sectionTitle("Reviews"),
            if (reviews.isNotEmpty) _reviewsList(reviews),

            /// ⭐ Contact
            _sectionTitle("Contact & Socials"),
            _contactSection(phone, website),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ⭐ WIDGETS
  // ---------------------------------------------------------------------------

  Widget _bannerImage(String image) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: Image.network(
        image,
        height: 230,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 230,
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, size: 40),
        ),
      ),
    );
  }

  Widget _logoSection(String logo) {
    return Align(
      alignment: Alignment.center,
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.white,
        child: ClipOval(
          child: Image.network(
            logo,
            height: 90,
            width: 90,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.store, size: 40),
          ),
        ),
      ),
    );
  }

  Widget _titleRating(String name, String rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 4),
              Text(rating, style: const TextStyle(fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _addressTile(String address) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.deepPurple),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              address,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 25, 16, 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _description(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
      ),
    );
  }

  Widget _servicesList(List services) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: services
            .map(
              (s) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.deepPurple),
                    const SizedBox(width: 10),
                    Text(s.toString(), style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _couponsList(List coupons) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: coupons.map((c) {
          final title = c["title"] ?? "";
          final code = c["code"] ?? "";

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
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
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    code,
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _reviewsList(List reviews) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: reviews.map((r) {
          final user = r["user"] ?? "User";
          final comment = r["comment"] ?? "";
          final rating = r["rating"].toString();

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      user,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(rating),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  comment,
                  style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _contactSection(String phone, String website) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _contactTile(Icons.phone, "Phone", phone),
          const SizedBox(height: 10),
          _contactTile(Icons.language, "Website", website),
        ],
      ),
    );
  }

  Widget _contactTile(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "$title: $value",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
