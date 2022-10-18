import Foundation

final class APIClient {
    private let apiKey = APIKey.key
    static let shared = APIClient()
    
    private init(){}

    func fetchStockData(symbols: [String]) async throws -> [Stock] {
        let query = symbols.joined(separator: ",")
        let url = URL(string: "https://financialmodelingprep.com/api/v3/profile/\(query)?apikey=\(apiKey)")
        let (data, _) = try await URLSession.shared.data(from: url!)
        let stockDTOs = try JSONDecoder().decode([StockDTO].self, from: data)
        let logos = try await fetchLogos(stockDTOs: stockDTOs)
        return stockDTOs.map { Stock(stockDTO: $0,
                                     logoData: logos[$0.symbol]) }
    }
    
    private func fetchLogos(stockDTOs: [StockDTO]) async throws -> [String: Data] {
        try await withThrowingTaskGroup(of: (String, Data).self) { group in
            for stockDTO in stockDTOs {
                group.addTask {
                    let url = URL(string: stockDTO.image)
                    let (data, _) = try await URLSession.shared.data(from: url!)
                    return (stockDTO.symbol, data)
                }
            }
            var logos = [String: Data]()
            for try await (symbol, data) in group {
                logos[symbol] = data
            }
            return logos
        }
    }
}
