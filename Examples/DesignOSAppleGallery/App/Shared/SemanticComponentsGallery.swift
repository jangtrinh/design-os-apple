import SwiftUI

struct SemanticComponentsGallery: View {
  var body: some View {
    List {
      Section("Content components") {
        NavigationLink("List row") {
          DesignOSListRowGallery()
            .navigationTitle("List row")
        }
        NavigationLink("Sidebar row") {
          DesignOSSidebarRowGallery()
            .navigationTitle("Sidebar row")
        }
      }
    }
  }
}
