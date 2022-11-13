import Foundation

enum SortType: Hashable, CaseIterable {
    case alphabetical, changePercent
    
    var sortTypeStr: String {
        switch self {
        case .alphabetical: return "Alphabetical"
        case .changePercent: return "Percentage Change"
        }
    }
}
