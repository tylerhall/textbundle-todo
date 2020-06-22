//
//  Document.swift
//  todo
//
//  Created by Tyler Hall on 6/21/20.
//  Copyright © 2020 Tyler Hall. All rights reserved.
//

import Foundation

class Document {
    
    static var all = [Document]()

    var fileURL: URL
    var tasks = [Task]()
    var people = Set<Person>()

    var title: String {
        return fileURL.deletingPathExtension().lastPathComponent
    }

    var date: Date {
        let pattern = #"20[0-9]{2}-[0-9]{2}-[0-9]{2}"#
        let matches = title.matchingStrings(regex: pattern)
        if matches.count > 0 {
            let df = DateFormatter()
            df.dateFormat = "YYYY-MM-dd"
            if let dateStr = matches[0].first, let date = df.date(from: dateStr) {
                 return date
            }
        }

        if let attr = try? FileManager.default.attributesOfItem(atPath: fileURL.path), let date = attr[FileAttributeKey.creationDate] as? Date {
            return date
        }

        return Date.distantPast
    }
    
    var string: String {
        let df = DateFormatter()
        df.dateFormat = "EEEE MMM d"
        let dateStr = df.string(from: date)
        return "\(dateStr): \(title)".uppercased()
    }

    init(fileURL: URL) {
        self.fileURL = fileURL
        parse()
    }
    
    func parse() {
        let textURL = fileURL.appendingPathComponent("text").appendingPathExtension("md")
        guard let data = try? Data(contentsOf: textURL) else { return }
        guard let contents = String(data: data, encoding: .utf8) else { return }
        let lines = contents.components(separatedBy: "\n")
        guard lines.count > 0 else { return }

        for line in lines {
            let pattern = #"@[a-zA-Z]{3,99}"#
            let names = line.matchingStrings(regex: pattern)
            if names.count > 0 {
                let task = Task(document: self, text: line)
                tasks.append(task)

                for name in names {
                    if let name = name.first {
                        let person = Person.withName(name)
                        people.insert(person)
                        task.people.insert(person)
                        person.tasks.append(task)
                    }
                }
            }
        }
    }
}
