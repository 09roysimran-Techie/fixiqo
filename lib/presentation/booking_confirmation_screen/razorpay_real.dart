import 'package:razorpay_flutter/razorpay_flutter.dart';

void openRazorpay({
  required int amount,
  required String bookingId,
  required String description,
  required void Function(String paymentId) onSuccess,
  required void Function(int code, String description) onFailure,
  required void Function(String walletName) onWalletCreated,
}) {
  const String keyId = String.fromEnvironment(
    'RAZORPAY_KEY_ID',
    defaultValue: '',
  );

  final razorpay = Razorpay();

  razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (
    PaymentSuccessResponse response,
  ) {
    razorpay.clear();
    onSuccess(response.paymentId ?? bookingId);
  });

  razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse response) {
    razorpay.clear();
    onFailure(response.code ?? 0, response.message ?? 'Payment failed');
  });

  razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (
    ExternalWalletResponse response,
  ) {
    razorpay.clear();
    onWalletCreated(response.walletName ?? '');
  });

  final options = {
    'key': keyId,
    'amount': amount,
    'currency': 'INR',
    'name': 'FixIQ',
    'description': description,
    'order_id': bookingId,
    'prefill': {'contact': '', 'email': ''},
    'theme': {'color': '#00C896'},
    'retry': {'enabled': true, 'max_count': 3},
  };

  razorpay.open(options);
}
