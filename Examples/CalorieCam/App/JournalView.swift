import SwiftUI
import DesignOSApple
import CalorieCamCore

struct JournalView: View {
    @Bindable var model: JournalModel
    @State private var day = Date()
    @State private var selection: UUID?
    @State private var isAdding = false
    @State private var deletion: MealEntry?

    private var meals: [MealEntry] { model.meals(on: day) }
    private var selected: MealEntry? { meals.first { $0.id == selection } }

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                Section {
                    DatePicker("Journal date", selection: $day, displayedComponents: .date)
                        .accessibilityIdentifier("journalDate")
                    LabeledContent("Logged total") {
                        Text("\(meals.reduce(0) { $0 + $1.totalCalories }, format: .number.precision(.fractionLength(0))) kcal")
                            .monospacedDigit()
                    }
                    Text("Includes any saved demo entries. Calories are approximate, not a daily target.")
                        .font(.footnote)
                        .foregroundStyle(DesignOSColorRole.labelSecondary.color)
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
                            .frame(minHeight: 44)
                            .accessibilityIdentifier("emptyAddMeal")
                    }
                } else {
                    Section("Meals") {
                        ForEach(meals) { meal in
                            NavigationLink(value: meal.id) {
                                MealRow(meal: meal)
                            }
                            .contextMenu {
                                Button("Delete meal", role: .destructive) { deletion = meal }
                            }
                        }
                    }
                }
            }
            .navigationTitle("CalorieCam")
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
                    Section {
                        Text(meal.origin.label).foregroundStyle(DesignOSColorRole.labelSecondary.color)
                        Text(meal.date, format: .dateTime.month().day().hour().minute())
                        LabeledContent("Total", value: "\(meal.totalCalories.formatted(.number.precision(.fractionLength(0)))) kcal")
                    }
                    Section("Foods") {
                        ForEach(meal.items) { food in
                            LabeledContent {
                                Text("\(food.calories.formatted(.number.precision(.fractionLength(0)))) kcal")
                            } label: {
                                Text(food.name)
                                Text(food.portion).foregroundStyle(.secondary)
                            }
                        }
                    }
                    if !meal.note.isEmpty { Section("Note") { Text(meal.note) } }
                    Section {
                        Button("Delete meal", role: .destructive) { deletion = meal }
                            .frame(minHeight: 44)
                    }
                }
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
    let meal: MealEntry
    var body: some View {
        DesignOSListRow {
            Image(systemName: "fork.knife").accessibilityHidden(true)
        } title: {
            Text(meal.items.map(\.name).joined(separator: ", "))
        } subtitle: {
            Text(meal.origin.label)
        } trailing: {
            Text("\(meal.totalCalories.formatted(.number.precision(.fractionLength(0)))) kcal")
                .monospacedDigit()
        }
        .frame(minHeight: 44)
        .accessibilityElement(children: .combine)
    }
}
