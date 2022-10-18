import UIKit
import Combine

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
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        return refreshControl
    }()
    
    private let viewModel = ViewModel()
    private var cancellables = Set<AnyCancellable>()
    private let selectedSegmentedIndex = PassthroughSubject<Int, Never>()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindInputs(); bindOutputs()
        Task { await viewModel.fetch() }
    }

    private func bindInputs() {
        selectedSegmentedIndex
            .map { $0 == 0 ? .alphabetical : .changePercent }
            .assign(to: &viewModel.$selectedSortType)
    }

    private func bindOutputs() {
        viewModel.$isLoading
            .dropFirst()
            .sink { [weak self] isLoading in
                self?.view.isUserInteractionEnabled = !isLoading
                if !isLoading {
                    self?.refreshControl.endRefreshing()
                    self?.activityIndicator?.removeFromSuperview()
                }
            }
            .store(in: &cancellables)
            
        viewModel.$stocks
            .sink(receiveValue: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .store(in: &cancellables)
        
        viewModel.$showingAlert
            .sink { [weak self] (isShowing, errorDescription) in
                guard isShowing else { return }
                let alert = UIAlertController(title: errorDescription,
                                              message: nil,
                                              preferredStyle: .alert)
                alert.addAction(.init(title: "Close", style: .cancel, handler: nil))
                self?.present(alert, animated: true)
            }
            .store(in: &cancellables)
    }
    
    @IBAction private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        selectedSegmentedIndex.send(sender.selectedSegmentIndex)
    }
    
    @objc private func refresh(sender: UISegmentedControl) {
        Task { await viewModel.fetch() }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.stocks.stocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StockTableViewCell", for: indexPath) as? StockTableViewCell
        else { return .init() }
        cell.configure(stock: viewModel.stocks.stocks[indexPath.row])
        return cell
     }
}
