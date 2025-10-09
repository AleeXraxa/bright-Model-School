String convertDateToWords(DateTime date) {
  final day = _numberToWords(date.day);
  final month = _monthToWords(date.month);
  final year = _yearToWords(date.year);
  return '$day $month $year';
}

String _numberToWords(int number) {
  const units = [
    '',
    'One',
    'Two',
    'Three',
    'Four',
    'Five',
    'Six',
    'Seven',
    'Eight',
    'Nine',
    'Ten',
    'Eleven',
    'Twelve',
    'Thirteen',
    'Fourteen',
    'Fifteen',
    'Sixteen',
    'Seventeen',
    'Eighteen',
    'Nineteen',
  ];

  const tens = [
    '',
    '',
    'Twenty',
    'Thirty',
    'Forty',
    'Fifty',
    'Sixty',
    'Seventy',
    'Eighty',
    'Ninety',
  ];

  if (number == 0) return 'Zero';
  if (number < 20) return units[number];
  if (number < 100) {
    final ten = tens[number ~/ 10];
    final unit = number % 10;
    return unit == 0 ? ten : '$ten ${units[unit]}';
  }
  return number.toString(); // For simplicity, handle larger numbers as is
}

String _monthToWords(int month) {
  const months = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return months[month];
}

String _yearToWords(int year) {
  final thousands = year ~/ 1000;
  final hundreds = (year % 1000) ~/ 100;
  final remainder = year % 100;

  String result = '';

  if (thousands > 0) {
    result += '${_numberToWords(thousands)} Thousand ';
  }

  if (hundreds > 0) {
    result += '${_numberToWords(hundreds)} Hundred ';
  }

  if (remainder > 0) {
    result += _numberToWords(remainder);
  }

  return result.trim();
}
