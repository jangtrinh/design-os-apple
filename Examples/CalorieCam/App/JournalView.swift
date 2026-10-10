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
                                MealRow(meal: meal)
                            }
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
                List {
                    if meal.origin == .demo {
                        Section {
                            VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
                                Image("DemoMeal").resizable().scaledToFit()
                                    .frame(maxWidth: .infinity, maxHeight: 320)
                                    .clipShape(RoundedRectangle(cornerRadius: style.metrics.surfaceRadius))
                                    .accessibilityLabel("Sample meal illustration")
                                Text("Sample illustration · original photo not stored")
                                    .font(.caption)
                                    .foregroundStyle(style.palette.secondaryInk.color)
                            }
                        }
                        .listRowSeparator(.hidden)
                    }
                    Section {
                        Text(meal.origin.label).foregroundStyle(DesignOSColorRole.labelSecondary.color)
                        Text(meal.date, format: .dateTime.month().day().hour().minute())
                        LabeledContent("Total", value: "\(meal.totalCalories.formatted(.number.precision(.fractionLength(0)))) kcal")
                    }
                    Section("Foods") {
                        ForEach(meal.items) { food in
                            LabeledContent {
                                Text("\(food.calories.formatted(.number.precision(.fractionLength(0)))) kcal")
                                    .accessibilityIdentifier("mealDetailCalories")
                            } label: {
                                Text(food.name)
                                    .accessibilityIdentifier("mealDetailFoodName")
                                Text(food.portion).foregroundStyle(.secondary)
                                    .accessibilityIdentifier("mealDetailPortion")
                            }
                        }
                    }
                    if !meal.note.isEmpty { Section("Note") { Text(meal.note) } }
                    Section {
                        Button("Delete meal", role: .destructive) { deletion = meal }
                            .frame(minHeight: 44)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(style.palette.canvas.color)
                .navigationTitle("Meal details")
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
    var body: some View {
        DesignOSMediaRow {
            if meal.origin == .demo {
                Image("DemoMeal").resizable().scaledToFill()
                    .accessibilityLabel("Sample meal illustration")
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
                Text(meal.items.map(\.name).joined(separator: ", "))
                    .font(.body.weight(.medium))
                    .foregroundStyle(style.palette.ink.color)
                Text(meal.date, format: .dateTime.hour().minute())
                    .font(.subheadline)
                    .foregroundStyle(style.palette.secondaryInk.color)
                Text("\(meal.totalCalories.formatted(.number.precision(.fractionLength(0)))) kcal")
                    .font(.subheadline)
                    .monospacedDigit()
                Text(meal.origin.label)
                    .font(.caption)
                    .foregroundStyle(style.palette.secondaryInk.color)
            }
        }
        .padding(.vertical, style.metrics.itemSpacing)
        .accessibilityElement(children: .combine)
    }
}
