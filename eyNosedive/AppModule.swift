//
//  AppModule.swift
//  iPromatSwift
//
//  Created by Kudryaev, Grigoriy on 06.09.16.
//  Copyright © 2016 Kudryaev, Grigoriy. All rights reserved.
//

import Foundation
import UIKit

//let iPromat = "iPromat"

class AppModule {
    
    static let shared = AppModule()
    
    static let defaultColor = UIColor (colorLiteralRed:248.0/255.0, green:139.0/255.0, blue:57.0/255.0, alpha:1)
    
    static let sectionBkColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
    
    func alertError (_ txtError: String, view: UIViewController) {
        
        let alert = UIAlertController(title: "Ошибка", message: txtError, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        //DispatchQueue.main.async
        //{
        view.present(alert, animated: true, completion: nil)
        //}
        
    }
    
    func alertMessage (_ txtMessage: String, view: UIViewController) {
        
        let alert = UIAlertController(title: "", message: txtMessage, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        //DispatchQueue.main.async
        //{
        view.present(alert, animated: true, completion: nil)
        //}
        
    }
    
    func goStoreBoard (storeBoardName: String) {
        let storyBoard = UIStoryboard.init(name: storeBoardName, bundle: nil)
        let vc = storyBoard.instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
    public func imageFromUrl(_ urlString: String?, _ imageView: UIImageView ) {
        
        if urlString == nil {
            return
        }
        
        let urlStr = urlString?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let url = URL(string: urlStr!)
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "GET"
        
        let loadDataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            DispatchQueue.main.async {
               if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode != 200 {
                        print("HTTP status code /(httpResponse.statusCode)")
                    } else {
                        imageView.image = UIImage(data: data!)
                    }
                }
            }
        })
        loadDataTask.resume()
    }

    
 }

