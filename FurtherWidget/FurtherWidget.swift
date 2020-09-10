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
    func getSnapshot(in context: Context, completion: @escaping (FurtherEntry) -> Void) {
        let entry = FurtherEntry(date: Date(), partipicantsCount: 25, positiveContactsCount: 0, isPlaceholder: false)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<FurtherEntry>) -> Void) {
        print("called to update widget!")
        var savedParticipants = [PersonModel]()
        var participantsCount = 0
        let storiesController = StoriesController()
        
        if let savedData = keyValStore.object(forKey: "interactions") as? Data {
            if let loadedData = try? decoder.decode([PersonModel].self, from: savedData) {
                savedParticipants = loadedData
            }
        }
        
        if savedParticipants.isEmpty {
            if let savedData = defaults.object(forKey: "interactions") as? Data {
                if let loadedData = try? decoder.decode([PersonModel].self, from: savedData) {
                    savedParticipants = loadedData
                }
            }
        }
        
        print("Participants:", participantsCount)
        
        if let earliestDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date()) {
            let todayPartipicants = savedParticipants.filter({ $0.connectTime >= earliestDate.timeIntervalSince1970 })
            participantsCount = todayPartipicants.count
            print("participants counts:", participantsCount)
        }
        
        storiesController.updateStories() { response in
            print("updating story!")
            if response {
                let nowDate = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let strDate = dateFormatter.string(from: nowDate)
                
                if let todayStory = storiesController.stories.first(where: { $0.displayDate == strDate }) {
                    let positiveCount = todayStory.positiveContacts.count
                    
                    let timeline = Timeline(entries: [FurtherEntry(date: Date(), partipicantsCount: participantsCount, positiveContactsCount: positiveCount, isPlaceholder: false)], policy: .atEnd)
                    completion(timeline)
                    return
                }
            }
        }
        
        let entry = FurtherEntry(date: Date(), partipicantsCount: participantsCount, positiveContactsCount: 0, isPlaceholder: false)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
    
    public typealias Entry = FurtherEntry
    
    // Helpers
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let defaults = UserDefaults.standard
    
    #if !os(watchOS)
    var keyValStore = NSUbiquitousKeyValueStore()
    #endif
    
    public func placeholder(in with: Context) -> FurtherEntry {
        let entry = FurtherEntry(date: Date(), partipicantsCount: 25, positiveContactsCount: 0, isPlaceholder: true)
        return entry
    }
}

struct FurtherEntry: TimelineEntry {
    public let date: Date
    var partipicantsCount: Int
    var positiveContactsCount: Int
    var isPlaceholder: Bool
}

struct WidgetHelper {
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
                helper.warningImage(positiveContacts: entry.positiveContactsCount, colorScheme: colorScheme)
                    .frame(width: 80.0, height: 80.0)
                    .aspectRatio(contentMode: .fit)
                    .padding([.top, .leading, .trailing], 8.0)
                if entry.isPlaceholder {
                    Text("Low Risk For")
                        .padding([.top], 7.0)
                        .redacted(reason: .placeholder)
                } else {
                    Text(helper.warningLevel(positiveContacts: entry.positiveContactsCount))
                        .font(.custom("Rubik-Medium", size: 23.3, relativeTo: .headline))
                        .padding([.top], 7.0)
                }
                
                Spacer()
            }
            
            Spacer()
            
            HStack {
                Spacer()
                if entry.isPlaceholder {
                    Text("Interactions")
                        .redacted(reason: .placeholder)
                } else {
                    Text("Interactions: \(entry.partipicantsCount)")
                        .font(Font.custom("Rubik-Light", size: 15.5))
                }
                Spacer()
            }.padding()
            
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
                helper.warningImage(positiveContacts: entry.positiveContactsCount, colorScheme: colorScheme)
                    
                VStack(alignment: .leading) {
                    Text(helper.warningLevel(positiveContacts: entry.positiveContactsCount))
                        .font(Font.custom("Rubik-Medium", size: 23.3))
                    Text("Interactions: \(entry.partipicantsCount)")
                }
                Spacer()
            }
            
            HStack {
                Text(helper.warningDetail(positiveContacts: entry.positiveContactsCount))
                    .font(Font.custom("Rubik-Light", size: 15.5))
            }.padding()
            
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
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct FurtherWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FurtherWidgetEntryView(entry: FurtherEntry(date: Date(), partipicantsCount: 10, positiveContactsCount: 0, isPlaceholder: true))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .environment(\.colorScheme, .light)
            
            FurtherWidgetEntryView(entry: FurtherEntry(date: Date(), partipicantsCount: 50, positiveContactsCount: 5, isPlaceholder: false))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .environment(\.colorScheme, .dark)
        }
        
    }
}
