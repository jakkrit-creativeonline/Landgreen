import 'package:flutter/foundation.dart';

class BahtText {
  final MAX_POSITION = 6;
  final UNIT_POSITION = 0;
  final TEN_POSITION = 1;

  final PRIMARY_UNIT = 'บาท';
  final SECONDARY_UNIT = 'สตางค์';
  final WHOLE_NUMBER_TEXT = 'ถ้วน';

  final NUMBER_TEXTS =
      'ศูนย์,หนึ่ง,สอง,สาม,สี่,ห้า,หก,เจ็ด,แปด,เก้า,สิบ'.split(',');
  final UNIT_TEXTS = 'สิบ,ร้อย,พัน,หมื่น,แสน,ล้าน'.split(',');

  getIntegerDigits(numberInput) =>
      int.parse(numberInput.toString().split('.')[0], radix: 10);

  getFractionalDigits(numberInput) =>
      int.parse(numberInput.toString().split('.')[1], radix: 10);

  hasFractionalDigits(numberInput) => numberInput != null && numberInput != 0;

  isZeroValue(number) => number == 0;
  isUnitPosition(position) => position == UNIT_POSITION;
  isTenPosition(position) => position % MAX_POSITION == TEN_POSITION;
  isMillionsPosition(position) =>
      (position >= MAX_POSITION && position % MAX_POSITION == 0);
  isLastPosition(position, lengthOfDigits) => position + 1 < lengthOfDigits;

  reverseNumber(number) {
    var numberStr = number.toString();
    return numberStr.split('').reversed.join('');
  }

  getBathUnit(position, number) {
    var unitText = '';

    if (!isUnitPosition(position)) {
      unitText = UNIT_TEXTS[(position - 1).abs() % MAX_POSITION];
    }

    if (isZeroValue(number) && !isMillionsPosition(position)) {
      unitText = '';
    }

    return unitText;
  }

  getBathText(position, number, lengthOfDigits) {
    var numberText = NUMBER_TEXTS[number];

    if (isZeroValue(number)) {
      return '';
    }

    if (isTenPosition(position) && number == 1) {
      numberText = '';
    }

    if (isTenPosition(position) && number == 2) {
      numberText = 'ยี่';
    }

    if (isMillionsPosition(position) &&
        isLastPosition(position, lengthOfDigits) &&
        number == 1) {
      numberText = 'เอ็ด';
    }

    if (lengthOfDigits == 2 &&
        isLastPosition(position, lengthOfDigits) &&
        number == 1) {
      numberText = 'เอ็ด';
    }

    if (lengthOfDigits > 1 && isUnitPosition(position) && number == 1) {
      numberText = 'เอ็ด';
    }

    return numberText;
  }

  // convert function without async
  convert(numberInput) {
    var numberReverse = reverseNumber(numberInput);
    var textOutput = '';
    numberReverse.split('').asMap().forEach((i, number) {
      var n = int.parse(number);
      textOutput =
          "${getBathText(i, n, numberReverse.length)}${getBathUnit(i, n)}$textOutput";
    });
    return textOutput;
  }

  parseFloatWithPrecision(number, {precision = 2}) {
    var numberFloatStr = double.parse(number.toString()).toString().split('.');
    var integerUnitStr = numberFloatStr[0];
    var fractionalUnitStr =
        (numberFloatStr.length == 2 && numberFloatStr[1] != '0')
            ? numberFloatStr[1].substring(0, precision)
            : '00';
    return double.parse("$integerUnitStr.$fractionalUnitStr")
        .toStringAsFixed(precision);
  }

  convertFullMoney(numberInput) {
    var numberStr = parseFloatWithPrecision(numberInput);

    var integerDigits = getIntegerDigits(numberStr);
    var fractionalDigits = getFractionalDigits(numberStr);

    var intTextOutput = convert(integerDigits);

    var textOutput = [];
    if (intTextOutput != null) {
      textOutput.add("${[intTextOutput, PRIMARY_UNIT].join('')}");
    }
    if (intTextOutput != null && !hasFractionalDigits(fractionalDigits)) {
      textOutput.add(WHOLE_NUMBER_TEXT);
    }
    if (hasFractionalDigits(fractionalDigits) &&
        convert(fractionalDigits) != null) {
      textOutput.add('${[convert(fractionalDigits), SECONDARY_UNIT].join('')}');
    }

    return textOutput.join('');
  }
}
