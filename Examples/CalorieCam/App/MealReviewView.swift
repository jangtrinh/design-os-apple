import SwiftUI
import CalorieCamCore
import DesignOSApple

struct MealReviewView: View {
    @Environment(\.designOSAppStyle) private var style
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var contrast
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
            if let preview {
                Section {
                    preview.resizable().scaledToFit().frame(maxWidth: .infinity, maxHeight: 280)
                        .clipShape(RoundedRectangle(cornerRadius: style.metrics.surfaceRadius))
                        .accessibilityLabel("Meal photo, for your reference only")
                }
                .listRowBackground(Color.clear)
            }
            Section {
                Label(entry.origin.label, systemImage: entry.origin == .demo ? "testtube.2" : "pencil")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(style.palette.secondaryInk.color)
                if entry.origin == .demo {
                    Text("Sample values, not a photo analysis. Review before saving.")
                        .font(.footnote)
                        .foregroundStyle(style.palette.secondaryInk.color)
                }
                DatePicker("Meal date", selection: $entry.date)
            }
            .listRowBackground(rowBackground)
            ForEach($entry.items) { $food in
                Section("Food") {
                    FoodFields(food: $food)
                    Button("Remove food", role: .destructive) { removal = food.id }
                        .frame(minHeight: 44)
                }
                .listRowBackground(rowBackground)
            }
            Section {
                Button { entry.items.append(FoodItem(name: "", portion: "", calories: 0)) } label: {
                    Label("Add food", systemImage: "plus")
                }.frame(minHeight: 44)
                TextField("Note (optional)", text: $entry.note, axis: .vertical)
                LabeledContent("Meal total", value: entry.totalCalories.isFinite ? "\(entry.totalCalories.formatted(.number.precision(.fractionLength(0)))) kcal" : "Check calorie values")
            }
            .listRowBackground(rowBackground)
            if let validationError {
                Section("Check before saving") { Text(validationError) }
                    .listRowBackground(rowBackground)
            }
            if let error = model.operationError {
                Section("Couldn’t save meal") { Text(error) }
                    .listRowBackground(rowBackground)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .background { MealPhotoBackdrop(preview: preview) }
        .accessibilityIdentifier("mealReviewForm")
        .navigationTitle("Review meal")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
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

    @ViewBuilder private var rowBackground: some View {
        if reduceTransparency || contrast == .increased {
            style.palette.surface.color
        } else {
            Rectangle().fill(.ultraThinMaterial)
        }
    }
}

/// Keep incomplete numeric text in the editor instead of silently saving the previous value.
private struct FoodFields: View {
    @Binding var food: FoodItem
    @State private var caloriesText: String
    @FocusState private var focusedField: Field?
    private enum Field: Hashable { case name, portion, calories }

    init(food: Binding<FoodItem>) {
        _food = food
        _caloriesText = State(initialValue: food.wrappedValue.calories.formatted(.number.grouping(.never)))
    }

    var body: some View {
        TextField("Food name", text: $food.name)
            .focused($focusedField, equals: .name)
            .frame(minHeight: 44)
            .accessibilityIdentifier("foodName")
        TextField("Portion", text: $food.portion)
            .focused($focusedField, equals: .portion)
            .frame(minHeight: 44)
            .accessibilityIdentifier("foodPortion")
        HStack {
            Text("Calories (kcal)")
            TextField("Calories (kcal)", text: $caloriesText)
                .focused($focusedField, equals: .calories)
                .labelsHidden()
                .accessibilityLabel("Calories (kcal)")
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
        #if os(iOS)
        .toolbar {
            if focusedField != nil {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focusedField = nil }
                        .accessibilityIdentifier("finishFoodEditing")
                }
            }
        }
        #endif
    }
}
