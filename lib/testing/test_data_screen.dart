import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/product_model.dart';

class TestDataScreen extends StatefulWidget {
  const TestDataScreen({super.key});

  @override
  State<TestDataScreen> createState() => _TestDataScreenState();
}

class _TestDataScreenState extends State<TestDataScreen> {
  final DatabaseReference _productsRef = FirebaseDatabase.instance.ref(
    'products',
  );

  bool _isUploading = false;
  int _uploadedCount = 0;

  Future<void> _uploadProducts() async {
    if (_isUploading) return;

    setState(() {
      _isUploading = true;
      _uploadedCount = 0;
    });

    try {
      final products = _getTestProducts();

      final Map<String, dynamic> updates = {};

      for (final product in products) {
        updates[product.id] = product.toMap();
      }

      await _productsRef.update(updates);

      setState(() {
        _uploadedCount = products.length;
      });

      Get.snackbar(
        'Success',
        '${products.length} products uploaded to Firebase successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: EdgeInsets.all(16.w),
        borderRadius: 12.r,
      );
    } catch (e) {
      Get.snackbar(
        'Upload Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: EdgeInsets.all(16.w),
        borderRadius: 12.r,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  List<ProductModel> _getTestProducts() {
    final now = DateTime.now();

    return [
      ProductModel(
        id: 'test_product_001',
        name: 'Classic Black T-Shirt',
        description:
            'Premium cotton classic black t-shirt with a comfortable regular fit.',
        categoryId: 'men',
        categoryName: 'Men',
        brand: 'Velora',
        price: 2499,
        salePrice: 1999,
        stock: 45,
        soldCount: 120,
        images: [
          'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab',
        ],
        variations: [
          ProductVariation(
            id: 'v001',
            name: 'Size',
            value: 'S',
            stock: 10,
            image: '',
          ),
          ProductVariation(
            id: 'v002',
            name: 'Size',
            value: 'M',
            stock: 15,
            image: '',
          ),
          ProductVariation(
            id: 'v003',
            name: 'Size',
            value: 'L',
            stock: 12,
            image: '',
          ),
        ],
        rating: 4.6,
        reviewCount: 38,
        isActive: true,
        isFeatured: true,
        isNew: false,
        isOnSale: true,
        createdAt: now,
        updatedAt: now,
      ),

      ProductModel(
        id: 'test_product_002',
        name: 'Oversized White Hoodie',
        description:
            'Soft oversized hoodie made for everyday comfort and streetwear style.',
        categoryId: 'men',
        categoryName: 'Men',
        brand: 'Velora',
        price: 4999,
        salePrice: 3999,
        stock: 28,
        soldCount: 86,
        images: ['https://images.unsplash.com/photo-1556821840-3a63f95609a7'],
        variations: [
          ProductVariation(
            id: 'v004',
            name: 'Size',
            value: 'M',
            stock: 8,
            image: '',
          ),
          ProductVariation(
            id: 'v005',
            name: 'Size',
            value: 'L',
            stock: 10,
            image: '',
          ),
        ],
        rating: 4.8,
        reviewCount: 27,
        isActive: true,
        isFeatured: true,
        isNew: true,
        isOnSale: true,
        createdAt: now,
        updatedAt: now,
      ),

      ProductModel(
        id: 'test_product_003',
        name: 'Slim Fit Denim Jeans',
        description:
            'Modern slim-fit denim jeans designed for casual everyday wear.',
        categoryId: 'men',
        categoryName: 'Men',
        brand: 'UrbanFit',
        price: 5499,
        salePrice: null,
        stock: 32,
        soldCount: 64,
        images: ['https://images.unsplash.com/photo-1542272604-787c3835535d'],
        variations: [
          ProductVariation(
            id: 'v006',
            name: 'Size',
            value: '32',
            stock: 12,
            image: '',
          ),
          ProductVariation(
            id: 'v007',
            name: 'Size',
            value: '34',
            stock: 10,
            image: '',
          ),
        ],
        rating: 4.4,
        reviewCount: 19,
        isActive: true,
        isFeatured: false,
        isNew: false,
        isOnSale: false,
        createdAt: now,
        updatedAt: now,
      ),

      ProductModel(
        id: 'test_product_004',
        name: 'Women Floral Summer Dress',
        description:
            'Elegant floral summer dress with a lightweight and comfortable fabric.',
        categoryId: 'women',
        categoryName: 'Women',
        brand: 'Velora',
        price: 5999,
        salePrice: 4499,
        stock: 22,
        soldCount: 91,
        images: [
          'https://images.unsplash.com/photo-1496747611176-843222e1e57c',
        ],
        variations: [
          ProductVariation(
            id: 'v008',
            name: 'Size',
            value: 'S',
            stock: 6,
            image: '',
          ),
          ProductVariation(
            id: 'v009',
            name: 'Size',
            value: 'M',
            stock: 8,
            image: '',
          ),
        ],
        rating: 4.7,
        reviewCount: 41,
        isActive: true,
        isFeatured: true,
        isNew: true,
        isOnSale: true,
        createdAt: now,
        updatedAt: now,
      ),

      ProductModel(
        id: 'test_product_005',
        name: 'Women Casual Handbag',
        description:
            'Stylish everyday handbag with spacious compartments and premium finish.',
        categoryId: 'women',
        categoryName: 'Women',
        brand: 'Luxe',
        price: 6999,
        salePrice: 5499,
        stock: 18,
        soldCount: 73,
        images: [
          'https://images.unsplash.com/photo-1584917865442-de89df76afd3',
        ],
        variations: [],
        rating: 4.5,
        reviewCount: 24,
        isActive: true,
        isFeatured: true,
        isNew: false,
        isOnSale: true,
        createdAt: now,
        updatedAt: now,
      ),

      ProductModel(
        id: 'test_product_006',
        name: 'Running Sneakers',
        description:
            'Lightweight running sneakers with cushioned soles for all-day comfort.',
        categoryId: 'shoes',
        categoryName: 'Shoes',
        brand: 'Sprint',
        price: 7999,
        salePrice: 6499,
        stock: 35,
        soldCount: 143,
        images: ['https://images.unsplash.com/photo-1542291026-7eec264c27ff'],
        variations: [
          ProductVariation(
            id: 'v010',
            name: 'Size',
            value: '40',
            stock: 8,
            image: '',
          ),
          ProductVariation(
            id: 'v011',
            name: 'Size',
            value: '41',
            stock: 10,
            image: '',
          ),
          ProductVariation(
            id: 'v012',
            name: 'Size',
            value: '42',
            stock: 9,
            image: '',
          ),
        ],
        rating: 4.9,
        reviewCount: 57,
        isActive: true,
        isFeatured: true,
        isNew: true,
        isOnSale: true,
        createdAt: now,
        updatedAt: now,
      ),

      ProductModel(
        id: 'test_product_007',
        name: 'Classic Leather Wallet',
        description:
            'Minimal leather wallet with multiple card slots and a compact design.',
        categoryId: 'accessories',
        categoryName: 'Accessories',
        brand: 'Luxe',
        price: 2999,
        salePrice: null,
        stock: 50,
        soldCount: 112,
        images: [
          'https://images.unsplash.com/photo-1627123424574-724758594e93',
        ],
        variations: [],
        rating: 4.3,
        reviewCount: 31,
        isActive: true,
        isFeatured: false,
        isNew: false,
        isOnSale: false,
        createdAt: now,
        updatedAt: now,
      ),

      ProductModel(
        id: 'test_product_008',
        name: 'Kids Cartoon T-Shirt',
        description:
            'Fun and colorful kids t-shirt made from soft breathable cotton.',
        categoryId: 'kids',
        categoryName: 'Kids',
        brand: 'HappyKids',
        price: 1999,
        salePrice: 1499,
        stock: 40,
        soldCount: 98,
        images: [
          'https://images.unsplash.com/photo-1519238263530-99bdd11df2ea',
        ],
        variations: [
          ProductVariation(
            id: 'v013',
            name: 'Size',
            value: '4-5Y',
            stock: 12,
            image: '',
          ),
          ProductVariation(
            id: 'v014',
            name: 'Size',
            value: '6-7Y',
            stock: 15,
            image: '',
          ),
        ],
        rating: 4.6,
        reviewCount: 28,
        isActive: true,
        isFeatured: false,
        isNew: true,
        isOnSale: true,
        createdAt: now,
        updatedAt: now,
      ),

      ProductModel(
        id: 'test_product_009',
        name: 'Premium Baseball Cap',
        description:
            'Adjustable premium baseball cap suitable for casual everyday outfits.',
        categoryId: 'accessories',
        categoryName: 'Accessories',
        brand: 'UrbanFit',
        price: 1799,
        salePrice: 1299,
        stock: 65,
        soldCount: 156,
        images: [
          'https://images.unsplash.com/photo-1521369909029-2afed882baee',
        ],
        variations: [],
        rating: 4.4,
        reviewCount: 36,
        isActive: true,
        isFeatured: false,
        isNew: true,
        isOnSale: true,
        createdAt: now,
        updatedAt: now,
      ),

      ProductModel(
        id: 'test_product_010',
        name: 'Classic Analog Watch',
        description:
            'Elegant analog watch with a clean dial and premium metal strap.',
        categoryId: 'accessories',
        categoryName: 'Accessories',
        brand: 'Chronos',
        price: 8999,
        salePrice: 7499,
        stock: 14,
        soldCount: 47,
        images: [
          'https://images.unsplash.com/photo-1524805444758-089113d48a6d',
        ],
        variations: [],
        rating: 4.7,
        reviewCount: 18,
        isActive: true,
        isFeatured: true,
        isNew: false,
        isOnSale: true,
        createdAt: now,
        updatedAt: now,
      ),

      ProductModel(
        id: 'test_product_011',
        name: 'Women Classic Blazer',
        description:
            'Elegant tailored blazer suitable for office and formal occasions.',
        categoryId: 'women',
        categoryName: 'Women',
        brand: 'Velora',
        price: 8999,
        salePrice: 6999,
        stock: 16,
        soldCount: 39,
        images: [
          'https://images.unsplash.com/photo-1591369822096-ffd140ec948f',
        ],
        variations: [
          ProductVariation(
            id: 'v015',
            name: 'Size',
            value: 'S',
            stock: 5,
            image: '',
          ),
          ProductVariation(
            id: 'v016',
            name: 'Size',
            value: 'M',
            stock: 6,
            image: '',
          ),
          ProductVariation(
            id: 'v017',
            name: 'Size',
            value: 'L',
            stock: 5,
            image: '',
          ),
        ],
        rating: 4.8,
        reviewCount: 22,
        isActive: true,
        isFeatured: true,
        isNew: false,
        isOnSale: true,
        createdAt: now,
        updatedAt: now,
      ),

      ProductModel(
        id: 'test_product_012',
        name: 'Men Casual Polo Shirt',
        description:
            'Premium polo shirt with a classic collar and comfortable cotton fabric.',
        categoryId: 'men',
        categoryName: 'Men',
        brand: 'UrbanFit',
        price: 3299,
        salePrice: 2799,
        stock: 29,
        soldCount: 83,
        images: [
          'https://images.unsplash.com/photo-1586790170083-2f9ceadc732d',
        ],
        variations: [
          ProductVariation(
            id: 'v018',
            name: 'Size',
            value: 'M',
            stock: 9,
            image: '',
          ),
          ProductVariation(
            id: 'v019',
            name: 'Size',
            value: 'L',
            stock: 10,
            image: '',
          ),
        ],
        rating: 4.5,
        reviewCount: 25,
        isActive: true,
        isFeatured: false,
        isNew: false,
        isOnSale: true,
        createdAt: now,
        updatedAt: now,
      ),

      ProductModel(
        id: 'test_product_013',
        name: 'Canvas Backpack',
        description:
            'Durable canvas backpack with multiple compartments for work and travel.',
        categoryId: 'bags',
        categoryName: 'Bags',
        brand: 'TravelPro',
        price: 4999,
        salePrice: 3999,
        stock: 24,
        soldCount: 61,
        images: ['https://images.unsplash.com/photo-1553062407-98eeb64c6a62'],
        variations: [],
        rating: 4.6,
        reviewCount: 21,
        isActive: true,
        isFeatured: true,
        isNew: true,
        isOnSale: true,
        createdAt: now,
        updatedAt: now,
      ),

      ProductModel(
        id: 'test_product_014',
        name: 'Classic Sunglasses',
        description:
            'Modern sunglasses with UV protection and a lightweight frame.',
        categoryId: 'accessories',
        categoryName: 'Accessories',
        brand: 'Vision',
        price: 3999,
        salePrice: 2999,
        stock: 31,
        soldCount: 89,
        images: [
          'https://images.unsplash.com/photo-1511499767150-a48a237f0083',
        ],
        variations: [],
        rating: 4.4,
        reviewCount: 34,
        isActive: true,
        isFeatured: false,
        isNew: true,
        isOnSale: true,
        createdAt: now,
        updatedAt: now,
      ),

      ProductModel(
        id: 'test_product_015',
        name: 'Premium Sports Jacket',
        description:
            'Lightweight sports jacket designed for outdoor activities and casual wear.',
        categoryId: 'men',
        categoryName: 'Men',
        brand: 'Sprint',
        price: 9999,
        salePrice: 7999,
        stock: 12,
        soldCount: 35,
        images: ['https://images.unsplash.com/photo-1551028719-00167b16eac5'],
        variations: [
          ProductVariation(
            id: 'v020',
            name: 'Size',
            value: 'M',
            stock: 4,
            image: '',
          ),
          ProductVariation(
            id: 'v021',
            name: 'Size',
            value: 'L',
            stock: 5,
            image: '',
          ),
        ],
        rating: 4.8,
        reviewCount: 17,
        isActive: true,
        isFeatured: true,
        isNew: true,
        isOnSale: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      appBar: AppBar(
        title: Text(
          'Test Data',
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600.w),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(32.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 80.w,
                      width: 80.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C4EFF).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.cloud_upload_outlined,
                        size: 40.sp,
                        color: const Color(0xFF6C4EFF),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    Text(
                      'Firebase Test Data',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    Text(
                      'Upload sample products to your Firebase Realtime Database for testing.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    SizedBox(height: 28.h),

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        children: [
                          _infoRow(
                            Icons.inventory_2_outlined,
                            'Products',
                            '15',
                          ),
                          SizedBox(height: 12.h),
                          _infoRow(
                            Icons.category_outlined,
                            'Categories',
                            'Men, Women, Kids, Shoes, Bags',
                          ),
                          SizedBox(height: 12.h),
                          _infoRow(
                            Icons.local_offer_outlined,
                            'Discounts',
                            'Included',
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 28.h),

                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton.icon(
                        onPressed: _isUploading ? null : _uploadProducts,
                        icon: _isUploading
                            ? SizedBox(
                                height: 20.w,
                                width: 20.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.cloud_upload_outlined),
                        label: Text(
                          _isUploading ? 'Uploading...' : 'Upload 15 Products',
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C4EFF),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(
                            0xFF6C4EFF,
                          ).withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),

                    if (_uploadedCount > 0) ...[
                      SizedBox(height: 20.h),
                      Text(
                        '$_uploadedCount products uploaded successfully.',
                        style: GoogleFonts.poppins(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: const Color(0xFF6C4EFF)),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          textAlign: TextAlign.right,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
