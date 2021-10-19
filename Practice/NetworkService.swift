//
//  NetworkService.swift
//  Practice
//
//  Created by Grigory Khaykin on 19.10.2021.
//

import Foundation

protocol NetworkServiceProtocol {
    func sendRequest(company: String)
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ())
}

final class NetworkService: NetworkServiceProtocol {
    
    private let decoder = JSONDecoder()
    private let token = "pk_404354cd570b4d2eb7f7aa12e2f525fe"
    private let baseURL = "https://cloud.iexapis.com/stable/stock/"
    var vc: ViewInputProtocol
    
    init(vc: ViewInputProtocol) {
        self.vc = vc
    }
    
    func sendRequest(company: String) {
        vc.resetView()
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 15
        let dataTask = URLSession(configuration: configuration).dataTask(with: requestURL(company: company)) { [weak self] data, response, error in
            if let _ = error {
                DispatchQueue.main.async {
                    self?.vc.showAlert()
                }
                return
            }
            print(data!)
            self?.parseQuote(data: data!)
        }
        dataTask.resume()
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    private func requestURL(company: String) -> URL {
        let urlString = "\(baseURL)\(company)/quote?&token=\(token)"
        guard let url = URL(string: urlString) else {
            fatalError()
        }
        return url
    }
    
    private func logoURL(company: String) -> URL{
        let urlString = "https://storage.googleapis.com/iex/api/logos/\(company).png"
        guard let url = URL(string: urlString) else {
            fatalError()
        }
        return url
    }
    
    private func parseQuote (data: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            
            guard
                let json = jsonObject as? [String: Any],
                let symbol = json["symbol"] as? String,
                let companyName = json["companyName"] as? String,
                let change = json["change"] as? Double,
                let latestPrice = json["latestPrice"] as? Double
                
            else {
                DispatchQueue.main.async {
                    self.vc.showAlert()
                }
                print("❗️invalid JSON format")
                return
            }
            DispatchQueue.main.async {
                self.vc.updateDisplayData(company: companyName,
                                     symbol: symbol,
                                     price: latestPrice,
                                     priceChange: change,
                                     logoURL: self.logoURL(company: symbol))
            }
        } catch {
            DispatchQueue.main.async {
                self.vc.showAlert()
            }
            print("! JSON parsing error:" + error.localizedDescription)
        }
    }
}
