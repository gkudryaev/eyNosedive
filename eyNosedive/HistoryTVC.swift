//
//  HistoryTVC.swift
//  eyNosedive
//
//  Created by Grisha on 6/29/17.
//  Copyright © 2017 EY. All rights reserved.
//

import UIKit

class HistoryTVC: UITableViewController {
    
    var assessments = UserData.shared.assessments
    var historyAssessments = UserData.shared.historyAssessments
    var historyDates = UserData.shared.historyDates
    var persons = UserData.shared.persons
    
    var selectedIndex: IndexPath?


    override func viewDidLoad() {
        super.viewDidLoad()
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return historyDates.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return historyAssessments[historyDates[section]]!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SearchCell
        
        let assessment = (historyAssessments[historyDates[indexPath.section]])![indexPath.row]
        
        let person = (persons.filter {$0.id == assessment.estimated}).first!
        
        cell.nameLabel.text = person.name
        cell.positionLabel.text = person.position + " / " + person.department
        cell.photoView.image = UIImage()
        
        cell.iconStar.isHidden = false
        
        AppModule.shared.imageFromUrl(person.photoUrl, cell.photoView)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 40
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let view = UISectionInHeaderView()
        view.header(commentString: historyDates[section])
        return view
    }


    


    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let selectedIndex = tableView.indexPathForSelectedRow {
            if let vc = segue.destination as? AssessmentTVC {

                vc.assessment = (historyAssessments[historyDates[selectedIndex.section]])![selectedIndex.row]
                vc.person = (persons.filter {$0.id == vc.assessment?.estimated}).first!
                vc.isEditable = false
            }
            
        }

    }
 

}
