import Foundation
import Combine
import StoreKit

/// StoreKit 2 subscription manager for Kombin PRO
@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    // Product IDs
    static let monthlyID = "com.kombin.pro.monthly"
    static let yearlyID = "com.kombin.pro.yearly"
    
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoading: Bool = false
    
    var isPremium: Bool {
        !purchasedProductIDs.isEmpty
    }
    
    private var transactionListener: Task<Void, Error>?
    
    init() {
        transactionListener = listenForTransactions()
        Task { await loadProducts() }
        Task { await updatePurchasedProducts() }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    // MARK: - Load Products
    
    func loadProducts() async {
        isLoading = true
        do {
            products = try await Product.products(for: [
                Self.monthlyID,
                Self.yearlyID
            ])
            products.sort { $0.price < $1.price }
        } catch {
            print("Failed to load products: \(error)")
        }
        isLoading = false
    }
    
    // MARK: - Purchase
    
    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await updatePurchasedProducts()
            return true
            
        case .userCancelled:
            return false
            
        case .pending:
            return false
            
        @unknown default:
            return false
        }
    }
    
    // MARK: - Restore
    
    func restorePurchases() async {
        try? await AppStore.sync()
        await updatePurchasedProducts()
    }
    
    // MARK: - Transaction Listener
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    await self.updatePurchasedProducts()
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification: \(error)")
                }
            }
        }
    }
    
    // MARK: - Update Purchased
    
    func updatePurchasedProducts() async {
        var purchased: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if transaction.revocationDate == nil {
                    purchased.insert(transaction.productID)
                }
            } catch {
                print("Transaction verification failed: \(error)")
            }
        }
        
        purchasedProductIDs = purchased
    }
    
    // MARK: - Verify
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified:
            throw SubscriptionError.verificationFailed
        }
    }
}

enum SubscriptionError: Error {
    case verificationFailed
}
