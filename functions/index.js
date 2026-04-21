const {onCall} = require("firebase-functions/v2/https");
const {RtcTokenBuilder, RtcRole} = require("agora-access-token");


exports.generateToken = onCall(
    (request) => {
      console.log(request.data.appId);
      const appId = request.data.appId;
      const appCertificate = request.data.appCertificate;
      const channelName = Math.floor(Math.random() * 100).toString();
      const uid = 0; // UID for the token, 0 for default
      const role = RtcRole.PUBLISHER; // or use RtcRole.SUBSCRIBER
      const expireTime = 36000; // Token expiration time in seconds (1 hour)

      if (!appId || !appCertificate) {
        throw new Error("Agora APP_ID or APP_CERTIFICATE not configured");
      }

      // Calculate token expiration time
      const currentTime = Math.floor(Date.now() / 1000);
      const privilegeExpiredTs = currentTime + expireTime;

      // Generate the Agora token
      const token = RtcTokenBuilder.buildTokenWithUid(
          appId,
          appCertificate,
          channelName,
          uid,
          role,
          privilegeExpiredTs,
      );

      return {
        data: {
          token: token,
          channelName: channelName,
        },
      };
    },
);
