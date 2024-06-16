//
//  ExchangeRateManager.swift
//  STP
//
//  Created by Eric Wong on 6/6/2024.
//

import Foundation

class ExchangeRateManager: ObservableObject {
    @Published var exchangeRates: [String: Double] = [:]
    private let apiKey = "ef6e641447520a774eeccafe" // Replace with your actual API key

    func fetchExchangeRates(baseCurrency: String = "HKD") {
        guard let url = URL(string: "https://v6.exchangerate-api.com/v6/\(apiKey)/latest/\(baseCurrency)") else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let rates = json["conversion_rates"] as? [String: Double] {
                    DispatchQueue.main.async {
                        self.exchangeRates = rates
                    }
                }
            } catch {
                print("Failed to parse JSON: \(error)")
            }
        }.resume()
    }
}
