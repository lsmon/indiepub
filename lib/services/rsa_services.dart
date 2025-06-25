// import 'dart:io';
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:logger/web.dart';
// import 'package:pointycastle/asymmetric/oaep.dart';
// import 'package:pointycastle/digests/sha256.dart';
// import 'package:pointycastle/pointycastle.dart';
// import 'package:pointycastle/asymmetric/rsa.dart';
// import 'package:pointycastle/signers/rsa_signer.dart';
// import 'package:asn1lib/asn1lib.dart' as asn1lib;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
// import 'package:basic_utils/basic_utils.dart';

// class RsaServices {
//   final logger = Logger(
//     printer: PrettyPrinter(
//       methodCount: 0,
//       errorMethodCount: 0,
//       colors: true,
//       printEmojis: true,
//     ),
//   );
  
  
//   RSAPrivateKey? _appPrivateKey;
//   RSAPublicKey? _appPublicKey;
//   RSAPublicKey? _serverPublicKey;
//   bool _isInitialized = false;

//   RSAPrivateKey? getAppPrivateKey() => _appPrivateKey;
//   RSAPublicKey? getAppPublicKey() => _appPublicKey;
//   RSAPublicKey? getServerPublicKey() => _serverPublicKey;
//   bool get isInitialized => _isInitialized;

//   Future<void> initialize(BuildContext context) async {
//     if (_isInitialized) return;
//     try {
//       AssetBundle resources = DefaultAssetBundle.of(context);

//       final appPrivateKey = await resources.loadString('resources/indiefront_prv.pem');
//       final appPublicKey = await resources.loadString('resources/indiefront_pub.pem');
//       final serverPublicKey = await resources.loadString('resources/indieback_pub.pem');

//       // _appPrivateKey = loadPrivateKey('resources/indiefront_prv.pem'); //CryptoUtils.rsaPrivateKeyFromPem(appPrivateKey); // _parsePrivateKey(appPrivateKey);
//       // _appPublicKey = loadPublicKey('resources/indiefront_pub.pem'); // CryptoUtils.rsaPublicKeyFromPem(appPublicKey); // _parsePublicKey(appPublicKey);
//       // _serverPublicKey = loadPublicKey('resources/indieback_pub.pem'); //CryptoUtils.rsaPublicKeyFromPem(serverPublicKey); // _parsePublicKey(serverPublicKey);
      
//       _appPrivateKey = CryptoUtils.rsaPrivateKeyFromPem(appPrivateKey); // _parsePrivateKey(appPrivateKey);
//       _appPublicKey = CryptoUtils.rsaPublicKeyFromPem(appPublicKey); // _parsePublicKey(appPublicKey);
//       _serverPublicKey = CryptoUtils.rsaPublicKeyFromPem(serverPublicKey); // _parsePublicKey(serverPublicKey);

//       // _appPrivateKey = _parsePrivateKey(appPrivateKey);
//       // _appPublicKey = _parsePublicKey(appPublicKey);
//       // _serverPublicKey = _parsePublicKey(serverPublicKey);

//       _isInitialized = true;
//     } catch (e) {
//       throw Exception('Failed to load or parse RSA key: $e');
//     }
//   }

//   // Load private key from file
//   RSAPrivateKey loadPrivateKey(String filename) {
//     final key = File(filename).readAsStringSync();
//     return CryptoUtils.rsaPrivateKeyFromPem(key);
//   }

//   // Load public key from file
//   RSAPublicKey loadPublicKey(String filename) {
//     final key = File(filename).readAsStringSync();
//     return CryptoUtils.rsaPublicKeyFromPem(key);
//   }


//   // Parse PEM public key
//   RSAPublicKey _parsePublicKey(String pem) {
//     try {
//       // Remove PEM headers and footers, and decode base64
//       final lines = pem
//           .split('\n')
//           .where((line) => !line.contains('-----') && line.trim().isNotEmpty)
//           .join();
//       final bytes = base64Decode(lines);

//       // Parse the top-level ASN.1 structure (SubjectPublicKeyInfo)
//       final parser = ASN1Parser(bytes);
//       final topLevelSeq = parser.nextObject();

//       // Validate top-level sequence
//       if (topLevelSeq is! ASN1Sequence || topLevelSeq.elements?.length != 2) {
//         throw Exception('Invalid X.509 SubjectPublicKeyInfo structure');
//       }

//       // Verify structure: AlgorithmIdentifier (SEQUENCE) and subjectPublicKey (BIT STRING)
//       if (topLevelSeq.elements?[0] is! ASN1Sequence || topLevelSeq.elements?[1] is! ASN1BitString) {
//         throw Exception('Unsupported public key format');
//       }

//       // Extract the subjectPublicKey BIT STRING
//       final publicKeyBitString = topLevelSeq.elements![1] as ASN1BitString;
//       final publicKeyBytes = publicKeyBitString.valueBytes;

//       if (publicKeyBytes == null) {
//         throw Exception('BIT STRING value is null');
//       }

//       // Debug: Print raw bytes to inspect
//       logger.d('BIT STRING bytes: ${publicKeyBytes.length} bytes, ${publicKeyBytes.take(10).toList()}...');

//       // Skip the leading padding byte (0x00) if present
//       final adjustedBytes = publicKeyBytes[0] == 0 ? publicKeyBytes.sublist(1) : publicKeyBytes;

//       // Parse the adjusted BIT STRING content as an ASN.1 sequence (RSAPublicKey structure)
//       final bitStringParser = ASN1Parser(adjustedBytes);
//       final publicKeySeq = bitStringParser.nextObject();

//       // Validate RSAPublicKey sequence
//       if (publicKeySeq is! ASN1Sequence || publicKeySeq.elements?.length != 2) {
//         throw Exception('Invalid RSAPublicKey structure in BIT STRING');
//       }

//       // Extract modulus and exponent
//       final modulusElement = publicKeySeq.elements?[0];
//       final exponentElement = publicKeySeq.elements?[1];

//       if (modulusElement is! ASN1Integer || exponentElement is! ASN1Integer) {
//         throw Exception('Modulus or exponent is not an ASN1Integer');
//       }

//       final modulus = modulusElement.integer;
//       final exponent = exponentElement.integer;

//       if (modulus == null || exponent == null) {
//         throw Exception('Modulus or exponent is null');
//       }

//       return RSAPublicKey(modulus, exponent);
//     } catch (e, stackTrace) {
//       throw Exception('Failed to parse public key: $e\n$stackTrace');
//     }
// }

//   // Parse PEM private key (supports PKCS#8)
//   RSAPrivateKey _parsePrivateKey(String pem) {
//     try {
//       final lines = pem.split('\n').where((line) => !line.contains('-----') && line.trim().isNotEmpty).join();
//       final asn1Parser = asn1lib.ASN1Parser(base64Decode(lines));
//       final topLevelSeq = asn1Parser.nextObject() as asn1lib.ASN1Sequence;

//       // PKCS#8: PrivateKeyInfo ::= SEQUENCE { ... privateKey OCTET STRING }
//       final privateKeyOctetString = topLevelSeq.elements[2] as asn1lib.ASN1OctetString;
//       final privateKeyAsn = asn1lib.ASN1Parser(privateKeyOctetString.valueBytes());
//       final pkSeq = privateKeyAsn.nextObject() as asn1lib.ASN1Sequence;

//       final modulus = (pkSeq.elements[1] as asn1lib.ASN1Integer).valueAsBigInteger;
//       final privateExponent = (pkSeq.elements[3] as asn1lib.ASN1Integer).valueAsBigInteger;
//       final p = (pkSeq.elements[4] as asn1lib.ASN1Integer).valueAsBigInteger;
//       final q = (pkSeq.elements[5] as asn1lib.ASN1Integer).valueAsBigInteger;
//       return RSAPrivateKey(modulus, privateExponent, p, q);
//     } catch (e) {
//       throw Exception('Failed to parse private key: $e');
//     }
//   }
//  /* 
//   // Encrypt data with RSA public key
//   Uint8List encrypt(Uint8List data, RSAPublicKey publicKey) {
//     try {
//       final cipher = RSAEngine()
//         ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));
//       final encrypted = cipher.process(data);
//       // logger.d('Encrypted data: ${base64Encode(encrypted)}');
//       return encrypted;
//     } catch (e) {
//       throw Exception('Encryption failed: $e');
//     }
//   }
//  */
//   Uint8List encrypt(String message, RSAPrivateKey privateKey) {
//     try {
//       final messageBytes = Uint8List.fromList(utf8.encode(message));

//       // --- ENCRYPTION ---
//       // Create an RSA engine with OAEP encoding – make sure to use the same algorithm parameters as in your server.
//       final oaepEncryptor = OAEPEncoding(RSAEngine())
//         ..init(
//           true, // true = encryption
//           PrivateKeyParameter<RSAPrivateKey>(privateKey),
//         );

//       // Encrypt the message (ensure that the message size is within RSA bounds)
//       return oaepEncryptor.process(messageBytes);
//     } catch (e) {
//       throw Exception('Encryption failed: $e');
//     }
//   }
// /* 
//   Uint8List encrypt(String message, RSAPublicKey publicKey) {
//     try {
//       final messageBytes = Uint8List.fromList(utf8.encode(message));

//       // --- ENCRYPTION ---
//       // Create an RSA engine with OAEP encoding – make sure to use the same algorithm parameters as in your server.
//       final oaepEncryptor = RSAEngine()
//         ..init(
//           true, // true = encryption
//           PublicKeyParameter<RSAPublicKey>(publicKey),
//         );

//       // Encrypt the message (ensure that the message size is within RSA bounds)
//       return oaepEncryptor.process(messageBytes);
//     } catch (e) {
//       throw Exception('Encryption failed: $e');
//     }
//   }
//  */  
//   // Sign data with RSA private key
//   Uint8List sign(Uint8List data, RSAPrivateKey privateKey) {
//     try {
//       final signer = RSASigner(SHA256Digest(), '0609608648016503040201')
//         ..init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));
//       final signature = signer.generateSignature(data).bytes;
//       // logger.d('Generated signature: ${base64Encode(signature)}');
//       return signature;
//     } catch (e) {
//       throw Exception('Signing failed: $e');
//     }
//   }

//   // Verify signature with RSA public key
//   bool verify(Uint8List data, Uint8List signature, RSAPublicKey publicKey) {
//     try {
//       final verifier = RSASigner(SHA256Digest(), '0609608648016503040201')
//         ..init(false, PublicKeyParameter<RSAPublicKey>(publicKey));
//       final verified = verifier.verifySignature(data, RSASignature(signature));
//       // logger.d('Signature verification result: $verified');
//       return verified;
//     } catch (e) {
//       throw Exception('Signature verification failed: $e');
//     }
//   }
// }
import 'package:fast_rsa/fast_rsa.dart' as fastRsa;

class RsaServices {
   final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 0,
      colors: true,
      printEmojis: true,
    ),
  );
  
  
  String? _appPrivateKey;
  String? _appPublicKey;
  String? _serverPublicKey;
  bool _isInitialized = false;

  String? getAppPrivateKey() => _appPrivateKey;
  String? getAppPublicKey() => _appPublicKey;
  String? getServerPublicKey() => _serverPublicKey;
  bool get isInitialized => _isInitialized;

  Future<void> initialize(BuildContext context) async {
    if (_isInitialized) return;
    try {
      AssetBundle resources = DefaultAssetBundle.of(context);

      _appPrivateKey = await resources.loadString('resources/indiefront_prv.pem');
      _appPublicKey = await resources.loadString('resources/indiefront_pub.pem');
      _serverPublicKey = await resources.loadString('resources/indieback_pub.pem');

      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to load or parse RSA key: $e');
    }
  }

  // Encrypt with public key (PEM)
  Future<String> encrypt(String message, String publicKeyPem) async {
    try {
      // return await fastRsa.RSA.encryptOAEP(message, '', fastRsa.Hash.SHA256, publicKeyPem);
      return await fastRsa.RSA.encryptPKCS1v15(message, publicKeyPem);
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  // Decrypt with private key (PEM)
  Future<String> decrypt(String base64Cipher, String privateKeyPem) async {
    try {
      // return await fastRsa.RSA.decryptOAEP(base64Cipher, '', fastRsa.Hash.SHA256, privateKeyPem);
      return await fastRsa.RSA.decryptPKCS1v15(base64Cipher, privateKeyPem);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  // Sign with private key (PEM)
  Future<String> sign(String message, String privateKeyPem) async {
    try {
      return await fastRsa.RSA.signPKCS1v15(message, fastRsa.Hash.SHA256, privateKeyPem);
    } catch (e) {
      throw Exception('Signing failed: $e');
    }
  }

  // Verify with public key (PEM)
  Future<bool> verify(String message, String signature, String publicKeyPem) async {
    try {
      return await fastRsa.RSA.verifyPKCS1v15(message, signature, fastRsa.Hash.SHA256, publicKeyPem);
    } catch (e) {
      throw Exception('Verification failed: $e');
    }
  }
}