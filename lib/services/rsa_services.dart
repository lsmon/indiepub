import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/signers/rsa_signer.dart';
import 'package:asn1lib/asn1lib.dart' as asn1lib;

class RsaServices {
  RSAPrivateKey? _appPrivateKey;
  RSAPublicKey? _appPublicKey;
  RSAPublicKey? _serverPublicKey;
  bool _isInitialized = false;

  RSAPrivateKey? getAppPrivateKey() => _appPrivateKey;
  RSAPublicKey? getAppPublicKey() => _appPublicKey;
  RSAPublicKey? getServerPublicKey() => _serverPublicKey;
  bool get isInitialized => _isInitialized;

  Future<void> initialize(BuildContext context) async {
    if (_isInitialized) return;
    try {
      AssetBundle resources = DefaultAssetBundle.of(context);

      final appPrivateKey = await resources.loadString('resources/indiepub.pem');
      final appPublicKey = await resources.loadString('resources/public_indiepub.pem');
      final serverPublicKey = await resources.loadString('resources/indieback.pub');

      _appPrivateKey = _parsePrivateKey(appPrivateKey);
      _appPublicKey = _parsePublicKey(appPublicKey);
      _serverPublicKey = _parsePublicKey(serverPublicKey);
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to load or parse RSA key: $e');
    }
  }

  // Parse PEM public key
  RSAPublicKey _parsePublicKey(String pem) {
    try {
      final lines = pem.split('\n').where((line) => !line.contains('-----') && line.trim().isNotEmpty).join();
      final parser = asn1lib.ASN1Parser(base64Decode(lines));
      final seq = parser.nextObject() as asn1lib.ASN1Sequence;
      final modulus = (seq.elements[0] as asn1lib.ASN1Integer).valueAsBigInteger;
      final exponent = (seq.elements[1] as asn1lib.ASN1Integer).valueAsBigInteger;
      return RSAPublicKey(modulus, exponent);
    } catch (e) {
      throw Exception('Failed to parse public key: $e');
    }
  }

  // Parse PEM private key
  RSAPrivateKey _parsePrivateKey(String pem) {
    try {
      final lines = pem.split('\n').where((line) => !line.contains('-----') && line.trim().isNotEmpty).join();
      final parser = asn1lib.ASN1Parser(base64Decode(lines));
      final seq = parser.nextObject() as asn1lib.ASN1Sequence;
      final modulus = (seq.elements[1] as asn1lib.ASN1Integer).valueAsBigInteger;
      final privateExponent = (seq.elements[3] as asn1lib.ASN1Integer).valueAsBigInteger;
      final p = (seq.elements[4] as asn1lib.ASN1Integer).valueAsBigInteger;
      final q = (seq.elements[5] as asn1lib.ASN1Integer).valueAsBigInteger;
      return RSAPrivateKey(modulus, privateExponent, p, q);
    } catch (e) {
      throw Exception('Failed to parse private key: $e');
    }
  }

  // Encrypt data with RSA public key
  Uint8List encrypt(Uint8List data, RSAPublicKey publicKey) {
    try {
      final cipher = RSAEngine()
        ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));
      return cipher.process(data);
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  // Sign data with RSA private key
  Uint8List sign(Uint8List data, RSAPrivateKey privateKey) {
    try {
      final signer = RSASigner(SHA256Digest(), '0609608648016503040201')
        ..init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));
      return signer.generateSignature(data).bytes;
    } catch (e) {
      throw Exception('Signing failed: $e');
    }
  }

  // Verify signature with RSA public key
  bool verify(Uint8List data, Uint8List signature, RSAPublicKey publicKey) {
    try {
      final verifier = RSASigner(SHA256Digest(), '0609608648016503040201')
        ..init(false, PublicKeyParameter<RSAPublicKey>(publicKey));
      return verifier.verifySignature(data, RSASignature(signature));
    } catch (e) {
      throw Exception('Signature verification failed: $e');
    }
  }
}