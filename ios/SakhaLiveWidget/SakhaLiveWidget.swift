//
//  SakhaLiveWidget.swift
//  SakhaLiveWidget
//
//  Виджет для главного экрана iOS
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), stationName: "SakhaLive", currentTrack: "Нажмите для запуска", isPlaying: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), stationName: "SakhaLive", currentTrack: "", isPlaying: false)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Получаем данные из UserDefaults (shared с основным приложением)
        let defaults = UserDefaults(suiteName: "group.com.sakhalive.shared")
        let stationName = defaults?.string(forKey: "stationName") ?? "SakhaLive"
        let currentTrack = defaults?.string(forKey: "currentTrack") ?? ""
        let isPlaying = defaults?.string(forKey: "isPlaying") == "1"

        // Создаём entry
        let entry = SimpleEntry(
            date: Date(),
            stationName: stationName,
            currentTrack: currentTrack,
            isPlaying: isPlaying
        )
        entries.append(entry)

        // Обновляем каждые 30 минут
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let stationName: String
    let currentTrack: String
    let isPlaying: Bool
}

struct SakhaLiveWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "radio")
                    .foregroundColor(.yellow)
                Text(entry.stationName)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: entry.isPlaying ? "play.circle.fill" : "pause.circle.fill")
                    .foregroundColor(.yellow)
            }

            // Current track
            Text(entry.currentTrack.isEmpty ? "Нажмите для запуска" : entry.currentTrack)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            // Buttons
            HStack(spacing: 16) {
                Button(action: {
                    // Play/Pause action
                    openApp()
                }) {
                    Image(systemName: entry.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.title2)
                        .foregroundColor(.yellow)
                }

                Spacer()

                Button(action: {
                    // Open app
                    openApp()
                }) {
                    Image(systemName: "arrow.up.right.square")
                        .font(.title3)
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color(hex: "1A1A1A"))
    }

    func openApp() {
        if let url = URL(string: "sakhalive://widget_action") {
            UIApplication.shared.open(url)
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

@main
struct SakhaLiveWidget: Widget {
    let kind: String = "SakhaLiveWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: Provider()
        ) { entry in
            SakhaLiveWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("SakhaLive Radio")
        .description("Ваше любимое радио всегда с вами")
        .supportedFamilies([.systemSmall])
    }
}

struct SakhaLiveWidget_Previews: PreviewProvider {
    static var previews: some View {
        SakhaLiveWidgetEntryView(
            entry: SimpleEntry(
                date: Date(),
                stationName: "SakhaLive",
                currentTrack: "Европа Плюс - Imagine Dragons",
                isPlaying: true
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
