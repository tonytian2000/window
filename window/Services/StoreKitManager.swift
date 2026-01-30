import Foundation
import StoreKit

@MainActor
final class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()

    private let premiumProductID = "com.tonytian.window.premium"
    private let productIDs: Set<String>
    private var updatesTask: Task<Void, Never>?

    @Published private(set) var products: [Product] = []
    @Published private(set) var hasPremium = false
    @Published private(set) var isLoading = false
    @Published private(set) var isPurchasing = false
    @Published private(set) var isRestoring = false
    @Published var lastErrorMessage: String?

    var premiumProduct: Product? {
        products.first { $0.id == premiumProductID }
    }

    var premiumPriceText: String? {
        premiumProduct?.displayPrice
    }

    private init() {
        self.productIDs = [premiumProductID]
        self.updatesTask = Task { await listenForTransactions() }
        Task { await refreshProducts() }
    }

    deinit {
        updatesTask?.cancel()
    }

    func refreshProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            products = try await Product.products(for: Array(productIDs))
            await updatePurchasedProducts()
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    func purchasePremium() async {
        isPurchasing = true
        defer { isPurchasing = false }

        if products.isEmpty {
            await refreshProducts()
        }

        guard let product = premiumProduct else {
            lastErrorMessage = "Product unavailable."
            return
        }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await updatePurchasedProducts()
            case .pending:
                break
            case .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    func restorePurchases() async {
        isRestoring = true
        defer { isRestoring = false }

        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            do {
                let transaction = try checkVerified(result)
                if productIDs.contains(transaction.productID) {
                    await updatePurchasedProducts()
                }
                await transaction.finish()
            } catch {
                lastErrorMessage = error.localizedDescription
            }
        }
    }

    private func updatePurchasedProducts() async {
        var purchased = Set<String>()

        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result), productIDs.contains(transaction.productID) {
                purchased.insert(transaction.productID)
            }
        }

        hasPremium = purchased.contains(premiumProductID)
        AppSettings.shared.hasPremium = hasPremium
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified(_, let error):
            throw error
        }
    }
}
