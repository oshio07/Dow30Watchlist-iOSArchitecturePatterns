import Foundation
import RxSwift
import RxRelay

protocol ViewModelType: AnyObject {
    var inputs: ViewModelInputs { get }
    var outputs: ViewModelOutputs { get }
}

protocol ViewModelInputs: AnyObject {
    var selectedSortType: AnyObserver<SortType> { get }
    func fetch() async
}

protocol ViewModelOutputs: AnyObject {
    var updatedStocksObservable: Observable<Stocks> { get }
    var isLoading: Observable<Bool> { get }
    var fetchFailed: Observable<String> { get }
}

final class StocksViewModel: ViewModelType, ViewModelInputs, ViewModelOutputs {
    var inputs: ViewModelInputs { return self }
    var outputs: ViewModelOutputs { return self }
    
    private let _stocks = PublishRelay<Stocks>()
    
    private let _updatedStocksObservable = PublishRelay<Stocks>()
    lazy var updatedStocksObservable = _updatedStocksObservable.asObservable()
    
    private let _isLoading = PublishRelay<Bool>()
    var isLoading: Observable<Bool> { _isLoading.asObservable() }
    
    private let _fetchFailed = PublishRelay<String>()
    var fetchFailed: Observable<String> { _fetchFailed.asObservable() }
        
    private let _selectedSortType = BehaviorRelay<SortType>(value: .alphabetical)
    var selectedSortType: AnyObserver<SortType> {
        .init(eventHandler: { [weak self] event in
            if let sortType = event.element {
                self?._selectedSortType.accept(sortType)
            } })
    }
    
    private let disposeBag = DisposeBag()
    
    init() {
        Observable
            .combineLatest(_selectedSortType, _stocks) { sortType, stocks in
                var stocks = stocks
                stocks.sort(by: sortType); return stocks
            }
            .bind(to: _updatedStocksObservable)
            .disposed(by: disposeBag)
    }
    
    func fetch() async {
        _isLoading.accept(true); defer { _isLoading.accept(false) }
        
        do {
            let stocks = try await APIClient.shared.fetchStockData(symbols: ["AAPL", "MSFT", "DIS", "KO", "MCD", "NKE", "V", "JNJ", "AXP", "AMGN", "BA", "CAT", "CSCO", "CVX", "GS", "HD", "HON", "IBM", "INTC", "JPM", "MMM", "MRK", "PG", "TRV", "UNH", "CRM", "VZ", "WBA", "WMT", "DOW"])
            _stocks.accept(Stocks(stocks: stocks))
        } catch {
            print("error: ", error)
            _fetchFailed.accept(error.localizedDescription)
            if case APIClientError.responseError(let code) = error,
               let code {
                _fetchFailed.accept(String(code) + "/n" + error.localizedDescription)
            } else {
                _fetchFailed.accept(error.localizedDescription)
            }
        }
    }
}
