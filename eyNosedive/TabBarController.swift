//
//  TabBarController.swift
//  eyNosedive
//
//  Created by Grisha on 6/30/17.
//  Copyright © 2017 EY. All rights reserved.
//

import UIKit



enum Pages: Int {
    case Search = 0, Profile, Archive, Request
}

class TabBarController: UITabBarController {
    
    
    
    var personsSeq = UserData.shared.personsSeq

    override func viewDidLoad() {
        super.viewDidLoad()
        Queue.shared.tabBar = self
        Queue.shared.load()
        Queue.shared.startTimer()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if personsSeq != UserData.shared.personsSeq {
            for vc in viewControllers! {
                if let vc = vc as? UITableViewController {
                    vc.tableView.reloadData()
                }
            }
            personsSeq = UserData.shared.personsSeq
        }
        
        let ind = tabBar.items?.index(of: item)
        
        if let vc = viewControllers?[ind!] {
            
            if let vc = viewControllers?[0] as? SearchTVC {
                vc.searchController.isActive = false
                
            }
            
            if let vc = vc as? HistoryTVC {
                vc.assessments = UserData.shared.assessments
                vc.historyAssessments = UserData.shared.historyAssessments
                vc.historyDates = UserData.shared.historyDates
                vc.persons = UserData.shared.persons

                vc.tableView.reloadData()
            }
            if let vc = vc as? RequestTVC {
                vc.requests = UserData.shared.requests
                vc.eventRequests = UserData.shared.eventRequests
                vc.events = UserData.shared.events
                vc.persons = UserData.shared.persons
                
                vc.tableView.reloadData()
            }
        }
    }


}
