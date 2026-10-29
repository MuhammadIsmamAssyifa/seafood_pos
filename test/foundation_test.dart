import 'package:flutter_test/flutter_test.dart';
import 'package:seafood_pos/core/api/api_exception.dart';
import 'package:seafood_pos/core/api/api_response.dart';
import 'package:seafood_pos/core/config/env_config.dart';
import 'package:seafood_pos/core/utils/formatter.dart';
import 'package:seafood_pos/core/utils/validators.dart';
import 'package:seafood_pos/features/auth/models/user_model.dart';
import 'package:seafood_pos/shared/enums/app_enums.dart';

void main() {
  group('Foundation Unit Tests', () {
    test('EnvConfig switches environments correctly', () {
      EnvConfig.init(environment: AppEnvironment.development);
      expect(EnvConfig.isDevelopment, isTrue);
      expect(EnvConfig.appName, contains('Dev'));

      EnvConfig.init(environment: AppEnvironment.production);
      expect(EnvConfig.isProduction, isTrue);
      expect(EnvConfig.appName, equals('Seafood POS'));
    });

    test('AppFormatter formats currency correctly', () {
      final formatted = AppFormatter.formatCurrency(50000);
      expect(formatted, contains('50.000'));
    });

    test('AppValidators validate inputs as expected', () {
      expect(AppValidators.requiredField(''), isNotNull);
      expect(AppValidators.requiredField('Seafood'), isNull);

      expect(AppValidators.email('invalid-email'), isNotNull);
      expect(AppValidators.email('kasir@restoran.com'), isNull);

      expect(AppValidators.password('123'), isNotNull);
      expect(AppValidators.password('secret123'), isNull);
    });

    test('ApiException parses correctly', () {
      final exception = ApiException(
        message: 'Validasi gagal',
        statusCode: 422,
        type: ApiExceptionType.validationError,
        errors: {
          'email': ['Email sudah terdaftar']
        },
      );

      expect(exception.statusCode, equals(422));
      expect(exception.firstValidationError, equals('Email sudah terdaftar'));
    });

    test('ApiResponse and UserModel serialize correctly', () {
      final userJson = {
        'id': 1,
        'name': 'Kasir Utama',
        'username': 'kasir1',
        'email': 'kasir@resto.id',
        'role': 'cashier',
        'token': 'mock-jwt-token',
      };

      final user = UserModel.fromJson(userJson);
      expect(user.id, equals(1));
      expect(user.name, equals('Kasir Utama'));
      expect(user.role, equals(UserRole.cashier));

      final response = ApiResponse<UserModel>.success(data: user);
      expect(response.success, isTrue);
      expect(response.data?.name, equals('Kasir Utama'));
    });
  });
}

