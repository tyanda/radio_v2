# radio_v2

# Radio V2

A new Flutter project for Sakha Radio with integrated horoscope, weather, and RSS feed functionality.

## Features

- Radio streaming
- Weather information
- Daily horoscopes
- RSS feed integration
- Multi-platform support (Android, iOS, Web, Desktop)

## Special Feature: CORS Proxy Server

This project includes a special proxy server solution to handle CORS (Cross-Origin Resource Sharing) issues when requesting data from external APIs like `horo.mail.ru`.

### Problem
When running the app in a web browser, direct requests to external APIs like `horo.mail.ru` are blocked by the browser due to CORS security policies.

### Solution
A Node.js proxy server is included that acts as an intermediary, fetching data from external APIs and serving it to the Flutter app without CORS restrictions.

### Setup
1. Install Node.js dependencies: `npm install`
2. Start the proxy server: `node server.js`
3. Run the Flutter app: `flutter run -d chrome`

Alternatively, you can use the startup script:
- On Windows: `run_app.bat`
- On Linux/Mac: `./run_app.sh`

The proxy server runs on port 5000 and handles requests to external APIs securely.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
