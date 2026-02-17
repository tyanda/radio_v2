const functions = require("firebase-functions");
const axios = require("axios");

// Функция для получения новостей без CORS
exports.getNews = functions.https.onCall(async (data, context) => {
  try {
    const response = await axios.get("https://ysia.ru/feed/");
    return response.data; // Отправляем XML/текст во Flutter
  } catch (error) {
    console.error("Ошибка запроса:", error);
    throw new functions.https.HttpsError("internal", "Server error");
  }
});