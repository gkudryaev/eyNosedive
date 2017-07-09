//
//  ProfileTVC.swift
//  eyNosedive
//
//  Created by Grisha on 6/20/17.
//  Copyright © 2017 EY. All rights reserved.
//

import UIKit

class ProfileTVC: UITableViewController {
    
    var imageData: Data?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func photoPressed(_ sender: Any) {

        /*
        if let imageData = imageData {
            
            request(imageData: imageData)
            return
        }
        */
        
        let AC = UIAlertController(title: "Смена фото", message: "", preferredStyle: .alert)
        let cameraRollBtn = UIAlertAction(title: "Загрузить фото из галереи", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: { _ in })
        })
        let noBtn = UIAlertAction(title: "Отменить", style: .default, handler: {(_ action: UIAlertAction) -> Void in
        })
        AC.addAction(cameraRollBtn)
        AC.addAction(noBtn)
        self.parent!.present(AC, animated: true, completion: { _ in })
    }
    
    @IBAction func logoffPressed(_ sender: Any) {
        let userData = UserData.shared
        userData.id = ""
        userData.save()
        AppModule.shared.goStoreBoard(storeBoardName: "Logon")
    }
    
    @IBAction func refreshPressed(_ sender: Any) {
        requestRefresh()
    }
    
    func requestRefresh () {
        JsonHelper.request(.refresh,
                           ["personsSeq": UserData.shared.personsSeq],
                           self,
                           {(json: [String: Any]?, error: String?) -> Void in
                            self.responseRefresh(json: json, error: error)
                            
        })
    }
    
    func responseRefresh (json: [String: Any]?, error: String?) {
        if let error = error {
            AppModule.shared.alertError(error, view: self)
        } else {
            UserData.shared.save(json: json!)
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {


        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath)
                as! ProfileCell
            let user = UserData.shared.persons.filter {
                $0.id == UserData.shared.id
            }.first
            AppModule.shared.imageFromUrl(user?.photoUrl, cell.photoImageView)
            cell.nameLabel.text = user?.name
            cell.position.text = user?.position
            cell.department.text = user?.department
            cell.email.text = user?.email
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RefreshCell", for: indexPath)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LogoffCell", for: indexPath)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 320
        }
        else {
            return 44
        }
    }
}


extension ProfileTVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            if let imageData = UIImageJPEGRepresentation(image, 0.01) {
                self.imageData = imageData
                request(imageData: imageData)
            }
            
            // imageData = UIImageJPEGRepresentation(image, 0.8) as NSData!
            //uploadImage = true;
        }
        
        picker.dismiss(animated: true, completion: nil);
    }
    
    func request (imageData: Data) {
        
        

        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration:configuration)

        let url = URL(string:"http://ec2-52-57-85-114.eu-central-1.compute.amazonaws.com/wsgi/ords/ey/v000.1/photoUpload")
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let sh = UserData.shared
        request.httpBody = createBody(parameters: [
            "id": sh.id,
            "pass": sh.pass,
            "device": (UIDevice.current.identifierForVendor?.uuidString)!,
            "personsSeq": UserData.shared.personsSeq
            ], filePathKey: "img.jpg", boundary: boundary, imageData: imageData)
        
        let loadDataTask = session.dataTask(with: request as URLRequest) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode != 200 {
                        //completion(nil, "HTTP status code /(httpResponse.statusCode)")
                    } else {
                        if let json = try? JSONSerialization.jsonObject(with: data!)  as? [String: Any] {
                            UserData.shared.save(json: json!)
                        }
                    }
                }
                JsonHelper.stopActivity()
                self.tableView.reloadData()
            }
        }
        JsonHelper.startActivity()
        loadDataTask.resume()

    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }

    
    func createBody(parameters:[String:String], filePathKey:String, boundary:String, imageData: Data) -> Data{
        
        var body = Data()
        
        let jsonData = try! JSONSerialization.data(withJSONObject: parameters, options: [])

        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Disposition: form-data; name=\"json\"\r\n\r\n".utf8))
        body.append(jsonData)
        body.append(Data("--\(boundary)\r\n".utf8))
        
        let mimetype = "image/jpg"
        
        let defFileName = "yourImageName.jpg"
        
        body.append(Data("Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"\(defFileName)\"\r\n".utf8))
        body.append(Data("Content-Type: \(mimetype)\r\n\r\n".utf8))
        body.append(imageData)
        body.append(Data("\r\n".utf8))
        
        body.append(Data("--\(boundary)--\r\n".utf8))
        
        return body
    }
}
