importScripts("https://www.gstatic.com/firebasejs/9.22.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.22.1/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyApqgccLr4zrPFv5PIXgQiJa4BKfSRkw7Q",
  appId: "1:1097107309921:web:72ee1a1fd96448f62d3120",
  messagingSenderId: "1097107309921",
  projectId: "sakhalive-ticker",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('Received background message ', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/favicon.png'
  };

  return self.registration.showNotification(notificationTitle,
    notificationOptions);
});
