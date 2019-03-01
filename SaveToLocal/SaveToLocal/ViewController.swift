//
//  ViewController.swift
//  SaveToLocal
//
//  Created by Varun Jandhyala on 2/9/19.
//  Copyright © 2019 varun. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var attributionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadWebView()
        parseJSON()
        downloadImage()
        setupAttribution()
    }
    
    func setupAttribution() {
        attributionLabel.isUserInteractionEnabled = true
        
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(ViewController.attributionLabelPressed))
        attributionLabel.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func attributionLabelPressed() {
        UIApplication.shared.open(URL(string: "https://www.unsplash.com")!, options: [:], completionHandler: { completed in
        })
    }

    func urlRequest(_ path: String) -> URLRequest {
        let url = URL.init(string: path)
        let request = URLRequest.init(url: url!)
        return request
    }
    
    func loadWebView() {
        let request = urlRequest("http://numbersapi.com/1..10/math?json")
        webView.uiDelegate = self
        webView.load(request)
    }

    func downloadImage() {
        let request = urlRequest("https://source.unsplash.com/random")

        _ = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            guard error == nil else {
                print("OH NO AN ERROR \(String(describing: error))")
                return
            }
            
            if let d = data {
                if let image = UIImage.init(data: d) {
                    self.saveImage(image)
                    self.showImage(image)
                }
            }
        }).resume()
    }
    
    func saveImage(_ image: UIImage) {
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        do {
            let imagePath = documentsDirectoryURL.appendingPathComponent("testimg.png")
            if let imageData = image.pngData() {
                try imageData.write(to: imagePath, options: .atomic)
            }
        } catch { print("BLAH!!!! An error \(error)") }
    }
    
    func showImage(_ image: UIImage) {
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let filePath = documentsDirectoryURL.appendingPathComponent("testimg.png").path
        
        
        if FileManager.default.fileExists(atPath: filePath) {
            DispatchQueue.main.async {
                self.imageView.image = UIImage(contentsOfFile: filePath)
            }
        }
    }
    
    func parseJSON() {
        let request = urlRequest("http://numbersapi.com/1..10/math?json")
        _ = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            guard error == nil else { return }
            do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    self.saveJSON(json)
                } catch { print(error) }
            }).resume()
    }
    
    func saveJSON(_ json: Any) {
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        print("DOCUMENTS DIRECTORY URL: \(documentsDirectoryURL)")
        let fileURL = documentsDirectoryURL.appendingPathComponent("math.json")
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            try data.write(to: fileURL, options: [])
        } catch {
            print("This is the error: \(error)")
        }
    }
}

