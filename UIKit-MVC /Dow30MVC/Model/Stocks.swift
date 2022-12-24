import Foundation

struct Stocks {
    private var value: [Stock]

    init(stocks: [Stock]) { value = stocks }
    subscript(index: Int) -> Stock { value[index] }
    
    var count: Int { value.count }
            
    mutating func sort(by sortType: SortType) {
        switch sortType {
        case .alphabetical: value.sort { $0.symbol < $1.symbol }
        case .changePercent: value.sort { $1.changePercent < $0.changePercent }
        }
    }
}
