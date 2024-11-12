//
//  Store.swift
//  HP Trivia
//
//  Created by Jinyuan Zhang on 12/11/2024.
//

import Foundation
import StoreKit // 不然不能调用 Product

enum BookSatus: Codable {
    case active
    case inactive
    case locked
}

@MainActor
class Store: ObservableObject {
    @Published var books: [BookSatus] = [
        .active,
        .active,
        .inactive,
        .locked,
        .locked,
        .locked,
        .locked
    ]
    
    @Published var products: [Product] = []
    @Published var purchasedIDs = Set<String>()
    
    private let productIDs = ["hp4", "hp5", "hp6", "hp7"]
    private var updates: Task<Void, Never>? = nil
    private let savePath = FileManager.documentsDirectory.appending(path: "SavedBookStatus")
    
    init() {
        updates = watchForUpdates()
        
        Task {
            await loadProducts()
            await checkPurchased()
        }
    }
        
    func loadProducts() async {
        do {
            products = try await Product.products(for: productIDs)
        } catch {
            print("Coulnd't fetch those products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            
            // Purchase successful, but now we have to verify receipt
            switch result {
            case .success(let verificationResult):
                switch verificationResult {
                case .unverified(let signedType, let verificationError):
                    print("Unverified receipt: \(signedType), \(verificationError)")
                    
                case .verified(let signedType):
                    purchasedIDs.insert(signedType.productID)
                }
                
            // User cancelled or parent disapproved child's purchase request
            case .userCancelled:
                break
            
            // Waiting for approval
            case .pending:
                break
                
            @unknown default:
                break
            }
        } catch {
            print("Couldn't purchase that product: \(error)")
        }
    }
    
    func saveStatus() {
        do {
            let data = try JSONEncoder().encode(books)
            try data.write(to: savePath)
        } catch {
            print("Unable to save book status: \(error)")
        }
    }
    
    func loadStatus() {
        do {
            let data = try Data(contentsOf: savePath)
            books = try JSONDecoder().decode([BookSatus].self, from: data)
        } catch {
            print("Unable to load book status: \(error)")
        }
    }
    
    private func checkPurchased() async {
        for product in products {
            if let state = await product.currentEntitlement {
                switch state {
                case .unverified(let signedType, let verificationError):
                    print("Unverified receipt: \(signedType), \(verificationError)")
                case .verified(let signedType):
                    if signedType.revocationDate == nil {
                        purchasedIDs.insert(signedType.productID)
                    } else {
                        purchasedIDs.remove(signedType.productID)
                    }
                }
            }
        }
    }
    
    // 用户可能在 App Store 直接购买（或恢复购买），而不是通过应用内购买。通过监听 Transaction.updates，应用可以捕获这些外部购买或恢复事件，并实时更新 purchasedIDs，确保用户在应用内获得正确的内容访问权限。
    private func watchForUpdates() -> Task<Void, Never> {
        Task(priority: .background) {
            for await _ in Transaction.updates {
                await checkPurchased()
            }
        }
    }
}
