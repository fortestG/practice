//
//  ViewController.swift
//  Practice
//
//  Created by Grigory Khaykin on 19.10.2021.
//

import UIKit

protocol ViewInputProtocol {
    
    func updateDisplayData(company: String,
                           symbol: String,
                           price: Double,
                           priceChange: Double,
                           logoURL: URL)
    func resetView()
    func showAlert()
}

class ViewController: UIViewController {
    
    private var networkService: NetworkServiceProtocol?
    
    @IBOutlet weak var companyPickerView: UIPickerView!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var priceChange: UILabel!
    @IBOutlet weak var companyLogo: UIImageView!
    
    private let companies: [String: String] = ["Apple": "AAPL", "Microsoft": "MCRSFT", "Google": "GOOG", "Amazon": "AMZN", "Facebook": "FB"]
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        networkService = NetworkService(vc: self)
        self.companyPickerView.dataSource = self
        self.companyPickerView.delegate = self
        self.activityIndicator.hidesWhenStopped = true
        requestQuoteUpdate()
    }
    
    private func requestQuoteUpdate() {
        
        self.activityIndicator.startAnimating()
        self.companyNameLabel.text = "-"
        let selectedRow = self.companyPickerView.selectedRow(inComponent: 0)
        let selectedSymbol = Array(self.companies.values)[selectedRow]
        self.networkService?.sendRequest(company: selectedSymbol)
    }
    
    private func downloadImage(from url: URL) {
        
        networkService!.getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.companyLogo.image = UIImage(data: data)
            }
        }
    }
}

extension ViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return self.companies.keys.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return Array(self.companies.keys)[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.activityIndicator.startAnimating()
        let selectedSymbol = Array(self.companies.values)[row]
        self.networkService!.sendRequest(company: selectedSymbol)
    }
}

extension ViewController: UIPickerViewDelegate {
    
}


extension ViewController: ViewInputProtocol {
    
    func updateDisplayData(company: String,
                           symbol: String,
                           price: Double,
                           priceChange: Double,
                           logoURL: URL) {
        activityIndicator.stopAnimating()
        self.companyNameLabel.text = company
        self.symbol.text = symbol
        self.price.text = "\(price)"
        self.priceChange.text = "\(priceChange)"
        if priceChange > 0 {
            self.priceChange.textColor = .green
        } else if priceChange < 0 {
            self.priceChange.textColor = .red
        } else if priceChange == 0 {
            self.priceChange.textColor = .black
        }
        
        downloadImage(from: logoURL)
    }
    
    func resetView() {
        
        self.companyNameLabel.text = "_"
        self.symbol.text = "_"
        self.price.text = "_"
        self.priceChange.text = "_"
        self.priceChange.textColor = .black
    }
    
    func showAlert() {
        
        let alertVC = UIAlertController(
            title: "Error",
            message: "Something went wrong",
            preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
    }
}

