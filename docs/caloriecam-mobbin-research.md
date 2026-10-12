# CalorieCam: small, native food-logging flow

Research date: 2026-10-10. Source: Mobbin MCP `search_flows` and `search_screens`, platform iOS. Returned image previews were inspected. These are interaction references, not evidence about the source apps' implementation frameworks. No reference imagery or branded assets are copied into CalorieCam.

## Two useful references

### MyFitnessPal: review before committing

[Scanning a meal](https://mobbin.com/flows/e5e452d7-f91e-4939-9fa0-59ea87b7d47a)

Observed in flow previews: the review surface lists Potato, Green onions, Bacon, and Egg. Each row shows calories and a human-readable portion, with a delete action. A single “Log breakfast” button commits the meal. The last preview returns to Today, updates the calorie total, shows the diary, and displays “Breakfast logged!”

Decision: keep the captured photo and editable meal facts together before Save. After saving, return directly to the journal and show the new entry and updated total. Avoid a separate celebratory confirmation page or wizard. An entry must not count toward totals before it is saved.

Native equivalents: `NavigationStack`, `List` with `Section`, a sheet containing `Form`, toolbar Cancel/Save actions, and native row editing/swipe actions. These are recommendations, not claims about MyFitnessPal's code.

### Yazio: clear image source and explicit portion correction

- [AI camera](https://mobbin.com/screens/660a22dd-cf3b-453f-a96f-9648745a0599): visible framing corners, a large shutter, Photos and Flash actions, and short instructions to keep the meal well lit and within the frame.
- [Picture source action sheet](https://mobbin.com/screens/5ddbe2cf-23e8-4408-90ae-869f4305ea6c): “Choose picture,” “Take picture,” and “Cancel.”
- [Banana portion editor](https://mobbin.com/screens/718af603-cfe1-4ce2-966f-92d6d2c58531): a compact quantity/serving row above a single Save button, with a wheel-style quantity and serving selector expanded below.
- [Recipe portion row](https://mobbin.com/screens/1a739003-3276-4202-b928-60c7491a35d3): photo and food title above nutrition facts, then “1 Serving (205 g)” with a single Add button.
- [AI camera logging flow](https://mobbin.com/flows/0b1a85b5-c663-4c49-b613-aed10479d33a): inspected previews include an “Analyzing…” photo state and a final meal list with food names and calorie values. The intermediate result-editing screens were not all returned as previews, so no precise behavior is inferred for those screens.

Decision: one obvious Add meal action, with camera and library choices. Preserve the chosen image while reviewing. Make portions and calories editable in one place, without adding barcode scanning, recipe discovery, macro dashboards, or meal-planning tabs.

Native equivalents: `confirmationDialog` for source selection, `PhotosPicker` for library selection, the system camera where supported, and labeled `TextField` controls in a `Form`. A `Stepper` or `Picker` is suitable only if the data model has explicit serving units and a known per-serving calorie value. Free-text portions must not silently imply automatic calorie recalculation.

## Proposed minimal journey

1. Journal: today's total and a short chronological list of meals, with one Add meal action.
2. Add meal: choose camera, library, or manual entry. If camera access is denied or hardware unavailable, keep library/manual paths available.
3. Review: photo if present, meal name, portion, calories, and date/time. Native Cancel and Save. Validate required fields and finite positive calories.
4. Save: dismiss back to the journal, immediately show the entry and recalculate the total. Selecting an entry edits it. Deleting updates totals.

The journal doubles as the home screen; a separate dashboard is unnecessary. A native date picker can support other dates if the implemented scope includes history. A single primary flow is preferable to multiple competing navigation surfaces.

## Honesty and accessibility

- Actual AI analysis is not configured. Do not present generated calories as photo recognition. A real photo can accompany manually entered nutrition. Any demo estimate must be explicitly labeled as a sample and editable before saving.
- Use a real `ProgressView` only for an actual asynchronous operation, never a simulated analysis sequence.
- Use system text styles, Dynamic Type, semantic colors, standard touch targets, accessible labels, and native focus/keyboard behavior.
- Color and images are supplementary; the food name, portion, calories, and action labels must remain understandable without them.

## Deliberate exclusion

An [Oura logging flow](https://mobbin.com/flows/2525850e-700c-42a1-94b3-4297f7f8ce3a) was also inspected. Its preview contains a larger quick-action menu, an analysis loading state, and a meal-quality trend view. Those surfaces are unnecessary for this calorie journal, so they are not adopted.
