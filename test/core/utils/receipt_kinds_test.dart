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

  group('built-in food apps', () {
    // Laid out as Jack's own screenshots, as the phone reads them; shops,
    // people, plates and the phone number are made up.
    final shopeeTop = parseReceipt([
      line('Order Details', 1),
      line("We'll notify you once your order is heading to you.", 2),
      line('Ahmad Faiz (Driver)', 3),
      line('5.0 • WXY 1234', 4),
      line('Take from', 5),
      line('Kedai Teh Ali - Taman Contoh', 6),
      line('NO.1, GROUND FLOOR, Jalan Contoh 1,', 7),
      line('Taman Contoh, 12345 Bandar Contoh, Selangor,', 8),
      line('Petaling, Selangor', 9),
      line('Deliver to', 10),
      line('Ali Ahmad - (+60) 12-345 6789', 11),
      line('InstantMart', 12),
      line('GET YOUR', 13),
      line('FRESH EGGS IN', 14),
      line('Item Details', 15),
      line('Mee Ayam Goreng', 16),
      line('RM26.90', 16),
      line('Item Subtotal (1 item)', 17),
      line('RM26.90', 17),
      line('Food Discount Voucher', 18),
      line('-RM7.00', 18),
      line('Paid', 19),
      line('RM19.90', 20),
      line('Tax included, where applicable.', 21),
    ]).labels;

    final shopeeLower = parseReceipt([
      line('Order Details', 1),
      line('4.6 • ABC1234', 2),
      line('Take from', 3),
      line('Mee Sup Abu - Medan Selera', 4),
      line('Deliver to', 5),
      line('ORDERED MORE THAN RM15?', 6),
      line('Item Details', 7),
      line('Mee Kari (soup)', 8),
      line('RM16.20', 8),
      line('Item Subtotal (1 item)', 9),
      line('Food Discount Voucher', 10),
      line('Delivery Fee', 11),
      line('Delivery Discount Subtotal', 12),
      line('RM13.20', 13),
      line('Tax included, where applicable.', 14),
      line('Order Info', 15),
      line('If item unavailable', 16),
      line('Ask me first', 16),
    ]).labels;

    ReceiptReading grab(String shop, String status) => parseReceipt([
      line('Get help', 1),
      line('Saver Delivery', 2),
      line('11:55 AM - 12:10 PM', 3),
      line(status, 4),
      line("We'll let you know when it's in the restaurant.", 5),
      line(shop, 6),
      line('Save this restaurant to Favourites and find it', 7),
      line('quickly next time.', 8),
      line('PayLater', 9),
      line('2 offers applied.', 10),
      line('Total', 11),
      line('RM20.34', 11),
      line('Yay, you’ve saved RM9.30', 12),
      line('RM29.64', 12),
      line('View order summary', 13),
      line('GrabMore and save on delivery', 14),
    ]);

    test('Shopee order pages are Shopeefood, scrolled or not', () {
      expect(kindFor(shopeeTop, const [])?.name, 'Shopeefood');
      expect(kindFor(shopeeLower, const [])?.name, 'Shopeefood');
      expect(kindFor(orderBottom, const [])?.name, 'Shopeefood');
    });

    test('Grab order pages are Grabfood, whatever the shop', () {
      final first = grab('Ayam Goreng Mala - Taman Contoh', 'On time');
      final second = grab(
        'Kedai Mee Siti - (Bandar Contoh',
        "On time · Restaurant's preparing your order",
      );
      expect(kindFor(first.labels, const [])?.name, 'Grabfood');
      expect(kindFor(second.labels, const [])?.name, 'Grabfood');
    });

    test('other pages are neither', () {
      expect(kindFor(transfer, const []), isNull);
    });

    test('a learned kind still counts when no food app matches', () {
      final kinds = <ReceiptKind>[(labels: transfer, name: 'Bank')];
      expect(kindFor(transfer, kinds)?.name, 'Bank');
      expect(kindFor(shopeeTop, kinds)?.name, 'Shopeefood');
    });

    test('the built-in names are known, any case', () {
      expect(isBuiltInKind('shopeefood '), isTrue);
      expect(isBuiltInKind('Grabfood'), isTrue);
      expect(isBuiltInKind('Food App'), isFalse);
    });
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
    // No shop read, so Jack typed it: only the part before it is the kind.
    expect(learnedKindName(note: 'Food Go - Kedai Abu'), 'Food Go');
    // The shop was misread and Jack retyped it: the kind still counts...
    expect(
      learnedKindName(note: 'Food go - kedai abu', shop: 'ALL IVIaia - IVI'),
      'Food go',
    );
    // ...but tidying the read shop names no kind.
    expect(
      learnedKindName(
        note: 'Kedai Ali - Puchong',
        shop: 'Kedai Ali - Puchong Jaya',
      ),
      isNull,
    );
  });
}
