import Foundation

protocol PresenterOutput: AnyObject {
    func reloadData()
    func stopIndicator()
    func showAlert(title: String)
    func toggleUserInteractionEnabled(viewIsLoading: Bool)
}

final class Presenter {
    private(set) var stocks = Stocks(stocks: []) {
        didSet {
            stocks.sort(by: selectedSortType)
        }
    }
    private var selectedSortType: SortType = .alphabetical
    private var isLoading = false {
        didSet {
            view?.toggleUserInteractionEnabled(viewIsLoading: isLoading)
            if !isLoading { view?.stopIndicator() }
        }
    }
    
    private weak var view: PresenterOutput!
    
    init(view: PresenterOutput) {
        self.view = view
    }
    
    func viewDidLoad() {
        fetch()
    }
    
    @objc func refresh() {
        fetch()
    }
    
    func segmentedControlValueChanged(selectedSegmentIndex: Int) {
        selectedSortType = selectedSegmentIndex == 0 ? .alphabetical : .changePercent
        stocks.sort(by: selectedSortType)
        view?.reloadData()
    }
    
    private func fetch() {
        Task { @MainActor in
            isLoading = true; defer { isLoading = false }
            do {
                let stocks = try await APIClient.shared.fetchStockData(symbols: ["AAPL", "MSFT", "DIS", "KO", "MCD", "NKE", "V", "JNJ", "AXP", "AMGN", "BA", "CAT", "CSCO", "CVX", "GS", "HD", "HON", "IBM", "INTC", "JPM", "MMM", "MRK", "PG", "TRV", "UNH", "CRM", "VZ", "WBA", "WMT", "DOW"])
                self.stocks = Stocks(stocks: stocks)
                view?.reloadData()
            } catch {
                print("Error: ", error)
                if case APIClientError.responseError(let code) = error,
                   let code {
                    view?.showAlert(title: String(code) + "/n" + error.localizedDescription)
                } else {
                    view?.showAlert(title: error.localizedDescription)
                }
            }
        }
    }
}
