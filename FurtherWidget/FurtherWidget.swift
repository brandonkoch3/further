//
//  FurtherWidget.swift
//  FurtherWidget
//
//  Created by Brandon on 7/14/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    
    public typealias Entry = FurtherEntry
    
    // Helpers
    let defaults = UserDefaults.standard
    
    #if !os(watchOS)
    var keyValStore = NSUbiquitousKeyValueStore()
    #endif
    
    func getSnapshot(in context: Context, completion: @escaping (FurtherEntry) -> Void) {
        let entry = FurtherEntry(date: Date(), lastUsed: Date(), isPlaceholder: false)
        print("Snapshot")
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<FurtherEntry>) -> Void) {
        
        print("Timeline")
        
        // Determine the last used date
        var lastUsedDate: Date?
        let lastUsed = defaults.integer(forKey: "lastScanned")
        if lastUsed == 0 {
            lastUsedDate = Date(timeIntervalSince1970: 0)
        } else {
            lastUsedDate = Date(timeIntervalSince1970: TimeInterval(lastUsed))
        }
        
        let entry = FurtherEntry(date: Date(), lastUsed: lastUsedDate!, isPlaceholder: false)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
    
    public func placeholder(in with: Context) -> FurtherEntry {
        let entry = FurtherEntry(date: Date(), lastUsed: Date(), isPlaceholder: true)
        return entry
    }
}

struct FurtherEntry: TimelineEntry {
    public let date: Date
    var lastUsed: Date
    var isPlaceholder: Bool
}

struct WidgetHelper {
    func qrImage(colorScheme: ColorScheme) -> Image {
        print("image?")
        let paths = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.bnbmedia.further.contents")!
        let file = paths.appendingPathComponent("qrcode_\(colorScheme == .light ? "light" : "dark").png")
        if let qrImage = UIImage(contentsOfFile: file.path) {
            return Image(uiImage: qrImage)
        }
        
        return Image(colorScheme == .light ? "light_low_risk" : "dark_low_risk")
    }
    
    func warningImage(positiveContacts: Int, colorScheme: ColorScheme) -> Image {
        if positiveContacts >= 3 {
            return Image(colorScheme == .light ? "light_high_risk" : "dark_high_risk")
        } else if positiveContacts >= 1 {
            return Image(colorScheme == .light ? "light_medium_risk" : "dark_medium_risk")
        } else {
            return Image(colorScheme == .light ? "light_low_risk" : "dark_low_risk")
        }
    }
    
    func warningLevel(positiveContacts: Int) -> String {
        if positiveContacts >= 2 {
            return "High Risk"
        } else if positiveContacts >= 1 {
            return "Medium Risk"
        } else {
            return "Low Risk"
        }
    }
    
    func warningDetail(positiveContacts: Int) -> String {
        if positiveContacts >= 1 {
            return "Based on your risk level, you should consider a 14-day quarantine and a COVID-19 test."
        }
        else {
            return "Based on your risk level, please ensure a face covering and social distancing."
        }
    }
}

struct FurtherWidgetEntryView : View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.widgetFamily) var family
    var helper = WidgetHelper()
    var entry: Provider.Entry

    @ViewBuilder
    var body: some View {
        ZStack {
            EntryBackgroundView()
            switch family {
            case .systemSmall:
                FurtherStatsWidgetViewSmall(entry: entry, helper: helper)
            default:
                FurtherStatsWidgetViewMedium(entry: entry, helper: helper)
            }
        }
    }
}

struct FurtherStatsWidgetViewSmall: View {
    
    @Environment(\.colorScheme) var colorScheme
    var entry: Provider.Entry
    var helper: WidgetHelper
    
    @ViewBuilder
    var body: some View {
        VStack {
            HStack {
                Spacer()
                helper.qrImage(colorScheme: colorScheme)
                    .resizable()
                    .frame(width: 100.0, height: 100.0)
                    .aspectRatio(contentMode: .fit)
                    .padding([.top], 18.0)
                
                Spacer()
            }
            
            Spacer()
            
            VStack {
                if entry.isPlaceholder {
                    Text("Last Used")
                        .redacted(reason: .placeholder)
                } else {
                    Text("Last Scanned:")
                        .font(Font.custom("Rubik-Light", size: 13))
                    if entry.lastUsed == Date(timeIntervalSince1970: 0) {
                        Text("Never")
                            .font(Font.custom("Rubik-Light", size: 13))
                    } else {
                        Text(entry.lastUsed, style: .date)
                            .font(Font.custom("Rubik-Light", size: 13))
                    }
                }
                Spacer()
            }
            
            Spacer()
        }
    }
}

struct FurtherStatsWidgetViewMedium: View {
    
    @Environment(\.colorScheme) var colorScheme
    var entry: Provider.Entry
    var helper: WidgetHelper
    
    var body: some View {
        VStack {
            HStack {
                helper.qrImage(colorScheme: colorScheme)
                    .resizable()
                    .frame(width: 110, height: 110)
                    .padding([.leading], 12.0)
                    .padding([.top], 12.0)
                Spacer()
                Text("Scan To Share")
                    .font(Font.custom("Rubik-Medium", size: 18))
                Spacer()
            }
            
            
            if entry.isPlaceholder {
                Text("Last Scanned: September 30, 2020")
                    .redacted(reason: .placeholder)
            } else {
                if entry.lastUsed == Date(timeIntervalSince1970: 0) {
                    Text("Last Scanned: Never")
                        .font(Font.custom("Rubik-Light", size: 15.5))
                } else {
                    Text("Last Scanned: \(entry.lastUsed, style: .date))")
                        .font(Font.custom("Rubik-Light", size: 15.5))
                }
            }
            
            Spacer()
        }
    }
}

@main
struct FurtherWidget: Widget {
    private let kind: String = "com.bnbmedia.furtherstats"

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FurtherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Further Interactions")
        .description("Number of nearby users and risk level.")
        .supportedFamilies([.systemSmall])
    }
}

struct FurtherWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FurtherWidgetEntryView(entry: FurtherEntry(date: Date(), lastUsed: Date(), isPlaceholder: false))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .environment(\.colorScheme, .light)
            
            FurtherWidgetEntryView(entry: FurtherEntry(date: Date(), lastUsed: Date(), isPlaceholder: false))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .environment(\.colorScheme, .dark)
        }
        
    }
}
