import '../../features/auth/domain/entities/app_user.dart';
import '../../features/catalog/domain/entities/business.dart';
import '../../features/catalog/domain/entities/category.dart';
import '../../features/catalog/domain/entities/coupon.dart';
import '../../features/notifications/domain/entities/app_notification.dart';
import '../../features/offers/domain/entities/offer.dart';
import 'hive_service.dart';

/// Populates the local database the first time the app runs (or after the seed
/// version is bumped). Until a real backend exists this is what makes the whole
/// flow browsable.
class LocalSeed {
  const LocalSeed._();

  /// Bump to force re-seeding on next launch.
  static const int version = 1;

  /// Credentials for the demo accounts shown on the login screen.
  static const String demoUserEmail = 'demo@702foru.com';
  static const String demoUserPassword = 'demo123';
  static const String demoProviderEmail = 'provider@702foru.com';
  static const String demoProviderPassword = 'demo123';

  static Future<void> runIfNeeded() async {
    final box = HiveService.session;
    final seeded = box.get(HiveKeys.seedVersion);
    if (seeded is int && seeded >= version) return;
    await _seed();
    await box.put(HiveKeys.seedVersion, version);
  }

  static Future<void> _seed() async {
    await _seedCategories();
    await _seedBusinesses();
    await _seedCoupons();
    await _seedOffers();
    await _seedNotifications();
    await _seedAccounts();
  }

  // ── Categories ─────────────────────────────────────────────────────────
  static const List<Category> categories = [
    Category(
      id: 'arts-culture',
      name: 'Arts & Culture',
      imageUrl: 'https://images.pexels.com/photos/1674049/pexels-photo-1674049.jpeg',
      description: 'Galleries, museums, street art and live performance.',
      sortOrder: 0,
      isFeatured: true,
    ),
    Category(
      id: 'food-drink',
      name: 'Food & Drink',
      imageUrl: 'https://images.pexels.com/photos/315755/pexels-photo-315755.jpeg',
      description: 'Restaurants, cafés, bars and late-night bites.',
      sortOrder: 1,
      isFeatured: true,
    ),
    Category(
      id: 'nightlife-entertainment',
      name: 'Nightlife & Entertainment',
      imageUrl: 'https://images.pexels.com/photos/164821/pexels-photo-164821.jpeg',
      description: 'Clubs, shows, lounges and live music.',
      sortOrder: 2,
    ),
    Category(
      id: 'health-wellness',
      name: 'Health & Wellness',
      imageUrl: 'https://images.pexels.com/photos/3823039/pexels-photo-3823039.jpeg',
      description: 'Spas, clinics, therapy and self-care.',
      sortOrder: 3,
    ),
    Category(
      id: 'shopping-boutiques',
      name: 'Shopping & Boutiques',
      imageUrl: 'https://images.pexels.com/photos/298863/pexels-photo-298863.jpeg',
      description: 'Local boutiques, malls and specialty shops.',
      sortOrder: 4,
    ),
    Category(
      id: 'outdoor-adventures',
      name: 'Outdoor Adventures',
      imageUrl: 'https://images.pexels.com/photos/414171/pexels-photo-414171.jpeg',
      description: 'Hikes, desert tours, kayaking and day trips.',
      sortOrder: 5,
    ),
    Category(
      id: 'family-kids',
      name: 'Family & Kids Activities',
      imageUrl: 'https://images.pexels.com/photos/5081910/pexels-photo-5081910.jpeg',
      description: 'Everything the whole family can enjoy.',
      sortOrder: 6,
    ),
    Category(
      id: 'fitness-sports',
      name: 'Fitness & Sports',
      imageUrl: 'https://images.pexels.com/photos/841130/pexels-photo-841130.jpeg',
      description: 'Gyms, studios, courts and coaching.',
      sortOrder: 7,
    ),
    Category(
      id: 'local-services',
      name: 'Local Services',
      imageUrl: 'https://images.pexels.com/photos/4386369/pexels-photo-4386369.jpeg',
      description: 'Trusted everyday professionals near you.',
      sortOrder: 8,
    ),
    Category(
      id: 'unique-experiences',
      name: 'Unique Experiences',
      imageUrl: 'https://images.pexels.com/photos/1190298/pexels-photo-1190298.jpeg',
      description: 'Only-in-Vegas moments worth remembering.',
      sortOrder: 9,
    ),
    Category(
      id: 'home-personal-services',
      name: 'Home & Personal Services',
      imageUrl: 'https://images.pexels.com/photos/3768916/pexels-photo-3768916.jpeg',
      description: 'Handymen, cleaners, salons and more.',
      sortOrder: 10,
    ),
    Category(
      id: 'free-things-to-do',
      name: 'Free Things To Do',
      imageUrl: 'https://images.pexels.com/photos/1194231/pexels-photo-1194231.jpeg',
      description: 'Curated free events and spots across the valley.',
      sortOrder: 11,
    ),
  ];

  // ── Businesses ─────────────────────────────────────────────────────────
  static List<Business> _businesses() {
    final now = DateTime.now();
    Business b({
      required String id,
      required String name,
      required String category,
      required String cover,
      required String logo,
      required double rating,
      required int reviews,
      required String address,
      required String description,
      required String phone,
      required String website,
      required List<String> services,
      List<String> gallery = const [],
      bool sponsored = false,
      double lat = 36.1699,
      double lng = -115.1398,
      String? owner,
    }) {
      return Business(
        id: id,
        name: name,
        categoryId: category,
        coverUrl: cover,
        logoUrl: logo,
        rating: rating,
        reviewCount: reviews,
        address: address,
        description: description,
        phone: phone,
        website: website,
        services: services,
        gallery: gallery.isEmpty ? [cover] : gallery,
        isSponsored: sponsored,
        trackingCode: '702-4U-${id.toUpperCase().replaceAll('-', '').substring(0, 4)}',
        latitude: lat,
        longitude: lng,
        ownerId: owner,
        createdAt: now.subtract(const Duration(days: 120)),
      );
    }

    return [
      // Arts & Culture
      b(
        id: 'sunset-art-gallery',
        name: 'Sunset Art Gallery',
        category: 'arts-culture',
        cover: 'https://images.pexels.com/photos/1674049/pexels-photo-1674049.jpeg',
        logo: 'https://images.pexels.com/photos/2372978/pexels-photo-2372978.jpeg',
        rating: 4.8,
        reviews: 214,
        address: '123 Art St, Las Vegas, NV',
        description:
            'A beautiful gallery featuring modern and contemporary collections from local and international artists.',
        phone: '+1 702 123 4567',
        website: 'https://sunsetgallery.com',
        services: ['Exhibitions', 'Guided Tours', 'Art Classes'],
        gallery: [
          'https://images.pexels.com/photos/1674049/pexels-photo-1674049.jpeg',
          'https://images.pexels.com/photos/3004909/pexels-photo-3004909.jpeg',
        ],
        sponsored: true,
      ),
      b(
        id: 'creative-minds-studio',
        name: 'Creative Minds Studio',
        category: 'arts-culture',
        cover: 'https://images.pexels.com/photos/102127/pexels-photo-102127.jpeg',
        logo: 'https://images.pexels.com/photos/4348403/pexels-photo-4348403.jpeg',
        rating: 4.6,
        reviews: 98,
        address: '45 Gallery Ave, Las Vegas, NV',
        description: 'Creative workshops, photography and art supplies for all ages.',
        phone: '+1 702 987 2222',
        website: 'https://creativeminds.com',
        services: ['Workshops', 'Photography', 'Art Supplies'],
      ),
      // Food & Drink
      b(
        id: 'burger-house',
        name: 'Burger House',
        category: 'food-drink',
        cover: 'https://images.pexels.com/photos/1639557/pexels-photo-1639557.jpeg',
        logo: 'https://images.pexels.com/photos/1639557/pexels-photo-1639557.jpeg',
        rating: 4.4,
        reviews: 512,
        address: '77 Flavor Road, Las Vegas, NV',
        description: 'The best burgers in town, with homemade sauces and fresh-baked buns.',
        phone: '+1 702 111 2233',
        website: 'https://burgerhouse.com',
        services: ['Dine-in', 'Takeaway', 'Delivery'],
        sponsored: true,
      ),
      b(
        id: 'tasty-pizza',
        name: 'Tasty Pizza',
        category: 'food-drink',
        cover: 'https://images.pexels.com/photos/2619967/pexels-photo-2619967.jpeg',
        logo: 'https://images.pexels.com/photos/2619967/pexels-photo-2619967.jpeg',
        rating: 4.7,
        reviews: 331,
        address: '12 Slice Street, Las Vegas, NV',
        description: 'Wood-fired pizzas made with imported Italian flour.',
        phone: '+1 702 222 8899',
        website: 'https://tastypizza.com',
        services: ['Dine-in', 'Delivery'],
      ),
      // Nightlife
      b(
        id: 'neon-lounge',
        name: 'Neon Lounge',
        category: 'nightlife-entertainment',
        cover: 'https://images.pexels.com/photos/164821/pexels-photo-164821.jpeg',
        logo: 'https://images.pexels.com/photos/164821/pexels-photo-164821.jpeg',
        rating: 4.5,
        reviews: 640,
        address: '88 Strip Blvd, Las Vegas, NV',
        description: 'Craft cocktails, resident DJs and a rooftop view of the Strip.',
        phone: '+1 702 555 0101',
        website: 'https://neonlounge.com',
        services: ['Cocktails', 'Live DJ', 'Rooftop'],
      ),
      b(
        id: 'golden-stage',
        name: 'Golden Stage Theatre',
        category: 'nightlife-entertainment',
        cover: 'https://images.pexels.com/photos/167491/pexels-photo-167491.jpeg',
        logo: 'https://images.pexels.com/photos/167491/pexels-photo-167491.jpeg',
        rating: 4.9,
        reviews: 421,
        address: '9 Showtime Way, Las Vegas, NV',
        description: 'Nightly resident shows, comedy and live music.',
        phone: '+1 702 555 0202',
        website: 'https://goldenstage.com',
        services: ['Live Shows', 'Comedy', 'Group Bookings'],
      ),
      // Health & Wellness
      b(
        id: 'pure-yoga-studio',
        name: 'Pure Yoga Studio',
        category: 'health-wellness',
        cover: 'https://images.pexels.com/photos/3823039/pexels-photo-3823039.jpeg',
        logo: 'https://images.pexels.com/photos/3823039/pexels-photo-3823039.jpeg',
        rating: 4.9,
        reviews: 187,
        address: '88 Zen Road, Las Vegas, NV',
        description: 'Calming studio with certified instructors for every level.',
        phone: '+1 702 333 9090',
        website: 'https://pureyoga.com',
        services: ['Yoga', 'Meditation', 'Wellness Coaching'],
      ),
      b(
        id: 'healthy-life-clinic',
        name: 'Healthy Life Clinic',
        category: 'health-wellness',
        cover: 'https://images.pexels.com/photos/757880/pexels-photo-757880.jpeg',
        logo: 'https://images.pexels.com/photos/757880/pexels-photo-757880.jpeg',
        rating: 4.5,
        reviews: 143,
        address: '55 Care Blvd, Las Vegas, NV',
        description: 'General check-ups, therapy and personalised wellness programmes.',
        phone: '+1 702 555 1717',
        website: 'https://healthylifeclinic.com',
        services: ['Check-ups', 'Therapy', 'Consultations'],
      ),
      // Shopping
      b(
        id: 'fashion-zone',
        name: 'Fashion Zone',
        category: 'shopping-boutiques',
        cover: 'https://images.pexels.com/photos/298863/pexels-photo-298863.jpeg',
        logo: 'https://images.pexels.com/photos/298863/pexels-photo-298863.jpeg',
        rating: 4.3,
        reviews: 276,
        address: '99 Trendy Mall, Las Vegas, NV',
        description: 'Trendy clothing and accessories for every season.',
        phone: '+1 702 888 4545',
        website: 'https://fashionzone.com',
        services: ['Clothing', 'Accessories', 'Footwear'],
      ),
      b(
        id: 'tech-world',
        name: 'Tech World',
        category: 'shopping-boutiques',
        cover: 'https://images.pexels.com/photos/18105/pexels-photo.jpg',
        logo: 'https://images.pexels.com/photos/18105/pexels-photo.jpg',
        rating: 4.8,
        reviews: 389,
        address: '50 Digital Plaza, Las Vegas, NV',
        description: 'Electronics, repairs and accessories at fair prices.',
        phone: '+1 702 222 9090',
        website: 'https://techworld.com',
        services: ['Mobiles', 'Laptops', 'Repairs'],
      ),
      // Outdoor
      b(
        id: 'red-rock-tours',
        name: 'Red Rock Tours',
        category: 'outdoor-adventures',
        cover: 'https://images.pexels.com/photos/414171/pexels-photo-414171.jpeg',
        logo: 'https://images.pexels.com/photos/414171/pexels-photo-414171.jpeg',
        rating: 4.7,
        reviews: 205,
        address: '1 Canyon Drive, Las Vegas, NV',
        description: 'Guided hikes, sunset tours and desert photography trips.',
        phone: '+1 702 444 1212',
        website: 'https://redrocktours.com',
        services: ['Guided Hikes', 'Sunset Tours', 'Equipment Rental'],
      ),
      b(
        id: 'lake-mead-kayaks',
        name: 'Lake Mead Kayaks',
        category: 'outdoor-adventures',
        cover: 'https://images.pexels.com/photos/1170979/pexels-photo-1170979.jpeg',
        logo: 'https://images.pexels.com/photos/1170979/pexels-photo-1170979.jpeg',
        rating: 4.6,
        reviews: 118,
        address: '220 Lakeshore Rd, Boulder City, NV',
        description: 'Kayak and paddleboard hire with guided canyon routes.',
        phone: '+1 702 444 3434',
        website: 'https://lakemeadkayaks.com',
        services: ['Kayak Hire', 'Paddleboard', 'Guided Trips'],
      ),
      // Family & Kids
      b(
        id: 'adventure-playhouse',
        name: 'Adventure Playhouse',
        category: 'family-kids',
        cover: 'https://images.pexels.com/photos/5081910/pexels-photo-5081910.jpeg',
        logo: 'https://images.pexels.com/photos/5081910/pexels-photo-5081910.jpeg',
        rating: 4.5,
        reviews: 233,
        address: '310 Fun Street, Las Vegas, NV',
        description: 'Indoor soft play, climbing walls and birthday party packages.',
        phone: '+1 702 666 7878',
        website: 'https://adventureplayhouse.com',
        services: ['Soft Play', 'Climbing', 'Birthday Parties'],
      ),
      b(
        id: 'little-chefs-lab',
        name: 'Little Chefs Lab',
        category: 'family-kids',
        cover: 'https://images.pexels.com/photos/4056777/pexels-photo-4056777.jpeg',
        logo: 'https://images.pexels.com/photos/4056777/pexels-photo-4056777.jpeg',
        rating: 4.8,
        reviews: 87,
        address: '14 Bake Lane, Las Vegas, NV',
        description: 'Hands-on cooking classes designed for kids aged 5–12.',
        phone: '+1 702 666 1212',
        website: 'https://littlechefslab.com',
        services: ['Kids Classes', 'Camps', 'Party Events'],
      ),
      // Fitness & Sports
      b(
        id: 'ironpeak-gym',
        name: 'IronPeak Gym',
        category: 'fitness-sports',
        cover: 'https://images.pexels.com/photos/841130/pexels-photo-841130.jpeg',
        logo: 'https://images.pexels.com/photos/841130/pexels-photo-841130.jpeg',
        rating: 4.6,
        reviews: 421,
        address: '78 Strength Ave, Las Vegas, NV',
        description: '24/7 gym with free weights, classes and personal coaching.',
        phone: '+1 702 777 2323',
        website: 'https://ironpeakgym.com',
        services: ['Gym Access', 'Classes', 'Personal Training'],
      ),
      b(
        id: 'court-side-club',
        name: 'Court Side Club',
        category: 'fitness-sports',
        cover: 'https://images.pexels.com/photos/2277981/pexels-photo-2277981.jpeg',
        logo: 'https://images.pexels.com/photos/2277981/pexels-photo-2277981.jpeg',
        rating: 4.4,
        reviews: 164,
        address: '5 Baseline Court, Las Vegas, NV',
        description: 'Indoor courts for tennis, padel and pickleball by the hour.',
        phone: '+1 702 777 4545',
        website: 'https://courtsideclub.com',
        services: ['Tennis', 'Padel', 'Pickleball'],
      ),
      // Local Services
      b(
        id: 'swiftfix-handyman',
        name: 'SwiftFix Handyman',
        category: 'local-services',
        cover: 'https://images.pexels.com/photos/4386369/pexels-photo-4386369.jpeg',
        logo: 'https://images.pexels.com/photos/4386369/pexels-photo-4386369.jpeg',
        rating: 4.7,
        reviews: 302,
        address: 'Serving Greater Las Vegas, NV',
        description: 'Same-day repairs, installations and small renovations.',
        phone: '+1 702 909 1010',
        website: 'https://swiftfix.com',
        services: ['Repairs', 'Installations', 'Assembly'],
      ),
      b(
        id: 'bright-clean-co',
        name: 'Bright & Clean Co.',
        category: 'local-services',
        cover: 'https://images.pexels.com/photos/4239146/pexels-photo-4239146.jpeg',
        logo: 'https://images.pexels.com/photos/4239146/pexels-photo-4239146.jpeg',
        rating: 4.5,
        reviews: 128,
        address: 'Serving Greater Las Vegas, NV',
        description: 'Residential and commercial cleaning with eco-friendly products.',
        phone: '+1 702 909 2020',
        website: 'https://brightcleanco.com',
        services: ['Home Cleaning', 'Office Cleaning', 'Move-out'],
      ),
      // Unique Experiences
      b(
        id: 'skyline-heli-tours',
        name: 'Skyline Heli Tours',
        category: 'unique-experiences',
        cover: 'https://images.pexels.com/photos/1190298/pexels-photo-1190298.jpeg',
        logo: 'https://images.pexels.com/photos/1190298/pexels-photo-1190298.jpeg',
        rating: 4.9,
        reviews: 512,
        address: 'Henderson Executive Airport, NV',
        description: 'Helicopter tours over the Strip and the Grand Canyon.',
        phone: '+1 702 123 9999',
        website: 'https://skylineheli.com',
        services: ['Strip Tour', 'Canyon Tour', 'Private Charter'],
        sponsored: true,
      ),
      b(
        id: 'desert-stargazing',
        name: 'Desert Stargazing Nights',
        category: 'unique-experiences',
        cover: 'https://images.pexels.com/photos/1252890/pexels-photo-1252890.jpeg',
        logo: 'https://images.pexels.com/photos/1252890/pexels-photo-1252890.jpeg',
        rating: 4.8,
        reviews: 76,
        address: 'Mojave Desert, NV',
        description: 'Small-group telescope sessions under the desert sky.',
        phone: '+1 702 123 7373',
        website: 'https://desertstargazing.com',
        services: ['Stargazing', 'Astrophotography', 'Private Events'],
      ),
      // Home & Personal
      b(
        id: 'glow-salon',
        name: 'Glow Salon & Spa',
        category: 'home-personal-services',
        cover: 'https://images.pexels.com/photos/3768916/pexels-photo-3768916.jpeg',
        logo: 'https://images.pexels.com/photos/3768916/pexels-photo-3768916.jpeg',
        rating: 4.7,
        reviews: 351,
        address: '22 Beauty Lane, Las Vegas, NV',
        description: 'Hair, nails, facials and massage in one calm space.',
        phone: '+1 702 321 4321',
        website: 'https://glowsalon.com',
        services: ['Hair', 'Nails', 'Massage'],
      ),
      b(
        id: 'handy-home-help',
        name: 'Handy Home Help',
        category: 'home-personal-services',
        cover: 'https://images.pexels.com/photos/6195122/pexels-photo-6195122.jpeg',
        logo: 'https://images.pexels.com/photos/6195122/pexels-photo-6195122.jpeg',
        rating: 4.4,
        reviews: 92,
        address: 'Serving Greater Las Vegas, NV',
        description: 'Weekly home help, errands and personal assistance.',
        phone: '+1 702 321 8765',
        website: 'https://handyhomehelp.com',
        services: ['Errands', 'Home Help', 'Personal Assistant'],
      ),
      // Free things to do
      b(
        id: 'strip-fountain-show',
        name: 'Free Strip Fountain Show',
        category: 'free-things-to-do',
        cover: 'https://images.pexels.com/photos/1194231/pexels-photo-1194231.jpeg',
        logo: 'https://images.pexels.com/photos/1194231/pexels-photo-1194231.jpeg',
        rating: 4.9,
        reviews: 1024,
        address: 'Las Vegas Strip, NV',
        description: 'Nightly fountain show – completely free, every 30 minutes.',
        phone: '+1 702 000 0000',
        website: 'https://702foru.com/free/fountain-show',
        services: ['Free Entry', 'Nightly Shows'],
      ),
      b(
        id: 'springs-preserve',
        name: 'Springs Preserve Trails',
        category: 'free-things-to-do',
        cover: 'https://images.pexels.com/photos/1659438/pexels-photo-1659438.jpeg',
        logo: 'https://images.pexels.com/photos/1659438/pexels-photo-1659438.jpeg',
        rating: 4.6,
        reviews: 268,
        address: '333 S Valley View Blvd, Las Vegas, NV',
        description: 'Free garden and trail access on select community days.',
        phone: '+1 702 822 7700',
        website: 'https://springspreserve.org',
        services: ['Free Trails', 'Gardens', 'Family Friendly'],
      ),
    ];
  }

  // ── Coupons ────────────────────────────────────────────────────────────
  static List<Coupon> _coupons() {
    final expiry = DateTime.now().add(const Duration(days: 45));
    return [
      Coupon(
        id: 'c-sunset-10',
        businessId: 'sunset-art-gallery',
        title: '10% off gallery entry',
        code: 'ART10',
        description: 'Show this code at the front desk.',
        discountPercent: 10,
        redemptionCount: 128,
        expiresAt: expiry,
      ),
      Coupon(
        id: 'c-creative-bogo',
        businessId: 'creative-minds-studio',
        title: 'Buy 1 workshop, get 1 free',
        code: 'WORKSHOP2026',
        description: 'Applies to weekend workshops only.',
        discountPercent: 50,
        redemptionCount: 64,
        expiresAt: expiry,
      ),
      Coupon(
        id: 'c-burger-drink',
        businessId: 'burger-house',
        title: 'Free drink with any combo',
        code: 'BURGERDRINK',
        description: 'One per table.',
        discountPercent: 0,
        redemptionCount: 412,
        expiresAt: expiry,
      ),
      Coupon(
        id: 'c-pizza-20',
        businessId: 'tasty-pizza',
        title: '20% off large pizzas',
        code: 'PIZZA20',
        description: 'Excludes delivery fees.',
        discountPercent: 20,
        redemptionCount: 233,
        expiresAt: expiry,
      ),
      Coupon(
        id: 'c-yoga-free',
        businessId: 'pure-yoga-studio',
        title: 'First session free',
        code: 'YOGA1',
        description: 'New students only.',
        discountPercent: 100,
        redemptionCount: 88,
        expiresAt: expiry,
      ),
      Coupon(
        id: 'c-heli-15',
        businessId: 'skyline-heli-tours',
        title: '15% off Strip helicopter tour',
        code: 'SKY15',
        description: 'Book at least 24 hours in advance.',
        discountPercent: 15,
        redemptionCount: 57,
        expiresAt: expiry,
      ),
    ];
  }

  // ── Offers ─────────────────────────────────────────────────────────────
  static List<Offer> _offers() {
    final expiry = DateTime.now().add(const Duration(days: 30));
    return [
      Offer(
        id: 'o-win-gifts',
        title: 'Win Gifts & Discounts',
        subtitle: 'Exclusive 702FORU Offer',
        imageUrl: 'https://images.pexels.com/photos/3184407/pexels-photo-3184407.jpeg',
        ctaLabel: 'Explore Now',
        expiresAt: expiry,
      ),
      Offer(
        id: 'o-spotlight',
        title: 'Spotlight Your Business',
        subtitle: 'Reach thousands of Vegas locals',
        imageUrl: 'https://images.pexels.com/photos/3184291/pexels-photo-3184291.jpeg',
        ctaLabel: 'Learn More',
        expiresAt: expiry,
      ),
      Offer(
        id: 'o-free-week',
        title: 'Free Things To Do Week',
        subtitle: 'Curated free events across the valley',
        imageUrl: 'https://images.pexels.com/photos/1194231/pexels-photo-1194231.jpeg',
        ctaLabel: 'Explore Now',
        categoryId: 'free-things-to-do',
        expiresAt: expiry,
      ),
      Offer(
        id: 'o-food-fest',
        title: 'Vegas Food Fest',
        subtitle: 'Up to 25% off at participating restaurants',
        imageUrl: 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg',
        ctaLabel: 'Explore Now',
        categoryId: 'food-drink',
        expiresAt: expiry,
      ),
      Offer(
        id: 'o-heli',
        title: 'Skyline Heli Tours',
        subtitle: '15% off Strip tours this month',
        imageUrl: 'https://images.pexels.com/photos/1190298/pexels-photo-1190298.jpeg',
        ctaLabel: 'Claim Offer',
        businessId: 'skyline-heli-tours',
        expiresAt: expiry,
      ),
    ];
  }

  // ── Notifications ──────────────────────────────────────────────────────
  static List<AppNotification> _notifications() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'n-welcome',
        title: 'Welcome to 702FORU',
        body: 'Your Vegas, ready. Explore 12 categories of things to do.',
        type: NotificationType.system,
        createdAt: now.subtract(const Duration(minutes: 12)),
      ),
      AppNotification(
        id: 'n-offer-heli',
        title: 'New offer: Skyline Heli Tours',
        body: '15% off Strip helicopter tours for the next 30 days.',
        type: NotificationType.offer,
        offerId: 'o-heli',
        businessId: 'skyline-heli-tours',
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      AppNotification(
        id: 'n-coupon-burger',
        title: 'Coupon unlocked',
        body: 'Free drink with any combo at Burger House.',
        type: NotificationType.coupon,
        businessId: 'burger-house',
        createdAt: now.subtract(const Duration(hours: 20)),
        isRead: true,
      ),
      AppNotification(
        id: 'n-review-reply',
        title: 'Pure Yoga Studio replied',
        body: 'Thanks for visiting — your first class is on us next time!',
        type: NotificationType.review,
        businessId: 'pure-yoga-studio',
        createdAt: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
      AppNotification(
        id: 'n-new-business',
        title: 'New in Food & Drink',
        body: 'Tasty Pizza just joined 702FORU. Take a look.',
        type: NotificationType.business,
        businessId: 'tasty-pizza',
        createdAt: now.subtract(const Duration(days: 4)),
        isRead: true,
      ),
    ];
  }

  // ── Demo accounts ──────────────────────────────────────────────────────
  static Future<void> _seedAccounts() async {
    final users = HiveService.box(HiveBoxes.users);
    final now = DateTime.now();

    final demoProvider = AppUser(
      id: 'u-provider-demo',
      fullName: 'Josie S. (Demo Business)',
      email: demoProviderEmail,
      phone: '+1 702 555 0100',
      role: UserRole.provider,
      businessId: 'sunset-art-gallery',
      passwordHash: AppUser.encodePassword(demoProviderPassword),
      marketingOptIn: true,
      createdAt: now.subtract(const Duration(days: 60)),
    );

    final demoUser = AppUser(
      id: 'u-visitor-demo',
      fullName: 'Demo Visitor',
      email: demoUserEmail,
      phone: '+1 702 555 0199',
      role: UserRole.user,
      passwordHash: AppUser.encodePassword(demoUserPassword),
      marketingOptIn: false,
      createdAt: now.subtract(const Duration(days: 30)),
    );

    for (final user in [demoProvider, demoUser]) {
      await users.put(user.id, user.toMap());
    }
  }

  static Future<void> _seedCategories() async {
    final box = HiveService.box(HiveBoxes.categories);
    for (final category in categories) {
      await box.put(category.id, category.toMap());
    }
  }

  static Future<void> _seedBusinesses() async {
    final box = HiveService.box(HiveBoxes.businesses);
    for (final business in _businesses()) {
      await box.put(business.id, business.toMap());
    }
  }

  static Future<void> _seedCoupons() async {
    final box = HiveService.box(HiveBoxes.coupons);
    for (final coupon in _coupons()) {
      await box.put(coupon.id, coupon.toMap());
    }
  }

  static Future<void> _seedOffers() async {
    final box = HiveService.box(HiveBoxes.offers);
    for (final offer in _offers()) {
      await box.put(offer.id, offer.toMap());
    }
  }

  static Future<void> _seedNotifications() async {
    final box = HiveService.box(HiveBoxes.notifications);
    for (final notification in _notifications()) {
      await box.put(notification.id, notification.toMap());
    }
  }
}
