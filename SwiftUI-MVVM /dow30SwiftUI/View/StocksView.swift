import SwiftUI

struct StocksView: View {
    @StateObject var viewModel = ViewModel()
    @State private var isInitialLoading = false
    
    init() {
        UITableView.appearance().backgroundColor = .red
        UISegmentedControl.appearance().backgroundColor = .systemGray4
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                stockList
                    .refreshable { Task { await viewModel.fetch() } }
                
                VStack {
                    Spacer()
                    
                    sortTypePicker
                        .padding([.leading, .trailing], 30)
                }
                
                if isInitialLoading { progressViewForInitialLoading }
            }
            .navigationTitle(.init("Dow30 Watchlist"))
        }
        .onAppear {
            Task {
                isInitialLoading = true 
                await viewModel.fetch()
                isInitialLoading = false
            }
        }
        .alert(isPresented: $viewModel.showingAlert.isShowing) {
            Alert(title: Text(viewModel.showingAlert.errorDescription),
                  message: nil,
                  dismissButton: .default(Text("Close")))
        }
    }
    
    private var stockList: some View {
        List(viewModel.stocks.value) { stock in
            StockView(stock: stock)
        }
        .listRowBackground(Color(.systemBackground))
        .listRowSeparatorTint(Color.gray)
        .scrollContentBackground(.hidden)
        .background(Color.white)
    }
    
    private var sortTypePicker: some View {
        Picker("", selection: $viewModel.selectedSortType) {
            ForEach(SortType.allCases, id: \.self) { sortType in
                Text(sortType.sortTypeStr)
                    .tag(sortType)
            }
        }
        .allowsHitTesting(!viewModel.isLoading)
        .pickerStyle(.segmented)
    }
    
    private var progressViewForInitialLoading: some View {
        ProgressView()
            .scaleEffect(2)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        StocksView()
    }
}
