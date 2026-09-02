import DesignOSApple
import SwiftUI

struct OmniActCommandRowStory: View {
  @Environment(\.designOSProfile) private var profile
  @State private var isEnabled = true
  @State private var lastAction = "No recent action"

  var body: some View {
    Form {
      Section("Commands") {
        DesignOSListRow {
          Image(systemName: "text.badge.checkmark")
            .foregroundStyle(.tint)
            .accessibilityHidden(true)
        } title: {
          Text("Polish selected text")
            .font(DesignOSTypographyRole.headline.font(profile: profile))
        } subtitle: {
          Text("\(isEnabled ? "Enabled" : "Disabled") · \(lastAction)")
            .font(DesignOSTypographyRole.caption.font(profile: profile))
        } trailing: {
          Toggle("Enable Polish selected text", isOn: $isEnabled)
            .labelsHidden()
            .toggleStyle(.switch)
            .accessibilityLabel("Polish selected text enabled")
          Menu {
            Button("Edit") { lastAction = "Edit opened" }
            Button("Duplicate") { lastAction = "Command duplicated" }
          } label: {
            Image(systemName: "ellipsis.circle")
              .frame(minWidth: 44, minHeight: 44)
          }
          .accessibilityLabel("Actions for Polish selected text")
        }
      }
    }
    .formStyle(.grouped)
    .navigationTitle("Command library")
  }
}
