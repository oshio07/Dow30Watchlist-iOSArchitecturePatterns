import Foundation
import Combine

@MainActor
final class ViewModel: ObservableObject {
    @Published private(set) var stocks = Stocks(stocks: .init())
    @Published private(set) var isLoading = false
    @Published var showingAlert = (isShowing: false, errorDescription: "")
    @Published var selectedSortType: SortType = .alphabetical
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $selectedSortType
            .sink { [weak self] sortType in
                self?.stocks.sort(by: sortType)
            }
            .store(in: &cancellables)
    }
    
    func fetch() async {
        isLoading = true; defer { isLoading = false }
        
        do {
            let stocks = try await APIClient.shared.fetchStockData(symbols: ["AAPL", "MSFT", "DIS", "KO", "MCD", "NKE", "V", "JNJ", "AXP", "AMGN", "BA", "CAT", "CSCO", "CVX", "GS", "HD", "HON", "IBM", "INTC", "JPM", "MMM", "MRK", "PG", "TRV", "UNH", "CRM", "VZ", "WBA", "WMT", "DOW"])
            self.stocks = Stocks(stocks: stocks)
            self.stocks.sort(by: selectedSortType)
        } catch {
            print("Error: ", error)
            showingAlert = (true, error.localizedDescription)
        }
    }
    
}
