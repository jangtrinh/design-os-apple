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
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
                    Text("Foods").font(.headline).accessibilityAddTraits(.isHeader)
                    ForEach($entry.items) { $food in
                        DesignOSAppSurface(tone: .ambient) {
                            VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
                                HStack {
                                    Text("Item \((entry.items.firstIndex(where: { $0.id == food.id }) ?? 0) + 1)")
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(style.palette.secondaryInk.color)
                                    Spacer()
                                    Menu {
                                        Button("Remove food", role: .destructive) { removal = food.id }
                                    } label: {
                                        Label("Food actions", systemImage: "ellipsis")
                                            .labelStyle(.iconOnly)
                                            .frame(minWidth: 44, minHeight: 44)
                                    }
                                    .buttonStyle(.bordered)
                                    .buttonBorderShape(.capsule)
                                    .accessibilityLabel("Actions for \(food.name.isEmpty ? "unnamed food" : food.name)")
                                }
                                FoodFields(food: $food)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
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
                    Text(validationError)
                        .font(.footnote)
                        .foregroundStyle(style.palette.secondaryInk.color)
                        .accessibilityIdentifier("mealValidationSummary")
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
                #if os(macOS)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                #endif
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
    @State private var editedName = false
    @State private var editedCalories = false
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
                    .onChange(of: food.name) { _, _ in editedName = true }
            }
            .contentShape(Rectangle())
            .onTapGesture { focusedField = .name }
            if editedName && food.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text("Enter a food name.")
                    .font(.caption)
                    .accessibilityIdentifier("foodNameError")
                    .padding(.bottom, 8)
            }
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
                        editedCalories = true
                        let normalized = value.replacingOccurrences(of: Locale.current.decimalSeparator ?? ".", with: ".")
                        food.calories = Double(normalized) ?? .nan
                    }
            }
            .contentShape(Rectangle())
            .onTapGesture { focusedField = .calories }
            if editedCalories && (!food.calories.isFinite || !(0...10_000).contains(food.calories)) {
                Text("Enter calories from 0 to 10,000.")
                    .font(.caption)
                    .accessibilityIdentifier("foodCaloriesError")
                    .padding(.bottom, 8)
            }
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
