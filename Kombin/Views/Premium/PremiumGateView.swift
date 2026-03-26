import SwiftUI
import StoreKit

struct PremiumGateView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.xxl) {
            Spacer()
            
            // Logo
            VStack(spacing: AppTheme.Spacing.sm) {
                Text("Kombin")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text("PRO")
                    .font(AppTheme.Typography.caption1)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.Colors.buttonText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(AppTheme.Colors.buttonFill)
                    .clipShape(Capsule())
            }
            
            // Features list
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                proFeatureRow(icon: "infinity", text: "Sınırsız kombin oluşturma")
                proFeatureRow(icon: "sparkles", text: "AI Stil Koçu")
                proFeatureRow(icon: "wand.and.stars", text: "AI kıyafet illüstrasyonu")
                proFeatureRow(icon: "suitcase", text: "Valiz modu")
                proFeatureRow(icon: "chart.pie", text: "Detaylı istatistikler")
                proFeatureRow(icon: "xmark.circle", text: "Reklamsız deneyim")
            }
            .padding(.horizontal, AppTheme.Spacing.xxl)
            
            Spacer()
            
            // Pricing
            if subscriptionManager.isLoading {
                ProgressView()
            } else {
                VStack(spacing: AppTheme.Spacing.md) {
                    ForEach(subscriptionManager.products, id: \.id) { product in
                        Button(action: {
                            Task {
                                _ = try? await subscriptionManager.purchase(product)
                            }
                        }) {
                            VStack(spacing: 2) {
                                Text(product.displayName)
                                    .font(AppTheme.Typography.headline)
                                Text(product.displayPrice)
                                    .font(AppTheme.Typography.caption1)
                            }
                            .foregroundColor(AppTheme.Colors.buttonText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppTheme.Spacing.lg)
                            .background(AppTheme.Colors.buttonFill)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                        }
                    }
                    
                    // If no products loaded, show placeholder
                    if subscriptionManager.products.isEmpty {
                        VStack(spacing: AppTheme.Spacing.md) {
                            pricingButton(title: "Aylık", price: "$2.99/ay")
                            pricingButton(title: "Yıllık", price: "$19.99/yıl", savings: "44% tasarruf")
                        }
                    }
                    
                    Button(action: {
                        Task { await subscriptionManager.restorePurchases() }
                    }) {
                        Text("Satın almayı geri yükle")
                            .font(AppTheme.Typography.caption1)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.xl)
            }
            
            // Close
            Button(action: { dismiss() }) {
                Text("Daha sonra")
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(AppTheme.Colors.textTertiary)
            }
            .padding(.bottom, AppTheme.Spacing.xxl)
        }
        .background(AppTheme.Colors.background)
    }
    
    private func proFeatureRow(icon: String, text: String) -> some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .frame(width: 28)
            
            Text(text)
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Spacer()
        }
    }
    
    private func pricingButton(title: String, price: String, savings: String? = nil) -> some View {
        Button(action: {}) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppTheme.Typography.headline)
                    Text(price)
                        .font(AppTheme.Typography.caption1)
                }
                Spacer()
                if let savings = savings {
                    Text(savings)
                        .font(AppTheme.Typography.caption2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.Colors.elevatedBackground)
                        .clipShape(Capsule())
                }
            }
            .foregroundColor(AppTheme.Colors.buttonText)
            .padding(AppTheme.Spacing.lg)
            .background(AppTheme.Colors.buttonFill)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
        }
    }
}

#Preview {
    PremiumGateView()
}
