//
//  Task.swift
//  todo
//
//  Created by Tyler Hall on 6/21/20.
//  Copyright © 2020 Tyler Hall. All rights reserved.
//

import Foundation

class Task {
    
    static var all = [Ticket]()

    var guid = UUID().uuidString
    var document: Document
    var text: String
    var people = Set<Person>()
    var tickets = [Ticket]()

    var completed: Bool {
        let lower = text.lowercased()
        if lower.contains("xxx") {
            return true
        }
        if lower.hasPrefix("x ") {
            return true
        }
        return false
    }

    var date: Date {
        if text.contains("EOD") {
            return document.date
        }

        let pattern = #"20[0-9]{2}-[0-9]{2}-[0-9]{2}"#
        let matches = text.matchingStrings(regex: pattern)
        if matches.count > 0 {
            let df = DateFormatter()
            df.dateFormat = "YYYY-MM-dd"
            if let dateStr = matches[0].first, let date = df.date(from: dateStr) {
                 return date
            }
        }

        return document.date
    }

    var string: String {
        var str = completed ? "[x] " : "[ ] "

        if !Calendar.current.isDate(date, inSameDayAs: document.date) {
            let dateStr = mainDF.string(from: date)
            str += "(\(dateStr) "
        }

        return "\(str) \(text)"
    }
    
    init(document: Document, text: String) {
        self.document = document
        self.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
