enum FraudRiskLevel { Safe, Medium, High, Critical }

class UserModel {
  final String uid;
  final String email;
  final String phoneNumber;
  final bool isSubscribed;
  final DateTime? subscriptionExpiry;
  final DateTime createdAt;

  // New fields for MFA and fraud risk
  final bool mfaEnabled;
  final String? quantumPublicKey;
  final FraudRiskLevel fraudRiskLevel;

  UserModel({
    required this.uid,
    required this.email,
    required this.phoneNumber,
    this.isSubscribed = false,
    this.subscriptionExpiry,
    required this.createdAt,
    this.mfaEnabled = false,
    this.quantumPublicKey,
    this.fraudRiskLevel = FraudRiskLevel.Safe,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      isSubscribed: json['isSubscribed'] ?? false,
      subscriptionExpiry: json['subscriptionExpiry']?.toDate(),
      createdAt: json['createdAt'].toDate(),
      mfaEnabled: json['mfaEnabled'] ?? false,
      quantumPublicKey: json['quantumPublicKey'],
      fraudRiskLevel: json['fraudRiskLevel'] != null
          ? FraudRiskLevel.values[json['fraudRiskLevel']]
          : FraudRiskLevel.Safe,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'phoneNumber': phoneNumber,
      'isSubscribed': isSubscribed,
      'subscriptionExpiry': subscriptionExpiry,
      'createdAt': createdAt,
      'mfaEnabled': mfaEnabled,
      'quantumPublicKey': quantumPublicKey,
      'fraudRiskLevel': fraudRiskLevel.index,
    };
  }
}
