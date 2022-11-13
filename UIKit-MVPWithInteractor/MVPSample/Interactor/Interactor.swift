import Foundation

protocol InteractorOutput: AnyObject {
    func didFetch(result: Result<[Stock], Error>)
}

final class Interactor {
    weak var presenter: InteractorOutput!
    
    init(presenter: InteractorOutput) {
        self.presenter = presenter
    }
    
    func fetch() {
        Task {
            do {
                let stocks = try await APIClient.shared.fetchStockData(symbols: ["AAPL", "MSFT", "DIS", "KO", "MCD", "NKE", "V", "JNJ", "AXP", "AMGN", "BA", "CAT", "CSCO", "CVX", "GS", "HD", "HON", "IBM", "INTC", "JPM", "MMM", "MRK", "PG", "TRV", "UNH", "CRM", "VZ", "WBA", "WMT", "DOW"])
                presenter.didFetch(result: .success(stocks))
            } catch {
                print("Error: ", error)
                presenter.didFetch(result: .failure(error))
            }
        }
    }
}
