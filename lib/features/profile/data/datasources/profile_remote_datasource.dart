import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ProfileRemoteDataSource {
  Future<Map<String, dynamic>?> getProfile(String userId);

  Stream<Map<String, dynamic>?> streamProfile(String userId);

  Future<String> uploadKycDocument({
    required String userId,
    required Uint8List fileBytes,
    required String fileExtension,
    required String documentType,
  });

  Future<void> updateKycStatus({
    required String userId,
    required String status,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient client;

  ProfileRemoteDataSourceImpl({required this.client});

  @override
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final response = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return response;
  }

  @override
  Stream<Map<String, dynamic>?> streamProfile(String userId) {
    return client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((rows) => rows.isNotEmpty ? rows.first : null);
  }

  @override
  Future<String> uploadKycDocument({
    required String userId,
    required Uint8List fileBytes,
    required String fileExtension,
    required String documentType,
  }) async {
    final ext = fileExtension.replaceAll('.', '').toLowerCase();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final storagePath = '$userId/kyc_${documentType}_$timestamp.$ext';

    String mimeType = 'image/jpeg';
    if (ext == 'png') {
      mimeType = 'image/png';
    } else if (ext == 'webp') {
      mimeType = 'image/webp';
    } else if (ext == 'pdf') {
      mimeType = 'application/pdf';
    }

    // 1. Upload to Supabase Storage bucket 'kyc-documents'
    await client.storage.from('kyc-documents').uploadBinary(
          storagePath,
          fileBytes,
          fileOptions: FileOptions(
            contentType: mimeType,
            upsert: true,
          ),
        );

    // 2. Update user profile row with pending KYC status and document reference
    final nowIso = DateTime.now().toIso8601String();
    await client.from('profiles').upsert({
      'id': userId,
      'kyc_status': 'pending',
      'kyc_document_url': storagePath,
      'kyc_document_type': documentType,
      'kyc_submitted_at': nowIso,
      'updated_at': nowIso,
    });

    return storagePath;
  }

  @override
  Future<void> updateKycStatus({
    required String userId,
    required String status,
  }) async {
    await client.from('profiles').update({
      'kyc_status': status,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }
}

