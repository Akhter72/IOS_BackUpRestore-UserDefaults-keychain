//
//  ViewController.swift
//  UserDefaults
//
//  Created by Mac on 10/08/23.
//

import UIKit
import Security

class ViewController: UIViewController, UIDocumentInteractionControllerDelegate  {
        var obj: MyData?
    var service: String = "com.ideas2it"
    var account: String = "user123"
    var myAlert: UIAlertController?
    override func viewDidLoad() {
        super.viewDidLoad()
        let dataToSave = MyData(name: "Akhter", age: 20, dob: "2023-02-01", isLoggedIn: true, isActDeleted: true, phoneNumber: "7780951191")
        obj = dataToSave
        let alert = UIAlertController(title: "Alert", message: "Default values saved", preferredStyle: .alert)
        let action = UIAlertAction(title: "ok", style: .default)
        alert.addAction(action)
        myAlert = alert
    }
    
    
    func printUserDefaults(){
        print(UserDefaults.standard.string(forKey: "name")!)
    }
    
    func saveData() {
        let defaults = UserDefaults.standard
        defaults.set(obj?.name, forKey: "name")
        defaults.set(obj?.age, forKey: "age")
        defaults.set(obj?.isActDeleted , forKey: "isActDeleted")
        defaults.set(obj?.isLoggedIn , forKey: "isLoggedIn")
        defaults.set(obj?.dob , forKey: "dob")
        defaults.set(obj?.phoneNumber , forKey: "phoneNumber")
        self.myAlert?.message = "User Defaults saved successfully"
        self.present(myAlert!, animated: true)
    }
    
    func writeData() {
        let projectDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let textFileName = "nodeData.json"
        let textFileURL = projectDirectoryURL.appendingPathComponent(textFileName)

        // Your data to be written to the file
        let defaults = UserDefaults.standard
        let customUserDefaults = UserDefaults(suiteName: "")
        let defaultKeys = customUserDefaults?.dictionaryRepresentation().keys
        let dictionary = defaults.dictionaryRepresentation()
        let ourKeys = dictionary.keys.filter { key in
            return !defaultKeys!.contains(key)
        }
        var dictionaryData: [String: Any] = [:]
        for key in ourKeys {
            dictionaryData[key] = dictionary[key]
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: dictionaryData, options: [])
            try data.write(to: textFileURL)
            self.myAlert?.message = "Data written to the file successfully!"
        } catch {
            self.myAlert?.message = "Error writing to file: \(error)"
        }
        self.present(myAlert!, animated: true)
    }
    
    func previewData() {

        let projectDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let fileName = "nodeData.json"
        let fileURL = projectDirectoryURL.appendingPathComponent(fileName)
        let documentController = UIDocumentInteractionController(url: fileURL)
        documentController.delegate = self
        documentController.presentPreview(animated: true)
        
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    func readAndSaveFile() {
        let projectDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "nodeData.json"
        let fileURL = projectDirectoryURL.appendingPathComponent(fileName)
        do {
            
            let fileData = try Data(contentsOf: fileURL)
            if let json = try JSONSerialization.jsonObject(with: fileData, options: []) as? NSDictionary {
                print(json.allKeys)
                
                for key in json.allKeys {
                    print("key = \(key) and value is \(json.value(forKey: key as! String)!)")
                    UserDefaults.standard.set(json.value(forKey: key as! String) , forKey: key as! String)
                }
                self.myAlert?.message = "file data saved to device"
            }
        } catch {
            self.myAlert?.message = "there was error saving file data to device"
            print("error")
        }
    }
    
    func saveKeyChainData(value: String) -> Bool {
        if let data = value.data(using: .utf8) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account,
                kSecValueData as String: data
            ]
            
            SecItemDelete(query as CFDictionary)
            
            let status = SecItemAdd(query as CFDictionary, nil)
            return status == errSecSuccess
        }
        return false
    }
    
    func writeKeyChainData() {
        let query: [String: Any] = [
              kSecClass as String: kSecClassGenericPassword,
              kSecAttrService as String: service,
              kSecAttrAccount as String: account,
              kSecReturnData as String: kCFBooleanTrue!,
              kSecMatchLimit as String: kSecMatchLimitOne
          ]
          
          var result: AnyObject?
          let status = SecItemCopyMatching(query as CFDictionary, &result)
          
          if status == errSecSuccess, let data = result as? Data, let stringValue = String(data: data, encoding: .utf8) {
              let projectDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
              let fileName = "nodeDataKeyChain.txt"
              let fileURL = projectDirectoryURL.appendingPathComponent(fileName)
              do {
                  try stringValue.write(to: fileURL, atomically: true, encoding: .utf8)
                  myAlert?.message = "data written in file successfully"
              } catch {
                  myAlert?.message = "error in writing to file"
              }
          }
        self.present(myAlert!, animated: true)
    }
    
    func previewKeyChainData() {
        let projectDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "nodeDataKeyChain.txt"
        let fileURL = projectDirectoryURL.appendingPathComponent(fileName)
        let documentController = UIDocumentInteractionController(url: fileURL)
        documentController.delegate = self
        documentController.presentPreview(animated: true)

        print(fileURL)
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            saveData()
            break
        case 2:
            writeData()
            break
        case 3:
            previewData()
            break
        case 4:
            if saveKeyChainData(value: "Hlo i am saving this String into key chain") {
                myAlert?.message = "message saved into key chain successfully"
            } else {
                myAlert?.message = "error message saving into key chain"
            }
            self.present(myAlert!, animated: true)
            break
        case 5:
            writeKeyChainData()
            break
        case 6:
            previewKeyChainData()
            break
        default:
            print("hhhh")
        }

    }
}

class MyData {
    var name: String
    var age: Int
    var dob: String
    var isLoggedIn: Bool
    var isActDeleted: Bool
    var phoneNumber: String
    
    init(name: String, age: Int, dob: String, isLoggedIn: Bool, isActDeleted: Bool, phoneNumber: String) {
        self.name = name
        self.age = age
        self.dob = dob
        self.isLoggedIn = isLoggedIn
        self.isActDeleted = isActDeleted
        self.phoneNumber = phoneNumber
    }
}

