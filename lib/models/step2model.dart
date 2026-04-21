// /*

// class Step2Model {
//   int? serviceId;
//   String? perServicemanCharge;
//   int? requiredServicemen;
//   String? totalServicemenCharge;
//   int? discountPercent;
//   String? discountAmount;
//   String? totalAmount;
//   String? addonsTotalAmount;
//   List<AdditionalService>? additionalServices;

//   Step2Model(
//       {this.serviceId,
//       this.perServicemanCharge,
//       this.requiredServicemen,
//       this.totalServicemenCharge,
//       this.discountPercent,
//       this.discountAmount,
//       this.totalAmount,
//       this.addonsTotalAmount,
//       this.additionalServices});

//   Step2Model.fromJson(Map<String, dynamic> json) {
//     serviceId = json['service_id'];
//     perServicemanCharge = json['per_serviceman_charge'];
//     requiredServicemen = json['required_servicemen'];
//     totalServicemenCharge = json['total_servicemen_charge'];
//     discountPercent = json['discount_percent'];
//     discountAmount = json['discount_amount'];
//     totalAmount = json['total_amount'];
//     addonsTotalAmount = json['addons_total_amount'];
//     if (json['addons'] != null) {
//       additionalServices = <AdditionalService>[];
//       json['addons'].forEach((v) {
//         additionalServices!.add(AdditionalService.fromJson(v));
//       });
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['service_id'] = this.serviceId;
//     data['per_serviceman_charge'] = this.perServicemanCharge;
//     data['required_servicemen'] = this.requiredServicemen;
//     data['total_servicemen_charge'] = this.totalServicemenCharge;
//     data['discount_percent'] = this.discountPercent;
//     data['discount_amount'] = this.discountAmount;
//     data['total_amount'] = this.totalAmount;
//     data['addons_total_amount'] = this.addonsTotalAmount;
//     if (additionalServices != null) {
//       data['addons'] = additionalServices!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
// */

// class Step2Model {
//   int? serviceId;
//   String? perServicemanCharge;
//   int? requiredServicemen;
//   String? totalServicemenCharge;
//   int? discountPercent;
//   String? discountAmount;
//   String? addonsTotalAmount;
//   List<Addons>? additionalServices;
//   String? totalAmount;

//   Step2Model(
//       {this.serviceId,
//       this.perServicemanCharge,
//       this.requiredServicemen,
//       this.totalServicemenCharge,
//       this.discountPercent,
//       this.discountAmount,
//       this.addonsTotalAmount,
//       this.additionalServices,
//       this.totalAmount});

//   Step2Model.fromJson(Map<String, dynamic> json) {
//     serviceId = json['service_id'];
//     perServicemanCharge = json['per_serviceman_charge'];
//     requiredServicemen = json['required_servicemen'];
//     totalServicemenCharge = json['total_servicemen_charge'];
//     discountPercent = json['discount_percent'];
//     discountAmount = json['discount_amount'];
//     addonsTotalAmount = json['addons_total_amount'];
//     if (json['addons'] != null) {
//       additionalServices = <Addons>[];
//       json['addons'].forEach((v) {
//         additionalServices!.add(Addons.fromJson(v));
//       });
//     }
//     totalAmount = json['total_amount'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['service_id'] = serviceId;
//     data['per_serviceman_charge'] = perServicemanCharge;
//     data['required_servicemen'] = requiredServicemen;
//     data['total_servicemen_charge'] = totalServicemenCharge;
//     data['discount_percent'] = discountPercent;
//     data['discount_amount'] = discountAmount;
//     data['addons_total_amount'] = addonsTotalAmount;
//     if (additionalServices != null) {
//       data['addons'] = additionalServices!.map((v) => v.toJson()).toList();
//     }
//     data['total_amount'] = totalAmount;
//     return data;
//   }
// }

// class Addons {
//   int? id;
//   String? title;
//   int? price;

//   Addons({this.id, this.title, this.price});

//   Addons.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     title = json['title'];
//     price = json['price'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['title'] = title;
//     data['price'] = price;
//     return data;
//   }
// }

/*

class Step2Model {
  int? serviceId;
  String? perServicemanCharge;
  int? requiredServicemen;
  String? totalServicemenCharge;
  int? discountPercent;
  String? discountAmount;
  String? totalAmount;
  String? addonsTotalAmount;
  List<AdditionalService>? additionalServices;

  Step2Model(
      {this.serviceId,
      this.perServicemanCharge,
      this.requiredServicemen,
      this.totalServicemenCharge,
      this.discountPercent,
      this.discountAmount,
      this.totalAmount,
      this.addonsTotalAmount,
      this.additionalServices});

  Step2Model.fromJson(Map<String, dynamic> json) {
    serviceId = json['service_id'];
    perServicemanCharge = json['per_serviceman_charge'];
    requiredServicemen = json['required_servicemen'];
    totalServicemenCharge = json['total_servicemen_charge'];
    discountPercent = json['discount_percent'];
    discountAmount = json['discount_amount'];
    totalAmount = json['total_amount'];
    addonsTotalAmount = json['addons_total_amount'];
    if (json['addons'] != null) {
      additionalServices = <AdditionalService>[];
      json['addons'].forEach((v) {
        additionalServices!.add(AdditionalService.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['service_id'] = this.serviceId;
    data['per_serviceman_charge'] = this.perServicemanCharge;
    data['required_servicemen'] = this.requiredServicemen;
    data['total_servicemen_charge'] = this.totalServicemenCharge;
    data['discount_percent'] = this.discountPercent;
    data['discount_amount'] = this.discountAmount;
    data['total_amount'] = this.totalAmount;
    data['addons_total_amount'] = this.addonsTotalAmount;
    if (additionalServices != null) {
      data['addons'] = additionalServices!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
*/

class Step2Model {
  int? serviceId;
  String? perServicemanCharge;
  int? requiredServicemen;
  String? totalServicemenCharge;
  int? discountPercent;
  String? discountAmount;
  String? addonsTotalAmount;
  List<Addons>? additionalServices;
  String? totalAmount;

  Step2Model(
      {this.serviceId,
      this.perServicemanCharge,
      this.requiredServicemen,
      this.totalServicemenCharge,
      this.discountPercent,
      this.discountAmount,
      this.addonsTotalAmount,
      this.additionalServices,
      this.totalAmount});

  Step2Model.fromJson(Map<String, dynamic> json) {
    serviceId = json['service_id'];
    perServicemanCharge = json['per_serviceman_charge'];
    requiredServicemen = json['required_servicemen'];
    totalServicemenCharge = json['total_servicemen_charge'];
    discountPercent = json['discount_percent'];
    discountAmount = json['discount_amount'];
    addonsTotalAmount = json['addons_total_amount'];
    if (json['addons'] != null) {
      additionalServices = <Addons>[];
      json['addons'].forEach((v) {
        additionalServices!.add(Addons.fromJson(v));
      });
    }
    totalAmount = json['total_amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['service_id'] = serviceId;
    data['per_serviceman_charge'] = perServicemanCharge;
    data['required_servicemen'] = requiredServicemen;
    data['total_servicemen_charge'] = totalServicemenCharge;
    data['discount_percent'] = discountPercent;
    data['discount_amount'] = discountAmount;
    data['addons_total_amount'] = addonsTotalAmount;
    if (additionalServices != null) {
      data['addons'] = additionalServices!.map((v) => v.toJson()).toList();
    }
    data['total_amount'] = totalAmount;
    return data;
  }
}

class Addons {
  int? id;
  String? title;
  int? price;
  int? qty;
  dynamic totalPrice;

  Addons({this.id, this.title, this.price});

  Addons.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    price = json['price'];
    qty = json['qty'];
    totalPrice = json['total_price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['price'] = price;
    data['qty'] = qty;
    data['total_price'] = totalPrice;
    return data;
  }
}
