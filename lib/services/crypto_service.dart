import 'package:encrypt/encrypt.dart';

class CryptoService {
  late final Encrypter _encrypter;
  late final IV _iv;
  
  void setKey(String keyString) {
    // Ensure key is exactly 32 characters for AES-256
    final normalizedKey = keyString.length >= 32 
        ? keyString.substring(0, 32)
        : keyString.padRight(32, '0');
    
    final key = Key.fromUtf8(normalizedKey);
    _iv = IV.fromUtf8('1234567890123456'); // 16 chars for AES
    _encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  }

  String encryptPassword(String plainText) {
    final encrypted = _encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  String decryptPassword(String encryptedBase64) {
    final encrypted = Encrypted.fromBase64(encryptedBase64);
    final decrypted = _encrypter.decrypt(encrypted, iv: _iv);
    return decrypted;
  }
}
