//
//  SearchTVC.swift
//  eyNosedive
//
//  Created by Grisha on 6/6/17.
//  Copyright © 2017 EY. All rights reserved.
//

import UIKit

class SearchTVC: UITableViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var filteredPersons: [UserData.Person] = []
    
    var selectedIndex: IndexPath?
    
    
    @IBAction func cancelAssessment(segue:UIStoryboardSegue) {
    }
    @IBAction func saveAssessment(segue:UIStoryboardSegue) {
        
        let vc: AssessmentTVC = segue.source as! AssessmentTVC
        let qy = vc.questionary
        var i = 1
        var questions: [String:String] = [:]
        for q in qy {
            let indexPath = IndexPath(row: 0, section: i)
            let cell: QuestCell = vc.tableView.cellForRow(at: indexPath) as! QuestCell
            var val: Int = -1
            if cell.reuseIdentifier == "cellSwitch" {
                val = cell.questSwitch.isOn ? 1 : 0
            }
            if cell.reuseIdentifier == "cellStar" {
                val = Int(cell.questStar.rating)
            }
            questions [String(q.id)] = String(val)
            //todo append event_id
            i += 1
        }
        //requestAssessment(estimated: vc.person!.id, assessment: assessment, request: vc.request)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let sysdate = dateFormatter.string(from: Date())
        
        let assessment = UserData.Assessment(assessmentAttr:
            ["MANUAL",
             sysdate,
             sysdate + " title",
             vc.person!.id,
             questions
             ]
            )
        UserData.shared.assessments.append(assessment)
        UserData.shared.save()
        
        var params: [String: Any] = [
            "estimated_id": vc.person!.id,
            "assessment": questions,
            "date": sysdate
        ]
        if let request = vc.request {
            params["request_id"] = request.id
        }
        Queue.shared.append(url: .assessment, params: params)
        
        tableView.reloadData()
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
//        searchController.searchBar.barTintColor = AppModule.defaultColor
        searchController.searchBar.isOpaque = true
        searchController.searchBar.isTranslucent = false
        
        searchController.delegate = self
        searchController.searchBar.delegate = self
        
        //todo разобраться с этим
        searchController.hidesNavigationBarDuringPresentation = false
        
        //self.navigationItem.titleView = searchController.searchBar
        navigationController?.navigationBar.topItem?.titleView = searchController.searchBar
        //tableView.tableHeaderView = searchController.searchBar
        //navigationController?.navigationBar.isHidden = true
    }
    
    
    /*
    override func viewDidDisappear(_ animated: Bool) {
        
        //searchController.searchBar.isHidden = true
    }
 */
    
     /*
    override func viewDidAppear(_ animated: Bool) {
        searchController.searchBar.isHidden = false
    }
 */
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredPersons.count
        } else {
            return UserData.shared.personsSearch.count
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SearchCell
        let person: UserData.Person
        if searchController.isActive && searchController.searchBar.text != "" {
            person = filteredPersons[indexPath.row]
        } else {
            person = UserData.shared.personsSearch[indexPath.row]
        }
        cell.nameLabel.text = person.name
        cell.positionLabel.text = person.position + " / " + person.department
        cell.photoView.image = UIImage()
        
        let assessemnts = UserData.shared.assessments
        let a = assessemnts.filter {$0.estimated == person.id}
        cell.iconStar.isHidden = a.count == 0
        
        AppModule.shared.imageFromUrl(person.photoUrl, cell.photoView)
        return cell
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath
        
        performSegue(withIdentifier: "assessment", sender: nil)
    }
 
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        
        let tokens = searchText.lowercased().components(separatedBy: " ").filter{i in
            return i.characters.count > 0
        }
        
        filteredPersons = UserData.shared.personsSearch.filter{
            s in
            for token in tokens {
                if !s.searchString.contains(token) {
                    return false
                }
            }
            return true
        }
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AssessmentTVC {
            if searchController.isActive && searchController.searchBar.text != "" {
                vc.person = filteredPersons[selectedIndex!.row]
            } else {
                vc.person = UserData.shared.personsSearch[selectedIndex!.row]
            }
            let assessments = UserData.shared.assessments
            var paa = assessments.filter {$0.estimated == vc.person!.id}
            paa = paa.sorted {UserData.toDate($0.date) > UserData.toDate($1.date)}
            vc.assessment = paa.first
        }
    }

}

extension SearchTVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension SearchTVC: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
        
    }
}

extension SearchTVC: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        //performSegue(withIdentifier: "cancelSearch", sender: nil)
        
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if let vc = self.parent as? UITabBarController {
            vc.selectedIndex = 0
        }
        return true
    }
    
}
