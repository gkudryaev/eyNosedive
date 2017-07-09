//
//  JsonHelper.swift
//  iPromatSwift
//
//  Created by Kudryaev, Grigoriy on 04.09.16.
//  Copyright © 2016 Kudryaev, Grigoriy. All rights reserved.
//

import Foundation
import UIKit


enum JsonUrls {
    
    case logon
    case logonCode
    case assessment
    case requestManual
    case requestDelete
    case refresh
    
    func request () -> (url: String, method: String) {
        
        //let host = "http://127.0.0.1:8080/ords/ey/"
        //let host = "http://192.168.0.131:8080/ords/ey/"
        //let host = "http://127.0.0.1:8000/nosedive/apex/"
        //let host = "http://192.168.0.131:8000/nosedive/apex/"
        let host = "http://ec2-52-57-85-114.eu-central-1.compute.amazonaws.com/wsgi/ords/ey/"

        switch self {
        case .logon:
            return (host + "v000.1/logon", "POST")
        case .logonCode:
            return (host + "v000.1/logonCode", "POST")
        case .assessment:
            return (host + "v000.1/assessment", "POST")
        case .requestManual:
            return (host + "v000.1/request", "POST")
        case .requestDelete:
            return (host + "v000.1/requestDelete", "POST")
        case .refresh:
            return (host + "v000.1/refresh", "POST")
        }
    }
}

class JsonHelper {
    
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
                stopActivity()
            }
        }
        startActivity()
        loadDataTask.resume()
    }
    
    class func startActivity () {
        
        guard let view = UIApplication.shared.keyWindow?.subviews.last else {
            return
        }
        
        container.frame = view.frame
        container.center = view.center
        container.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = view.center
        loadingView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.8)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        //activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 80.0, height: 80.0);
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = view.center
        activityIndicator.color = .white
        
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        view.addSubview(container)
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    class func startActivityOld () {
        let view = UIApplication.shared.keyWindow?.subviews.last
        activityIndicator.center = view!.center
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.color = .gray
        activityIndicator.startAnimating()
        view?.addSubview(activityIndicator)
    }
    class func stopActivity () {
        activityIndicator.stopAnimating()
        container.removeFromSuperview()
        activityIndicator.removeFromSuperview()
    }
}
