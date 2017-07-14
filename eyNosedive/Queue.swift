//
//  Queue.swift
//  eyNosedive
//
//  Created by Grisha on 7/12/17.
//  Copyright © 2017 EY. All rights reserved.
//

import Foundation
import UIKit

class Event {
    enum Status: String {
        case queue, ok, error
    }
    
    let url: JsonUrls
    let params: [String: Any]
    var status: Status
    var msg: String
    
    func attributes() -> [Any] {
        return [
            url.rawValue,
            params,
            status.rawValue,
            msg
        ]
    }
    
    init (url: JsonUrls, params: [String: Any]) {
        self.url = url
        self.params = params
        self.status = .queue
        self.msg = ""
    }
    init(attr: [Any]) {
        self.url = JsonUrls(rawValue: attr[0] as! String)!
        self.params = attr[1] as! [String : Any]
        self.status = Status(rawValue: attr[2] as! String)!
        self.msg = attr[3] as! String
    }
}


class Queue {

    let lock = DispatchQueue(label: "com.ey.nosedive.queue")
    let keyQueue = "com.ey.nosedive.queue"
    
    var queue: [Event] = []
    
    var tabBar: UITabBarController?
    
    static let shared: Queue = Queue()
    
    //TODO - Profile - add information queue about
    

    func save () {

        let std = UserDefaults.standard
        
        var eventsAttr: [[Any]] = []
        for event in queue {
            eventsAttr.append(event.attributes())
        }
        std.set(eventsAttr, forKey: keyQueue)
    }
    
    func load() {

        var queue: [Event] = []
        if let eventsAttr = UserDefaults.standard.array(forKey: keyQueue) as? [[Any]] {
            for eventAttr in eventsAttr {
                queue.append(Event(attr: eventAttr))
            }
        }
        self.queue = queue
        setBadge()
    }

    
    func setBadge () {
        
        tabBar?.viewControllers?[Pages.Profile.rawValue].tabBarItem.badgeValue =
            queue.count == 0 ? nil : String(queue.count)

    }

    func append (url: JsonUrls, params: [String: Any]) {
        lock.sync() {
            queue.append(Event(url: url, params: params))
            setBadge()
            save()
        }
        //synch() - should wait
    }
    
    func startTimer() {
        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.synch), userInfo: nil, repeats: false)
    }
    
    @objc func synch() {
        lock.sync() {
            guard (queue.count != 0) else {
                startTimer()
                return
            }
            
            let event = queue.first!
            JsonHelperAsynch.request(event.url,
                                     event.params,
                                     nil,
                                     {(json: [String: Any]?, error: String?) -> Void in
                                        self.response(json: json, error: error)
                                        
            })
        }
    }

    func response (json: [String: Any]?, error: String?) {
        lock.sync() {
            if let error = error {
                if let event = queue.first {
                    event.msg = error
                    event.status = .error
                }
            } else {
                queue.remove(at: 0)
                if queue.count == 0 {
                    UserData.shared.save(json: json!)
                }
                setBadge()
            }
            save()
        }
        startTimer()
    }
}
