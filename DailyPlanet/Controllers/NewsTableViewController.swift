//
//  NewsTableViewController.swift
//  DailyPlanet
//
//  Created by jazeps.ivulis on 24/11/2021.
//

import UIKit

class NewsTableViewController: UITableViewController {
    
    var newsItems: [NewsItem] = []
    var keyword = "country=us"
    var category = "&category=general"
    var apiKey = "346062761bab432696b614d07c01c24c"
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "General news"
        handleGetData(keyword: keyword)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    /*
    //MARK: - Refresh data button action
    @IBAction func refreshDataTapped(_ sender: Any) {
        handleGetData(keyword: keyword)
    }
     */
    
    //MARK: - News feed info button
    @IBAction func newsFeedInfo(_ sender: Any) {
        basicAlert(title: "Latest top articles info", message: "In this section you will find latest top articles in Latvia or globally.\nPress on \"refresh\" 🔄 button to reload the articles.")
    }
    
    
    @IBAction func changeCategoryButtonTapped(_ sender: Any) {
        let categoryMenu = UIAlertController(title: "Choose news category", message: .none, preferredStyle: .actionSheet)
        let business = UIAlertAction(title: "Business", style: .default) { Action in
            self.category = "&category=business"
            self.navigationItem.title = "Business news"
            self.handleGetData(keyword: self.keyword, category: self.category)
        }
        let entertainment = UIAlertAction(title: "Entertainment", style: .default) { Action in
            self.category = "&category=entertainment"
            self.navigationItem.title = "Entertainment news"
            self.handleGetData(keyword: self.keyword, category: self.category)
        }
        let general = UIAlertAction(title: "General", style: .default) { Action in
            self.category = "&category=general"
            self.navigationItem.title = "General news"
            self.handleGetData(keyword: self.keyword, category: self.category)
        }
        let health = UIAlertAction(title: "Health", style: .default) { Action in
            self.category = "&category=health"
            self.navigationItem.title = "Health news"
            self.handleGetData(keyword: self.keyword, category: self.category)
        }
        let science = UIAlertAction(title: "Science", style: .default) { Action in
            self.category = "&category=science"
            self.navigationItem.title = "Science news"
            self.handleGetData(keyword: self.keyword, category: self.category)
        }
        let sports = UIAlertAction(title: "Sports", style: .default) { Action in
            self.category = "&category=sports"
            self.navigationItem.title = "Sports news"
            self.handleGetData(keyword: self.keyword, category: self.category)
        }
        let technology = UIAlertAction(title: "Technology", style: .default) { Action in
            self.category = "&category=technology"
            self.navigationItem.title = "Technology news"
            self.handleGetData(keyword: self.keyword, category: self.category)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        categoryMenu.addAction(business)
        categoryMenu.addAction(entertainment)
        categoryMenu.addAction(general)
        categoryMenu.addAction(health)
        categoryMenu.addAction(science)
        categoryMenu.addAction(sports)
        categoryMenu.addAction(technology)
        categoryMenu.addAction(cancel)
        
        present(categoryMenu, animated: true, completion: nil)
    }
    
    
    //MARK: - Activity indicator
    func activityIndicator(animated: Bool){
        DispatchQueue.main.async {
            if animated{
                self.activityIndicatorView.isHidden = false
                self.activityIndicatorView.startAnimating()
            }else{
                self.activityIndicatorView.isHidden = true
                self.activityIndicatorView.stopAnimating()
            }
        }
    }
    
    //MARK: - Get data
    func handleGetData(keyword: String, category: String? = nil){
        newsItems.removeAll()
        tableView.reloadData()
        activityIndicator(animated: true)
        let jsonUrl = "https://newsapi.org/v2/top-headlines?\(keyword)\(category ?? "")&apiKey=\(apiKey)"
        
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
                self.newsItems = jsonData.articles
                DispatchQueue.main.async {
                    print("self.newsItems:", self.newsItems)
                    self.tableView.reloadData()
                    self.activityIndicator(animated: false)
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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return newsItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as? NewsTableViewCell else {return UITableViewCell()}

        let item = newsItems[indexPath.row]
        cell.newsTitleLabel.text = item.title
        cell.newsTitleLabel.numberOfLines = 0
        cell.newsImageView.sd_setImage(with:URL(string: item.urlToImage ?? ""), placeholderImage: UIImage(named: "news.png"))

        return cell
    }
    
    //MARK: - Row height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    //MARK: - Navigate to article preview
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storybord = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let vc = storybord.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {return}
        let item = newsItems[indexPath.row]
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
