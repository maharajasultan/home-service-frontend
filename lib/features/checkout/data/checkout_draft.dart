import 'package:flutter_riverpod/flutter_riverpod.dart';

class CheckoutLine {
  const CheckoutLine({
    required this.productId,
    required this.productName,
    required this.productType,
    required this.variantId,
    required this.variantLabel,
    required this.unitPrice,
    required this.baseFee,
    required this.qty,
  });

  final int productId;
  final String productName;
  final String productType;
  final int variantId;
  final String variantLabel;
  final int unitPrice;
  final int baseFee;
  final int qty;

  int get lineTotal => (unitPrice + baseFee) * qty;
}

class CheckoutDraft {
  const CheckoutDraft({required this.source, required this.lines});

  final String source; // direct | cart
  final List<CheckoutLine> lines;

  int get total => lines.fold(0, (sum, line) => sum + line.lineTotal);
}

class CheckoutDraftController extends Notifier<CheckoutDraft?> {
  @override
  CheckoutDraft? build() => null;

  void setDirect(CheckoutLine line) => state = CheckoutDraft(source: 'direct', lines: [line]);

  void clear() => state = null;
}

final checkoutDraftProvider = NotifierProvider<CheckoutDraftController, CheckoutDraft?>(CheckoutDraftController.new);