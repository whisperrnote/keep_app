import 'package:appwrite/appwrite.dart';
import '../constants/appwrite_constants.dart';

class AppwriteService {
  static final AppwriteService _instance = AppwriteService._internal();
  
  late Client _client;
  late Account _account;
  late Databases _databases;
  late Storage _storage;
  
  factory AppwriteService() {
    return _instance;
  }
  
  AppwriteService._internal() {
    _client = Client()
      .setEndpoint(AppwriteConstants.endpoint)
      .setProject(AppwriteConstants.projectId)
      .setSelfSigned(status: true); // For dev/self-signed certs if needed

    _account = Account(_client);
    _databases = Databases(_client);
    _storage = Storage(_client);
  }
  
  Client get client => _client;
  Account get account => _account;
  Databases get databases => _databases;
  Storage get storage => _storage;
}
