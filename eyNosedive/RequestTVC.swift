//
//  RequestTVC.swift
//  eyNosedive
//
//  Created by Grisha on 7/4/17.
//  Copyright © 2017 EY. All rights reserved.
//

import UIKit

class RequestTVC: UITableViewController {
    
    var requests = UserData.shared.requests
    var eventRequests = UserData.shared.eventRequests
    var events = UserData.shared.events
    var persons = UserData.shared.persons

    func updateData () {
        requests = UserData.shared.requests
        eventRequests = UserData.shared.eventRequests
        events = UserData.shared.events
        persons = UserData.shared.persons
    }


    func shortName () {
        requests = UserData.shared.requests
        eventRequests = UserData.shared.eventRequests
        events = UserData.shared.events
        persons = UserData.shared.persons
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return events.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (eventRequests[events[section]]?.count)!
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SearchCell
        
        let request = (eventRequests[events[indexPath.section]])![indexPath.row]
        
        let person = (persons.filter {$0.id == request.estimated}).first!
        
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
        view.header(commentString: events[section])
        return view
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            if let requestId = (eventRequests[events[indexPath.section]])?[indexPath.row].id {
                requestRequestDelete(requestId: requestId)
            }
        }
        
    }

    func requestRequestDelete (requestId: String) {
        let u = UserData.shared
        JsonHelper.request(.requestDelete,
                           ["id": u.id,
                            "pass": u.pass,
                            "request_id": requestId
                            ],
                           self,
                           {(json: [String: Any]?, error: String?) -> Void in
                            self.responseRequestDelete(json: json, error: error)
                            
        })
        
    }
    
    func responseRequestDelete (json: [String: Any]?, error: String?) {
        
        if let error = error {
            AppModule.shared.alertError(error, view: self)
        } else {
            UserData.shared.save(json: json!)
            shortName()
            tableView.reloadData()
        }
        
    }

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AssessmentTVC {
            if let selectedIndex = tableView.indexPathForSelectedRow {
                let request = (eventRequests[events[selectedIndex.section]])! [selectedIndex.row]
                vc.request = request
                vc.person = (persons.filter {$0.id == request.estimated}).first!

                let assessments = UserData.shared.assessments
                var paa = assessments.filter {$0.estimated == vc.person!.id}
                paa = paa.sorted {UserData.toDate($0.date) > UserData.toDate($1.date)}
                vc.assessment = paa.first

                vc.isEditable = true
            }
        }
    }



}
