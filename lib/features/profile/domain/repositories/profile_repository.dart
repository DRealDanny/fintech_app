import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/user_profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfileEntity>> getProfile();

  Future<Either<Failure, UserProfileEntity>> toggleBiometrics(bool enabled);

  Future<Either<Failure, UserProfileEntity>> toggleNotifications(bool enabled);

  Future<Either<Failure, UserProfileEntity>> upgradeTier(UserTier newTier);
}
