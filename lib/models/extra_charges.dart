class ExtraCharges {
  int? id;
  String? title;
  int? perServiceAmount;
  int? noServiceDone;
  String? paymentMethod;
  String? paymentStatus;
  int? total;
  dynamic taxAmount;
  int? platformFees;
  dynamic grandTotal;

  ExtraCharges(
      {this.id,
      this.title,
      this.perServiceAmount,
      this.noServiceDone,
      this.paymentMethod,
      this.paymentStatus,
      this.total,
      this.taxAmount,
      this.platformFees,
      this.grandTotal});

  ExtraCharges.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    perServiceAmount = json['per_service_amount'];
    noServiceDone = json['no_service_done'];
    paymentMethod = json['payment_method'];
    paymentStatus = json['payment_status'];
    total = json['total'];
    taxAmount = json['tax_amount'];
    platformFees = json['platform_fees'];
    grandTotal = json['grand_total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['per_service_amount'] = perServiceAmount;
    data['no_service_done'] = noServiceDone;
    data['payment_method'] = paymentMethod;
    data['payment_status'] = paymentStatus;
    data['total'] = total;
    data['tax_amount'] = taxAmount;
    data['platform_fees'] = platformFees;
    data['grand_total'] = grandTotal;
    return data;
  }
}
// class ExtraCharges {
//   int? id;
//   String? title;
//   int? perServiceAmount;
//   int? noServiceDone;
//   String? paymentMethod;
//   String? paymentStatus;
//   int? total;
//   double? taxAmount;
//   int? platformFees;
//   double? grandTotal;

//   ExtraCharges(
//       {this.id,
//       this.title,
//       this.perServiceAmount,
//       this.noServiceDone,
//       this.paymentMethod,
//       this.paymentStatus,
//       this.total,
//       this.taxAmount,
//       this.platformFees,
//       this.grandTotal});

//   ExtraCharges.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     title = json['title'];
//     perServiceAmount = json['per_service_amount'];
//     noServiceDone = json['no_service_done'];
//     paymentMethod = json['payment_method'];
//     paymentStatus = json['payment_status'];
//     total = json['total'];
//     taxAmount = json['tax_amount'];
//     platformFees = json['platform_fees'];
//     grandTotal = json['grand_total'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = Map<String, dynamic>();
//     data['id'] = this.id;
//     data['title'] = this.title;
//     data['per_service_amount'] = this.perServiceAmount;
//     data['no_service_done'] = this.noServiceDone;
//     data['payment_method'] = this.paymentMethod;
//     data['payment_status'] = this.paymentStatus;
//     data['total'] = this.total;
//     data['tax_amount'] = this.taxAmount;
//     data['platform_fees'] = this.platformFees;
//     data['grand_total'] = this.grandTotal;
//     return data;
//   }
// }
