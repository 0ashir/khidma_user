class Payment {
  Payment({
    this.id,
    this.userId,
    this.orderId,
    this.type,
    this.txnId,
    this.amount,
    this.currencySymbol,
    this.currencyDecimalPlaces,
    this.status,
    this.message,
    this.translatedStatus,
    this.translatedMessage,
    this.transactionDate,
  });

  Payment.fromJson(final Map<String, dynamic> json) {
    id = json["id"]?.toString() ?? '';
    userId = json["user_id"]?.toString() ?? '';
    orderId = json["order_id"]?.toString() ?? '';
    type = json["type"]?.toString() ?? '';
    txnId = json["txn_id"]?.toString() ?? '';
    amount = json["amount"]?.toString() ?? '';
    currencySymbol = json["currency_symbol"]?.toString() ?? '';
    currencyDecimalPlaces = int.tryParse(
      json["currency_decimal_places"]?.toString() ?? '',
    );
    status = json["status"]?.toString() ?? '';
    message = json["message"]?.toString() ?? '';

    translatedStatus = (json["translated_status"]?.toString() ?? '').isNotEmpty
        ? json["translated_status"]!.toString()
        : (json["status"]?.toString() ?? '');

    translatedMessage =
        (json["translated_message"]?.toString() ?? '').isNotEmpty
        ? json["translated_message"]!.toString()
        : (json["message"]?.toString() ?? '');

    transactionDate = json["transaction_date"]?.toString() ?? '';
  }

  String? id;
  String? userId;
  String? orderId;
  String? type;
  String? txnId;
  String? amount;
  String? currencySymbol;
  int? currencyDecimalPlaces;
  String? status;
  String? message;
  String? translatedStatus;
  String? translatedMessage;
  String? transactionDate;
}
