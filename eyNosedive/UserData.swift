//
//  UserData.swift
//  eyNosedive
//
//  Created by Grisha on 6/19/17.
//  Copyright © 2017 EY. All rights reserved.
//

import Foundation



class UserData {
    
    static var shared = UserData()
    
    let keyUserAttributes = "eyNosediveUserAttributes"
    let keyPersons = "eyNosedivePersons"
    let keyQuestionary = "eyNosediveQuestionary"
    let keyAssessmentsOutgoing = "eyAssessmentsOutgoing"
    let keyAssessments = "eyAssessments"
    
    var id: String = ""
    var name: String = ""
    var email: String = ""
    var pass: String = ""
    
    var persons: [Person] = []
    var questionary: [Quest] = []
    var assessments: [Assessment] = []
    var historyDates: [String] = []
    var historyAssessments: [String: [Assessment]] = [:]
    
    
    
    struct Person {
        var name: String
        var email: String
        var position: String
        var department: String
        var photoUrl: String = ""
        var id: String
        var sn: String

        var searchString: String

        init (_ person: [String]) {
            self.id = person[0]
            self.name = person[1]
            self.email = person[2]
            self.position = person[3]
            self.department = person[4]
            self.photoUrl = person[5]
            self.sn = ""
            self.searchString = self.name.lowercased() + " " + self.email.lowercased()
        }
        func attibutes() -> [String] {
            return [
                id,
                name,
                email,
                position,
                department,
                photoUrl
            ]
        }
        static func initPersons (personsAttributes: [[String]]) -> [Person] {
            var persons: [Person] = []
            for personAttributes in personsAttributes {
                persons.append (Person(personAttributes))
            }
            return persons
        }
        
    }
    
    struct Quest {
        var questionary: String
        var id: String
        var type: String
        var point: String
        var desc: String
        
        init (_ quest: [String]) {
            self.questionary = quest[0]
            self.id = quest [1]
            self.type = quest[2]
            self.point = quest[3]
            self.desc = quest[4]
        }
        func attributes () -> [String] {
            return [
                questionary,
                id,
                type,
                point,
                desc
            ]
        }
        static func initQuestionary (questionaryAttributes: [[String]]) -> [Quest] {
            var questionary: [Quest] = []
            for questAttributes in questionaryAttributes {
                questionary.append (Quest(questAttributes))
            }
            return questionary
        }

    }
    
    struct Assessment {
        enum AssessmentType: String {
            case date
            case event
        }
        var type: AssessmentType
        var date: String
        var title: String
        var estimated: String
        var questions: [String:String] = [:] // "id", "value"
        
        init (assessmentAttr: [Any]) {
            self.type = AssessmentType(rawValue: assessmentAttr[0] as! String)!
            self.date = assessmentAttr[1] as! String
            self.title = assessmentAttr[2] as! String
            self.estimated = assessmentAttr[3] as! String
            self.questions = assessmentAttr[4] as! [String:String]
        }
        func attributes () -> [Any] {
            return [
                type.rawValue,
                date,
                title,
                estimated,
                questions
            ]
        }
        static func toDate (_ str: String) -> String {
            var strAttr = str.components(separatedBy: ".")
            return strAttr[2] + strAttr[1] + strAttr[0]
        }
        static func initAssessments (assessAttrs: [[Any]]) ->
            ([Assessment], [String: [Assessment]], [String])
        {
            var assessments: [Assessment] = []
            var historyAssessments: [String:[Assessment]] = [:]
            for a in assessAttrs {
                let assessment = Assessment(assessmentAttr: a)
                assessments.append(assessment)
                var a = historyAssessments[assessment.date]
                if a == nil {
                    a = []
                }
                a?.append(assessment)
                historyAssessments[assessment.date] = a
            }
            var historyDates: [String] = Array(historyAssessments.keys)
            historyDates.sort {toDate($0) > toDate($1)}
            
            return (assessments, historyAssessments, historyDates)
        }
        
    }

    
   func save() {
        let std = UserDefaults.standard
        std.set ([
            "id": id,
            "name": name,
            "email": email,
            "pass": pass
            ], forKey: keyUserAttributes
        )
        
        var personsAttributes: [[String]] = []
        for person in persons {
            personsAttributes.append(person.attibutes())
        }
        
        std.set(personsAttributes, forKey: keyPersons)
        
        var qustionaryAttributes: [[String]] = []
        for quest in questionary {
            qustionaryAttributes.append(quest.attributes())
        }
        std.set(qustionaryAttributes, forKey: keyQuestionary)

        var assessmentsAttributes: [[Any]] = []
        for assessment in assessments {
            assessmentsAttributes.append(assessment.attributes())
        }
        std.set(assessmentsAttributes, forKey: keyAssessments)

    }
    
    func save (json: [String: Any]) {
        
        if let json = json["user"] as? [String:String] {
            id = json ["id"] ?? ""
            name = json ["name"] ?? ""
            email = json ["email"] ?? ""
            pass = json ["pass"] ?? ""
        }
        
        if let personsJson = json["persons"] as? [[String]] {
            persons = Person.initPersons(personsAttributes: personsJson)
        }
        
        if let questionaryJson = json["questionary"] as? [[String]] {
            questionary = Quest.initQuestionary(questionaryAttributes: questionaryJson)
        }

        if let assessmentsJson = json["assessments"] as? [[Any]] {
            (assessments, historyAssessments, historyDates)
                = Assessment.initAssessments(assessAttrs: assessmentsJson)
        }
        
        save()
    }

    func load () {
        if let p = UserDefaults.standard.dictionary(forKey: keyUserAttributes) as? [String:String] {
            id = p["id"] ?? ""
            name = p["name"] ?? ""
            email = p["email"] ?? ""
            pass = p["pass"] ?? ""
        }
        

        if let personsAttributes = UserDefaults.standard.array(forKey: keyPersons) as? [[String]] {
            persons = Person.initPersons(personsAttributes: personsAttributes)
        }
        if let questionaryAttributes = UserDefaults.standard.array(forKey: keyQuestionary) as? [[String]] {
            questionary = Quest.initQuestionary(questionaryAttributes: questionaryAttributes)
        }
        if let assessmentsAttributes = UserDefaults.standard.array(forKey: keyAssessments) as? [[Any]] {
            (assessments, historyAssessments, historyDates)
                = Assessment.initAssessments(assessAttrs:assessmentsAttributes)
        }

    }

}
