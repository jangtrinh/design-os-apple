# ``NativeTextSearchAndKeyboardInputRecipe``

Use `TextField`, `.searchable`, and product-required `FocusState` directly. The caller owns text and focus bindings while the operating system owns keyboard presentation, selection, dictation, paste, and safe-area behavior.

## Optional editorial appearance

Apply `DesignOSAppTextFieldModifier` directly to a standalone native `TextField` or
`SecureField` when the editorial filled-field appearance is appropriate. Use the multiline
variant for expanding text. Keep inline Form rows plain. Labels, values, focus, keyboard,
validation messages and secure entry remain native or caller-owned. See
`docs/reusable-app-style.md` for reference provenance and verification requirements.
