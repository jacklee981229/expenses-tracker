import 'package:expense_tracker/core/utils/receipt_kinds.dart';
import 'package:expense_tracker/core/utils/receipt_parser.dart';
import 'package:flutter_test/flutter_test.dart';

ReadLine line(String text, int row) =>
    (text: text, top: row * 60.0, bottom: row * 60.0 + 40, left: 40);

// Two screenshots of the same kind of order page, scrolled differently and
// with different ads, and a transfer page; all made up.
final orderTop = parseReceipt([
  line('Order Details', 1),
  line('Take from', 2),
  line('Nasi Kandar Corner', 3),
  line('Deliver to', 4),
  line('GET YOUR FRESH EGGS', 5),
  line('Item Details', 6),
  line('Item Subtotal (1 item)', 7),
  line('RM20.00', 7),
  line('Food Discount Voucher', 8),
  line('RM18.00', 9),
]).labels;

final orderBottom = parseReceipt([
  line('Item Details', 1),
  line('Item Subtotal (2 items)', 2),
  line('Food Discount Voucher', 3),
  line('RM36.10', 4),
  line('Order Info', 5),
  line('If item unavailable', 6),
  line('Ask me first', 7),
  line('Order Time', 8),
  line('26 Oct 2026 13:55', 8),
]).labels;

final transfer = parseReceipt([
  line('RM 0.01', 1),
  line('Transferred', 2),
  line('Receiver', 3),
  line('Remark', 4),
  line('Fund Transfer', 4),
  line('Date & Time', 5),
  line('Item Details', 6),
]).labels;

void main() {
  test('labels are lower-case words, without amounts and dates', () {
    expect(orderBottom, contains('item subtotal'));
    expect(orderBottom, contains('if item unavailable'));
    expect(orderBottom.any((label) => label.contains('oct')), isFalse);
    expect(orderBottom.any((label) => label.contains('rm')), isFalse);
  });

  test('the same kind matches across scroll positions', () {
    final kinds = <ReceiptKind>[(labels: orderTop, name: 'Food App')];
    // orderTop and orderBottom share item details, item subtotal and food
    // discount voucher; the order details heading makes four.
    final scrolled = {...orderBottom, 'order details'};
    expect(matchKind(scrolled, kinds)?.name, 'Food App');
  });

  test('another kind of page does not match', () {
    final kinds = <ReceiptKind>[(labels: orderTop, name: 'Food App')];
    expect(matchKind(transfer, kinds), isNull);
    expect(matchKind(const {}, kinds), isNull);
  });

  test('the closest kind wins', () {
    final kinds = <ReceiptKind>[
      (
        labels: {
          'item details',
          'order info',
          'remark',
          'ask me first',
          'x',
          'y',
          'z',
          'w',
        },
        name: 'Loose',
      ),
      (labels: orderBottom, name: 'Close'),
    ];
    expect(matchKind(orderBottom, kinds)?.name, 'Close');
  });

  test('the note joins the kind and the shop', () {
    expect(
      receiptNote(shop: 'Kedai Ali', kindName: 'Food App'),
      'Food App - Kedai Ali',
    );
    expect(receiptNote(kindName: 'Food App'), 'Food App');
    expect(receiptNote(shop: 'Kedai Ali'), 'Kedai Ali');
    expect(receiptNote(), isNull);
  });

  test('the name to learn comes from the saved note', () {
    expect(learnedKindName(note: ' Food App '), 'Food App');
    expect(
      learnedKindName(note: 'Food App - Kedai Ali', shop: 'Kedai Ali'),
      'Food App',
    );
    expect(learnedKindName(note: 'Kedai Ali', shop: 'Kedai Ali'), isNull);
    expect(learnedKindName(note: 'Lunch', shop: 'Kedai Ali'), isNull);
    expect(learnedKindName(note: '  '), isNull);
  });
}
