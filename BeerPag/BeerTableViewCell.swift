//
//  BeerTableViewCell.swift
//  BeerPag
//
//  Created by Ricardo do Espirito Santo Bailoni on 29/05/17.
//  Copyright © 2017 Ricardo Bailoni. All rights reserved.
//

import UIKit

class BeerTableViewCell: UITableViewCell {
    
    var beer: Beer! {
        didSet{
            lblName.text = beer.name
            lblABV.text = "\(beer.abv!)º"
        }
    }
    
    var task: URLSessionDataTask?

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblABV: UILabel!
    @IBOutlet weak var imgBeer: UIImageView!
    @IBOutlet weak var loadingBeer: UIActivityIndicatorView!
    @IBOutlet weak var loadImgBeer: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
