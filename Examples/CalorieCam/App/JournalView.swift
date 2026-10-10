import SwiftUI
import DesignOSApple
import CalorieCamCore

struct JournalView: View {
    @Environment(\.designOSAppStyle) private var style
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Bindable var model: JournalModel
    @State private var day = Date()
    @State private var selection: UUID?
    @State private var isAdding = false
    @State private var deletion: MealEntry?

    private var meals: [MealEntry] { model.meals(on: day) }
    private var selected: MealEntry? { meals.first { $0.id == selection } }

    var body: some View {
        let separatorInset: CGFloat = dynamicTypeSize.isAccessibilitySize ? 0 : style.metrics.mediaSize + style.metrics.itemSpacing
        NavigationSplitView {
            List(selection: $selection) {
                Section {
                    VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
                        DesignOSAppSectionHeader("Your meals") {
                            DatePicker("Journal date", selection: $day, displayedComponents: .date)
                                .labelsHidden()
                                .accessibilityLabel("Journal date")
                                .accessibilityIdentifier("journalDate")
                        }
                        Text("\(meals.reduce(0) { $0 + $1.totalCalories }, format: .number.precision(.fractionLength(0))) kcal logged")
                            .font(.subheadline)
                            .monospacedDigit()
                            .foregroundStyle(style.palette.secondaryInk.color)
                        if meals.contains(where: { $0.origin == .demo }) {
                            Text("Includes sample demo values")
                                .font(.caption)
                                .foregroundStyle(style.palette.secondaryInk.color)
                        }
                    }
                    .padding(.vertical, style.metrics.itemSpacing)
                    .listRowSeparator(.hidden)
                }
                if let failure = model.loadFailure {
                    Section("Journal unavailable") {
                        Text(failure)
                        Button("Try opening again") { model.reload() }
                            .buttonStyle(DesignOSSecondaryButtonStyle())
                    }
                } else if meals.isEmpty {
                    ContentUnavailableView {
                        Label("No meals logged", systemImage: "fork.knife")
                    } description: {
                        Text("Add a photo or enter a meal to start this day’s journal.")
                    } actions: {
                        Button("Add meal") { isAdding = true }
                            .buttonStyle(DesignOSPrimaryButtonStyle())
                            .accessibilityIdentifier("emptyAddMeal")
                    }
                } else {
                    Section {
                        ForEach(meals) { meal in
                            NavigationLink(value: meal.id) {
                                MealRow(meal: meal, isSelected: selection == meal.id)
                            }
                            .accessibilityIdentifier("savedMeal-\(meal.id.uuidString)")
                            .listRowInsets(EdgeInsets(top: 0, leading: style.metrics.pageInset, bottom: 0, trailing: style.metrics.pageInset))
                            .listRowSeparatorTint(style.palette.separator.color)
                            .alignmentGuide(.listRowSeparatorLeading) { _ in
                                separatorInset
                            }
                            .contextMenu {
                                Button("Delete meal", role: .destructive) { deletion = meal }
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(style.palette.canvas.color)
            .navigationTitle("CalorieCam")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .navigationSplitViewColumnWidth(min: 280, ideal: 360)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { isAdding = true } label: { Label("Add meal", systemImage: "plus") }
                        .disabled(model.loadFailure != nil)
                        .accessibilityIdentifier("addMeal")
                }
            }
        } detail: {
            if let meal = selected {
                MealDetailView(meal: meal) { deletion = meal }
            } else {
                ContentUnavailableView("Your meal journal", systemImage: "book.closed", description: Text("Select a meal to see its foods and portions."))
            }
        }
        .onChange(of: day) { _, _ in selection = nil }
        .sheet(isPresented: $isAdding) {
            CaptureMealView(model: model, journalDay: day)
        }
        .confirmationDialog("Delete this meal?", isPresented: Binding(get: { deletion != nil }, set: { if !$0 { deletion = nil } }), titleVisibility: .visible) {
            Button("Delete meal", role: .destructive) {
                if let deletion { model.delete(deletion) }
                deletion = nil
            }
            Button("Keep meal", role: .cancel) { deletion = nil }
        } message: { Text("The meal will be removed from your local journal. This cannot be undone.") }
        .alert("Journal update failed", isPresented: Binding(get: { model.operationError != nil }, set: { if !$0 { model.operationError = nil } })) {
            Button("OK") { model.operationError = nil }
        } message: { Text(model.operationError ?? "") }
    }
}

private struct MealRow: View {
    @Environment(\.designOSAppStyle) private var style
    let meal: MealEntry
    let isSelected: Bool
    // Native selection can use an accent or inactive highlight independent of tint.
    // Leave selected text automatic so the platform supplies its matching foreground.
    @ViewBuilder private func rowText(_ text: Text, secondary: Bool = false) -> some View {
        if isSelected { text }
        else { text.foregroundStyle(secondary ? style.palette.secondaryInk.color : style.palette.ink.color) }
    }
    var body: some View {
        DesignOSMediaRow {
            if meal.origin == .demo {
                if let image = DemoMealAsset.image {
                    image.resizable().scaledToFill()
                        .accessibilityLabel("Sample meal illustration")
                } else {
                    Text("Sample image unavailable").font(.caption)
                }
            } else {
                // Real photos are not persisted. Text-only records get an honest symbol.
                ZStack {
                    style.palette.subtleSurface.color
                    Image(systemName: "fork.knife")
                        .font(.title2)
                        .foregroundStyle(style.palette.secondaryInk.color)
                }
                .accessibilityHidden(true)
            }
        } content: {
            VStack(alignment: .leading, spacing: style.profile.spacing.titleSubtitle) {
                rowText(Text(meal.items.map(\.name).joined(separator: ", ")))
                    .font(.body.weight(.medium))
                rowText(Text(meal.date, format: .dateTime.hour().minute()), secondary: true)
                    .font(.subheadline)
                rowText(Text("\(meal.totalCalories.formatted(.number.precision(.fractionLength(0)))) kcal"))
                    .font(.subheadline)
                    .monospacedDigit()
                rowText(Text(meal.origin.label), secondary: true)
                    .font(.caption)
            }
        }
        .padding(.vertical, style.metrics.itemSpacing)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(meal.items.map(\.name).joined(separator: ", ")), \(meal.date.formatted(date: .abbreviated, time: .shortened)), \(meal.totalCalories.formatted(.number.precision(.fractionLength(0)))) kcal, \(meal.origin.label)")
    }
}
