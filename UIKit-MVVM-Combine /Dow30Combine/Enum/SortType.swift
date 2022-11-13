import Foundation

enum SortType {
    case alphabetical, changePercent
    
    var sortTypeStr: String {
        switch self {
        case .alphabetical: return "Alphabetical"
        case .changePercent: return "Percentage Change"
        }
    }
}
