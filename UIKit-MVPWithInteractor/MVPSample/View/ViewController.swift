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
    private let refreshControl = UIRefreshControl()
    
    private var presenter: Presenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = Presenter(view: self)
        setUp()
        presenter.viewDidLoad()
    }
    
    private func setUp() {
        refreshControl.addTarget(presenter, action: #selector(presenter.refresh), for: .valueChanged)
    }
    
    @IBAction private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        presenter.segmentedControlValueChanged(selectedSegmentIndex: sender.selectedSegmentIndex)
    }
}

extension ViewController: PresenterOutput {
    func reloadData() {
        tableView.reloadData()
    }
    
    func stopIndicator() {
        activityIndicator?.removeFromSuperview()
        refreshControl.endRefreshing()
    }
    
    func toggleUserInteractionEnabled(viewIsLoading: Bool) {
        view.isUserInteractionEnabled = !viewIsLoading
    }
    
    func showAlert(title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(.init(title: "Close", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.stocks.stocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StockTableViewCell", for: indexPath) as? StockTableViewCell
        else { return .init() }
        cell.configure(stock: presenter.stocks.stocks[indexPath.row])
        return cell
     }
}
