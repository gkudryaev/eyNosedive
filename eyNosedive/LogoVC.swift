//
//  LogoVC.swift
//  eyNosedive
//
//  Created by Grisha on 6/19/17.
//  Copyright © 2017 EY. All rights reserved.
//

import UIKit

class LogoVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserData.shared.load()
        if UserData.shared.id != "" {
            AppModule.shared.goStoreBoard(storeBoardName: "Directory")
        }
    }

}
