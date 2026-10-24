import '../../features/attractions/domain/entities/attraction.dart';
import '../../features/auth/domain/entities/app_user.dart';
import '../../features/catalog/domain/entities/business.dart';
import '../../features/catalog/domain/entities/category.dart';
import '../../features/catalog/domain/entities/coupon.dart';
import '../../features/notifications/domain/entities/app_notification.dart';
import '../../features/offers/domain/entities/offer.dart';
import '../router/app_routes.dart';
import 'hive_service.dart';

/// Populates the local database the first time the app runs (or after the seed
/// version is bumped). Until a real backend exists this is what makes the whole
/// flow browsable.
class LocalSeed {
  const LocalSeed._();

  /// Bump to force re-seeding on next launch.
  static const int version = 4;

  /// Seed rows that were removed from the catalogue. Deleting them on the next
  /// launch replaces the old list without touching anything the user created.
  static const List<String> retiredBusinessIds = [
    'strip-fountain-show',
    'springs-preserve',
  ];

  static const List<String> retiredOfferIds = ['o-food-fest'];

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
    await _seedAttractions();
    await _seedCoupons();
    await _seedOffers();
    await _seedNotifications();
    await _seedAccounts();
    await _pruneRetired();
  }

  /// Removes listings and offers that are no longer in the catalogue, plus any
  /// attraction row that has dropped out of [attractions]. User-created data is
  /// never touched.
  static Future<void> _pruneRetired() async {
    final businesses = HiveService.box(HiveBoxes.businesses);
    for (final id in retiredBusinessIds) {
      await businesses.delete(id);
    }

    final offers = HiveService.box(HiveBoxes.offers);
    for (final id in retiredOfferIds) {
      await offers.delete(id);
    }

    final attractionBox = HiveService.box(HiveBoxes.attractions);
    final activeIds = attractions.map((a) => a.id).toSet();
    for (final key in attractionBox.keys.toList()) {
      if (!activeIds.contains(key)) await attractionBox.delete(key);
    }
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
      description: 'Free gardens, landmarks and monthly events across the valley.',
      sortOrder: 11,
    ),
  ];

  // ── Free things to do ─────────────────────────────────────────────────
  /// Curated, currently-open free spots. Each one has its own detail page.
  /// Retired or closed places are deleted on the next seed (see [_pruneRetired]).
  static final List<Attraction> attractions = [
    Attraction(
      id: 'bellagio-fountains-conservatory',
      name: 'Bellagio Fountains & Conservatory',
      tagline: 'Dancing water and a free seasonal garden on the Strip.',
      description:
          'The Fountains of Bellagio perform free shows every 15–30 minutes, with '
          'the choreography changing through the day. Inside the hotel, the '
          'Conservatory & Botanical Gardens is free to walk through and is '
          'redecorated for every season.',
      imageUrl: 'https://images.pexels.com/photos/1194231/pexels-photo-1194231.jpeg',
      gallery: [
        'https://images.pexels.com/photos/1194231/pexels-photo-1194231.jpeg',
        'https://images.pexels.com/photos/1659438/pexels-photo-1659438.jpeg',
      ],
      address: '3600 S Las Vegas Blvd, Las Vegas, NV 89109',
      latitude: 36.1126,
      longitude: -115.1767,
      hoursLabel: 'Fountains every 15–30 min · Conservatory open 24 hours',
      website: 'https://www.bellagio.com/en/entertainment/fountains-of-bellagio.html',
      goodToKnow: ['Free to watch', 'Best after dark', 'Resort parking is paid'],
      sortOrder: 0,
      lastVerifiedAt: DateTime(2026, 10, 1),
    ),
    Attraction(
      id: 'fremont-street-experience',
      name: 'Fremont Street Experience',
      tagline: 'Downtown’s free light show under a giant canopy.',
      description:
          'Viva Vision is the biggest video screen in the world, and its hourly '
          'light shows are free. Three stages host free live music most nights, '
          'with bars, casinos and street performers all along the pedestrian mall.',
      imageUrl: 'https://images.pexels.com/photos/19045720/pexels-photo-19045720.jpeg',
      gallery: [
        'https://images.pexels.com/photos/19045720/pexels-photo-19045720.jpeg',
        'https://images.pexels.com/photos/164821/pexels-photo-164821.jpeg',
      ],
      address: '425 Fremont St, Las Vegas, NV 89101',
      latitude: 36.1707,
      longitude: -115.1447,
      hoursLabel: 'Light shows hourly from dusk to midnight',
      website: 'https://vegasexperience.com',
      goodToKnow: ['Free entry', 'Covered canopy', 'Busiest on weekends'],
      sortOrder: 1,
      lastVerifiedAt: DateTime(2026, 10, 1),
    ),
    Attraction(
      id: 'welcome-sign',
      name: 'Welcome to Fabulous Las Vegas Sign',
      tagline: 'The classic photo stop at the south end of the Strip.',
      description:
          'Betty Willis designed the neon sign in 1959 and it is still the most '
          'photographed spot in the city. There is a free dedicated car park '
          'behind it, and the queue moves quickly — early morning is quietest.',
      imageUrl: 'https://images.pexels.com/photos/165799/pexels-photo-165799.jpeg',
      gallery: ['https://images.pexels.com/photos/165799/pexels-photo-165799.jpeg'],
      address: '5100 S Las Vegas Blvd, Las Vegas, NV 89119',
      latitude: 36.0820,
      longitude: -115.1728,
      hoursLabel: 'Open 24 hours',
      goodToKnow: ['Free parking', 'Bring water in summer', 'Go early for shorter queues'],
      sortOrder: 2,
      lastVerifiedAt: DateTime(2026, 10, 1),
    ),
    Attraction(
      id: 'seven-magic-mountains',
      name: 'Seven Magic Mountains',
      tagline: 'Seven neon totems standing in the open desert.',
      description:
          'Ugo Rondinone’s public artwork stacks 33 locally sourced boulders into '
          'seven brightly painted columns. It is about 25 miles south of the '
          'Strip, free to visit and best photographed at sunrise or sunset.',
      imageUrl: 'https://images.pexels.com/photos/8314277/pexels-photo-8314277.jpeg',
      gallery: ['https://images.pexels.com/photos/8314277/pexels-photo-8314277.jpeg'],
      address: 'S Las Vegas Blvd, Jean, NV 89019',
      latitude: 35.8397,
      longitude: -115.2711,
      hoursLabel: 'Open daily, sunrise to sunset',
      website: 'https://sevenmagicmountains.com',
      goodToKnow: ['Free entry', 'No shade or water', '20–30 min drive from the Strip'],
      sortOrder: 3,
      lastVerifiedAt: DateTime(2026, 10, 1),
    ),
    Attraction(
      id: 'ethel-m-cactus-garden',
      name: 'Ethel M Botanical Cactus Garden',
      tagline: 'A free desert garden in Henderson.',
      description:
          'More than 300 species of cactus and desert plants fill this free '
          'self-guided garden beside the Ethel M chocolate factory. In winter the '
          'whole garden is covered in holiday lights.',
      imageUrl: 'https://images.pexels.com/photos/414171/pexels-photo-414171.jpeg',
      gallery: ['https://images.pexels.com/photos/414171/pexels-photo-414171.jpeg'],
      address: '2 Cactus Garden Dr, Henderson, NV 89014',
      latitude: 36.0453,
      longitude: -115.0553,
      hoursLabel: 'Daily 8:30am–8pm (seasonal)',
      website: 'https://www.ethelm.com',
      goodToKnow: ['Free entry', 'Shaded paths', 'Holiday lights in winter'],
      sortOrder: 4,
      lastVerifiedAt: DateTime(2026, 10, 1),
    ),
    Attraction(
      id: 'clark-county-wetlands-park',
      name: 'Clark County Wetlands Park',
      tagline: 'Trails, ponds and wildlife minutes from the city.',
      description:
          'Nearly 3,000 acres of ponds, trails and bird habitat along the Las '
          'Vegas Wash. Entry to the park, the trails and the nature centre is '
          'free — bring water and go early in the warmer months.',
      imageUrl: 'https://images.pexels.com/photos/17315260/pexels-photo-17315260.jpeg',
      gallery: ['https://images.pexels.com/photos/17315260/pexels-photo-17315260.jpeg'],
      address: '7050 Wetlands Park Ln, Las Vegas, NV 89122',
      latitude: 36.1017,
      longitude: -114.9995,
      hoursLabel: 'Trails daily 6am–dusk · Nature Center 9am–3pm',
      website: 'https://www.clarkcountynv.gov/government/departments/parks_recreation/wetlands_park.php',
      goodToKnow: ['Free parking', 'Paved and dirt trails', 'Bring binoculars'],
      sortOrder: 5,
      lastVerifiedAt: DateTime(2026, 10, 1),
    ),
    Attraction(
      id: 'downtown-container-park',
      name: 'Downtown Container Park',
      tagline: 'Shops, a playground and a giant mantis — free entry.',
      description:
          'A shopping and dining courtyard built from shipping containers, with '
          'a free play area, a 30-foot praying mantis that shoots flames at '
          'night, and regular free live music on the lawn.',
      imageUrl: 'https://images.pexels.com/photos/1190298/pexels-photo-1190298.jpeg',
      gallery: ['https://images.pexels.com/photos/1190298/pexels-photo-1190298.jpeg'],
      address: '707 Fremont St, Las Vegas, NV 89101',
      latitude: 36.1692,
      longitude: -115.1398,
      hoursLabel: 'Mon–Thu 11am–9pm · Fri–Sun 11am–10pm',
      website: 'https://downtowncontainerpark.com',
      goodToKnow: ['Free entry', 'Kids’ play area', '21+ after 9pm'],
      sortOrder: 6,
      lastVerifiedAt: DateTime(2026, 10, 1),
    ),
    Attraction(
      id: 'first-friday-arts-district',
      name: 'First Friday Arts District',
      tagline: 'A free monthly street festival for local art and food.',
      description:
          'On the first Friday of every month the 18b Arts District fills with '
          'open galleries, food trucks, makers and live music. Entry is free; '
          'many galleries stay open late and parking is limited, so rideshare is '
          'easier.',
      imageUrl: 'https://images.pexels.com/photos/3004909/pexels-photo-3004909.jpeg',
      gallery: ['https://images.pexels.com/photos/3004909/pexels-photo-3004909.jpeg'],
      address: '1025 S 1st St, Las Vegas, NV 89101',
      latitude: 36.1586,
      longitude: -115.1484,
      hoursLabel: 'First Friday of each month, 5pm–11pm',
      website: 'https://firstfridaylv.org',
      goodToKnow: ['Free entry', 'Monthly only', 'Food and drink for purchase'],
      sortOrder: 7,
      lastVerifiedAt: DateTime(2026, 10, 1),
    ),
  ];

  // ── Businesses ─────────────────────────────────────────────────────────
  /// Where each demo listing actually is in the valley.
  ///
  /// Without this every business shared the city-centre default, so every
  /// listing page showed the same "0.1 mi from the Strip" map label. A map of
  /// the valley with one pin is indistinguishable from placeholder data.
  static const Map<String, (double, double)> _locations = {
    'sunset-art-gallery': (36.1553, -115.1480),
    'creative-minds-studio': (36.1260, -115.1700),
    'burger-house': (36.1147, -115.1720),
    'tasty-pizza': (36.1450, -115.1570),
    'neon-lounge': (36.1020, -115.1740),
    'golden-stage': (36.1210, -115.1690),
    'pure-yoga-studio': (36.1700, -115.3100),
    'healthy-life-clinic': (36.0910, -115.1900),
    'fashion-zone': (36.0900, -115.1780),
    'tech-world': (36.1480, -115.3340),
    'red-rock-tours': (36.1350, -115.4300),
    'lake-mead-kayaks': (36.0170, -114.8000),
    'adventure-playhouse': (36.0740, -115.2900),
    'little-chefs-lab': (36.1360, -115.2200),
    'ironpeak-gym': (36.0650, -115.2400),
    'court-side-club': (36.1080, -115.3200),
    'swiftfix-handyman': (36.1699, -115.1398),
    'bright-clean-co': (36.1900, -115.2400),
    'skyline-heli-tours': (35.9980, -115.0700),
    'desert-stargazing': (36.3000, -115.5000),
    'glow-salon': (36.1400, -115.1800),
    'handy-home-help': (36.1600, -115.2000),
  };

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
      double? lat,
      double? lng,
      String? owner,
    }) {
      final location = _locations[id];
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
        latitude: lat ?? location?.$1 ?? 36.1699,
        longitude: lng ?? location?.$2 ?? -115.1398,
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
        sponsored: true,
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
        sponsored: true,
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
        sponsored: true,
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
  /// Every seeded offer, in display order. Exposed so tests can assert that no
  /// offer ships without a working destination.
  static List<Offer> offers() {
    final expiry = DateTime.now().add(const Duration(days: 30));
    return [
      Offer(
        id: 'o-win-gifts',
        title: 'Win Gifts & Discounts',
        subtitle: 'Join free and enter the monthly draw',
        imageUrl: 'https://images.pexels.com/photos/3184407/pexels-photo-3184407.jpeg',
        ctaLabel: 'Join free',
        route: AppRoutes.signUpUser,
        expiresAt: expiry,
      ),
      Offer(
        id: 'o-spotlight',
        title: 'Spotlight Your Business',
        subtitle: 'Reach thousands of Vegas locals',
        imageUrl: 'https://images.pexels.com/photos/3184291/pexels-photo-3184291.jpeg',
        ctaLabel: 'Learn More',
        route: AppRoutes.spotlightInfo,
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
        id: 'o-featured-vegas',
        title: 'Skyline Heli Tours',
        subtitle: '15% off Strip tours this month',
        imageUrl: 'https://images.pexels.com/photos/1190298/pexels-photo-1190298.jpeg',
        ctaLabel: 'View details',
        businessId: 'skyline-heli-tours',
        isFeatured: true,
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

  static Future<void> _seedAttractions() async {
    final box = HiveService.box(HiveBoxes.attractions);
    for (final attraction in attractions) {
      await box.put(attraction.id, attraction.toMap());
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
    for (final offer in offers()) {
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
