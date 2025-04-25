class Formatters {
  static String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.startsWith("+94")) {
      return '0' + phoneNumber.substring(3);
    } else if (phoneNumber.startsWith("0")) {
      return '+94' + phoneNumber.substring(1);
    }
    return phoneNumber;
  }
}
