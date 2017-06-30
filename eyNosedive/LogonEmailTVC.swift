//
//  LogonEmailTVC.swift
//  eyNosedive
//
//  Created by Grisha on 6/19/17.
//  Copyright © 2017 EY. All rights reserved.
//

import UIKit

class LogonEmailTVC: UITableViewController {
    
    
    @IBAction func continuePressed(_ sender: Any) {
        requestLogon()
    }
    @IBOutlet weak var email: UITextField!
    
    
    func requestLogon () {
        JsonHelper.request(.logon,
                           ["email":email.text!],
                           self,
                           {(json: [String: Any]?, error: String?) -> Void in
                            self.responseLogon(json: json, error: error)
                            
        })
    }
    
    func responseLogon (json: [String: Any]?, error: String?) {
        if let error = error {
            AppModule.shared.alertError(error, view: self)
        } else {
            self.performSegue(withIdentifier: "emailCode", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? LogonEmailCodeTVC {
            vc.email = email.text!
        }
    }
    
    

}
