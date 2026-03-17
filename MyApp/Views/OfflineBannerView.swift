import SwiftUI

struct OfflineBannerView: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash")
                .font(.subheadline)
            Text("No Internet Connection")
                .font(.subheadline.weight(.semibold))
        }
        .foregroundStyle(.white)
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(Color.orange)
    }
}

#Preview {
    VStack {
        OfflineBannerView()
        Spacer()
    }
}
