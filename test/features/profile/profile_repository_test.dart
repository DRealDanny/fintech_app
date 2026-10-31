import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:fintech_app/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:fintech_app/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:fintech_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:fintech_app/features/profile/domain/entities/user_profile_entity.dart';

class MockProfileLocalDataSource implements ProfileLocalDataSource {
  UserProfileEntity profile = const UserProfileEntity(
    fullName: 'Danny Adebayo',
    email: 'danny@nova.finance',
    phone: '+234 801 234 5678',
    novaTag: '\$danny.nova',
    tier: UserTier.tier1Basic,
    dailyLimitDollars: 5000,
    isBiometricEnabled: true,
    pushNotificationsEnabled: true,
    twoFactorEnabled: true,
    kycStatus: 'none',
  );

  @override
  Future<UserProfileEntity> getProfile() async => profile;

  @override
  Future<UserProfileEntity> updateBiometrics(bool enabled) async {
    profile = profile.copyWith(isBiometricEnabled: enabled);
    return profile;
  }

  @override
  Future<UserProfileEntity> updateNotifications(bool enabled) async {
    profile = profile.copyWith(pushNotificationsEnabled: enabled);
    return profile;
  }

  @override
  Future<UserProfileEntity> updateTier(UserTier tier) async {
    profile = profile.copyWith(tier: tier);
    return profile;
  }

  @override
  Future<UserProfileEntity> updateKycStatus({
    required String status,
    String? docUrl,
    String? docType,
  }) async {
    profile = profile.copyWith(
      kycStatus: status,
      kycDocumentUrl: docUrl,
      kycDocumentType: docType,
      tier: status == 'approved' ? UserTier.tier2Verified : profile.tier,
    );
    return profile;
  }
}

class MockProfileRemoteDataSource implements ProfileRemoteDataSource {
  bool uploadCalled = false;

  @override
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    return {
      'id': userId,
      'full_name': 'Danny Remote',
      'email': 'danny@remote.io',
      'kyc_status': 'none',
    };
  }

  @override
  Stream<Map<String, dynamic>?> streamProfile(String userId) {
    return Stream.value({'id': userId, 'kyc_status': 'none'});
  }

  @override
  Future<String> uploadKycDocument({
    required String userId,
    required Uint8List fileBytes,
    required String fileExtension,
    required String documentType,
  }) async {
    uploadCalled = true;
    return '$userId/kyc_document.jpg';
  }

  @override
  Future<void> updateKycStatus({
    required String userId,
    required String status,
  }) async {}
}

void main() {
  late MockProfileLocalDataSource mockLocalDs;
  late MockProfileRemoteDataSource mockRemoteDs;
  late ProfileRepositoryImpl repository;

  setUp(() {
    mockLocalDs = MockProfileLocalDataSource();
    mockRemoteDs = MockProfileRemoteDataSource();
    repository = ProfileRepositoryImpl(
      localDataSource: mockLocalDs,
      remoteDataSource: mockRemoteDs,
    );
  });

  test('getProfile returns default profile successfully', () async {
    final result = await repository.getProfile();
    expect(result.isRight(), isTrue);
    result.fold(
      (failure) => fail('Expected Right but got Left($failure)'),
      (profile) {
        expect(profile.fullName, equals('Danny Adebayo'));
        expect(profile.tier, equals(UserTier.tier1Basic));
        expect(profile.isKycApproved, isFalse);
      },
    );
  });

  test('uploadKycDocument updates status to pending', () async {
    final dummyBytes = Uint8List.fromList([1, 2, 3, 4]);
    final result = await repository.uploadKycDocument(
      fileBytes: dummyBytes,
      fileName: 'nin_slip.jpg',
      documentType: 'national_id',
    );

    expect(result.isRight(), isTrue);
    result.fold(
      (failure) => fail('Expected Right but got Left($failure)'),
      (profile) {
        expect(profile.kycStatus, equals('pending'));
        expect(profile.isKycPending, isTrue);
      },
    );
  });
}

