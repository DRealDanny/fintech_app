import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/user_profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfileEntity>> getProfile();

  Future<Either<Failure, UserProfileEntity>> toggleBiometrics(bool enabled);

  Future<Either<Failure, UserProfileEntity>> toggleNotifications(bool enabled);

  Future<Either<Failure, UserProfileEntity>> upgradeTier(UserTier newTier);

  Future<Either<Failure, UserProfileEntity>> uploadKycDocument({
    required Uint8List fileBytes,
    required String fileName,
    required String documentType,
  });
}
