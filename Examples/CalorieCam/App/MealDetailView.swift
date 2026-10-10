import SwiftUI
import DesignOSApple
import CalorieCamCore

/// A native scrolling detail surface. Only demo records have a bundled illustration;
/// manual/remote records remain honest text records because personal photos aren't kept.
struct MealDetailView: View {
    @Environment(\.designOSAppStyle) private var style
    @Environment(\.colorScheme) private var inheritedColorScheme
    let meal: MealEntry
    let delete: () -> Void
    private var preview: Image? { meal.origin == .demo ? DemoMealAsset.image : nil }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: style.metrics.sectionSpacing) {
                if let preview {
                    VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
                        MealPhotoCover(image: preview, maximumSize: 360, label: "Sample meal illustration", identifier: "sampleDetailImage")
                        Text("Sample illustration · original photo not stored")
                            .font(.caption)
                            .foregroundStyle(style.palette.secondaryInk.color)
                    }
                }
                VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
                    Text(meal.items.map(\.name).joined(separator: ", "))
                        .font(.title2.weight(.semibold))
                        .accessibilityAddTraits(.isHeader)
                    Text(meal.date, format: .dateTime.month().day().hour().minute())
                        .foregroundStyle(style.palette.secondaryInk.color)
                    Text(meal.origin.label)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(style.palette.secondaryInk.color)
                    Text("\(meal.totalCalories.formatted(.number.precision(.fractionLength(0)))) kcal")
                        .font(.headline)
                        .monospacedDigit()
                }
                DesignOSAppSurface(tone: .ambient) {
                    VStack(alignment: .leading, spacing: style.metrics.contentInset) {
                        Text("Foods").font(.headline).accessibilityAddTraits(.isHeader)
                        ForEach(meal.items) { food in
                            LabeledContent {
                                Text("\(food.calories.formatted(.number.precision(.fractionLength(0)))) kcal")
                                    .accessibilityIdentifier("mealDetailCalories")
                            } label: {
                                Text(food.name).accessibilityIdentifier("mealDetailFoodName")
                                Text(food.portion)
                                    .foregroundStyle(style.palette.secondaryInk.color)
                                    .accessibilityIdentifier("mealDetailPortion")
                            }
                            .accessibilityElement(children: .contain)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                if !meal.note.isEmpty {
                    VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
                        Text("Note").font(.headline).accessibilityAddTraits(.isHeader)
                        Text(meal.note).foregroundStyle(style.palette.secondaryInk.color)
                    }
                }
                Button("Delete meal", role: .destructive, action: delete)
                    .buttonStyle(DesignOSSecondaryButtonStyle())
            }
            .padding(style.metrics.pageInset)
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)
        }
        .foregroundStyle(style.palette.ink.color)
        .background { MealPhotoBackdrop(preview: preview) }
        .navigationTitle("Meal details")
        .environment(\.colorScheme, preview == nil ? inheritedColorScheme : .dark)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(preview == nil ? nil : .dark, for: .navigationBar)
        #endif
    }
}
