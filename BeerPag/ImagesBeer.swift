//
//  ImagesBeer.swift
//  BeerPag
//
//  Created by Ricardo do Espirito Santo Bailoni on 30/05/17.
//  Copyright © 2017 Ricardo Bailoni. All rights reserved.
//

import UIKit

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentDirectory = paths[0]
    print(documentDirectory)
    return documentDirectory
}

func savePNGImage(image: UIImage, urlImage: String){
    let nameImage = getNameImageBeer(urlImage: urlImage)
    if let data = UIImagePNGRepresentation(image){
        let fileName = getDocumentsDirectory().appendingPathComponent(nameImage)
        try? data.write(to: fileName)
    }
}

func getNameImageBeer(urlImage: String) -> String{
    let arrayURL = urlImage.components(separatedBy: "/")
    let name = arrayURL.last
    return name!
}

func fileExists(urlImage: String) -> Bool{
    let nameImage = getNameImageBeer(urlImage: urlImage)
    let fileNamePath = getDocumentsDirectory().appendingPathComponent(nameImage).path
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: fileNamePath){
        return true
    }
    return false
}

func loadSaveImage(urlImage: String) -> UIImage?{
    let nameImage = getNameImageBeer(urlImage: urlImage)
    let fileNamePath = getDocumentsDirectory().appendingPathComponent(nameImage).path
    let image = UIImage(contentsOfFile: fileNamePath)
    return image
}
