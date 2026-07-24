// Stub implementation for web platform — Razorpay SDK not available on web
void openRazorpay({
  required int amount,
  required String bookingId,
  required String description,
  required void Function(String paymentId) onSuccess,
  required void Function(int code, String description) onFailure,
  required void Function(String walletName) onWalletCreated,
}) {
  // Web: no-op — handled by kIsWeb check in booking_confirmation_screen.dart
}
