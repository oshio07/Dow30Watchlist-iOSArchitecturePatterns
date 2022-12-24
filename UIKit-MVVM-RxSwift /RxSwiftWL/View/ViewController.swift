import UIKit
import RxSwift
import RxCocoa

final class ViewController: UIViewController {
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var segmentedControl: UISegmentedControl! {
        didSet {
            segmentedControl.rx.selectedSegmentIndex
                .map { $0 == 0 ? .alphabetical : .changePercent }
                .bind(to: viewModel.inputs.selectedSortType)
                .disposed(by: disposeBag)
        }
    }
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            let cell = UINib(nibName: "StockTableViewCell", bundle: nil)
            tableView.register(cell, forCellReuseIdentifier: "StockTableViewCell")
            tableView.refreshControl = refreshControl
        }
    }
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                Task { await self?.viewModel.inputs.fetch() }
            })
            .disposed(by: disposeBag)
        return refreshControl
    }()
    
    private let viewModel = StocksViewModel()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        Task { await viewModel.inputs.fetch() }
    }
    
    private func bind() {
        viewModel.outputs.updatedStocksObservable
            .observe(on: MainScheduler.instance)
            .map { $0.value }
            .bind(to: tableView.rx.items) { (tableView, _, stock) in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "StockTableViewCell") as? StockTableViewCell else { return .init() }
                cell.configure(stock: stock)
                return cell
            }
            .disposed(by: disposeBag)
        
        viewModel.outputs.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                self?.view.isUserInteractionEnabled = !isLoading
                if !isLoading {
                    self?.refreshControl.endRefreshing()
                    self?.activityIndicator?.removeFromSuperview()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.fetchFailed
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] errorMessage in
                let alert = UIAlertController(title: errorMessage, message: nil, preferredStyle: .alert)
                alert.addAction(.init(title: "Close", style: .cancel, handler: nil))
                self?.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
