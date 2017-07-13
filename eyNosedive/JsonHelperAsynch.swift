//
//  JsonHelper.swift
//  iPromatSwift
//
//  Created by Kudryaev, Grigoriy on 04.09.16.
//  Copyright © 2016 Kudryaev, Grigoriy. All rights reserved.
//

import Foundation
import UIKit


class JsonHelperAsynch {
    
    static let activityIndicator = UIActivityIndicatorView()
    static var container: UIView = UIView()
    static var loadingView: UIView = UIView()
    
    
    
    class func request (_ url: JsonUrls,
                        _ params: Dictionary<String, Any>?,
                        _ viewController: UIViewController?,
                        _ completion:@escaping (_ json: [String: Any]?, _ errStr: String?) -> Void
        ) {
        // может быть это лишний слой - все засунуть в этот вызов
        let r = url.request()
        loadDataFromURL (
            r.url,
            method: r.method,
            params:params,
            viewController:viewController){
                (json: [String: Any]?, error: String?) -> Void in
                if let respError = error {
                    print ("error" + respError)
                }
                completion (json, error)
        }
    }
    
    
    class func loadDataFromURL(_ urlString: String,
                               method: String,
                               params: Dictionary<String,Any>?,
                               viewController: UIViewController?,
                               completion:@escaping (_ json: [String:Any]?, _ errStr: String?) -> Void) {
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration:configuration)
        
        let url = URL(string:urlString)
        let request = NSMutableURLRequest(url: url!)
        
        request.httpMethod = method
        
        if var params = params {
            if UserData.shared.id != "" {
                params["id"] = UserData.shared.id
                params["pass"] = UserData.shared.pass
            }
            let dev = UIDevice.current
            params ["device"] = dev.identifierForVendor?.uuidString
            params["os"] = "iOS"
            params ["deviceProp"] = [
                ["name": "model", "val": dev.model],
                ["name": "name", "val": dev.name],
                ["name": "systemName", "val": dev.systemName],
                ["name": "systemVersion", "val": dev.systemVersion],
                ["name": "localizedModel", "val": dev.localizedModel]
            ]
            request.httpBody = try! JSONSerialization.data(withJSONObject: params, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let loadDataTask = session.dataTask(with: request as URLRequest) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode != 200 {
                        completion(nil, "HTTP status code /(httpResponse.statusCode)")
                    } else {
                        if let json = try? JSONSerialization.jsonObject(with: data!)  as? [String: Any] {
                            if let vc = viewController, let txtError = json?["error"] as? String
                            {
                                completion(nil, txtError)
                            } else {
                                completion(json, nil)
                            }
                        }
                    }
                }
            }
        }
        loadDataTask.resume()
    }
    
}
