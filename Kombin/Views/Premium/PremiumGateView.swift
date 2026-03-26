import SwiftUI
import StoreKit

struct PremiumGateView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .padding(8)
                            .background(AppTheme.Colors.elevatedBackground)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        Task { await subscriptionManager.restorePurchases() }
                    }) {
                        Text("Geri Yükle")
                            .font(AppTheme.Typography.caption1)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.xl)
                .padding(.top, AppTheme.Spacing.lg)
                
                // Hero illustration area
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Decorative circles
                    ZStack {
                        Circle()
                            .stroke(AppTheme.Colors.border.opacity(0.3), lineWidth: 1)
                            .frame(width: 200, height: 200)
                        Circle()
                            .stroke(AppTheme.Colors.border.opacity(0.2), lineWidth: 1)
                            .frame(width: 160, height: 160)
                        Circle()
                            .stroke(AppTheme.Colors.border.opacity(0.1), lineWidth: 1)
                            .frame(width: 120, height: 120)
                        
                        // Center icon
                        VStack(spacing: 4) {
                            Image(systemName: "wand.and.stars")
                                .font(.system(size: 36, weight: .light))
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            Text("PRO")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                    }
                    .padding(.top, AppTheme.Spacing.xxl)
                    
                    Text("Kombin PRO")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Text("Gardırobunun tam potansiyelini aç.")
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                .padding(.bottom, AppTheme.Spacing.xxl)
                
                // Features
                VStack(spacing: AppTheme.Spacing.lg) {
                    featureRow(icon: "infinity", title: "Sınırsız Gardırop", desc: "30 kıyafet limitini kaldır.")
                    featureRow(icon: "bubble.left.and.bubble.right", title: "AI Stil Koçu", desc: "Yapay zeka ile sınırsız sohbet.")
                    featureRow(icon: "suitcase", title: "Valiz Modu", desc: "Hava durumuna göre kapsül gardırop.")
                    featureRow(icon: "chart.bar", title: "Gelişmiş İstatistikler", desc: "Dolap kullanım oranı ve içgörüler.")
                    featureRow(icon: "scissors", title: "PRO Arkaplan Kesici", desc: "Kusursuz ürün kesimleri.")
                }
                .padding(.horizontal, AppTheme.Spacing.xl)
                
                // Pricing
                VStack(spacing: AppTheme.Spacing.md) {
                    if subscriptionManager.products.isEmpty {
                        pricingCard(title: "Aylık", price: "₺99.99/ay", isPopular: false)
                        pricingCard(title: "Yıllık", price: "₺799.99/yıl", isPopular: true)
                    } else {
                        ForEach(subscriptionManager.products, id: \.id) { product in
                            Button(action: {
                                Task { _ = try? await subscriptionManager.purchase(product) }
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(product.displayName)
                                            .font(AppTheme.Typography.headline)
                                        Text(product.displayPrice)
                                            .font(AppTheme.Typography.caption1)
                                            .foregroundColor(AppTheme.Colors.textSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(AppTheme.Typography.caption1)
                                        .foregroundColor(AppTheme.Colors.textTertiary)
                                }
                                .padding(AppTheme.Spacing.lg)
                                .background(AppTheme.Colors.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                        .stroke(AppTheme.Colors.border, lineWidth: 1)
                                )
                            }
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.xl)
                .padding(.top, AppTheme.Spacing.xxl)
                
                // Legal
                VStack(spacing: 8) {
                    Text("Abonelikler iTunes hesabınızdan tahsil edilir.")
                        .multilineTextAlignment(.center)
                    HStack(spacing: AppTheme.Spacing.md) {
                        Link("Gizlilik Politikası", destination: URL(string: "https://example.com/privacy")!)
                        Text("•")
                        Link("Kullanım Şartları", destination: URL(string: "https://apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    }
                }
                .font(AppTheme.Typography.caption2)
                .foregroundColor(AppTheme.Colors.textTertiary)
                .padding(.horizontal, AppTheme.Spacing.xl)
                .padding(.top, AppTheme.Spacing.xxl)
                .padding(.bottom, AppTheme.Spacing.xxxl)
            }
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
    }
    
    private func featureRow(icon: String, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .light))
                .foregroundColor(AppTheme.Colors.textPrimary)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTheme.Typography.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                Text(desc)
                    .font(AppTheme.Typography.caption1)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            Spacer()
        }
    }
    
    private func pricingCard(title: String, price: String, isPopular: Bool) -> some View {
        Button(action: {}) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppTheme.Typography.headline)
                    Text(price)
                        .font(AppTheme.Typography.caption1)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                Spacer()
                
                if isPopular {
                    Text("En Popüler")
                        .font(AppTheme.Typography.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.Colors.buttonText)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(AppTheme.Colors.buttonFill)
                        .clipShape(Capsule())
                }
            }
            .padding(AppTheme.Spacing.lg)
            .background(AppTheme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .stroke(AppTheme.Colors.border, lineWidth: 1)
            )
        }
        .foregroundColor(AppTheme.Colors.textPrimary)
    }
}

#Preview {
    PremiumGateView()
}
