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
    
    private var interactor: Interactor!
    private weak var view: PresenterOutput!
    
    init(view: PresenterOutput) {
        self.view = view
        self.interactor = Interactor(presenter: self)
    }
    
    func viewDidLoad() {
        isLoading = true
        interactor.fetch()
    }
    
    @objc func refresh() {
        isLoading = true
        interactor.fetch()
    }
    
    func segmentedControlValueChanged(selectedSegmentIndex: Int) {
        selectedSortType = selectedSegmentIndex == 0 ? .alphabetical : .changePercent
        stocks.sort(by: selectedSortType)
        view?.reloadData()
    }
}

extension Presenter: InteractorOutput {
    func didFetch(result: Result<[Stock], Error>) {
        Task { @MainActor in
            switch result {
            case .success(let stocks):
                self.stocks = Stocks(stocks: stocks)
                view?.reloadData()
            case .failure(let error):
                if case APIClientError.responseError(let code) = error,
                   let code {
                    view?.showAlert(title: String(code) + "/n" + error.localizedDescription)
                } else {
                    view?.showAlert(title: error.localizedDescription)
                }
            }
            isLoading = false
        }
    }
}
