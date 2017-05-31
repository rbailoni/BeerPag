//
//  ViewController.swift
//  BeerPag
//
//  Created by Ricardo do Espirito Santo Bailoni on 29/05/17.
//  Copyright © 2017 Ricardo Bailoni. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableViewBeers: UITableView!
    
    var page = 1
    var arrayBeers = [Beer]()
    var load = true

    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewBeers.delegate = self;
        tableViewBeers.dataSource = self;
        
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(loadRefresh), for: .valueChanged)
        tableViewBeers.refreshControl = refresh
    }
    
    func loadRefresh() {
        page = 1
        arrayBeers = [Beer]()
        load = true
        loadBeers(page: page)
    }

    func loadBeers(page: Int) {
        Alamofire.request("https://api.punkapi.com/v2/beers?page=\(page)").responseJSON { response in
            if case let .failure(error) = response.result{
                let alerta = UIAlertController(title: "Erro", message: error.localizedDescription, preferredStyle: .alert)
                let actionOk = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alerta.addAction(actionOk)
                self.present(alerta, animated: true, completion: nil)
                self.tableViewBeers.refreshControl?.endRefreshing()
                return
            }
            if case let .success(value) = response.result{
                let json = JSON(value)
                if response.response?.statusCode != 200{
                    let alerta = UIAlertController(title: "Erro", message: json["message"].string, preferredStyle: .alert)
                    let actionOk = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alerta.addAction(actionOk)
                    self.present(alerta, animated: true, completion: nil)
                    self.tableViewBeers.refreshControl?.endRefreshing()
                    return
                }else{
                    var finishBeers = true
                    for (_,beerJSON) in json{
                        if beerJSON["name"].exists(){
                            finishBeers = false
                            let newBeer = Beer()
                            newBeer.name = beerJSON["name"].string
                            newBeer.imageURL = beerJSON["image_url"].string
                            newBeer.abv = beerJSON["abv"].float
                            newBeer.ibu = beerJSON["ibu"].float
                            newBeer.tagline = beerJSON["tagline"].string
                            newBeer.description = beerJSON["description"].string
                            self.arrayBeers.append(newBeer)
                        }
                    }
                    if finishBeers{
                        self.load = false
                    }
                    self.tableViewBeers.refreshControl?.endRefreshing()
                    self.tableViewBeers.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if load {
            return arrayBeers.count + 1
        }else{
            return arrayBeers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < arrayBeers.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellBeer", for: indexPath) as! BeerTableViewCell
            cell.beer = arrayBeers[indexPath.row]
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellBeerLoading", for: indexPath) as! BeerTableViewCell
            cell.loadingBeer.startAnimating()
            cell.tag = 1000
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.tag == 1000{
            page += 1
            loadBeers(page: page)
        }else{
            let cellBeer = cell as! BeerTableViewCell
            
            cellBeer.imgBeer.image = nil
            cellBeer.loadImgBeer.startAnimating()
            if fileExists(urlImage: cellBeer.beer.imageURL!) {
                cellBeer.loadImgBeer.stopAnimating()
                cellBeer.imgBeer.image = loadSaveImage(urlImage: cellBeer.beer.imageURL!)
            }else{
                let url = URL(string: cellBeer.beer.imageURL!)
                cellBeer.task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
                    guard let data = data else {return}
                    guard let image = UIImage(data: data) else {return}
                    DispatchQueue.main.async {() -> Void in
                        guard let updateCell = tableView.cellForRow(at: indexPath) as? BeerTableViewCell else {return}
                        savePNGImage(image: image, urlImage: cellBeer.beer.imageURL!)
                        updateCell.loadImgBeer.stopAnimating()
                        updateCell.imgBeer.image = image
                    }
                }
                cellBeer.task?.resume()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.tag != 1000 {
            let cellBeer = cell as! BeerTableViewCell
            cellBeer.task?.cancel()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if arrayBeers.count > 0 {
            tableViewBeers.separatorStyle = .singleLine
            return 1
        }else {
            let lblMessage = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
            lblMessage.text = "Deslize a tela para baixo para carregar as informações"
            lblMessage.textAlignment = .center
            lblMessage.numberOfLines = 0
            lblMessage.sizeToFit()
            
            tableViewBeers.backgroundView = lblMessage
            tableViewBeers.separatorStyle = .none
        }
        return 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue",
            let destination = segue.destination as? DetailViewController,
            let indexPath = self.tableViewBeers.indexPathForSelectedRow {
            let beer = arrayBeers[indexPath.row]
            destination.beer = beer
        }
    }
}

