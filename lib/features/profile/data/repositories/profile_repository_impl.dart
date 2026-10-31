import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/services/supabase_client.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;
  final ProfileRemoteDataSource? remoteDataSource;

  ProfileRepositoryImpl({
    required this.localDataSource,
    this.remoteDataSource,
  });

  @override
  Future<Either<Failure, UserProfileEntity>> getProfile() async {
    try {
      // 1. Try fetching from live Supabase DB
      if (remoteDataSource != null && SupabaseService.isInitialized) {
        try {
          final userId = SupabaseService.client.auth.currentUser?.id;
          if (userId != null) {
            final row = await remoteDataSource!.getProfile(userId);
            if (row != null) {
              final kycStatus = row['kyc_status'] as String? ?? 'none';
              final userTier = kycStatus == 'approved'
                  ? UserTier.tier2Verified
                  : UserTier.tier1Basic;

              final profile = UserProfileEntity(
                fullName: row['full_name'] as String? ?? 'Danny Adebayo',
                email: row['email'] as String? ?? 'danny@nova.finance',
                phone: SupabaseService.client.auth.currentUser?.phone ??
                    '+234 801 234 5678',
                novaTag: '\$danny.nova',
                tier: userTier,
                dailyLimitDollars: userTier == UserTier.tier2Verified ? 25000 : 5000,
                isBiometricEnabled: true,
                pushNotificationsEnabled: true,
                twoFactorEnabled: true,
                kycStatus: kycStatus,
                kycDocumentUrl: row['kyc_document_url'] as String?,
                kycDocumentType: row['kyc_document_type'] as String?,
                kycSubmittedAt: row['kyc_submitted_at'] != null
                    ? DateTime.tryParse(row['kyc_submitted_at'] as String)
                    : null,
              );
              return Right(profile);
            }
          }
        } catch (_) {
          // Fall through to local fallback
        }
      }

      // 2. Local fallback
      final p = await localDataSource.getProfile();
      return Right(p);
    } catch (e) {
      return Left(CacheFailure('Failed to load profile: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfileEntity>> toggleBiometrics(
      bool enabled) async {
    try {
      final p = await localDataSource.updateBiometrics(enabled);
      return Right(p);
    } catch (e) {
      return Left(CacheFailure('Failed to update biometrics: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfileEntity>> toggleNotifications(
      bool enabled) async {
    try {
      final p = await localDataSource.updateNotifications(enabled);
      return Right(p);
    } catch (e) {
      return Left(CacheFailure('Failed to update notifications: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfileEntity>> upgradeTier(
      UserTier newTier) async {
    try {
      final p = await localDataSource.updateTier(newTier);
      return Right(p);
    } catch (e) {
      return Left(CacheFailure('Failed to upgrade tier: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfileEntity>> uploadKycDocument({
    required Uint8List fileBytes,
    required String fileName,
    required String documentType,
  }) async {
    try {
      String? uploadedPath;

      // 1. Try uploading to Supabase Storage Vault
      if (remoteDataSource != null && SupabaseService.isInitialized) {
        try {
          final userId =
              SupabaseService.client.auth.currentUser?.id ?? 'usr_dev';
          final ext = fileName.contains('.') ? fileName.split('.').last : 'jpg';

          uploadedPath = await remoteDataSource!.uploadKycDocument(
            userId: userId,
            fileBytes: fileBytes,
            fileExtension: ext,
            documentType: documentType,
          );
        } catch (e) {
          // Storage bucket might still need policy application; continue with local sync
        }
      }

      // 2. Update local state to pending
      final updated = await localDataSource.updateKycStatus(
        status: 'pending',
        docUrl: uploadedPath ?? fileName,
        docType: documentType,
      );

      return Right(updated);
    } catch (e) {
      return Left(ServerFailure('Failed to upload KYC document: $e'));
    }
  }
}
