import 'package:flutter/material.dart';
import 'package:for_you/app/pages/About702Page.dart';
import 'package:for_you/app/pages/CategoryPage.dart';
import 'package:for_you/app/pages/CityPage.dart';
import 'package:for_you/app/pages/OrderPage.dart';
import 'package:for_you/app/pages/ProfilePage.dart';
import 'package:for_you/app/utils/app_themes.dart';
import 'package:for_you/app/widgets/animated_rss_marquee.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;

import 'package:get/state_manager.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreenContent(),
    CityPage(),
    OrderPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    Widget _animatedIcon(IconData icon, int index) {
      final isSelected = _selectedIndex == index;

      return AnimatedScale(
        scale: isSelected ? 1.25 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        child: Icon(icon, color: isSelected ? Colors.deepPurple : Colors.grey),
      );
    }

    return Scaffold(
      body:
          // _pages[_selectedIndex]
          HomeScreenContent(),
      // bottomNavigationBar: Container(
      //   decoration: BoxDecoration(
      //     color: Colors.white.withOpacity(0.65),
      //     borderRadius: const BorderRadius.only(
      //       topLeft: Radius.circular(20),
      //       topRight: Radius.circular(20),
      //     ),
      //     boxShadow: [
      //       BoxShadow(
      //         color: Colors.black.withOpacity(0.1),
      //         blurRadius: 20,
      //         offset: const Offset(0, -2),
      //       ),
      //     ],
      //   ),
      //   child: ClipRRect(
      //     borderRadius: const BorderRadius.only(
      //       topLeft: Radius.circular(20),
      //       topRight: Radius.circular(20),
      //     ),
      //     child: BackdropFilter(
      //       filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      //       child: BottomNavigationBar(
      //         currentIndex: _selectedIndex,
      //         onTap: (index) => setState(() => _selectedIndex = index),
      //         type: BottomNavigationBarType.fixed,
      //         backgroundColor: Colors.white.withOpacity(0.3),
      //         elevation: 0,
      //         selectedItemColor: Colors.deepPurple,
      //         unselectedItemColor: Colors.grey,

      //         selectedFontSize: 13,
      //         unselectedFontSize: 12,

      //         showSelectedLabels: true,
      //         showUnselectedLabels: true,

      //         items: [
      //           BottomNavigationBarItem(
      //             icon: _animatedIcon(Icons.home, 0),
      //             label: "Home",
      //           ),
      //           BottomNavigationBarItem(
      //             icon: _animatedIcon(Icons.location_city, 1),
      //             label: "City",
      //           ),
      //           BottomNavigationBarItem(
      //             icon: _animatedIcon(Icons.shopping_bag, 2),
      //             label: "Order",
      //           ),
      //           BottomNavigationBarItem(
      //             icon: _animatedIcon(Icons.person, 3),
      //             label: "Profile",
      //           ),
      //         ],
      //       ),
      // ),
      // ),
      // ),
      
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  final List<Map<String, String>> categories = [
    {
      'title': 'Arts & Culture',
      'image': 'https://images.pexels.com/photos/21014/pexels-photo.jpg',
    },
    {
      'title': 'Food & Drink',
      'image':
          'https://images.pexels.com/photos/315755/pexels-photo-315755.jpeg',
    },
    {
      'title': 'Nightlife & Entertainment',
      'image':
          'https://images.pexels.com/photos/164821/pexels-photo-164821.jpeg',
    },
    {
      'title': 'Health & Wellness',
      'image':
          'https://images.pexels.com/photos/40568/medical-appointment-doctor-healthcare-40568.jpeg',
    },
    {
      'title': 'Shopping & Boutiques',
      'image':
          'https://images.pexels.com/photos/298863/pexels-photo-298863.jpeg',
    },
    {
      'title': 'Outdoor Adventures',
      'image':
          'https://images.pexels.com/photos/414171/pexels-photo-414171.jpeg',
    },
    {
      'title': 'Family & Kids Activities',
      'image':
          'https://images.pexels.com/photos/5081910/pexels-photo-5081910.jpeg',
    },
    {
      'title': 'Fitness & Sports',
      'image':
          'https://images.pexels.com/photos/841130/pexels-photo-841130.jpeg',
    },
    {
      'title': 'Local Services',
      'image':
          'https://images.pexels.com/photos/4386369/pexels-photo-4386369.jpeg',
    },
  ];

  // Dummy businesses map keyed by category title.
  // All values are List<Map<String,String>> to match CategoryPage signature.

  final Map<String, List<Map<String, dynamic>>> dummyBusinesses = {
    "Arts & Culture": [
      {
        "name": "Sunset Art Gallery",
        "image": "https://images.pexels.com/photos/21014/pexels-photo.jpg",
        "logo":
            "https://images.pexels.com/photos/936722/pexels-photo-936722.jpeg",
        "rating": "4.8",
        "address": "123 Art St, Las Vegas",
        "description": "A beautiful gallery featuring modern art collections.",
        "phone": "+1 702 123 4567",
        "website": "https://sunsetgallery.com",
        "services": ["Painting", "Sculptures", "Art Classes"],
        "coupons": [
          {"title": "10% Off Entry", "code": "ART10"},
        ],
        "reviews": [
          {"user": "Emily", "comment": "Loved the paintings!", "rating": 5},
          {
            "user": "John",
            "comment": "Great artists and vibes!",
            "rating": 4.5,
          },
        ],
      },
      {
        "name": "Creative Minds Studio",
        "image":
            "https://images.pexels.com/photos/102127/pexels-photo-102127.jpeg",
        "logo":
            "https://images.pexels.com/photos/4348403/pexels-photo-4348403.jpeg",
        "rating": "4.6",
        "address": "45 Gallery Ave",
        "description": "A studio offering creative workshops for all ages.",
        "phone": "+1 702 987 2222",
        "website": "https://creativeminds.com",
        "services": ["Workshops", "Photography", "Art Supplies"],
        "coupons": [
          {"title": "Buy 1 Workshop Get 1 Free", "code": "WORKSHOP2025"},
        ],
        "reviews": [
          {"user": "Lara", "comment": "Amazing environment!", "rating": 4.8},
        ],
      },
    ],

    "Food & Drink": [
      {
        "name": "Burger House",
        "image":
            "https://images.pexels.com/photos/163956/food-salad-healthy-vegetables.jpg",
        "logo":
            "https://images.pexels.com/photos/163956/food-salad-healthy-vegetables.jpg",
        "rating": "4.4",
        "address": "77 Flavor Road",
        "description": "Best burgers in town with homemade sauces.",
        "phone": "+1 702 111 2233",
        "website": "https://burgerhouse.com",
        "services": ["Dine-in", "Takeaway", "Delivery"],
        "coupons": [
          {"title": "Free Drink with Combo", "code": "BURGERDRINK"},
        ],
        "reviews": [
          {"user": "Sam", "comment": "Delicious burgers!", "rating": 4.7},
        ],
      },
      {
        "name": "Tasty Pizza",
        "image":
            "https://images.pexels.com/photos/2619967/pexels-photo-2619967.jpeg",
        "logo":
            "https://images.pexels.com/photos/2619967/pexels-photo-2619967.jpeg",
        "rating": "4.7",
        "address": "12 Slice Street",
        "description": "Fresh pizzas baked in wood-fired ovens.",
        "phone": "+1 702 222 8899",
        "website": "https://tastypizza.com",
        "services": ["Dine-in", "Delivery"],
        "coupons": [
          {"title": "20% Off Large Pizza", "code": "PIZZA20"},
        ],
        "reviews": [
          {"user": "Tony", "comment": "Best pizza ever!", "rating": 5},
        ],
      },
    ],

    "Health & Wellness": [
      {
        "name": "Pure Yoga Studio",
        "image":
            "https://images.pexels.com/photos/3823039/pexels-photo-3823039.jpeg",
        "logo":
            "https://images.pexels.com/photos/4056723/pexels-photo-4056723.jpeg",
        "rating": "4.9",
        "address": "88 Zen Road",
        "description": "Calming yoga studio with experienced instructors.",
        "phone": "+1 702 333 9090",
        "website": "https://pureyoga.com",
        "services": ["Yoga", "Meditation", "Wellness Coaching"],
        "coupons": [
          {"title": "Free First Session", "code": "YOGA1"},
        ],
        "reviews": [
          {"user": "Sarah", "comment": "Super relaxing!", "rating": 4.9},
        ],
      },
      {
        "name": "Healthy Life Clinic",
        "image":
            "https://images.pexels.com/photos/757880/pexels-photo-757880.jpeg",
        "logo":
            "https://images.pexels.com/photos/757880/pexels-photo-757880.jpeg",
        "rating": "4.5",
        "address": "55 Care Blvd",
        "description": "General health checkups and wellness programs.",
        "phone": "+1 702 555 1717",
        "website": "https://healthylifeclinic.com",
        "services": ["Checkups", "Therapy", "Consultations"],
        "coupons": [
          {"title": "10% Off Health Package", "code": "HEALTH10"},
        ],
        "reviews": [
          {"user": "David", "comment": "Very professional!", "rating": 4.6},
        ],
      },
    ],

    "Shopping": [
      {
        "name": "Fashion Zone",
        "image":
            "https://images.pexels.com/photos/2983464/pexels-photo-2983464.jpeg",
        "logo":
            "https://images.pexels.com/photos/2983464/pexels-photo-2983464.jpeg",
        "rating": "4.3",
        "address": "99 Trendy Mall",
        "description": "Trendy clothes and accessories for all ages.",
        "phone": "+1 702 888 4545",
        "website": "https://fashionzone.com",
        "services": ["Clothing", "Accessories", "Footwear"],
        "coupons": [
          {"title": "15% Off Clothing", "code": "FASHION15"},
        ],
        "reviews": [
          {"user": "Maria", "comment": "Great styles!", "rating": 4.4},
        ],
      },
      {
        "name": "Tech World",
        "image": "https://images.pexels.com/photos/18105/pexels-photo.jpg",
        "logo": "https://images.pexels.com/photos/18105/pexels-photo.jpg",
        "rating": "4.8",
        "address": "50 Digital Plaza",
        "description": "All kinds of electronics at the best prices.",
        "phone": "+1 702 222 9090",
        "website": "https://techworld.com",
        "services": ["Mobiles", "Laptops", "Accessories"],
        "coupons": [
          {"title": "5% Off Electronics", "code": "TECH5"},
        ],
        "reviews": [
          {"user": "Kevin", "comment": "Affordable prices!", "rating": 4.7},
        ],
      },
    ],
  };

  HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context),
            const SizedBox(height: 20),

            /// ⭐ 702FORU LOGO
            GestureDetector(
              onTap: () {
                Get.to(() => About702Page());
              },
              child: _appLogo(),
            ),

            const SizedBox(height: 18),

            // ⭐ RSS TICKER BELOW LOGO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: RSSMarquee(
                items: [
                  "Breaking News: Las Vegas traffic update.",
                  // "Weather Alert: Sunny week ahead ☀️",
                  // "702FORU: New businesses added today!",
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// ⭐ Banner below logo
            _promoBanner(),

            const SizedBox(height: 25),

            /// ⭐ Sphere Category Grid
            _sphereGrid(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // ⭐ HEADER (Time + Search + Sign In / Sign Up)
  // -----------------------------------------------------------
  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: time on left, sign-in button + notification on right
          Row(
            children: [
              const Text(
                "9:41",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Spacer(),

              // Sign In / Sign Up button — clearly visible
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple, // prominent color
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  elevation: 3,
                ),
                onPressed: () => _showAuthDialog(context),
                child: const Text(
                  'Sign In / Sign Up',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(width: 10),

              // Notification icon
              IconButton(
                onPressed: () {
                  // TODO: open notifications
                },
                icon: const Icon(Icons.notifications),
                tooltip: 'Notifications',
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: "Search...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // ⭐ Show a simple auth dialog (placeholder)
  // -----------------------------------------------------------
  void _showAuthDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Welcome to 702FORU'),
          content: const Text(
            'Choose an option to continue. (Replace with your auth flow)',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                // TODO: navigate to Sign In screen
                // Navigator.pushNamed(context, '/signin');
              },
              child: const Text('Sign In'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                // TODO: navigate to Sign Up screen
                // Navigator.pushNamed(context, '/signup');
              },
              child: const Text('Sign Up'),
            ),
          ],
        );
      },
    );
  }

  // -----------------------------------------------------------
  // ⭐ 702FORU LOGO
  // -----------------------------------------------------------
  Widget _appLogo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: AppColors.splashBackgroundColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Image.asset(
              "assets/logo.png", // your app logo
              height: 130,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // ⭐ RSS FEED AREA (simple scrolling text bar)
  // -----------------------------------------------------------
  Widget _rssFeedArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            const Icon(Icons.rss_feed, color: Colors.orange, size: 22),

            const SizedBox(width: 10),

            // Moving text
            Expanded(
              child: ClipRect(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 800),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      "Breaking News: Welcome to 702FORU • Weather: Sunny 75°F • Traffic: Smooth flow on I-15 • More updates coming soon...",
                      key: ValueKey(DateTime.now().millisecondsSinceEpoch),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // ⭐ PROMO BANNER STYLE
  // -----------------------------------------------------------
  Widget _promoBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Exclusive 702FORU Offer",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Win Gifts & Discounts",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      // TODO: banner CTA
                    },
                    child: const Text("Explore Now"),
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                "https://images.pexels.com/photos/3184407/pexels-photo-3184407.jpeg",
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.broken_image),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // ⭐ SPHERE GRID (3 in a row)
  // -----------------------------------------------------------
  Widget _sphereGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisExtent: 150,
          crossAxisSpacing: 14,
          mainAxisSpacing: 18,
        ),
        itemBuilder: (context, index) {
          final item = categories[index];

          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.7, end: 1),
            duration: Duration(milliseconds: 500 + index * 120),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: _sphereCard(context, item),
          );
        },
      ),
    );
  }

  // -----------------------------------------------------------
  // ⭐ SPHERE CARD
  // -----------------------------------------------------------
  // SPHERE CARD (navigates with dummy list)
  Widget _sphereCard(BuildContext context, Map<String, String> item) {
    return GestureDetector(
      onTap: () {
        final categoryName = item['title']!;
        final list = dummyBusinesses[categoryName] ?? [];
        print("---- CATEGORY CLICKED ----");
        print("Category: $categoryName");

        print("---- BUSINESSES IN THIS CATEGORY ----");
        print(list);
        // convert to Map<String,String> list (already is) and navigate
        Get.to(() => CategoryPage(title: categoryName, businesses: list));
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.blueAccent.withOpacity(0.7),
                  Colors.purpleAccent.withOpacity(0.6),
                  Colors.deepPurple.withOpacity(0.4),
                ],
                center: const Alignment(-0.3, -0.2),
                radius: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.25),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.network(
                item['image']!,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item['title']!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
