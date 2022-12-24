import UIKit

final class StockTableViewCell: UITableViewCell {
    @IBOutlet private weak var symbolLabel: UILabel!
    @IBOutlet private weak var companyNameLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var changePercentLabel: UILabel!
    @IBOutlet private weak var logoImage: UIImageView!
    
    func configure(stock: Stock) {
        symbolLabel.text = stock.symbol
        companyNameLabel.text = stock.companyName
        priceLabel.text = String(format: "%.2f", stock.price)
        changePercentLabel.text = String(format: "%.2f", stock.changePercent) + "%"
        changePercentLabel.textColor = stock.changePercent >= 0 ? #colorLiteral(red: 0.2, green: 0.78, blue: 0.35, alpha: 1.0) : #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        logoImage.layer.cornerRadius = logoImage.frame.width * 0.3
        if let logo = stock.logoData {
            logoImage.image = UIImage(data: logo)
        } else {
            logoImage.image = UIImage(systemName: "swift")
        }
    }
}
