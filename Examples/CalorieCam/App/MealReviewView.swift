import SwiftUI
import CalorieCamCore
import DesignOSApple

struct MealReviewView: View {
    @State var entry: MealEntry
    @Bindable var model: JournalModel
    let preview: Image?
    let saved: () -> Void
    @State private var didSave = false
    @State private var removal: UUID?

    private var validationError: String? {
        do { try entry.validate(); return nil }
        catch { return error.localizedDescription }
    }

    var body: some View {
        Form {
            Section {
                Label(entry.origin.label, systemImage: entry.origin == .demo ? "testtube.2" : "pencil")
                    .font(.headline)
                if let preview {
                    preview.resizable().scaledToFit().frame(maxHeight: 160)
                        .accessibilityLabel("Meal photo, for your reference only")
                }
                Text(entry.origin == .demo
                     ? "Sample foods and calories. Edit before saving; demo entries count toward the total."
                     : "Review every food and portion. Calories are approximate.")
                    .foregroundStyle(DesignOSColorRole.labelSecondary.color)
                DatePicker("Meal date", selection: $entry.date)
            }
            ForEach($entry.items) { $food in
                Section("Food") {
                    FoodFields(food: $food)
                    Button("Remove food", role: .destructive) { removal = food.id }
                        .frame(minHeight: 44)
                }
            }
            Section {
                Button { entry.items.append(FoodItem(name: "", portion: "", calories: 0)) } label: {
                    Label("Add food", systemImage: "plus")
                }.frame(minHeight: 44)
                TextField("Note (optional)", text: $entry.note, axis: .vertical)
                LabeledContent("Meal total", value: entry.totalCalories.isFinite ? "\(entry.totalCalories.formatted(.number.precision(.fractionLength(0)))) kcal" : "Check calorie values")
            }
            if let validationError { Section("Check before saving") { Text(validationError) } }
            if let error = model.operationError {
                Section("Couldn’t save meal") { Text(error) }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Review meal")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save meal") {
                    guard !didSave else { return }
                    didSave = true
                    model.operationError = nil
                    if model.save(entry) { saved() }
                    else { didSave = false }
                }
                .disabled(didSave || validationError != nil || model.loadFailure != nil)
                .accessibilityIdentifier("saveMeal")
                .keyboardShortcut(.defaultAction)
            }
        }
        .confirmationDialog("Remove this food?", isPresented: Binding(get: { removal != nil }, set: { if !$0 { removal = nil } }), titleVisibility: .visible) {
            Button("Remove food", role: .destructive) {
                entry.items.removeAll { $0.id == removal }
                removal = nil
            }
            Button("Keep food", role: .cancel) { removal = nil }
        }
    }
}

/// Keep incomplete numeric text in the editor instead of silently saving the previous value.
private struct FoodFields: View {
    @Binding var food: FoodItem
    @State private var caloriesText: String

    init(food: Binding<FoodItem>) {
        _food = food
        _caloriesText = State(initialValue: food.wrappedValue.calories.formatted(.number.grouping(.never)))
    }

    var body: some View {
        TextField("Food name", text: $food.name)
            .frame(minHeight: 44)
            .accessibilityIdentifier("foodName")
        TextField("Portion", text: $food.portion)
            .frame(minHeight: 44)
            .accessibilityIdentifier("foodPortion")
        HStack {
            Text("Calories (kcal)")
            TextField("Calories (kcal)", text: $caloriesText)
                .multilineTextAlignment(.trailing)
                #if os(iOS)
                .keyboardType(.decimalPad)
                #endif
                .frame(minHeight: 44)
                .accessibilityIdentifier("foodCalories")
                .onChange(of: caloriesText) { _, value in
                    let normalized = value.replacingOccurrences(of: Locale.current.decimalSeparator ?? ".", with: ".")
                    food.calories = Double(normalized) ?? .nan
                }
        }
    }
}
