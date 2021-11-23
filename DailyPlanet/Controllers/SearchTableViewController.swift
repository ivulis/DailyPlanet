//
//  SearchTableViewController.swift
//  DailyPlanet
//
//  Created by jazeps.ivulis on 22/11/2021.
//

import UIKit
import SDWebImage

class SearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    let searchVC = UISearchController(searchResultsController: nil)
    var searchItems: [NewsItem] = []
    var keyword = ""
    var apiKey = "da4ea3d359ea4aa2bebd446fe3c94c3d"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Search"
        createSearchBar()
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    //MARK: - Search info button tapped
    @IBAction func searchInfoButtonTapped(_ sender: Any) {
        basicAlert(title: "Search info", message: "In this section you can search for articles by keywords.\nTap on search bar, enter anything you want to search for and press \"Search\" on the keyboard.")
    }
    
    //MARK: - Create search bar
    func createSearchBar() {
        navigationItem.searchController = searchVC
        searchVC.searchBar.delegate = self
    }
    
    /*
    //MARK: - Load data when view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //tableView.isEditing = false
        //handleGetData(keyword: keyword)
    }
     */
    
    //MARK: - Search bar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text, !keyword.isEmpty else {return}
        let trimmedKeyword = keyword.filter {!$0.isWhitespace}
        print(trimmedKeyword)
        
        handleGetData(keyword: trimmedKeyword)
    }
    
    //MARK: - Get data
    func handleGetData(keyword: String){
        //activityIndicator(animated: true)
        let jsonUrl = "https://newsapi.org/v2/everything?q=\(keyword)&language=en&sortBy=popularity&apiKey=\(apiKey)"
        
        guard let url = URL(string: jsonUrl) else {return}
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        
        URLSession(configuration: config).dataTask(with: urlRequest) { data, response, error in
            if error != nil {
                print((error?.localizedDescription)!)
                self.basicAlert(title: "Error!", message: "\(String(describing: error?.localizedDescription))")
                return
            }
            
            guard let data = data else {
                self.basicAlert(title: "Error!", message: "Something went wrong, no data.")
                return
            }
            
            do{
                let jsonData = try JSONDecoder().decode(Articles.self, from: data)
                self.searchItems = jsonData.articles
                DispatchQueue.main.async {
                    print("self.newsItems:", self.searchItems)
                    self.tableView.reloadData()
                    //self.activityIndicator(animated: false)
                }
            }catch{
                print("err:", error)
            }
        }.resume()
    }
    

    // MARK: - Table view data source

    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
     */

    //MARK: - Number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchItems.count
    }

    //MARK: - Write item in cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as? NewsTableViewCell else {return UITableViewCell()}

        let item = searchItems[indexPath.row]
        cell.newsTitleLabel.text = item.title
        cell.newsImageView.sd_setImage(with: URL(string: item.urlToImage ?? ""), placeholderImage: UIImage(named: "news.png"))

        return cell
    }
    
    //MARK: - Row height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    /*
    //MARK: - Navigate to web view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "WebViewController") as? WebViewController else {return}
        vc.urlString = self.searchItems[indexPath.row].url
        navigationController?.pushViewController(vc, animated: true)
    }
    */
    
    //MARK: - Navigate to article preview
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storybord = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let vc = storybord.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {return}
        let item = searchItems[indexPath.row]
        vc.newsImage = item.urlToImage ?? ""
        vc.titleString = item.title
        vc.webUrlString = item.url
        vc.contentString = item.description ?? ""
        
        navigationController?.pushViewController(vc, animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
