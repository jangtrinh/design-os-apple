extension LocalDemoDefinition {
  static let assistantDefinitions: [Self] = [
    .init(
      id: "demo.assistant.thoughtful-chat", section: .assistants,
      title: "Thoughtful Chat", flowLabel: "New conversation → working thread",
      symbolName: "text.bubble.fill", imageAssetName: "demo-thoughtful-chat-thumbnail",
      tint: .amber, entryDestination: .thoughtfulChatHome,
      detailDestination: .thoughtfulChatThread,
      states: [
        .init(
          id: "thoughtful-chat.new-conversation", title: "New conversation",
          view: "ThoughtfulChatHomeDemoView"),
        .init(
          id: "thoughtful-chat.working-thread", title: "Working thread",
          view: "ThoughtfulChatThreadDemoView"),
      ],
      patterns: ["Editorial assistant home", "Long-form response thread"],
      nativeAPIs: ["ScrollView", "NavigationLink", "safeAreaInset", "Button"],
      sourcePaths: thoughtfulChatPaths,
      assetNames: ["demo-thoughtful-chat-thumbnail"],
      platforms: applePlatforms, distribution: .localOnly),
    .init(
      id: "demo.assistant.visual", section: .assistants,
      title: "Visual Assistant", flowLabel: "Prompt home → answer canvas",
      symbolName: "sparkles", imageAssetName: "demo-visual-assistant-thumbnail",
      tint: .spectral, entryDestination: .visualAssistantHome,
      detailDestination: .visualAssistantAnswer,
      states: [
        .init(
          id: "visual-assistant.prompt-home", title: "Prompt home",
          view: "VisualAssistantHomeDemoView"),
        .init(
          id: "visual-assistant.answer-canvas", title: "Answer canvas",
          view: "VisualAssistantAnswerDemoView"),
      ],
      patterns: ["Spectral prompt home", "Grounded multimodal answer"],
      nativeAPIs: ["ScrollView", "NavigationLink", "Image", "safeAreaInset"],
      sourcePaths: visualAssistantPaths,
      assetNames: ["demo-visual-assistant-thumbnail", "visual-assistant-answer-art"],
      platforms: applePlatforms, distribution: .localOnly),
  ]

  private static let thoughtfulChatPaths =
    [
      "ThoughtfulChatHomeDemoView", "ThoughtfulChatThreadDemoView", "ThoughtfulChatTheme",
    ].map { "App/Shared/Flows/Assistants/\($0).swift" } + sharedMotionPaths

  private static let visualAssistantPaths =
    [
      "VisualAssistantHomeDemoView", "VisualAssistantAnswerDemoView",
      "VisualAssistantAnswerSupport", "VisualAssistantTheme",
    ].map { "App/Shared/Flows/Assistants/\($0).swift" } + sharedMotionPaths
}
