//
//  QuestCell.swift
//  eyNosedive
//
//  Created by Grisha on 6/20/17.
//  Copyright © 2017 EY. All rights reserved.
//

import UIKit

class QuestCell: UITableViewCell {
    
    var vc: AssessmentTVC?

    @IBOutlet weak var label: UILabel!

    @IBOutlet weak var questSwitch: UISwitch!
    @IBOutlet weak var questStar: CosmosView!
    
    @IBOutlet weak var labelDesc: UILabel!
    //CellPerson
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var positionLabel: UILabel!
    
    @IBOutlet weak var departmentLabel: UILabel!
    
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var photoView: UIImageView!
    
    @IBOutlet weak var requestButton: UIButton!

    @IBAction func pressRequest(_ sender: Any) {
        requestRequest()
    }
    
    func requestRequest () {
        let u = UserData.shared
        JsonHelper.request(.requestManual,
                           ["id": u.id,
                            "pass": u.pass,
                            "voter_id": vc!.person!.id
                            ],
                           vc!,
                           {(json: [String: Any]?, error: String?) -> Void in
                            self.responseRequest(json: json, error: error)
                            
        })

    }
    
    func responseRequest (json: [String: Any]?, error: String?) {
        
        if let error = error {
            AppModule.shared.alertError(error, view: vc!)
        } else {
            UserData.shared.save(json: json!)
            vc?.tableView.reloadData()
        }
 
    }

    
}
