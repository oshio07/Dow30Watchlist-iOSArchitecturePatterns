# Dow30Watchlist-iOSArchitecturePatterns

A sample application that simply displays the price and percentage change of the 30 stocks in the Dow Jones Industrial Average.  
ダウ平均30銘柄の株価と騰落率を表示するシンプルなサンプルアプリケーション。

Data provided by [Financial Modeling Prep](https://site.financialmodelingprep.com/developer/docs/)

- [SwiftUI-MVVM](https://github.com/oshio07/Dow30Watchlist-iOSArchitecturePatterns/tree/main/SwiftUI-MVVM%20)
- [UIKit-MVC](https://github.com/oshio07/Dow30Watchlist-iOSArchitecturePatterns/tree/main/UIKit-MVC%20)
- [UIKit-MVP](https://github.com/oshio07/Dow30Watchlist-iOSArchitecturePatterns/tree/main/UIKit-MVPWithInteractor)
- [UIKit-MVVM-Combine](https://github.com/oshio07/Dow30Watchlist-iOSArchitecturePatterns/tree/main/UIKit-MVVM-Combine%20)
- [UIKit-MVVM-RxSwift](https://github.com/oshio07/Dow30Watchlist-iOSArchitecturePatterns/tree/main/UIKit-MVVM-RxSwift%20)

### Demo

https://user-images.githubusercontent.com/114917347/196563915-f54fd7b6-17d3-47b1-9591-8f605a0d4d4c.mov

### To Run
Assign your API Key in `APIClient`.

```swift
    private var apiKeyQuery = URLQueryItem(
        name: "apikey",
        value: APIKey.key // Asign Your Key
    )
```
