import SwiftUI

struct TocChienChampionHeroNegativeControlStory: View {
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 28, style: .continuous)
        .fill(
          LinearGradient(
            colors: [.indigo, .purple, .black], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .accessibilityHidden(true)
      Circle()
        .fill(.white.opacity(0.18))
        .frame(width: 180, height: 180)
        .offset(x: 110, y: -95)
        .accessibilityHidden(true)
      VStack(alignment: .leading, spacing: 14) {
        Image(systemName: "sparkles.rectangle.stack.fill")
          .font(.system(size: 44))
          .accessibilityHidden(true)
        Text("Synthetic app control")
          .font(.title2.weight(.bold))
        Text("A local ownership-boundary fixture built without product assets.")
          .font(.subheadline)
        Text("App-specific fixture — runtime unavailable")
          .font(.caption.weight(.semibold))
      }
      .foregroundStyle(.white)
      .padding(28)
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .frame(minHeight: 280)
    .padding()
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(
      "Synthetic app-specific negative control. Runtime implementation unavailable."
    )
    .accessibilityIdentifier("design-os.tocchien.negative-control.runtime-unavailable")
  }
}
