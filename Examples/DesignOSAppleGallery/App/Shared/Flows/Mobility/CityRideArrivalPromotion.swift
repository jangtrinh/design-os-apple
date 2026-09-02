import SwiftUI

struct CityRideArrivalPromotion: View {
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  let onOptions: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text("Check this out before arriving").font(.subheadline.weight(.semibold))
        Spacer()
        Button(action: onOptions) {
          Image(systemName: "ellipsis")
            .foregroundStyle(.secondary)
            .frame(width: 44, height: 44)
        }
        .buttonStyle(LocalDemoPressButtonStyle())
        .accessibilityLabel("Arrival options")
      }
      Button(action: onOptions) {
        if dynamicTypeSize.isAccessibilitySize {
          accessibilityPromotion
        } else {
          compactPromotion
        }
      }
      .buttonStyle(.plain)
      .accessibilityLabel("Open arrival guide")
    }
    .padding(12)
    .background(MobilityDemoTheme.controlFill, in: RoundedRectangle(cornerRadius: 16))
    .overlay(RoundedRectangle(cornerRadius: 16).stroke(.gray.opacity(0.18)))
  }

  private var compactPromotion: some View {
    ZStack(alignment: .trailing) {
      promotionImage
      arrivalPromotionOverlay
    }
    .frame(height: 112)
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }

  private var accessibilityPromotion: some View {
    VStack(alignment: .leading, spacing: 0) {
      promotionImage
        .frame(height: 112)
        .clipped()
      arrivalPromotionCopy
        .foregroundStyle(MobilityDemoTheme.cityInk)
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MobilityDemoTheme.softFill)
    }
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }

  private var arrivalPromotionOverlay: some View {
    arrivalPromotionCopy
      .foregroundStyle(.white)
      .frame(width: 154, alignment: .leading)
      .padding(12)
      .shadow(color: .black.opacity(0.5), radius: 4, y: 1)
  }

  private var arrivalPromotionCopy: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("Terminal-ready essentials").font(.caption.weight(.bold))
      Text("A compact guide for pickup day")
        .font(.caption)
        .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
      Text("View guide")
        .font(.caption.weight(.semibold))
        .padding(.horizontal, 8)
        .frame(minHeight: 28)
        .background(MobilityDemoTheme.paper, in: Capsule())
        .foregroundStyle(MobilityDemoTheme.cityInk)
    }
  }

  private var promotionImage: some View {
    Image("city-ride-arrival-essentials")
      .resizable()
      .scaledToFill()
  }
}
