import DesignOSAppleCatalog
import Testing

@Test("The release catalog admits every closed story ID exactly once")
func releaseCandidateDescriptorsAreAdmitted() {
  let descriptors = DesignOSReleaseCatalog.stories
  #expect(descriptors.map(\.id) == DesignOSStoryID.allCases)
  #expect(Set(descriptors.map(\.id)).count == descriptors.count)
  #expect(descriptors.count == 33)
  #expect(
    descriptors.first(where: { $0.id == .omniactSettingsShell })?.runtimeDeliverableID
      == .listSidebarAndDisclosure)
  #expect(
    descriptors.first(where: { $0.id == .omniactCommandRow })?.runtimeDeliverableID
      == .designOSListRow)
  #expect(
    descriptors.first(where: { $0.id == .omniactHUDAutocompleteMaterial })?.runtimeDeliverableID
      == .materialAndGlassSurface)
  #expect(
    descriptors.first(where: { $0.id == .tocchienDictionarySearch })?.runtimeDeliverableID
      == .textSearchAndKeyboardInput)
  #expect(
    descriptors.first(where: { $0.id == .tocchienNavigationTabs })?.runtimeDeliverableID
      == .navigationTabsAndToolbars)
  #expect(descriptors.filter { $0.runtimeDeliverableID != nil }.count == 32)
  #expect(descriptors.filter { $0.owner == .runtimeImplementation }.count == 32)
  #expect(
    descriptors.first(where: { $0.id == .tocchienChampionHeroNegativeControl })?
      .runtimeDeliverableID
      == nil)
  #expect(
    descriptors.first(where: { $0.id == .tocchienChampionHeroNegativeControl })?.owner
      == .appSpecific)
  for descriptor in descriptors {
    #expect(!descriptor.examplePath.isEmpty)
    #expect(
      descriptor.owner
        == (descriptor.runtimeDeliverableID == nil ? .appSpecific : .runtimeImplementation))
  }
  for deliverableID in descriptors.compactMap(\.runtimeDeliverableID) {
    deliverableID.resolvesCompiledRuntimeSymbol()
  }
}

@Test("The dogfood pilot preserves its original six-story evidence boundary")
func dogfoodPilotPreservesOriginalStorySet() {
  #expect(
    DesignOSPilotCatalog.admittedStories.map(\.id) == [
      .omniactSettingsShell,
      .omniactCommandRow,
      .omniactHUDAutocompleteMaterial,
      .tocchienDictionarySearch,
      .tocchienNavigationTabs,
      .tocchienChampionHeroNegativeControl,
    ])
}
