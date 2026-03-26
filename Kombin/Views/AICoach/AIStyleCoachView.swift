import SwiftUI
import SwiftData

struct AIStyleCoachView: View {
    @Query(sort: \ClothingItem.createdAt) private var items: [ClothingItem]
    @Query(sort: \Outfit.createdAt) private var outfits: [Outfit]
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var isLoading: Bool = false
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showPremiumGate = false
    
    struct ChatMessage: Identifiable {
        let id = UUID()
        let text: String
        let isUser: Bool
        let suggestedOutfit: Outfit?
        let timestamp: Date
        
        init(text: String, isUser: Bool, suggestedOutfit: Outfit? = nil) {
            self.text = text
            self.isUser = isUser
            self.suggestedOutfit = suggestedOutfit
            self.timestamp = .now
        }
    }
    
    var body: some View {
        NavigationStack {
            if subscriptionManager.isPremium {
                VStack(spacing: 0) {
                    // Chat messages
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: AppTheme.Spacing.md) {
                                // Welcome message
                                if messages.isEmpty {
                                    welcomeMessage
                                }
                                
                                ForEach(messages) { message in
                                    chatBubble(message)
                                        .id(message.id)
                                }
                                
                                if isLoading {
                                    HStack {
                                        loadingIndicator
                                        Spacer()
                                    }
                                    .padding(.horizontal, AppTheme.Spacing.xl)
                                }
                            }
                            .padding(.vertical, AppTheme.Spacing.lg)
                        }
                        .onChange(of: messages.count) { _, _ in
                            if let last = messages.last {
                                withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Quick chips
                    quickChips
                    
                    // Input bar
                    inputBar
                }
                .background(AppTheme.Colors.background)
                .navigationTitle("AI Stil Koçu")
                .navigationBarTitleDisplayMode(.inline)
            } else {
                premiumLockOverlay
            }
        }
    }
    
    // MARK: - Premium Lock
    private var premiumLockOverlay: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "sparkles")
                .font(.system(size: 64))
                .foregroundColor(.yellow)
            
            Text("AI Stil Koçu")
                .font(AppTheme.Typography.title1)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text("Sana özel olarak eğitilmiş Kombin AI ile anında sohbet et, gardırobundaki parçalara göre en iyi önerileri al ve her gün harika görün.")
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.xl)
            
            Button("Sınırsız Sohbeti Başlat") {
                showPremiumGate = true
            }
            .font(AppTheme.Typography.headline)
            .foregroundColor(AppTheme.Colors.buttonText)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(AppTheme.Colors.buttonFill)
            .clipShape(Capsule())
            .padding(.top, AppTheme.Spacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.background)
        .sheet(isPresented: $showPremiumGate) {
            PremiumGateView()
        }
    }
    
    // MARK: - Welcome
    
    private var welcomeMessage: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "sparkles")
                .font(.system(size: 36, weight: .ultraLight))
                .foregroundColor(AppTheme.Colors.textTertiary)
            
            Text("Merhaba! Ben senin stil koçunum.\nBana ne giyeceğini sor, gardırobundan sana en uygun kombini önereyim.")
                .font(AppTheme.Typography.subheadline)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.xxl)
        }
        .padding(.top, AppTheme.Spacing.xxxl)
    }
    
    // MARK: - Chat Bubble
    
    private func chatBubble(_ message: ChatMessage) -> some View {
        HStack {
            if message.isUser { Spacer(minLength: 60) }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: AppTheme.Spacing.sm) {
                Text(message.text)
                    .font(AppTheme.Typography.subheadline)
                    .foregroundColor(message.isUser
                                     ? AppTheme.Colors.buttonText
                                     : AppTheme.Colors.textPrimary)
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.vertical, AppTheme.Spacing.md)
                    .background(message.isUser
                                ? AppTheme.Colors.buttonFill
                                : AppTheme.Colors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))
                    .overlay(
                        message.isUser ? nil :
                            RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                            .stroke(AppTheme.Colors.border, lineWidth: 1)
                    )
                
                // Outfit suggestion card
                if let outfit = message.suggestedOutfit {
                    outfitSuggestionCard(outfit)
                }
            }
            
            if !message.isUser { Spacer(minLength: 60) }
        }
        .padding(.horizontal, AppTheme.Spacing.xl)
    }
    
    private func outfitSuggestionCard(_ outfit: Outfit) -> some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(outfit.items.prefix(4)) { outfitItem in
                    if let data = outfitItem.clothingItem?.displayImage,
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .background(AppTheme.Colors.elevatedBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
            }
            
            Text(outfit.name)
                .font(AppTheme.Typography.caption1)
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .padding(AppTheme.Spacing.md)
        .cardStyle()
    }
    
    // MARK: - Loading
    
    private var loadingIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(AppTheme.Colors.textTertiary)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.xl)
        .padding(.vertical, AppTheme.Spacing.md)
        .background(AppTheme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                .stroke(AppTheme.Colors.border, lineWidth: 1)
        )
    }
    
    // MARK: - Quick Chips
    
    private var quickChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.sm) {
                quickChip("Bugün için", icon: "sun.max")
                quickChip("İş toplantısı", icon: "briefcase")
                quickChip("Akşam yemeği", icon: "fork.knife")
                quickChip("Hafta sonu", icon: "party.popper")
            }
            .padding(.horizontal, AppTheme.Spacing.xl)
            .padding(.vertical, AppTheme.Spacing.sm)
        }
    }
    
    private func quickChip(_ text: String, icon: String) -> some View {
        Button(action: { sendMessage(text) }) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(AppTheme.Typography.caption2)
                Text(text)
                    .font(AppTheme.Typography.caption1)
            }
            .foregroundColor(AppTheme.Colors.textPrimary)
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .overlay(Capsule().stroke(AppTheme.Colors.border, lineWidth: 1))
        }
    }
    
    // MARK: - Input Bar
    
    private var inputBar: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            TextField("Bu akşam ne giysem?", text: $inputText)
                .font(AppTheme.Typography.subheadline)
                .padding(.vertical, AppTheme.Spacing.md)
                .padding(.horizontal, AppTheme.Spacing.lg)
                .background(AppTheme.Colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.full))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.full)
                        .stroke(AppTheme.Colors.border, lineWidth: 1)
                )
                .onSubmit { sendMessage(inputText) }
            
            Button(action: { sendMessage(inputText) }) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(inputText.isEmpty
                                    ? AppTheme.Colors.textTertiary
                                    : AppTheme.Colors.buttonFill)
            }
            .disabled(inputText.isEmpty)
        }
        .padding(.horizontal, AppTheme.Spacing.xl)
        .padding(.vertical, AppTheme.Spacing.md)
    }
    
    // MARK: - Logic
    
    private func sendMessage(_ text: String) {
        guard !text.isEmpty else { return }
        
        let userMessage = ChatMessage(text: text, isUser: true)
        messages.append(userMessage)
        inputText = ""
        isLoading = true
        
        Task {
            await fetchAIResponse(for: text)
        }
    }
    
    private func fetchAIResponse(for text: String) async {
        let history = messages.map { ["role": $0.isUser ? "user" : "assistant", "content": $0.text] }
        
        do {
            let response = try await AIService.shared.fetchResponse(messages: history)
            
            // Randomly attach a local outfit for wow factor since function-calling isn't active
            let randomOutfit = outfits.randomElement()
            
            await MainActor.run {
                isLoading = false
                messages.append(ChatMessage(text: response, isUser: false, suggestedOutfit: randomOutfit))
            }
        } catch {
            await MainActor.run {
                isLoading = false
                messages.append(ChatMessage(text: error.localizedDescription, isUser: false))
            }
        }
    }
}

#Preview {
    AIStyleCoachView()
}
