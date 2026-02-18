import '../models/auth_response.dart';
import '../models/login_request.dart';

abstract class AuthInterface {
  Future<AuthResponse> login(LoginRequest request);
}
