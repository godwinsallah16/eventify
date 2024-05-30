import '../domain/cloud_services/cloud_storage.dart';

class UserName implements BaseModel {
  final String userName;

  UserName({
    required this.userName,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
    };
  }
}
