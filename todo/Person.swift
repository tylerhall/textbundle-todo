//
//  Person.swift
//  todo
//
//  Created by Tyler Hall on 6/21/20.
//  Copyright © 2020 Tyler Hall. All rights reserved.
//

import Foundation

class Person: Hashable {

    static var all = [Person]()
    
    var name = ""
    var tasks = [Task]()
    
    static func == (lhs: Person, rhs: Person) -> Bool {
        return lhs.name == rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    static func withName(_ name: String) -> Person {
        let name = name.trimmingCharacters(in: CharacterSet(charactersIn: "@")).lowercased()
        if let foundPerson = Person.all.first(where: { (p) -> Bool in
            return p.name == name
        }) {
            return foundPerson
        }

        let person = Person()
        person.name = name
        Person.all.append(person)
        return person
    }
}
