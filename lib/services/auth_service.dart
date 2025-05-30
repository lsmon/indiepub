import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:indiepub/services/api_service.dart';
import 'package:indiepub/services/database_service.dart';
import 'package:indiepub/services/rsa_services.dart';
import 'package:logger/logger.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final DatabaseService _dbService = DatabaseService();
  final RsaServices _rsaServices = RsaServices();
  final logger = Logger();

  String? _currentUserId;
  String? getCurrentUserId() => _currentUserId;
  void setCurrentUserId(String id) => _currentUserId = id;
  
  AuthService(BuildContext context) {
    _rsaServices.initialize(context);
  }
  

  Future<void> _ensureInitialized() async {
    if (!_rsaServices.isInitialized) {
      String errMsg = 'RsaServices not initialized. Call RsaServices().initialize(context) during app startup.';
      logger.e(errMsg);
      throw Exception(errMsg);
    }
    if (_rsaServices.getServerPublicKey() == null || _rsaServices.getAppPrivateKey() == null) {
      throw Exception('RSA keys not initialized');
    }
  }


  Future<String?> login(BuildContext context, String email, String password) async {
    _rsaServices.initialize(context);
    _ensureInitialized();
    final encryptedEmail = base64Encode(
      _rsaServices.encrypt(
        Uint8List.fromList(utf8.encode(email)), 
        _rsaServices.getServerPublicKey()!));
    final encryptedPassword = base64Encode(
      _rsaServices.encrypt(
        Uint8List.fromList(utf8.encode(password)), 
        _rsaServices.getServerPublicKey()!));
    final signature = base64Encode(
      _rsaServices.sign(
        Uint8List.fromList(utf8.encode(encryptedPassword)),
        _rsaServices.getAppPrivateKey()!));
    try {
      final user = await _apiService.login(encryptedEmail, '$encryptedPassword:$signature');
      if (user != null) {
        await _dbService.insertUser(user);
        _currentUserId = user.id;
        return user.id;
      }
      return null;
    } catch (e) {
      logger.i(e);
      return null;
    }
  }

  Future<String?> signup(BuildContext context, String email, String password, String role) async {
    _rsaServices.initialize(context);
    _ensureInitialized();
    final encryptedEmail = base64Encode(
      _rsaServices.encrypt(
        Uint8List.fromList(utf8.encode(email)), 
        _rsaServices.getServerPublicKey()!));
    final encryptedPassword = base64Encode(
      _rsaServices.encrypt(
        Uint8List.fromList(utf8.encode(password)), 
        _rsaServices.getServerPublicKey()!));
    final encryptedRole = base64Encode(
      _rsaServices.encrypt(
        Uint8List.fromList(utf8.encode(role)), 
        _rsaServices.getServerPublicKey()!));
    final signature = base64Encode(
      _rsaServices.sign(
        Uint8List.fromList(utf8.encode(encryptedPassword)),
        _rsaServices.getAppPrivateKey()!));
    
    try {
      final user = await _apiService.signup(encryptedEmail, '$encryptedPassword:$signature', encryptedRole);
      if (user != null) {
        await _dbService.insertUser(user);
        _currentUserId = user.id;
        return user.id;
      }
      return null;
    } catch (e) {
      logger.e(e);
      return null;
    }
  }
}