//
//  NewsFeedViewController.swift
//  DailyPlanet
//
//  Created by jazeps.ivulis on 22/11/2021.
//

import UIKit
import SDWebImage

class NewsFeedViewController: UIViewController {
    
    public var newsItems: [NewsItem] = []
    var keyword = "country=lv"

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var apiKey = "da4ea3d359ea4aa2bebd446fe3c94c3d"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "News"
        handleGetData(keyword: keyword)
    }

    //MARK: - Refresh data button action
    @IBAction func refreshDataTapped(_ sender: Any) {
        activityIndicator(animated: true)
        handleGetData(keyword: keyword)
    }
    
    //MARK: - News feed info button
    @IBAction func newsFeedInfo(_ sender: Any) {
        basicAlert(title: "Latest top articles info", message: "In this section you will find latest top articles in Latvia or globally.\nPress on \"refresh\" 🔄 button to reload the articles.")
    }
    
    
    @IBAction func newsTypeSelectedAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            keyword = "country=lv"
        case 1:
            keyword = "language=en"
        default:
            keyword = "country=lv"
        }
        handleGetData(keyword: keyword)
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
    func handleGetData(keyword: String){
        activityIndicator(animated: true)
        let jsonUrl = "https://newsapi.org/v2/top-headlines?\(keyword)&apiKey=\(apiKey)"
        
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
                    self.tblView.reloadData()
                    self.activityIndicator(animated: false)
                }
            }catch{
                print("err:", error)
            }
            
        }.resume()
    }
}

extension NewsFeedViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "topArticlesCell", for: indexPath) as? NewsTableViewCell else {return UITableViewCell()}
        
        let item = newsItems[indexPath.row]
        cell.newsTitleLabel.text = item.title
        cell.newsTitleLabel.numberOfLines = 0
        cell.newsImageView.sd_setImage(with:URL(string: item.urlToImage ?? ""), placeholderImage: UIImage(named: "news.png"))
        
        return cell
    }
    
    //MARK: - Row height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    //MARK: - Navigate to article preview
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storybord = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let vc = storybord.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {return}
        let item = newsItems[indexPath.row]
        vc.newsImage = item.urlToImage ?? ""
        vc.titleString = item.title
        vc.webUrlString = item.url
        vc.contentString = item.description ?? ""
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
