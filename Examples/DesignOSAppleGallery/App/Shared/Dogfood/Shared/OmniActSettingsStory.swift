import SwiftUI

struct OmniActSettingsStory: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @State private var values = OmniActSettingsValues()

  var body: some View {
    if horizontalSizeClass == .compact {
      settingsForm
    } else {
      NavigationSplitView {
        List {
          Label("General", systemImage: "gearshape")
          Label("Provider", systemImage: "sparkles")
        }
        .navigationTitle("OmniAct")
      } detail: {
        settingsForm
      }
    }
  }

  private var settingsForm: some View {
    Form {
      Section("General") {
        Toggle("Launch at login", isOn: $values.launchAtLogin)
        Toggle("Check for updates", isOn: $values.updatesEnabled)
      }
      Section("Provider") {
        LabeledContent("Status", value: values.providerName)
      }
      Section {
        HStack {
          Button("Test connection") {}
          Spacer()
          Button("Save") {}
            .buttonStyle(.borderedProminent)
        }
      }
    }
    .formStyle(.grouped)
    .navigationTitle("Settings")
  }
}
