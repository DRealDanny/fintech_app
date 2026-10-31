import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;
  const GetProfileUseCase(this.repository);

  Future<Either<Failure, UserProfileEntity>> call() => repository.getProfile();
}

class ToggleBiometricsUseCase {
  final ProfileRepository repository;
  const ToggleBiometricsUseCase(this.repository);

  Future<Either<Failure, UserProfileEntity>> call(bool enabled) =>
      repository.toggleBiometrics(enabled);
}

class ToggleNotificationsUseCase {
  final ProfileRepository repository;
  const ToggleNotificationsUseCase(this.repository);

  Future<Either<Failure, UserProfileEntity>> call(bool enabled) =>
      repository.toggleNotifications(enabled);
}

class UpgradeTierUseCase {
  final ProfileRepository repository;
  const UpgradeTierUseCase(this.repository);

  Future<Either<Failure, UserProfileEntity>> call(UserTier tier) =>
      repository.upgradeTier(tier);
}

class UploadKycDocumentUseCase {
  final ProfileRepository repository;
  const UploadKycDocumentUseCase(this.repository);

  Future<Either<Failure, UserProfileEntity>> call({
    required Uint8List fileBytes,
    required String fileName,
    required String documentType,
  }) =>
      repository.uploadKycDocument(
        fileBytes: fileBytes,
        fileName: fileName,
        documentType: documentType,
      );
}
