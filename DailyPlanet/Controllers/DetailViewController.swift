//
//  DetailViewController.swift
//  DailyPlanet
//
//  Created by jazeps.ivulis on 22/11/2021.
//

import UIKit
import SDWebImage
import CoreData

class DetailViewController: UIViewController {

    var savedItems = [Items]()
    var context: NSManagedObjectContext?
    var webUrlString = String()
    var titleString = String()
    var publishedAtString = String()
    var contentString = String()
    var newsImage = String()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var publishedAtLabel: UILabel!
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var saveArticleButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = titleString
        publishedAtLabel.text = publishedAtString.replacingOccurrences(of: "T", with: " ").replacingOccurrences(of: "Z", with: "")
        contentTextView.text = contentString
        newsImageView.sd_setImage(with: URL(string: newsImage), placeholderImage: UIImage(named: "news.png"))
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        
        hideSaveButton()
    }
    
    
    //MARK: - Is article already saved
    func hideSaveButton() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Items")
        fetchRequest.predicate = NSPredicate(format: "newsTitle == %@", titleString)
        
        do {
            let matchedArticles = try context?.fetch(fetchRequest) as! [Items]
            if matchedArticles.isEmpty {
                saveArticleButton.setTitle("Save article", for: .normal)
                saveArticleButton.isEnabled = true
            } else {
                saveArticleButton.setTitle("Already saved", for: .normal)
                saveArticleButton.backgroundColor = .init(red: 0, green: 0.5, blue: 0.1, alpha: 1)
                saveArticleButton.setTitleColor(.white, for: .disabled)
                saveArticleButton.isEnabled = false
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    
    //MARK: - Saving data
    func saveData() {
        do {
            try context?.save()
            basicAlert(title: "Article saved!", message: "Please, go to \"Saved articles\" tab bar to see your saved articles.")
        }catch{
            print(error.localizedDescription)
        }
    }
    
    
    //MARK: - Save button action
    @IBAction func saveButtonTapped(_ sender: Any) {
        let newItem = Items(context: context!)
        newItem.newsTitle = titleString
        newItem.publishedAt = publishedAtString
        newItem.newsContent = contentString
        newItem.url = webUrlString
        newItem.image = newsImage
        
        savedItems.append(newItem)
        saveData()
        
        saveArticleButton.setTitle("Already saved", for: .normal)
        saveArticleButton.backgroundColor = .init(red: 0, green: 0.5, blue: 0.1, alpha: 1)
        saveArticleButton.setTitleColor(.white, for: .disabled)
        saveArticleButton.isEnabled = false
    }
    
    
    //MARK: - Navigate to web view
    @IBAction func readArticleButtonTapped(_ sender: Any) {
        let storybord = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let vc = storybord.instantiateViewController(withIdentifier: "WebViewController") as? WebViewController else {return}
        
        vc.urlString = webUrlString
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
