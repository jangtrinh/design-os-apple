import DesignOSApple
import SwiftUI

struct TypographyGallery: View {
  var body: some View {
    Group {
      Text("Large title").font(DesignOSTypographyRole.largeTitle.font)
      Text("Title").font(DesignOSTypographyRole.title.font)
      Text("Headline").font(DesignOSTypographyRole.headline.font)
      Text("Body scales with Dynamic Type").font(DesignOSTypographyRole.body.font)
      Text("Emphasized callout").font(DesignOSTypographyRole.callout.emphasized().font)
      Text("Italic footnote").font(DesignOSTypographyRole.footnote.italic().font)
    }
  }
}
