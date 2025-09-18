import 'package:encrypt/encrypt.dart';

class CryptoService {
  static final _key = Key.fromUtf8('a2b4c6d8e1f3g5h7j9k2l4m6n8p0r3t5'); // 32 chars for AES-256
  static final _iv = IV.fromUtf8('1234567890123456'); // 16 chars for AES

  static final _encrypter = Encrypter(AES(_key, mode: AESMode.cbc));

  static String encryptPassword(String plainText) {
    final encrypted = _encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  static String decryptPassword(String encryptedBase64) {
    final encrypted = Encrypted.fromBase64(encryptedBase64);
    final decrypted = _encrypter.decrypt(encrypted, iv: _iv);
    return decrypted;
  }
}
