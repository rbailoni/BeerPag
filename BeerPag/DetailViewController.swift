//
//  DetailViewController.swift
//  BeerPag
//
//  Created by Ricardo do Espirito Santo Bailoni on 30/05/17.
//  Copyright © 2017 Ricardo Bailoni. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var beer: Beer?
    var task: URLSessionDataTask?
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblTagline: UILabel!
    @IBOutlet weak var lblTeorAlcoolico: UILabel!
    @IBOutlet weak var lblAmargor: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imgBeer: UIImageView!
    @IBOutlet weak var loadImgBeer: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblDescription.text = beer?.description
        lblName.text = beer?.name
        lblTagline.text = beer?.tagline
        if let teorAlcoolico = beer?.abv{
            lblTeorAlcoolico.text = "Teor Alcoolico\n\(teorAlcoolico)"
        }else{
            lblTeorAlcoolico.text = "Teor Alcoolico\n-"
        }
        if let amargor = beer?.ibu{
            lblAmargor.text = "Escala de Amargor\n\(amargor)"
        }else{
            lblAmargor.text = "Escala de Amargor\n-"
        }
        
        loadImgBeer.startAnimating()
        if fileExists(urlImage: (beer?.imageURL)!) {
            loadImgBeer.stopAnimating()
            imgBeer.image = loadSaveImage(urlImage: (beer?.imageURL)!)
        }else{
            let url = URL(string: (beer?.imageURL!)!)
            task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
                guard let data = data else {return}
                guard let image = UIImage(data: data) else {return}
                DispatchQueue.main.async {() -> Void in
                    savePNGImage(image: image, urlImage: (self.beer?.imageURL!)!)
                    self.loadImgBeer.stopAnimating()
                    self.imgBeer.image = image
                }
            }
            task?.resume()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        task?.cancel()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
