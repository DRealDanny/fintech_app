import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, UserProfileEntity>> getProfile() async {
    try {
      final p = await localDataSource.getProfile();
      return Right(p);
    } catch (e) {
      return Left(CacheFailure('Failed to load profile: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfileEntity>> toggleBiometrics(bool enabled) async {
    try {
      final p = await localDataSource.updateBiometrics(enabled);
      return Right(p);
    } catch (e) {
      return Left(CacheFailure('Failed to update biometrics: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfileEntity>> toggleNotifications(bool enabled) async {
    try {
      final p = await localDataSource.updateNotifications(enabled);
      return Right(p);
    } catch (e) {
      return Left(CacheFailure('Failed to update notifications: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfileEntity>> upgradeTier(UserTier newTier) async {
    try {
      final p = await localDataSource.updateTier(newTier);
      return Right(p);
    } catch (e) {
      return Left(CacheFailure('Failed to upgrade tier: $e'));
    }
  }
}
