import Foundation

struct Stock {
    let symbol: String
    let companyName: String
    let price: Double
    let changePercent: Double
    let logoData: Data?

    init(stockDTO: StockDTO, logoData: Data?) {
        self.symbol = stockDTO.symbol
        self.companyName = stockDTO.companyName
        self.price = stockDTO.price
        self.changePercent = stockDTO.changes / (stockDTO.price - stockDTO.changes) * 100
        self.logoData = logoData
    }
}

struct StockDTO: Decodable {
    let symbol: String
    let price: Double
    let changes: Double
    let companyName: String
    let image: URL
}
