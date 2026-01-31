import SwiftUI

struct SupportView: View {
    @ObservedObject var localization = LocalizationManager.shared
    @ObservedObject var settings = AppSettings.shared
    @ObservedObject var store = StoreKitManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var showErrorAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(localization.localized("support.title"))
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            .background(ContentView.adaptiveBackgroundColor(theme: settings.theme, backgroundColor: settings.backgroundColor, opacity: 0.95))
            
            ScrollView {
                VStack(spacing: 24) {
                    // Description
                    Text(localization.localized("support.description"))
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.top, 20)
                    
                    // Buy Me a Coffee Card
                    /*
                    SupportCard(
                        icon: "cup.and.saucer.fill",
                        title: localization.localized("support.coffee.title"),
                        description: localization.localized("support.coffee.description"),
                        buttonText: localization.localized("support.coffee.button"),
                        buttonColor: .orange,
                        action: {
                            if let url = URL(string: "https://buymeacoffee.com/zero2me") {
                                NSWorkspace.shared.open(url)
                            }
                        }
                    )
                    */
                    
                    // Premium Features Card
                    SupportCard(
                        icon: "star.fill",
                        title: localization.localized("support.premium.title"),
                        description: localization.localized("support.premium.description"),
                        buttonText: premiumButtonText,
                        buttonColor: .blue,
                        isButtonDisabled: premiumButtonDisabled,
                        action: {
                            Task {
                                await store.purchasePremium()
                            }
                        }
                    )

                    if store.hasPremium {
                        Text(localization.localized("support.premium.thanks"))
                            .font(.footnote)
                            .foregroundColor(.green)
                    } else if store.isPurchasing {
                        Text(localization.localized("support.premium.processing"))
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }

                    Button(restoreButtonText) {
                        Task {
                            await store.restorePurchases()
                        }
                    }
                    .buttonStyle(.link)
                    .disabled(store.isRestoring)
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            
            Divider()
            
            // Footer
            HStack {
                Spacer()
                Button(localization.localized("support.close")) {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .padding()
            }
            .background(ContentView.adaptiveBackgroundColor(theme: settings.theme, backgroundColor: settings.backgroundColor, opacity: 0.95))
        }
        .frame(width: 500, height: 550)
        .background(ContentView.adaptiveBackgroundColor(theme: settings.theme, backgroundColor: settings.backgroundColor, opacity: 1.0))
        .onChange(of: store.lastErrorMessage) { newValue in
            showErrorAlert = newValue != nil
        }
        .alert(isPresented: $showErrorAlert) {
            SwiftUI.Alert(
                title: Text(localization.localized("general.error")),
                message: Text(store.lastErrorMessage ?? ""),
                dismissButton: .default(Text(localization.localized("general.ok"))) {
                    store.lastErrorMessage = nil
                }
            )
        }
    }

    private var premiumButtonText: String {
        if store.hasPremium {
            return localization.localized("support.premium.purchased")
        }

        if store.isPurchasing {
            return localization.localized("support.premium.processing")
        }

        if let price = store.premiumPriceText {
            let buttonLabel = localization.localized("support.premium.button")
            return "\(buttonLabel) • \(price)"
        }

        return localization.localized("support.premium.button")
    }

    private var premiumButtonDisabled: Bool {
        store.hasPremium || store.isPurchasing || store.isLoading
    }

    private var restoreButtonText: String {
        store.isRestoring ? localization.localized("general.loading") : localization.localized("support.restore.button")
    }
}

struct SupportCard: View {
    let icon: String
    let title: String
    let description: String
    let buttonText: String
    let buttonColor: Color
    let isButtonDisabled: Bool
    let action: () -> Void
    
    @ObservedObject var settings = AppSettings.shared
    
    init(icon: String, title: String, description: String, buttonText: String, buttonColor: Color, isButtonDisabled: Bool = false, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.description = description
        self.buttonText = buttonText
        self.buttonColor = buttonColor
        self.isButtonDisabled = isButtonDisabled
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(buttonColor)
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: action) {
                Text(buttonText)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(buttonColor)
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isButtonDisabled)
            .opacity(isButtonDisabled ? 0.6 : 1.0)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ContentView.adaptiveBackgroundColor(theme: settings.theme, backgroundColor: settings.backgroundColor, opacity: 0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct SupportView_Previews: PreviewProvider {
    static var previews: some View {
        SupportView()
    }
}
