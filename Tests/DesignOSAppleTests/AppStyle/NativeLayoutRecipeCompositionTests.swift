import DesignOSApple
import SwiftUI
import Testing

// Copyable app-local recipes, not new library API. See docs/native-layout-recipes.md.
// Compilation checks every body; these tests instantiate views, not rendered UI or behavior.
// Images and strings are synthetic. Bindings, routes, validation, and effects belong to the app.

@Test("Flat media list composes native navigation and empty content")
@MainActor
func flatMediaListRecipeCompiles() {
  for items in [RecipeItem.samples, []] {
    acceptsRecipeView(
      NavigationStack {
        FlatMediaListRecipe(items: items)
          .navigationDestination(for: String.self) { identifier in
            Text(identifier)
          }
      }
      .designOSAppStyle(.editorial)
    )
  }
}

@Test("Detail and composer support actual media and deliberate no-media composition")
@MainActor
func optionalMediaRecipesCompile() {
  let images: [Image?] = [Image(systemName: "square.grid.2x2.fill"), nil]
  for image in images {
    acceptsRecipeView(
      OptionalMediaDetailRecipe(image: image, title: "Sample item", onEdit: {})
    )
    acceptsRecipeView(
      MediaComposerRecipe(
        image: image, title: .constant("Sample item"), isIncluded: .constant(true),
        error: "Sample validation message", canSave: false, onSave: {}
      )
    )
  }
}

@Test("Grouped management keeps native form controls")
@MainActor
func groupedManagementRecipeCompiles() {
  acceptsRecipeView(
    GroupedManagementRecipe(title: .constant("Sample collection"), isIncluded: .constant(true))
  )
}

@Test("Focused task uses a native sheet with caller-owned presentation")
@MainActor
func focusedTaskSheetRecipeCompiles() {
  acceptsRecipeView(
    Text("Presenting screen")
      .sheet(isPresented: .constant(true)) {
        NavigationStack {
          FocusedTaskSheetRecipe(
            value: .constant(""), error: "Enter a name.", canSave: false,
            onCancel: {}, onSave: {}
          )
        }
      }
  )
}

@Test("Search selection composes native search, selection, and no-results content")
@MainActor
func searchSelectionRecipeCompiles() {
  for query in ["", "No matching sample"] {
    acceptsRecipeView(
      SearchSelectionRecipe(
        items: RecipeItem.samples, query: .constant(query), selection: .constant(nil),
        onDone: {}
      )
    )
  }
}

@Test("Confirmation retains native destructive and cancel roles")
@MainActor
func nativeConfirmationRecipeCompiles() {
  acceptsRecipeView(
    NativeConfirmationRecipe(
      isPresented: .constant(false), consequence: "Remove this sample from the collection?",
      onConfirm: {}
    )
  )
}

private func acceptsRecipeView(_: some View) {}

private struct RecipeItem: Identifiable, Sendable {
  let id: String
  let title: String
  let subtitle: String

  static let samples = [
    RecipeItem(id: "sample-a", title: "Sample A", subtitle: "Supporting information"),
    RecipeItem(id: "sample-b", title: "Sample B", subtitle: "More information"),
  ]
}

// MARK: - Flat media list

private struct FlatMediaListRecipe: View {
  @Environment(\.designOSAppStyle) private var style
  let items: [RecipeItem]

  var body: some View {
    List {
      Section {
        ForEach(items) { item in
          NavigationLink(value: item.id) {
            DesignOSMediaRow {
              Image(systemName: "square.grid.2x2.fill")
                .resizable().scaledToFit().accessibilityHidden(true)
            } content: {
              VStack(alignment: .leading) {
                Text(item.title).font(.headline)
                Text(item.subtitle).font(.subheadline).foregroundStyle(.secondary)
              }
            }
          }
        }
      } header: {
        DesignOSAppSectionHeader("Recent items")
      }
    }
    .listStyle(.plain)
    .scrollContentBackground(.hidden)
    .background(style.palette.canvas.color)
    .overlay {
      if items.isEmpty {
        ContentUnavailableView("No items", systemImage: "tray")
      }
    }
    .navigationTitle("Collection")
  }
}

// MARK: - Optional-media detail

private struct OptionalMediaDetailRecipe: View {
  @Environment(\.designOSAppStyle) private var style
  let image: Image?
  let title: String
  let onEdit: () -> Void

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: style.metrics.sectionSpacing) {
        if let image {
          RecipeCover(image: image)
            .accessibilityLabel("Synthetic sample illustration")
        }
        Text(title).font(.largeTitle.bold())
        Text("Supporting information").foregroundStyle(style.palette.secondaryInk.color)
        Button("Edit", action: onEdit).buttonStyle(DesignOSSecondaryButtonStyle())
        Divider()
        DesignOSAppSectionHeader("Details")
        Text("Readable, flowing description supplied by the consuming app.")
      }
      .padding(style.metrics.pageInset)
    }
    .background {
      if let image {
        DesignOSMediaBackdrop { image.resizable().scaledToFill() }
      } else {
        style.palette.canvas.color
      }
    }
    .navigationTitle("Item")
  }
}

// MARK: - Media composer

private struct MediaComposerRecipe: View {
  @Environment(\.designOSAppStyle) private var style
  let image: Image?
  @Binding var title: String
  @Binding var isIncluded: Bool
  let error: String?
  let canSave: Bool
  let onSave: () -> Void

  var body: some View {
    ScrollView {
      VStack(spacing: style.metrics.sectionSpacing) {
        if let image {
          RecipeCover(image: image)
            .accessibilityLabel("Synthetic sample illustration")
        }
        DesignOSAppSurface(tone: image == nil ? .standard : .ambient) {
          VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
            TextField("Title", text: $title, axis: .vertical)
            Divider()
            Toggle("Include in collection", isOn: $isIncluded)
            if let error {
              Label(error, systemImage: "exclamationmark.circle")
                .font(.callout)
            }
          }
        }
      }
      .padding(style.metrics.pageInset)
    }
    .background {
      if let image {
        DesignOSMediaBackdrop { image.resizable().scaledToFill() }
      } else {
        style.palette.canvas.color
      }
    }
    .navigationTitle("Edit item")
    .toolbar {
      ToolbarItem(placement: .confirmationAction) {
        Button("Save", action: onSave).disabled(!canSave)
      }
    }
  }
}

// MARK: - Grouped management

private struct GroupedManagementRecipe: View {
  @Binding var title: String
  @Binding var isIncluded: Bool

  var body: some View {
    Form {
      Section("Details") {
        TextField("Name", text: $title)
      }
      Section {
        Toggle("Include in collection", isOn: $isIncluded)
      } header: {
        Text("Options")
      } footer: {
        Text("The consuming app supplies the effect and explanation of this option.")
      }
    }
    .formStyle(.grouped)
    .navigationTitle("Manage collection")
  }
}

// MARK: - Focused task sheet content

private struct FocusedTaskSheetRecipe: View {
  @Environment(\.designOSAppStyle) private var style
  @FocusState private var isFocused: Bool
  @Binding var value: String
  let error: String?
  let canSave: Bool
  let onCancel: () -> Void
  let onSave: () -> Void

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
        DesignOSAppSectionHeader("Name this item")
        TextField("Name", text: $value)
          .textFieldStyle(.roundedBorder)
          .focused($isFocused)
          .submitLabel(.done)
          .onSubmit {
            if canSave { onSave() }
          }
        if let error {
          Label(error, systemImage: "exclamationmark.circle").font(.callout)
        }
      }
      .padding(style.metrics.pageInset)
    }
    .safeAreaInset(edge: .bottom) {
      Button("Save", action: onSave)
        .buttonStyle(DesignOSPrimaryButtonStyle())
        .disabled(!canSave)
        .padding(style.metrics.pageInset)
        .background(style.palette.canvas.color)
    }
    .navigationTitle("Edit name")
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel", action: onCancel)
      }
    }
    .onAppear { isFocused = true }
  }
}

// MARK: - Searchable single selection

private struct SearchSelectionRecipe: View {
  let items: [RecipeItem]
  @Binding var query: String
  @Binding var selection: String?
  let onDone: () -> Void

  private var matches: [RecipeItem] {
    items.filter { query.isEmpty || $0.title.localizedCaseInsensitiveContains(query) }
  }

  var body: some View {
    List(matches, selection: $selection) { item in
      Text(item.title).tag(item.id)
    }
    .listStyle(.plain)
    .searchable(text: $query)
    .overlay {
      if matches.isEmpty {
        ContentUnavailableView.search(text: query)
      }
    }
    .navigationTitle("Choose an item")
    .toolbar {
      ToolbarItem(placement: .confirmationAction) {
        Button("Done", action: onDone).disabled(selection == nil)
      }
    }
  }
}

// MARK: - Native confirmation

private struct NativeConfirmationRecipe: View {
  @Binding var isPresented: Bool
  let consequence: String
  let onConfirm: () -> Void

  var body: some View {
    Button("Remove item", role: .destructive) { isPresented = true }
      .buttonStyle(DesignOSSecondaryButtonStyle())
      .confirmationDialog(
        "Remove item?", isPresented: $isPresented, titleVisibility: .visible
      ) {
        Button("Remove", role: .destructive, action: onConfirm)
        Button("Cancel", role: .cancel) {}
      } message: {
        Text(consequence)
      }
  }
}

// A standalone cover: no enclosing rounded parent, so no nested-radius subtraction.
// The overlay is clipped at its actual square bounds, independent of source image aspect.
private struct RecipeCover: View {
  @Environment(\.designOSAppStyle) private var style
  let image: Image

  var body: some View {
    Color.clear
      .aspectRatio(1, contentMode: .fit)
      .overlay { image.resizable().scaledToFill() }
      .clipShape(RoundedRectangle(cornerRadius: style.metrics.surfaceRadius, style: .continuous))
  }
}
