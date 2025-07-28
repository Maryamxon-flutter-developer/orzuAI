import 'package:flutter/material.dart';
import 'dart:async';
import 'package:orzulab/login_page.dart';
import 'package:orzulab/pages/support_page.dart';

void main() {
  runApp(OrzuLabApp());
}

class OrzuLabApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orzu Lab AI',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        fontFamily: 'Roboto',
      ),
      home: OrzuLabHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CarouselItem {
  final String mainImage;
  final String leftImage;
  final String rightImage;
  final String title;
  final String subtitle;

  const CarouselItem({
    required this.mainImage,
    required this.leftImage,
    required this.rightImage,
    required this.title,
    required this.subtitle,
  });
}

class CatalogItem {
  final String image;
  final String title;

  const CatalogItem({
    required this.image,
    required this.title,
  });
}

class OrzuLabHomePage extends StatefulWidget {
  @override
  _OrzuLabHomePageState createState() => _OrzuLabHomePageState();
}

class _OrzuLabHomePageState extends State<OrzuLabHomePage> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentCarouselIndex = 0;
  Timer? _carouselTimer;

  final List<CarouselItem> carouselItems = [
    const CarouselItem(
      mainImage: 'assets/hh.png',
      leftImage: 'assets/hh.png',
      rightImage: 'assets/hhh.png',
      title: 'NEW\nCOLLECTION',
      subtitle: 'Sentabr – oktabr\n2025',
    ),
    const CarouselItem(
      mainImage: 'assets/hhh.png',
      leftImage: 'assets/hh.png',
      rightImage: 'assets/hh.png',
      title: 'NEW\nCOLLECTION',
      subtitle: 'Sentabr – oktabr\n2025',
    ),
    const CarouselItem(
      mainImage: 'assets/hh.png',
      leftImage: 'assets/hhh.png',
      rightImage: 'assets/hh.png',
      title: 'NEW\nCOLLECTION',
      subtitle: 'Sentabr – oktabr\n2025',
    ),
  ];

  final List<CatalogItem> catalogItems = [
    const CatalogItem(image: 'assets/m.png', title: 'Elegant style'),
    const CatalogItem(image: 'assets/e.png', title: 'Classic style'),
    const CatalogItem(image: 'assets/hh.png', title: 'Romantic style'),
    const CatalogItem(image: 'assets/jkh.png', title: 'Romantic style'),
  ];

  @override
  void initState() {
    super.initState();
    _startCarouselTimer();
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startCarouselTimer() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;
      int nextPage = _currentCarouselIndex + 1;
      if (nextPage >= carouselItems.length) {
        nextPage = 0;
      }
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1200;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              SizedBox(height: 40),
              _buildCarousel(),
          
              SizedBox(height: 40),
              _buildCompleteLookSection(isTablet, isDesktop),
              SizedBox(height: 40),
              _buildVirtualTryOnSection(isTablet),
              SizedBox(height: 40),
              _buildFooter(),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset('assets/mm.png', height: 40, 
                errorBuilder: (context, error, stackTrace) => 
                  Container(width: 40, height: 40, color: Colors.grey[300]),
              ),
              SizedBox(width: 10),
            ],
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text(
                  'Skip',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatSupportScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  elevation: 0,
                ),
                child: Text('Contact Us'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    return Column(
      children: [
        Text(
          'Orzu Lab AI - tailored to your figure close to your heart!',
          style: TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        SizedBox(
          height: 320,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
            itemCount: carouselItems.length,
            itemBuilder: (context, index) {
              final item = carouselItems[index];
              return _buildCarouselCard(item, index);
            },
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            carouselItems.length,
            (index) {
              final isSelected = _currentCarouselIndex == index;
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.favorite,
                  color: isSelected ? Colors.black : Colors.grey[400],
                  size: isSelected ? 16 : 12,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCarouselCard(CarouselItem item, int index) {
    return Stack(
      children: [
        Positioned(
          left: 20,
          top: 0,
          child: Container(
            width: 500,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 170,
                  top: 0,
                  child: Container(
                    width: 140,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(60),
                      ),
                      color: Colors.grey[200],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(50),
                        ),
                      ),
                      child: Image.asset(
                        item.mainImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: Colors.grey[300]),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 270,
                  top: 100,
                  child: Container(
                    width: 120,
                    height: 190,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                      child: Image.asset(
                        item.mainImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: Colors.grey[300]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

 

  Widget _buildCompleteLookSection(bool isTablet, bool isDesktop) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Complete your Look!',
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Catalog',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 20),
          _buildCatalogGrid(isTablet, isDesktop),
        ],
      ),
    );
  }

  Widget _buildCatalogGrid(bool isTablet, bool isDesktop) {
    int crossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 2);
    double aspectRatio = isTablet ? 0.8 : 0.75;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: catalogItems.length,
      itemBuilder: (context, index) {
        final item = catalogItems[index];
        return Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    item.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.image_not_supported, 
                                     color: Colors.grey[500]),
                        ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              item.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }

  Widget _buildVirtualTryOnSection(bool isTablet) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Text(
            'Save time by choosing a wedding dress that suits your figure and style online with OrzuLabAI.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: 16),
        _buildTryOnContent(isTablet),
      ],
    );
  }

  Widget _buildTryOnContent(bool isTablet) {
    final imageContainer = _buildTryOnCard(
      child: Image.asset(
        'assets/cc.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[200],
          child: Icon(Icons.person, size: 80, color: Colors.grey[500]),
        ),
      ),
    );

    final ideasContainer = _buildTryOnCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Wedding dress ideas",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/dd.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(height: 100, color: Colors.grey[200]),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      'assets/gg.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(height: 100, color: Colors.grey[200]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final uploadContainer = _buildTryOnCard(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!, width: 2, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'Upload your photo',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ),
      ),
    );

    final arrowHorizontal = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Icon(Icons.arrow_forward_rounded, size: 40, color: Colors.grey[600]),
    );

    final arrowVertical = Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Icon(Icons.arrow_downward_rounded, size: 40, color: Colors.grey[600]),
    );

    if (isTablet) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: imageContainer),
            arrowHorizontal,
            Expanded(child: ideasContainer),
            arrowHorizontal,
            Expanded(child: uploadContainer),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            imageContainer,
            arrowVertical,
            ideasContainer,
            arrowVertical,
            uploadContainer,
          ],
        ),
      );
    }
  }

  Widget _buildTryOnCard({required Widget child}) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildFooter() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 155, 155, 155),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isWide = constraints.maxWidth > 600;
          
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildSocialMediaColumn()),
                Expanded(child: _buildContactColumn()),
                Expanded(child: _buildContactUsColumn()),
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSocialMediaColumn(),
                SizedBox(height: 20),
                _buildContactColumn(),
                SizedBox(height: 20),
                _buildContactUsColumn(),
              ],
            );
          }
        },
      ),
    );
  }

 
  Widget _buildSocialMediaColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Our social media',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        _buildSocialLink('Instagram@orzuLab_01/19'),
        SizedBox(height: 8),
        _buildSocialLink('Telegram@orzuLab_01/19'),
        SizedBox(height: 8),
        _buildSocialLink('Twitter@orzuLab_01/19'),
        SizedBox(height: 8),
        _buildSocialLink('YouTube@orzuLab_01/19'),
      ],
    );
  }

  Widget _buildContactColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Text('About us', style: TextStyle(color: Colors.white70)),
        SizedBox(height: 8),
        Text('Wedding dresses', style: TextStyle(color: Colors.white70)),
        SizedBox(height: 8),
        Text('Mehnat dresses', style: TextStyle(color: Colors.white70)),
        SizedBox(height: 8),
        Text('Dresses', style: TextStyle(color: Colors.white70)),
      ],
    );
  }

  Widget _buildContactUsColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact us',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.phone, color: Colors.white70, size: 16),
            SizedBox(width: 8),
            Text(
              '+998 99 365 51 12',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialLink(String text) {
    return Row(
      children: [
        if (text.contains('Instagram'))
          Image.asset('assets/v.png', height: 24, width: 24)
        else if (text.contains('Telegram'))
          Image.asset('assets/l.png', height: 24, width: 24)
        else if (text.contains('Twitter'))
          Image.asset('assets/n.png', height: 24, width: 24)
        else if (text.contains('YouTube'))
          Image.asset('assets/you.png', height: 24, width: 24)
        else
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        // Agar kerak bo'lsa, bu yerda boshqa ijtimoiy tarmoqlar uchun shartlarni qo'shing
        // Masalan:
        // else if (text.contains('Facebook'))
        //   Image.asset('assets/facebook_logo.png', height: 24, width: 24)
        // ...
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}