//
//  LogonEmailCodeTVC.swift
//  eyNosedive
//
//  Created by Grisha on 6/19/17.
//  Copyright © 2017 EY. All rights reserved.
//

import UIKit

class LogonEmailCodeTVC: UITableViewController {
    
    var email: String = ""
    @IBOutlet weak var code: UITextField!


    @IBAction func continuePressed(_ sender: Any) {
        requestLogonCode()
    }
    
    func requestLogonCode () {
        JsonHelper.request(.logonCode,
                           ["email":email,
                            "code":code.text!],
                           self,
                           {(json: [String: Any]?, error: String?) -> Void in
                            self.responseLogonCode(json: json, error: error)
                            
        })
    }
    
    func responseLogonCode (json: [String: Any]?, error: String?) {
        if let error = error {
            AppModule.shared.alertError(error, view: self)
        } else {
            UserData.shared.save(json: json!)
            AppModule.shared.goStoreBoard(storeBoardName: "Directory")
        }
    }
    

}
