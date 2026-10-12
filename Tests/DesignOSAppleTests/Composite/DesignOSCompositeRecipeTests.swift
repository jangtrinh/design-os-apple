import DesignOSApple
import SwiftUI
import Testing

/// Recipe disposition for composite/form-section: native Section already owns header, footer,
/// row backgrounds and form accessibility. A renamed wrapper would add no reusable behavior.
@Test("Form section recipe keeps native grouping and controls")
@MainActor
func nativeFormSectionRecipeCompiles() {
  acceptsCompositeRecipe(
    Form {
      Section {
        TextField("Name", text: .constant("Draft"))
        Toggle("Include", isOn: .constant(true))
      } header: {
        Text("Details")
      } footer: {
        Text("The app supplies validation and save behavior.")
      }
    }
  )
}

/// Recipe disposition for composite/sectioned-media-collection: native Section plus stable-ID
/// ForEach handles grouping and row identity. Keep the parent List as the only vertical scroller.
@Test("Sectioned media collection recipe keeps stable IDs and native sections")
@MainActor
func nativeSectionedMediaCollectionRecipeCompiles() {
  acceptsCompositeRecipe(
    DesignOSFlatListShell {
      ForEach(["Today", "Yesterday"], id: \.self) { day in
        Section(day) {
          ForEach(["One", "Two"], id: \.self) { item in
            NavigationLink(value: day + item) {
              DesignOSMediaRow {
                Image(systemName: "leaf").accessibilityHidden(true)
              } content: {
                Text(item)
              }
            }
          }
        }
      }
    }
  )
}

/// Recipe disposition for composite/status-content: use the existing semantic status API.
/// State selection, actual recovery actions and announcements stay with the consuming app.
@Test("Status content recipe reuses the existing semantic status component")
@MainActor
func reusedStatusContentRecipeCompiles() {
  acceptsCompositeRecipe(
    DesignOSStatusMessage("Could not save", message: "Your draft is still available.") {
      Image(systemName: "exclamationmark.circle").accessibilityHidden(true)
    } actions: {
      Button("Try again") {}
    }
  )
}

/// Recipe disposition for composite/confirmation-content: native consequence text and actions
/// compose in the existing sheet screen. Short decisions use confirmationDialog/alert instead.
/// Presentation, destructive/cancel roles and the real consequences remain app-owned.
@Test("Confirmation content recipe keeps native roles and explicit consequence copy")
@MainActor
func nativeConfirmationContentRecipeCompiles() {
  acceptsCompositeRecipe(
    DesignOSConfirmationScreen {
      Text("Remove this sample?").font(.title)
    } details: {
      Text("The consuming app describes whether removal is reversible.")
    } actions: {
      VStack {
        Button("Remove", role: .destructive) {}
        Button("Cancel", role: .cancel) {}
      }
    }
  )
}

private func acceptsCompositeRecipe(_: some View) {}
