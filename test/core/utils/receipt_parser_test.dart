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

  // Shaped like what text recognition read from Jack's real screenshots
  // (positions and sizes kept), with the names, address and numbers made up.
  ReadLine at(String text, double top, double bottom, double left) =>
      (text: text, top: top, bottom: bottom, left: left);

  test('a delivery order scrolled past its shop label: the shop line', () {
    final reading = parseReceipt([
      at('13:56', 68, 108, 173),
      at('KEDAI IVIAKAN - IVI JALAN CUNTUH', 326, 350, 62),
      at('A-1-2, Jalan Contoh 3, 12345 Bandar Contoh', 383, 423, 61),
      at('Deliver to', 540, 574, 115),
      at('Apartment Contoh, Jalan Dua, Bandar Contoh', 609, 649, 62),
      at('Ali Ahmad - (+60) 12-345 6789', 774, 810, 63),
      at('1 HOUR', 1117, 1228, 184),
      at('1x 12.Set A Nasi Lemak Ayam RM48.10', 1437, 1477, 213),
      at('Item Subtotal (1 item)', 1849, 1888, 64),
      at('RM48.10', 1851, 1882, 1056),
      at('Food Discount Voucher', 1961, 1988, 63),
      at('-RM12.00', 1959, 1990, 1069),
      at('Paid', 2131, 2164, 875),
      at('RM36.10', 2135, 2171, 1037),
      at('Order ID', 2622, 2649, 62),
      at('1234567890123456789 COPY', 2622, 2649, 697),
      at('Order Time', 2697, 2726, 61),
      at('26 Oct 2026 13:55', 2700, 2727, 912),
    ]);
    expect(reading.amountMinor, 3610);
    expect(reading.date, DateTime(2026, 10, 26));
    expect(reading.delivery, isTrue);
    expect(reading.shop, 'KEDAI IVIAKAN - IVI JALAN CUNTUH');
  });

  test('a customer line or a delivery time is not a shop', () {
    final reading = parseReceipt([
      line('11:55 AM - 12:10 PM', 1),
      line('Ali Ahmad - (+60) 12-345 6789', 2),
      line('Total', 3),
      line('RM20.00', 3, left: 700),
    ]);
    expect(reading.shop, isNull);
  });

  test('an e-wallet transfer with an ad: the big amount, not the ad', () {
    final reading = parseReceipt([
      at('13:57', 67, 107, 98),
      at('RM 0.01', 513, 585, 480),
      at('Transferred', 660, 697, 514),
      at('Receiver', 797, 834, 64),
      at('ALI BIN AHMAD', 794, 838, 904),
      at('Remark', 917, 953, 64),
      at('Fund Transfer', 916, 953, 917),
      at('Date & Time', 1035, 1072, 64),
      at('26/10/2026 13:56:56', 1034, 1076, 759),
      at('1 0CT -31 DEC 2026', 1420, 1448, 158),
      at('RM150', 1596, 1659, 988),
      at('Ad Limited-Time Offer! Enjoy Up to RM150 Rebate.', 1871, 1898, 49),
      at('Done', 2555, 2593, 780),
    ]);
    expect(reading.amountMinor, 1);
    expect(reading.shop, 'ALI BIN AHMAD');
    expect(reading.date, DateTime(2026, 10, 26));
    expect(reading.delivery, isFalse);
  });

  test('a bigger ad amount lower down does not beat the paid amount', () {
    final reading = parseReceipt([
      at('Payment Successful', 200, 240, 300),
      at('RM 5.00', 300, 360, 400),
      at('Receiver', 400, 440, 60),
      at('Date & Time', 460, 500, 60),
      at('Fund Transfer', 520, 560, 60),
      at('RM150', 900, 966, 700),
    ]);
    expect(reading.amountMinor, 500);
  });

  test('the shop on the same line as its label', () {
    final reading = parseReceipt([
      at('Receiver', 400, 440, 60),
      at('ALI BIN AHMAD', 400, 440, 700),
      at('Remark', 460, 500, 60),
    ]);
    expect(reading.shop, 'ALI BIN AHMAD');
  });

  test('an e-wallet transfer: the person under Transfer To', () {
    final reading = parseReceipt([
      at('-RM11.00', 260, 340, 40),
      at('Transaction Type', 420, 450, 40),
      at('Transfer to Wallet', 420, 450, 620),
      at('Transfer To', 530, 560, 40),
      at('CHIN CHIEH HUI', 530, 560, 640),
      at('Payment Details', 640, 670, 40),
      at('CHIN CHIEH HUI', 640, 670, 640),
      at('Date/Time', 860, 890, 40),
      at('09/11/2026 11:58:40', 860, 890, 580),
    ]);
    expect(reading.amountMinor, 1100);
    expect(reading.shop, 'CHIN CHIEH HUI');
    expect(reading.date, DateTime(2026, 11, 9));
  });

  test('an e-wallet payment: the big amount with its minus, the merchant', () {
    // Real recognised lines; the Chinese item line came out garbled.
    final reading = parseReceipt([
      at('T', 203, 245, 80),
      at('14:51', 64, 113, 156),
      at('-RM31.86', 379, 453, 54),
      at('Transaction Type', 584, 631, 49),
      at('Merchant', 745, 779, 52),
      at('Payment Details', 933, 980, 52),
      at('Payment Method', 1125, 1174, 51),
      at('Date/Time', 1287, 1326, 52),
      at('Wallet Ref', 1471, 1506, 49),
      at('Status', 1655, 1692, 51),
      at('Details', 200, 245, 557),
      at('Transaction No.', 1840, 1875, 50),
      at('77', 64, 107, 1117),
      at('+31 points', 397, 434, 1044),
      at('Payment', 588, 627, 1056),
      at('ONLINE MART', 745, 778, 1063),
      at('iRHA! 400g47E#RAT', 897, 947, 438),
      at('Powered by klipaył', 2127, 2183, 418),
      at('eWallet Balance', 1132, 1166, 909),
      at('06/11/2026 14:50:38', 1287, 1326, 805),
      at('202611061011000001000OTNGOW3MY1716', 1444, 1477, 304),
      at('49562626691', 1501, 1535, 945),
      at('Successful', 1656, 1691, 1013),
      at('202611060000000000008454090875', 1813, 1846, 421),
      at('09', 1870, 1904, 1188),
    ]);
    expect(reading.amountMinor, 3186);
    expect(reading.shop, 'ONLINE MART');
    expect(reading.date, DateTime(2026, 11, 6));
    expect(reading.delivery, isFalse);
  });

  test('a delivery being tracked: total, and the shop with no label', () {
    // Real recognised lines.
    final reading = parseReceipt([
      at('10:55', 66, 108, 143),
      at('Saver Delivery', 448, 484, 73),
      at('11:55 AM -12:10 PM', 562, 612, 69),
      at('On time We\'ve got your order', 652, 693, 50),
      at("We'll let you know when it's in the restaurant.", 863, 901, 49),
      at('G', 1503, 1539, 150),
      at('Kedai Ayam - Puchong', 1075, 1116, 267),
      at('Save this restaurant to Favourites and find it', 1259, 1287, 170),
      at('quickly next time.', 1299, 1336, 170),
      at('Total', 1825, 1868, 130),
      at('PayLater', 1506, 1551, 268),
      at('2 offers applied.', 1669, 1718, 267),
      at('Get help', 239, 281, 892),
      at("Yay, you've saved RM9.30", 1889, 1932, 124),
      at('View order summary', 2048, 2090, 108),
      at('91', 66, 103, 1084),
      at('3', 1268, 1320, 1052),
      at('RM20.34', 1829, 1865, 973),
      at('RM29.64', 1897, 1929, 1003),
      at('Join More and save on delivery', 2533, 2585, 225),
      at('14: 48', 2637, 2711, 544),
    ]);
    expect(reading.amountMinor, 2034);
    expect(reading.shop, 'Kedai Ayam - Puchong');
  });

  test('a food order: the shop line without its arrow', () {
    // Real recognised lines; the shop line ends in a tappable arrow.
    final reading = parseReceipt([
      at('17:39', 68, 108, 175),
      at('Take from', 402, 429, 98),
      at('Kedai Mala - Puchong Jaya >', 465, 507, 62),
      at('A-G-36, Jalan Puchong, Bandar Puchong Jaya,', 536, 574, 61),
      at('• Deliver to', 696, 723, 60),
      at('Order Details', 233, 278, 475),
      at('Item Subtotal (2 items)', 2109, 2148, 64),
      at('Food Discount Voucher', 2221, 2248, 63),
      at('Delivery Fee D', 2301, 2339, 63),
      at('Paid', 2559, 2591, 868),
      at('RM28.30', 2111, 2142, 1052),
      at('-RM7.00', 2222, 2249, 1092),
      at('↑ RM4.50', 2304, 2334, 1040),
      at('-RM3.00', 2387, 2416, 1084),
      at('RM22.80', 2563, 2599, 1031),
      at('Tax included, where applicable.', 2628, 2661, 699),
    ]);
    expect(reading.amountMinor, 2280);
    expect(reading.shop, 'Kedai Mala - Puchong Jaya');
  });

  test('a small minus amount is still a discount, not what was paid', () {
    final reading = parseReceipt([
      line('Voucher', 1),
      line('-RM5.00', 1, left: 700),
      line('RM12.00', 2, left: 700),
    ]);
    expect(reading.amountMinor, 1200);
  });
}
