//
//  main.swift
//  todo
//
//  Created by Tyler Hall on 6/21/20.
//  Copyright © 2020 Tyler Hall. All rights reserved.
//

import Foundation
import ArgumentParser

struct TodoOptions: ParsableArguments {
    @Option(name: .shortAndLong, help: ArgumentHelp("The folder to scan.", discussion: "If omitted, the current directory will be used.", valueName: "folder"))
    var folder: String?

    @Flag(help: "Show completed tasks.")
    var done: Bool

    @Flag(help: "Show incomplete tasks.")
    var undone: Bool

    @Option(name: .shortAndLong, help: ArgumentHelp("The number of recent documents to display", discussion: "Defaults to 1.", valueName: "integer"))
    var count: Int?
}

let options = TodoOptions.parseOrExit()
let documentCount = options.count ?? 1
let showDone = (!options.done && !options.undone) || options.done
let showUndone = (!options.done && !options.undone) || options.undone

let mainDF = DateFormatter()
mainDF.dateFormat = "YYYY-MM-dd"

let folderPath = options.folder ?? FileManager.default.currentDirectoryPath
let folderURL = URL(fileURLWithPath: folderPath)

var files: [URL]
do {
    files = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: [FileManager.DirectoryEnumerationOptions.skipsHiddenFiles])
} catch {
    fatalError("Could not read contents of \(folderPath)")
}

// PARSE CONTENTS

for file in files where file.pathExtension == "textbundle" {
    let doc = Document(fileURL: file)
    Document.all.append(doc)
}

let sortedDocuments = Document.all.sorted { (a, b) -> Bool in
    return a.date > b.date
}
for i in 0..<min(documentCount, sortedDocuments.count) {
    let doc = sortedDocuments[i]
    guard doc.tasks.count > 0 else { continue }

    let docStr = doc.string
    print(docStr)
    print(String(repeating: "=", count: docStr.count))

    let sortedPeople = doc.people.sorted { (a, b) -> Bool in
        return a.name < b.name
    }

    var printedSomething = false
    for person in sortedPeople where person.tasks.count > 0 {
        var tasksStr = ""
        for t in person.tasks where Calendar.current.isDate(t.date, inSameDayAs: doc.date) {
            if t.completed && showDone {
                tasksStr += t.string + "\n"
            } else if !t.completed && showUndone {
                tasksStr += t.string + "\n"
            }
        }

        if tasksStr != "" {
            print(person.name)
            print(String(repeating: "-", count: person.name.count))
            print(tasksStr)
            printedSomething = true
        }
    }
    
    if printedSomething {
        print("\n")
    }
}
