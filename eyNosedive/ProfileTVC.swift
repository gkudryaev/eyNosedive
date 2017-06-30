//
//  ProfileTVC.swift
//  eyNosedive
//
//  Created by Grisha on 6/20/17.
//  Copyright © 2017 EY. All rights reserved.
//

import UIKit

class ProfileTVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func logoffPressed(_ sender: Any) {
        let userData = UserData.shared
        userData.id = ""
        userData.save()
        AppModule.shared.goStoreBoard(storeBoardName: "Logon")
    }
}
