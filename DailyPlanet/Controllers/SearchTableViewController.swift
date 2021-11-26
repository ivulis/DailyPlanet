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
    var apiKey = "40861cbd1e744cae9c0975478d7576e7"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Search articles"
        createSearchBar()
    }
    
    
    //MARK: - Number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchItems.count == 0 {
            tableView.setEmptyView(title: "No search results", message: "Your search results will be here")
        } else {
            tableView.restore()
        }
        return searchItems.count
    }
    
    
    //MARK: - Search info button tapped
    @IBAction func searchInfoButtonTapped(_ sender: Any) {
        basicAlert(title: "Search info", message: "In this section you can search for articles by keyword.\nTap on search bar, enter any keyword you want to search for and press \"Search\" on the keyboard.")
    }
    
    
    //MARK: - Create search bar
    func createSearchBar() {
        navigationItem.searchController = searchVC
        searchVC.searchBar.placeholder = "Tap here to search by keyword"
        searchVC.searchBar.delegate = self
    }
    
    
    //MARK: - Search bar enter button
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text, !keyword.isEmpty else {return}
        let trimmedKeyword = keyword.filter {!$0.isWhitespace}
        print(trimmedKeyword)
        
        handleGetData(keyword: trimmedKeyword)
    }
    
    
    //MARK: - Search bar cancel button
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchItems.removeAll()
        tableView.reloadData()
    }
    
    
    //MARK: - Get data
    func handleGetData(keyword: String){
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
                }
            }catch{
                print("err:", error)
            }
        }.resume()
    }
    

    //MARK: - Write item in cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as? NewsTableViewCell else {return UITableViewCell()}

        let item = searchItems[indexPath.row]
        cell.newsTitleLabel.text = item.title
        cell.newsPublishedAtLabel.text = item.publishedAt.replacingOccurrences(of: "T", with: " ").replacingOccurrences(of: "Z", with: "")
        cell.newsImageView.sd_setImage(with: URL(string: item.urlToImage ?? ""), placeholderImage: UIImage(named: "news.png"))

        return cell
    }
    
    
    //MARK: - Row height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    
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
}
