import Foundation

struct Stock: Identifiable, Equatable {
    var id: String { symbol }
    let symbol: String
    let companyName: String
    let price: Double
    let changePercent: Double
    let logoData: Data?
}
