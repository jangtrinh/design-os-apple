import SwiftUI
import CalorieCamCore
import DesignOSApple

struct MealReviewView: View {
    @Environment(\.designOSAppStyle) private var style
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
        ScrollView {
            VStack(alignment: .leading, spacing: style.metrics.sectionSpacing) {
                if let preview {
                    MealPhotoCover(image: preview, label: "Meal photo, for your reference only")
                }
                DesignOSAppSurface(tone: .ambient) {
                    VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
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
                }
                ForEach($entry.items) { $food in
                    VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
                        Text("Food").font(.headline).accessibilityAddTraits(.isHeader)
                        DesignOSAppSurface(tone: .ambient) {
                            VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
                                FoodFields(food: $food)
                                Button("Remove food", role: .destructive) { removal = food.id }
                                    .buttonStyle(DesignOSSecondaryButtonStyle())
                            }
                        }
                    }
                }
                DesignOSAppSurface(tone: .ambient) {
                    VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
                        Button { entry.items.append(FoodItem(name: "", portion: "", calories: 0)) } label: {
                            Label("Add food", systemImage: "plus")
                        }.buttonStyle(DesignOSSecondaryButtonStyle())
                        TextField("Note (optional)", text: $entry.note, axis: .vertical)
                        LabeledContent("Meal total", value: entry.totalCalories.isFinite ? "\(entry.totalCalories.formatted(.number.precision(.fractionLength(0)))) kcal" : "Check calorie values")
                    }
                }
                if let validationError {
                    VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
                        Text("Check before saving").font(.headline).accessibilityAddTraits(.isHeader)
                        Text(validationError)
                    }
                }
                if let error = model.operationError {
                    VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
                        Text("Couldn’t save meal").font(.headline).accessibilityAddTraits(.isHeader)
                        Text(error)
                    }
                }
            }
            .padding(style.metrics.pageInset)
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)
        }
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
        VStack(spacing: 0) {
            LabeledContent("Food name") {
                TextField("Food name", text: $food.name)
                    .labelsHidden()
                    .accessibilityLabel("Food name")
                    .focused($focusedField, equals: .name)
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(.trailing)
                    .frame(minHeight: 44)
                    .accessibilityIdentifier("foodName")
            }
            .contentShape(Rectangle())
            .onTapGesture { focusedField = .name }
            Divider()
            LabeledContent("Portion") {
                TextField("Portion", text: $food.portion)
                    .labelsHidden()
                    .accessibilityLabel("Portion")
                    .focused($focusedField, equals: .portion)
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(.trailing)
                    .frame(minHeight: 44)
                    .accessibilityIdentifier("foodPortion")
            }
            .contentShape(Rectangle())
            .onTapGesture { focusedField = .portion }
            Divider()
            LabeledContent("Calories (kcal)") {
                TextField("Calories (kcal)", text: $caloriesText)
                    .focused($focusedField, equals: .calories)
                    .labelsHidden()
                    .accessibilityLabel("Calories (kcal)")
                    .textFieldStyle(.plain)
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
            .contentShape(Rectangle())
            .onTapGesture { focusedField = .calories }
        }
        #if os(iOS)
        .toolbar {
            if focusedField != nil {
                ToolbarItemGroup(placement: .keyboard) {
                    if focusedField == .calories {
                        Button("Clear calories") { caloriesText = "" }
                            .accessibilityIdentifier("clearCalories")
                    }
                    Spacer()
                    Button("Done") { focusedField = nil }
                        .accessibilityIdentifier("finishFoodEditing")
                }
            }
        }
        #endif
    }
}
