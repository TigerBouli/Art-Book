//
//  DetailViewController.swift
//  Art Book
//
//  Created by Wojciech Zakroczymski on 29/07/2021.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var authorText: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    
    var selectedId: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.isUserInteractionEnabled = true
        
        let taprecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        let tapImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(pickPicture))
        view.addGestureRecognizer(taprecognizer)
        imageView.addGestureRecognizer(tapImageRecognizer)
        
        saveButton.isEnabled = false
        
        if let id = selectedId {
            let appDeletegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDeletegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pictures")
            let idString = id.uuidString
            let predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.predicate = predicate
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        
                        if let author = result.value(forKey: "author") as? String {
                            authorText.text = author
                        }
                        if let year = result.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            } catch  {
                print("error")
            }
            
            
        }
        // Do any additional setup after loading the view.
    }
    
    @objc func dismissKeyboard () {
        view.endEditing(true)
    }
    
    @objc func pickPicture() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        picker.modalPresentationStyle = .overFullScreen
        present(picker, animated: true, completion: nil)
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        picker.dismiss(animated: true, completion: nil)
    }

    @IBAction func saveTapped(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context  = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Pictures", into: context)
        
        newPainting.setValue(nameText.text!, forKey: "name")
        newPainting.setValue(authorText.text!, forKey: "author")
        if let year = Int(yearText.text!) {
            newPainting.setValue(year, forKey: "year")
        }
        newPainting.setValue(UUID(), forKey: "id")
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        do {
            try context.save()
        } catch  {
            print("error")
        }
        self.navigationController?.popViewController(animated: true)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newData"), object: nil)
    }
    

}
