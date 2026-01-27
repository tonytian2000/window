import SwiftUI

struct AboutView: View {
    @ObservedObject var localization = LocalizationManager.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // App Icon
            Image("win")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
            
            // App Name
            Text(localization.localized("about.app_name"))
                .font(.system(size: 24, weight: .bold))
            
            // Version
            Text(localization.localized("about.version"))
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            Divider()
                .padding(.horizontal, 40)
            
            // Description
            Text(localization.localized("about.description"))
                .font(.system(size: 13))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            // Close button
            Button(action: {
                dismiss()
            }) {
                Text(localization.localized("about.close"))
                    .frame(width: 100)
            }
            .keyboardShortcut(.defaultAction)
            .padding(.bottom, 10)
        }
        .frame(width: 350, height: 350)
        .padding()
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
