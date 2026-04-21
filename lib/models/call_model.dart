
class Call {
  String? callerId;
  String? callerName;
  String? callerPic;
  String? receiverId;
  String? receiverName;
  String? receiverPic;
  String? channelId;
  int? timestamp;
  bool? hasDialled;
  bool? isVideoCall;
  String? agoraToken;

  Call({
    this.callerId,
    this.callerName,
    this.callerPic,
    this.receiverId,
    this.receiverName,
    this.receiverPic,
    this.timestamp,
    this.channelId,
    this.hasDialled,
    this.isVideoCall,
    this.agoraToken,
  });

  // to map
  Map<String, dynamic> toMap(Call call) {
    Map<String, dynamic> callMap = {};
    callMap["callerId"] = call.callerId;
    callMap["callerName"] = call.callerName;
    callMap["callerPic"] = call.callerPic;
    callMap["receiverId"] = call.receiverId;
    callMap["receiverName"] = call.receiverName;
    callMap["receiverPic"] = call.receiverPic;
    callMap["channelId"] = call.channelId;
    callMap["hasDialled"] = call.hasDialled;
    callMap["isVideoCall"] = call.isVideoCall;
    callMap["timestamp"] = call.timestamp;
    callMap["agoraToken"] = call.agoraToken;
    return callMap;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["callerId"] = callerId;
    data["callerName"] = callerName;
    data["callerPic"] = callerPic;
    data["receiverId"] = receiverId;
    data["receiverName"] = receiverName;
    data["receiverPic"] = receiverPic;
    data["channelId"] = channelId;
    data["hasDialled"] = hasDialled;
    data["isVideoCall"] = isVideoCall;
    data["timestamp"] = timestamp;
    data["agoraToken"] = agoraToken;
    return data;
  }

  Call.fromMap(Map callMap) {
    callerId = callMap["callerId"];
    callerName = callMap["callerName"];
    callerPic = callMap["callerPic"];
    receiverId = callMap["receiverId"];
    receiverName = callMap["receiverName"];
    receiverPic = callMap["receiverImage"];
    channelId = callMap["channelId"];
    hasDialled = callMap["hasDialled"];
    isVideoCall = callMap["isVideoCall"];
    timestamp = callMap["timestamp"];
    agoraToken = callMap["agoraToken"];
  }
}
