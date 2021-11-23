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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Saved articles"
        tableView.reloadData()
        tableView.delegate = self
        tableView.dataSource = self
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.loadData()
    }

    //MARK: - Info button action
    @IBAction func savedArticlesInfo(_ sender: Any) {
        basicAlert(title: "Saved articles info", message: "In this section you will find all of your saved articles. If you want to delete a article, click on the article you want to delete and swipe from right to left, then press \"Delete\" button.")
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
    
    //MARK: - Load data when view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.isEditing = false
        loadData()
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
        
        do{
            savedItems = try (context?.fetch(request))!
        }catch{
            print(error.localizedDescription)
        }
        tableView.reloadData()
    }
    
    //MARK: - Delete all data
    func deleteAllData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Items")
        let delete: NSBatchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do{
            try context?.execute(delete)
            saveData()
        }catch let err {
            print(err.localizedDescription)
        }
    }
    
    /*
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
     */

    //MARK: - Number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedItems.count
    }

    //MARK: - Write item in cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "savedArticleCell", for: indexPath) as? NewsTableViewCell else {return UITableViewCell()}

        let item = savedItems[indexPath.row]
        cell.newsImageView.sd_setImage(with: URL(string: item.image!), placeholderImage: UIImage(named: "news.png"))
        cell.newsTitleLabel.text = item.newsTitle

        return cell
    }

    //MARK: - Row height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    
    //MARK: - Confirmation of delete item
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "Delete article", message: "Are you sure you want to delete this article?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {_ in
                let item = self.savedItems[indexPath.row]
                self.context?.delete(item)
                self.saveData()
                self.loadData()
            }))
            self.present(alert, animated: true)
            
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    /*
    //MARK: - Navigate to web view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "WebViewController") as? WebViewController else {return}
        vc.urlString = self.savedItems[indexPath.row].url!
        navigationController?.pushViewController(vc, animated: true)
    }
     */
    
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

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
