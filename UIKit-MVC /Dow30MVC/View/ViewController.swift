import UIKit

final class ViewController: UIViewController {
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            let cell = UINib(nibName: "StockTableViewCell", bundle: nil)
            tableView.register(cell, forCellReuseIdentifier: "StockTableViewCell")
            tableView.refreshControl = refreshControl
        }
    }
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    
    private var stocks = Stocks(stocks: [])
    private var selectedSortType: SortType = .alphabetical
    private var isLoading = false {
        didSet {
            view.isUserInteractionEnabled = !isLoading
            if !isLoading {
                activityIndicator?.removeFromSuperview()
                refreshControl.endRefreshing()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetch()
    }

    @objc private func refresh() {
        fetch()
    }
    
    @IBAction private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        selectedSortType = sender.selectedSegmentIndex == 0 ? .alphabetical : .changePercent
        stocks.sort(by: selectedSortType)
        tableView.reloadData()
    }
    
    private func fetch() {
        Task {
            isLoading = true
            do {
                let stocks = try await APIClient.shared.fetchStockData(symbols: ["AAPL", "MSFT", "DIS", "KO", "MCD", "NKE", "V", "JNJ", "AXP", "AMGN", "BA", "CAT", "CSCO", "CVX", "GS", "HD", "HON", "IBM", "INTC", "JPM", "MMM", "MRK", "PG", "TRV", "UNH", "CRM", "VZ", "WBA", "WMT", "DOW"])
                self.stocks = Stocks(stocks: stocks)
                self.stocks.sort(by: selectedSortType)
                tableView.reloadData()
            } catch {
                print("Error: ", error)
                let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
                alert.addAction(.init(title: "Close", style: .cancel, handler: nil))
                present(alert, animated: true)
            }
            isLoading = false
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        stocks.stocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StockTableViewCell", for: indexPath) as? StockTableViewCell
        else { return .init() }
        cell.configure(stock: stocks.stocks[indexPath.row])
        return cell
     }
}
