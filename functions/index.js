const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

exports.sendChatNotification = onDocumentCreated(
  "chats/{chatId}/messages/{messageId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const messageData = snapshot.data();
    const receiverId = messageData.receiverId; // UID ของผู้รับ
    const senderName = messageData.senderName || "มีข้อความใหม่"; // ชื่อผู้ส่ง
    const text = messageData.text || "ส่งรูปภาพหรือข้อความ"; // ข้อความ

    try {
      // 1. ไปดึง fcmToken ของผู้รับจาก Collection 'users'
      const userDoc = await getFirestore().collection("users").doc(receiverId).get();
      
      if (!userDoc.exists) {
        console.log("ไม่พบข้อมูลผู้รับ");
        return;
      }

      const fcmToken = userDoc.data().fcmToken;

      if (!fcmToken) {
        console.log("ผู้รับไม่มี fcmToken");
        return;
      }

      // 2. สร้างโครงสร้าง Notification
      const payload = {
        token: fcmToken,
        notification: {
          title: senderName,
          body: text,
        },
        data: {
          chatId: event.params.chatId,
        },
      };

      // 3. ยิงแจ้งเตือนผ่าน FCM
      const response = await getMessaging().send(payload);
      console.log("ส่งแจ้งเตือนสำเร็จ:", response);
    } catch (error) {
      console.error("เกิดข้อผิดพลาดในการส่งแจ้งเตือน:", error);
    }
  }
);