import Foundation

enum LocalDemoSection: String, CaseIterable {
  case assistants = "Assistants"
  case mobility = "Mobility"
  case entertainment = "Entertainment"
}

enum LocalDemoDistribution: String {
  case localOnly
}

enum LocalDemoTint: String {
  case amber
  case spectral
  case flightBlue
  case cityGreen
  case cinemaRed
  case electricBlue
}

struct LocalDemoStateDefinition: Equatable {
  let id: String
  let title: String
  let view: String
}

struct LocalDemoDefinition: Identifiable {
  let id: String
  let section: LocalDemoSection
  let title: String
  let flowLabel: String
  let symbolName: String
  let imageAssetName: String
  let tint: LocalDemoTint
  let entryDestination: LocalDemoDestination
  let detailDestination: LocalDemoDestination
  let states: [LocalDemoStateDefinition]
  let patterns: [String]
  let nativeAPIs: [String]
  let sourcePaths: [String]
  let assetNames: [String]
  let platforms: [String]
  let distribution: LocalDemoDistribution
}

extension LocalDemoDefinition {
  static let all = assistantDefinitions + mobilityDefinitions + entertainmentDefinitions
  static let applePlatforms = ["iOS", "iPadOS", "macOS"]
  static let sharedMotionPaths = [
    "App/Shared/Flows/LocalDemoNavigationMotion.swift",
    "App/Shared/Flows/LocalDemoInteractionMotion.swift",
    "App/Shared/Flows/LocalDemoPasteboard.swift",
  ]

  static func demos(in section: LocalDemoSection) -> [Self] {
    all.filter { $0.section == section }
  }
}
