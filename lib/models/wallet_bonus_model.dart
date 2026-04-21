class WalletBonusModel {
  bool? success;
  List<WalletBonus>? data;

  WalletBonusModel({this.success, this.data});

  WalletBonusModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <WalletBonus>[];
      json['data'].forEach((v) {
        data!.add(WalletBonus.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class WalletBonus {
  int? id;
  String? name;
  String? description;

  WalletBonus({this.id, this.name, this.description});

  WalletBonus.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    return data;
  }

  @override
  String toString() {
    return 'WalletBonus(id: $id, title: $name, amount: $description)';
  }
}
