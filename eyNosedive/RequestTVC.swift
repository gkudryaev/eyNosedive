//
//  RequestTVC.swift
//  eyNosedive
//
//  Created by Grisha on 7/4/17.
//  Copyright © 2017 EY. All rights reserved.
//

import UIKit

class RequestTVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return UserData.shared.events.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (UserData.shared.eventRequests[UserData.shared.events[section]]?.count)!
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SearchCell
        
        let request = (UserData.shared.eventRequests[UserData.shared.events[indexPath.section]])![indexPath.row]
        
        let person = (UserData.shared.persons.filter {$0.id == request.estimated}).first!
        
        cell.nameLabel.text = person.name
        cell.positionLabel.text = person.position + " / " + person.department
        cell.photoView.image = UIImage()
        
        cell.iconStar.isHidden = (UserData.shared.assessments.filter {
            $0.estimated == person.id
        }).count == 0
        
        AppModule.shared.imageFromUrl(person.photoUrl, cell.photoView)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 40
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UISectionInHeaderView()
        view.header(commentString: UserData.shared.events[section])
        return view
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            if let request = (UserData.shared.eventRequests[UserData.shared.events[indexPath.section]])?[indexPath.row]
            {
                Queue.shared.append(url: .requestDelete, params:
                    [
                        "request_id": request.id
                    ]
                )
                if let ind = UserData.shared.requests.index(where: { (r) in
                    request.id == r.id
                }) {
                    UserData.shared.requests.remove(at: ind)
                    UserData.shared.save()
                    tableView.reloadData()
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AssessmentTVC {
            if let selectedIndex = tableView.indexPathForSelectedRow {
                let request = (UserData.shared.eventRequests[UserData.shared.events[selectedIndex.section]])! [selectedIndex.row]
                vc.request = request
                vc.person = (UserData.shared.persons.filter {$0.id == request.estimated}).first!

                let assessments = UserData.shared.assessments
                var paa = assessments.filter {$0.estimated == vc.person!.id}
                paa = paa.sorted {UserData.toDate($0.date) > UserData.toDate($1.date)}
                vc.assessment = paa.first

                vc.isEditable = true
            }
        }
    }



}
