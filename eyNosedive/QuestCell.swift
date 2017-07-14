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
        
        Queue.shared.append(url: .requestManual, params:
            [
                "voter_id": vc!.person!.id
            ]
        )
        UserData.shared.outRequests.append(vc!.person!.id)
        UserData.shared.save()
        vc?.tableView.reloadData()
    }
}
