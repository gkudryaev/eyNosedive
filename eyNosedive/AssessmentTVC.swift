//
//  AssessmentTVC.swift
//  eyNosedive
//
//  Created by Grisha on 6/19/17.
//  Copyright © 2017 EY. All rights reserved.
//

import UIKit

class UISectionInHeaderView: UIView {
    
    var commentString: String = ""
    
    func header (commentString: String)  {
        self.commentString = commentString
        
        self.backgroundColor = AppModule.sectionBkColor
        
        let comment = UILabel()
        comment.text = commentString
        comment.translatesAutoresizingMaskIntoConstraints = false
        comment.textColor = UIColor.lightGray
        comment.font = comment.font.withSize(13)
        comment.numberOfLines = 3
        comment.lineBreakMode = .byWordWrapping
        
        
        let views = ["comment":comment,"view": self]
        self.addSubview(comment)
        let vc1 = NSLayoutConstraint.constraints(withVisualFormat: "V:|-2-[comment]-2-|", options: .alignAllCenterX, metrics: nil, views: views)
        self.addConstraints(vc1)

        let hc1 = NSLayoutConstraint(item: comment, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailingMargin, multiplier: 1, constant: 0)
        self.addConstraint(hc1)

       let hc2 = NSLayoutConstraint(item: comment, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leadingMargin, multiplier: 1, constant: 0)
        self.addConstraint(hc2)
        
    }
    
}

class AssessmentTVC: UITableViewController {
    
    var person: UserData.Person?
    var questionary = UserData.shared.questionary
    var assessment: UserData.Assessment?
    var isEditable: Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem?.isEnabled = isEditable

    }
    

   // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + questionary.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section > 0 {
            return 1
        } else {
            return 1;
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPerson", for: indexPath) as! QuestCell
            cell.nameLabel.text = person?.name
            cell.positionLabel.text = person?.position
            cell.departmentLabel.text = person?.department
            cell.emailLabel.text = person?.email
            cell.photoView.image = UIImage()
            AppModule.shared.imageFromUrl(person?.photoUrl, cell.photoView)

            return cell
        }  else {
            let quest = questionary[indexPath.section-1]
            let cellId = (quest.type == "SWITCH") ? "cellSwitch" : "cellStar"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! QuestCell
            cell.label.text = quest.point
            cell.labelDesc.text = quest.desc
            if assessment != nil {
                let val = assessment?.questions[quest.id]
                switch quest.type {
                    case "SWITCH":
                    cell.questSwitch.isOn = (val != "0")
                    cell.questSwitch.isEnabled = isEditable
                    case "STAR":
                    cell.questStar.rating = Double(val!)!
                    cell.questStar.isUserInteractionEnabled = isEditable
                default: break
                    
                }
            }
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 0
        } else {
            return 10  //54
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 120
        } else {
            
            let quest = questionary[indexPath.section-1]
            let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 60))

            lbl.text = quest.desc
            lbl.font = UIFont.systemFont(ofSize: 13, weight: UIFontWeightLight)
            lbl.lineBreakMode = .byWordWrapping
            lbl.numberOfLines = 0
            lbl.adjustsFontSizeToFitWidth = true
            lbl.minimumScaleFactor = 0.5
            lbl.sizeToFit()
            return 46 + lbl.frame.height
            

        }
    }
    /*
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            return person?.name
        } else {
            let quest = questionary[section-1]
            return quest.desc
        }
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
