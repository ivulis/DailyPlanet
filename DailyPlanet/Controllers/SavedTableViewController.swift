//
//  SavedTableViewController.swift
//  DailyPlanet
//
//  Created by jazeps.ivulis on 22/11/2021.
//

import UIKit
import CoreData
import SDWebImage

class SavedTableViewController: UITableViewController {

    var savedItems = [Items]()
    var context: NSManagedObjectContext?
    var webUrlString = String()
    
    @IBOutlet weak var editButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var deleteAllArticlesButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Saved articles"
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        loadData()
    }

    //MARK: - Load data when view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadData()
    }
    
    //MARK: - Number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if savedItems.count == 0 {
            tableView.setEmptyView(title: "You don't have any saved articles", message: "Your saved articles will be here")
        } else {
            tableView.restore()
        }
        return savedItems.count
    }
    
    
    //MARK: - Edit button action
    @IBAction func editButtonTapped(_ sender: Any) {
        tableView.isEditing = !tableView.isEditing
        if tableView.isEditing{
            editButtonOutlet.title = "Save"
        }else{
            editButtonOutlet.title = "Edit"
        }
    }
    
    
    //MARK: - Delete all data button action
    @IBAction func deleteAllArticles(_ sender: Any) {
        let alertController = UIAlertController(title: "Delete all articles?", message: "Do you want to delete all saved articles?", preferredStyle: .alert)
        let deleteActionButton = UIAlertAction(title: "Delete", style: .destructive) { Action in
            self.deleteAllData()
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(deleteActionButton)
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true, completion: nil)
    }
    

    //MARK: - Save data
    func saveData() {
        do {
            try self.context?.save()
        }catch{
            print(error.localizedDescription)
        }
        loadData()
    }
    
    
    //MARK: - Load data
    func loadData() {
        let request: NSFetchRequest<Items> = Items.fetchRequest()
        
        do {
            savedItems = try (context?.fetch(request))!
        } catch {
            print(error.localizedDescription)
        }
        
        editButtonOutlet.isEnabled = isSavedEmpty()
        deleteAllArticlesButton.isEnabled = isSavedEmpty()
        tableView.reloadData()
    }
    
    
    //MARK: - Saved articles array isEmpty?
    func isSavedEmpty() -> Bool {
        var status = false
        let request: NSFetchRequest<Items> = Items.fetchRequest()
        
        do {
            savedItems = try (context?.fetch(request))!
            if !savedItems.isEmpty {
                status = true
            } else {
                status = false
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return status
    }
    
    
    //MARK: - Delete all data
    func deleteAllData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Items")
        let delete: NSBatchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do{
            try context?.execute(delete)
            saveData()
            basicAlert(title: "Success!", message: "All saved articles have been successfully deleted from your favorites.")
        }catch let err {
            print(err.localizedDescription)
        }
    }
    

    //MARK: - Write item in cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "savedArticleCell", for: indexPath) as? NewsTableViewCell else {
            return UITableViewCell()
        }

        let item = savedItems[indexPath.row]
        cell.newsTitleLabel.text = item.newsTitle
        cell.newsPublishedAtLabel.text = item.publishedAt?.replacingOccurrences(of: "T", with: " ").replacingOccurrences(of: "Z", with: "")
        cell.newsImageView.sd_setImage(with: URL(string: item.image!), placeholderImage: UIImage(named: "news.png"))

        return cell
    }

    
    //MARK: - Row height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    
    //MARK: - Confirmation of delete item
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "Delete article", message: "Are you sure you want to delete this article?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {_ in
                let item = self.savedItems[indexPath.row]
                self.context?.delete(item)
                self.saveData()
                self.basicAlert(title: "Success!", message: "Article has been successfully removed from your favorites.")
            }))
            self.present(alert, animated: true)
        }
    }
    
    
    //MARK: - Rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let row = savedItems.remove(at: fromIndexPath.row)
        savedItems.insert(row, at: to.row)
    }
    

    //MARK: - Conditional rearranging of table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    //MARK: - Navigate to article preview
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storybord = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let vc = storybord.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {return}
        let item = savedItems[indexPath.row]
        vc.newsImage = item.image!
        vc.titleString = item.newsTitle!
        vc.webUrlString = item.url!
        vc.contentString = item.newsContent!
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
