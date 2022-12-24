import Foundation

struct Stocks {
    private(set) var value: [Stock]

    init(stocks: [Stock]) { value = stocks }
    
    var count: Int { value.count }
            
    mutating func sort(by sortType: SortType) {
        switch sortType {
        case .alphabetical: value.sort { $0.symbol < $1.symbol }
        case .changePercent: value.sort { $1.changePercent < $0.changePercent }
        }
    }
}
