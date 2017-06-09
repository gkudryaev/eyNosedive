//
//  User.swift
//  eyNosedive
//
//  Created by Grisha on 6/6/17.
//  Copyright © 2017 EY. All rights reserved.
//

import Foundation


struct User {
    let fname: String
    let name: String
    let email: String
    
    let fullName: String
    let searchName: String
    
    static func initList() -> [User] {
        var userList: [User] = []
    
        let bundle = Bundle.main
        let path = bundle.path(forResource: "userList", ofType: "txt")
        
        do {
            let text =  try String(contentsOfFile: path!)
            let lines = text.components(separatedBy: .newlines)
            for line in lines {
                let fields = line.components(separatedBy: "\t")
                if fields.count>2 {
                    userList.append(
                        User(
                            name: fields[1], fname: fields[0], email: fields[2]
                        )
                    )
                }
            }
        } catch {
        }
        
        return userList

    }
    
    init (name: String, fname: String, email: String) {
        self.name = name
        self.fname = fname
        self.email = email
        self.fullName = name + " " + fname
        self.searchName = self.fullName.lowercased()
    }
    
    
}

