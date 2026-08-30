/// Metadata anchor for client-owned native text, search, focus, and keyboard input.
///
/// Use `TextField`, `searchable`, and product-required `FocusState` calls directly in a
/// native form, list, or navigation container. The caller owns text and focus bindings;
/// the operating system owns keyboard presentation, selection, dictation, paste, safe
/// areas, and hardware-input conventions. Visible labels and placeholders must provide
/// accessible names and native values. The APIs are available at the package floors.
public enum NativeTextSearchAndKeyboardInputRecipe {}
