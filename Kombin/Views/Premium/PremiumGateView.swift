import SwiftUI
import StoreKit

struct PremiumGateView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.xl) {
                
                // Header (Close Button + Restore)
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(AppTheme.Colors.textTertiary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        Task { await subscriptionManager.restorePurchases() }
                    }) {
                        Text("Geri Yükle")
                            .font(AppTheme.Typography.subheadline)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
                .padding(.top, AppTheme.Spacing.md)
                .padding(.horizontal, AppTheme.Spacing.lg)
                
                // Hero Section
                VStack(spacing: AppTheme.Spacing.md) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .padding(.bottom, AppTheme.Spacing.sm)
                    
                    Text("Kombin PRO")
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Text("Potansiyelini Sınırlandırma")
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                .padding(.top, AppTheme.Spacing.lg)
                
                // Features List
                VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                    proFeatureRow(icon: "infinity", title: "Sınırsız Gardırop", desc: "30 kıyafet limitini kaldırın.")
                    proFeatureRow(icon: "sparkles", title: "AI Stil Koçu", desc: "OpenAI destekli sınırsız sohbet.")
                    proFeatureRow(icon: "suitcase", title: "Valiz Modu", desc: "Tatillerinizi hava durumuna göre planlayın.")
                    proFeatureRow(icon: "scissors", title: "PRO Arkaplan Kesici", desc: "Kusursuz ve temiz ürün kesimleri.")
                    proFeatureRow(icon: "chart.pie", title: "Gelişmiş İstatistikler", desc: "Giyme başı maliyet ve içgörüler.")
                }
                .padding(.horizontal, AppTheme.Spacing.xl)
                .padding(.vertical, AppTheme.Spacing.md)
                
                // Pricing
                if subscriptionManager.isLoading {
                    ProgressView()
                        .padding()
                } else {
                    VStack(spacing: AppTheme.Spacing.md) {
                        if subscriptionManager.products.isEmpty {
                            // Fallback exactly like real subscriptions handles delays
                            pricingButton(title: "Aylık", price: "₺99.99/ay")
                            pricingButton(title: "Yıllık", price: "₺799.99/yıl", savings: "En Popüler")
                        } else {
                            ForEach(subscriptionManager.products, id: \.id) { product in
                                Button(action: {
                                    Task {
                                        _ = try? await subscriptionManager.purchase(product)
                                    }
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(product.displayName)
                                                .font(AppTheme.Typography.headline)
                                            Text(product.displayPrice)
                                                .font(AppTheme.Typography.caption1)
                                        }
                                        Spacer()
                                    }
                                    .padding(AppTheme.Spacing.lg)
                                    .background(AppTheme.Colors.cardBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                            .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                                    )
                                }
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.top, AppTheme.Spacing.lg)
                }
                
                // T&C / Privacy
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
                .padding(.top, AppTheme.Spacing.lg)
                .padding(.bottom, AppTheme.Spacing.xxl)
            }
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
    }
    
    private func proFeatureRow(icon: String, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.yellow)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text(desc)
                    .font(AppTheme.Typography.caption1)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    private func pricingButton(title: String, price: String, savings: String? = nil) -> some View {
        Button(action: {}) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppTheme.Typography.headline)
                    Text(price)
                        .font(AppTheme.Typography.caption1)
                }
                Spacer()
                
                if let savings = savings {
                    Text(savings)
                        .font(AppTheme.Typography.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.yellow)
                        .clipShape(Capsule())
                }
            }
            .padding(AppTheme.Spacing.lg)
            .background(AppTheme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
            )
        }
        .foregroundColor(AppTheme.Colors.textPrimary)
    }
}

#Preview {
    PremiumGateView()
}

