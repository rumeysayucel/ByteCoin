//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Rumeysa Yücel on 7.07.2021.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdatePrice(price: String, currency: String)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "C2CBB1F7-6552-4D0A-AD01-49D9D0348445"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    func getCoinPrice(for currency: String) {
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    let bitcoinPrice = self.parseJSON(safeData)
                    let priceString = String(format: "%.2f", bitcoinPrice as! CVarArg)
                    self.delegate?.didUpdatePrice(price: priceString, currency: currency)
                }
            }
            task.resume()
        }
    }
    
  
    
    func parseJSON(_ coinData : Data) -> Double? {
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(CoinData.self, from: coinData)
            let lastPrice = decodedData.rate
            return lastPrice
        }catch{
            self.delegate?.didFailWithError(error: error)
            return nil
        }
        
    }
    
}
