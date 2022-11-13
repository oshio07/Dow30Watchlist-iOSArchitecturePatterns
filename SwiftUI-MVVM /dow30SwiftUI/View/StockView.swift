import SwiftUI

struct StockView: View {
    var stock: Stock
    
    var body: some View {
        HStack {
            logoView(size: 40)
            stockDataView
        }
        .background(Color(.systemBackground))
    }
    
    private func logoView(size: CGFloat) -> some View {
        { () -> Image in
            if let logoData = stock.logoData,
               let logo = UIImage(data: logoData) {
                return .init(uiImage: logo)
            } else {
                return .init(systemName: "swift")
            }
        }()
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .cornerRadius(size * 0.3)
            .background(Color.white)
    }
    
    private var stockDataView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(stock.symbol)
                    .font(.system(size: 20, weight: .black, design: .default))
                Text(stock.companyName)
                    .lineLimit(1)
                    .foregroundColor(Color.gray)
                    .font(.system(size: 13))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 3) {
                Text("\(stock.price, specifier: "%.2f")")
                    .font(.system(size: 15, weight: .black, design: .default))
                Text("\(stock.changePercent, specifier: "%.2f")%")
                    .font(.system(size: 13, weight: .bold, design: .default))
                    .foregroundColor(stock.changePercent < 0 ? .red : .green)
            }
        }
    }
}

struct StockView_Previews: PreviewProvider {
    static var previews: some View {
        StockView(stock: Stock(symbol: "AAPL",
                               companyName: "Apple Inc.",
                               price: 123.45,
                               changePercent: 1.23,
                               logoData: try! Data(contentsOf: URL(string: "https://financialmodelingprep.com/image-stock/AAPL.png")!)))
    }
}
