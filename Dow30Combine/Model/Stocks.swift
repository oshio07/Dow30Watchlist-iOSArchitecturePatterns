import Foundation

struct Stocks {
    private(set) var stocks: [Stock]

    init(stocks: [Stock]) { self.stocks = stocks }
            
    mutating func sort(by sortType: SortType) {
        switch sortType {
        case .alphabetical: stocks.sort { $0.symbol < $1.symbol }
        case .changePercent: stocks.sort { $1.changePercent < $0.changePercent }
        }
    }
}

enum SortType { case alphabetical, changePercent }
