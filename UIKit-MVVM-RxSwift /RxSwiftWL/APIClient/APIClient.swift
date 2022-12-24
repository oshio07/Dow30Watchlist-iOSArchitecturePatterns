import Foundation

enum APIClientError: Error {
    case requestError
    case responseError(code: Int?)
    case parseError
}

final class APIClient {
    static let shared = APIClient()
    
    private let baseURL = URL(string: "https://financialmodelingprep.com/api/v3")!
    private var apiKeyQuery = URLQueryItem(name: "apikey", value: APIKey.key)
    
    private let decoder = JSONDecoder()
    
    private init(){}
}

extension APIClient {
    private var endpoint: String { "profile" }
    
    private func makeRequest(symbols: [String]) -> URLRequest {
        let joinedSymbols = symbols.joined(separator: ",")
        let url = baseURL
            .appendingPathComponent(endpoint, isDirectory: true)
            .appendingPathComponent(joinedSymbols, isDirectory: false)
        
        guard
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        else { fatalError("Invalid URL") }
        
        let queryItems: [URLQueryItem] = [apiKeyQuery]
        components.queryItems = queryItems
        
        guard let url = components.url else { fatalError("Invalid URL") }
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        
        return request
    }

    func fetchStockData(symbols: [String]) async throws -> [Stock] {
        let request = makeRequest(symbols: symbols)
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch { throw APIClientError.requestError }
        
        guard let response = response as? HTTPURLResponse else {
            throw APIClientError.responseError(code: nil)
        }
        
        guard (200...299).contains(response.statusCode) else {
            throw APIClientError.responseError(code: response.statusCode)
        }

        let stockDTOs: [StockDTO]
        do {
            stockDTOs = try decoder.decode([StockDTO].self, from: data)
        } catch { throw APIClientError.parseError }
        
        let logos = try await fetchLogos(stockDTOs: stockDTOs)
        return stockDTOs.map { Stock(stockDTO: $0,
                                     logoData: logos[$0.symbol]) }
        
    }
    
    private func fetchLogos(stockDTOs: [StockDTO]) async throws -> [String: Data] {
        try await withThrowingTaskGroup(of: (String, Data).self) { group in
            for stockDTO in stockDTOs {
                group.addTask {
                    let (data, response): (Data, URLResponse)
                    do {
                        let url = stockDTO.image
                        (data, response) = try await URLSession.shared.data(from: url)
                    } catch { throw APIClientError.requestError }
                    
                    guard let response = response as? HTTPURLResponse else {
                        throw APIClientError.responseError(code: nil)
                    }
                    
                    guard (200...299).contains(response.statusCode) else {
                        throw APIClientError.responseError(code: response.statusCode)
                    }
                    
                    return (stockDTO.symbol, data)
                }
            }
            var logos = [String: Data]()
            for try await (symbol, data) in group {
                logos[symbol] = data
            }
            return logos
        }
    }
}
