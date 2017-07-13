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
    let keyRequests = "eyRequests"
    let keyOutRequests = "eyOutRequests"
    let keyPersonsSeq = "eyPersonsSeq"
    
    var id: String = ""
    var name: String = ""
    var email: String = ""
    var pass: String = ""
    
    var persons: [Person] = [] {
        didSet {
            personsSearch = persons.filter {$0.id != self.id}
            user = persons.filter{$0.id == self.id}.first
        }
    }
    var personsSearch: [Person] = []
    var user: Person?
    var questionary: [Quest] = []
    var assessments: [Assessment] = [] {
        didSet {
            var historyAssessments: [String:[Assessment]] = [:]
            for assessment in assessments {
                var assDate = historyAssessments[assessment.date]
                if assDate == nil {
                    assDate = []
                }
                assDate?.append(assessment)
                historyAssessments[assessment.date] = assDate
            }
            var historyDates: [String] = Array(historyAssessments.keys)
            historyDates.sort {UserData.toDate($0) > UserData.toDate($1)}
            self.historyDates = historyDates
            self.historyAssessments = historyAssessments
        }
    }
    var historyDates: [String] = []
    var historyAssessments: [String: [Assessment]] = [:]
    
    var requests: [Request] = []
    var events: [String] = []
    var eventRequests : [String: [Request]] = [:]
    
    var outRequests: [String] = []
    
    var personsSeq: String = "0"

    static func toDate (_ str: String) -> String {
        var strAttr = str.components(separatedBy: ".")
        return strAttr[2] + strAttr[1] + strAttr[0]
    }

    
    struct Person {
        var name: String
        var email: String
        var position: String
        var department: String
        var photoUrl: String
        var status: String
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
            self.status = person[6]
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
                photoUrl,
                status
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
            case MANUAL
            case POOL
            case MEET
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
        static func initAssessments (assessAttrs: [[Any]]) ->
            [Assessment]
        {
            var assessments: [Assessment] = []
            for a in assessAttrs {
                let assessment = Assessment(assessmentAttr: a)
                assessments.append(assessment)
            }
            return assessments
        }
        
        
    }

    struct Request {
        
        enum EventType: String {
            case MANUAL
            case POOL
            case MEET
        }
        var id: String
        var date: String
        var type: EventType
        var estimated: String
        var event: String
        
        init (requestAttr: [String]) {
            self.id = requestAttr[0]
            self.date = requestAttr[1]
            self.type = EventType(rawValue: requestAttr[2])!
            self.estimated = requestAttr[3]
            self.event = requestAttr[4]
        }
        func attributes () -> [String] {
            return [
                id,
                date,
                type.rawValue,
                estimated,
                event             ]
        }
        static func initRequests (requestAttrs: [[String]]) ->
            ([Request], [String: [Request]], [String])
        {
            var requests: [Request] = []
            var eventRequests: [String:[Request]] = [:]
            for r in requestAttrs {
                let request = Request(requestAttr: r)
                requests.append(request)
                var r = eventRequests[request.event]
                if r == nil {
                    r = []
                }
                r?.append(request)
                eventRequests[request.event] = r
            }
            let events: [String] = Array(eventRequests.keys)
            //events.sort {toDate($0) > toDate($1)}
            
            return (requests, eventRequests, events)
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
    
        std.set(personsSeq, forKey: keyPersonsSeq)
        
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
    

        var requestsAttributes: [[String]] = []
        for request in requests {
            requestsAttributes.append(request.attributes())
        }
        std.set(requestsAttributes, forKey: keyRequests)
        
        
        std.set(outRequests, forKey: keyOutRequests)
    }
    
    func save (json: [String: Any]) {
        
        if let json = json["user"] as? [String:String] {
            id = json ["id"] ?? ""
            name = json ["name"] ?? ""
            email = json ["email"] ?? ""
            pass = json ["pass"] ?? ""
        }
        
        if let personsSeq = json["personsSeq"] as? String {
            self.personsSeq = personsSeq
        }
        
        if let personsJson = json["persons"] as? [[String]] {
            persons = Person.initPersons(personsAttributes: personsJson)
        }

        if let personsJson = json["personsIncrement"] as? [[String]] {
            
            let personsIncrement = Person.initPersons(personsAttributes: personsJson)
            if personsIncrement.count > 0 {
                var persDict: [String: Person] = [:]
                for person in persons {
                    persDict[person.id] = person
                }
                for person in personsIncrement {
                    persDict[person.id] = person
                }
                persons = Array(persDict.values)
            }
        }
        
        if let questionaryJson = json["questionary"] as? [[String]] {
            questionary = Quest.initQuestionary(questionaryAttributes: questionaryJson)
        }

        if let assessmentsJson = json["assessments"] as? [[Any]] {
            assessments = Assessment.initAssessments(assessAttrs: assessmentsJson)
        }

        if let requestsJson = json["requests"] as? [[String]] {
            (requests, eventRequests, events)
                = Request.initRequests(requestAttrs: requestsJson)
        }

        if let requestsJson = json["outRequests"] as? [String] {
            outRequests = requestsJson
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
        
        if let personsSeq = UserDefaults.standard.string(forKey: keyPersonsSeq) {
            self.personsSeq = personsSeq
        }

        if let personsAttributes = UserDefaults.standard.array(forKey: keyPersons) as? [[String]] {
            persons = Person.initPersons(personsAttributes: personsAttributes)
        }
        if let questionaryAttributes = UserDefaults.standard.array(forKey: keyQuestionary) as? [[String]] {
            questionary = Quest.initQuestionary(questionaryAttributes: questionaryAttributes)
        }
        if let assessmentsAttributes = UserDefaults.standard.array(forKey: keyAssessments) as? [[Any]] {
            assessments = Assessment.initAssessments(assessAttrs:assessmentsAttributes)
        }
        if let requestsAttributes = UserDefaults.standard.array(forKey: keyRequests) as? [[String]] {
            (requests, eventRequests, events)
                = Request.initRequests(requestAttrs: requestsAttributes)
        }
        if let outRequests = UserDefaults.standard.array(forKey: keyOutRequests) as? [String] {
            self.outRequests = outRequests
        }
    }

}
