import 'package:expense_tracker/core/utils/receipt_parser.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lines as text recognition returns them: a label on the left and its
/// amount on the right share a row; [row] numbers rows top down.
ReadLine line(String text, int row, {double left = 40}) =>
    (text: text, top: row * 60.0, bottom: row * 60.0 + 40, left: left);

// A delivery order screen, shaped like a real one, with made-up names.
final List<ReadLine> deliveryOrder = [
  line('1:00', 0),
  line('Order Details', 1, left: 300),
  line('Assigning Driver for You', 2),
  line('Take from', 4),
  line('Ayam Goreng Corner - Mid Valley', 5),
  line('Lot 12, Jalan Tun Razak, 55100 Kuala Lumpur', 6),
  line('Deliver to', 7),
  line('1 x Nasi Ayam Pedas', 9, left: 160),
  line('RM14.60', 9, left: 750),
  line('Item Subtotal (1 item)', 11),
  line('RM14.60', 11, left: 740),
  line('Food Discount Voucher', 12),
  line('-RM7.00', 12, left: 760),
  line('Delivery Fee', 13),
  line('RM4.00', 13, left: 770),
  line('Paid', 14, left: 600),
  line('RM11.60', 14, left: 730),
];

void main() {
  test('a delivery order: the bottom amount, the shop, delivery', () {
    final reading = parseReceipt(deliveryOrder);
    expect(reading.amountMinor, 1160);
    expect(reading.shop, 'Ayam Goreng Corner - Mid Valley');
    expect(reading.delivery, isTrue);
    expect(reading.date, isNull);
  });

  test('a total label wins over a lower amount', () {
    final reading = parseReceipt([
      line('Total', 1),
      line('RM25.30', 1, left: 700),
      line('Cashback earned', 2),
      line('RM0.50', 2, left: 720),
    ]);
    expect(reading.amountMinor, 2530);
  });

  test('the lowest total label wins over a higher one', () {
    final reading = parseReceipt([
      line('Total', 1),
      line('RM30.00', 1, left: 700),
      line('Voucher', 2),
      line('-RM5.00', 2, left: 700),
      line('Total paid', 3),
      line('RM25.00', 3, left: 700),
    ]);
    expect(reading.amountMinor, 2500);
  });

  test('Subtotal is not a total label', () {
    final reading = parseReceipt([
      line('Subtotal', 1),
      line('RM40.00', 1, left: 700),
      line('Delivery fee', 2),
      line('RM5.00', 2, left: 700),
      line('RM45.00', 3, left: 700),
    ]);
    expect(reading.amountMinor, 4500);
  });

  test('a payment screen: big amount, shop after a label, date', () {
    final reading = parseReceipt([
      line('Payment Successful', 1),
      line('RM 12.40', 2),
      line('Merchant', 4),
      line('Kedai Runcit Ah Seng', 5),
      line('Date & Time', 6),
      line('24 Oct 2026, 13:05', 7),
      line('Reference No. 202610241305', 8),
    ]);
    expect(reading.amountMinor, 1240);
    expect(reading.shop, 'Kedai Runcit Ah Seng');
    expect(reading.date, DateTime(2026, 10, 24));
    expect(reading.delivery, isFalse);
  });

  test('a shop beside its label, values laid out on the right', () {
    final reading = parseReceipt([
      line('Payment Successful', 1),
      line('RM 12.40', 2),
      // Text recognition may put the value a little higher than its label.
      (text: 'Kedai Runcit Ah Seng', top: 236, bottom: 276, left: 500),
      line('Merchant', 4),
      line('Date & Time', 5),
      line('24 Oct 2026, 13:05', 5, left: 520),
    ]);
    expect(reading.shop, 'Kedai Runcit Ah Seng');
    expect(reading.date, DateTime(2026, 10, 24));
  });

  test('a shop on the label line', () {
    expect(
      parseReceipt([line('Paid to: Warung Mak Cik', 1)]).shop,
      'Warung Mak Cik',
    );
  });

  test('amounts with thousands separators', () {
    expect(
      parseReceipt([
        line('Total Amount', 1),
        line('RM1,234.50', 1, left: 600),
      ]).amountMinor,
      123450,
    );
  });

  test('dates in the usual formats', () {
    DateTime? dateOf(String text) => parseReceipt([line(text, 1)]).date;
    expect(dateOf('24 October 2026'), DateTime(2026, 10, 24));
    expect(dateOf('Oct 24, 2026 1:05 PM'), DateTime(2026, 10, 24));
    expect(dateOf('24/10/2026 13:05'), DateTime(2026, 10, 24));
    expect(dateOf('2026-10-24'), DateTime(2026, 10, 24));
    expect(dateOf('31/02/2026'), isNull);
    expect(dateOf('55100 Kuala Lumpur'), isNull);
  });

  test('nothing useful in the picture', () {
    final reading = parseReceipt([line('Hello', 1), line('-RM3.00', 2)]);
    expect(reading.amountMinor, isNull);
    expect(reading.shop, isNull);
    expect(reading.date, isNull);
    expect(reading.delivery, isFalse);
    expect(parseReceipt(const []).amountMinor, isNull);
  });
}
