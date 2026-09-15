import 'package:e_commerce/views/customer/wishlist_screen.dart';

class AppRoutes {
  // ========================= // General // =========================
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const signUP = '/signUp';

  // ========================= // Customer // =========================
  static const home = '/home';

  static const products = '/products';
  static const productDetails = '/product-details';
  static const categories = '/categories';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const orderSuccess = '/order-success';
  static const orders = '/orders';
  static const orderDetails = '/order-details';
  static const myOrders = '/my-orders';
  static const profile = '/profile';
  static const wishlistScreen = '/wishlist';
  // ========================= // Admin // =========================
  static const adminDashboard = '/admin-dashboard';
  static const adminOrders = '/admin-orders';
  static const dispatchedOrders = '/dispatched-orders';
  static const adminProducts = '/admin-products';
  static const addProduct = '/add-product';
  static const editProduct = '/edit-product';
  static const adminCategories = '/admin-categories';
  static const adminCustomers = '/admin-customers';
  static const inventory = '/inventory';
  static const payments = '/payments';
  static const adminSettings = '/admin-settings';
  static const adminSetup = '/admin-setup';
  // ========================= // Testing // =========================
  static const testData = '/test-data';
}
