enum FraudRiskLevel {
  safe,
  low,
  medium,
  high,
  critical,
}

class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final String? phoneNumber;
  final DateTime? createdAt;
  final bool? mfaEnabled;
  final String? quantumPublicKey;
  final FraudRiskLevel? fraudRiskLevel;

  UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.phoneNumber,
    this.createdAt,
    this.mfaEnabled,
    this.quantumPublicKey,
    this.fraudRiskLevel = FraudRiskLevel.safe,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoURL: json['photoURL'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      mfaEnabled: json['mfaEnabled'] as bool?,
      quantumPublicKey: json['quantumPublicKey'] as String?,
      fraudRiskLevel: json['fraudRiskLevel'] != null
          ? FraudRiskLevel.values.firstWhere(
              (e) => e.toString() == 'FraudRiskLevel.' + json['fraudRiskLevel'],
              orElse: () => FraudRiskLevel.safe,
            )
          : FraudRiskLevel.safe,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt?.toIso8601String(),
      'mfaEnabled': mfaEnabled,
      'quantumPublicKey': quantumPublicKey,
      'fraudRiskLevel': fraudRiskLevel?.toString().split('.').last,
    };
  }
}
