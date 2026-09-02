#!/bin/zsh
set -euo pipefail

project_root=${0:A:h:h}
flows_root="$project_root/Examples/DesignOSAppleGallery/App/Shared/Flows"
gallery="$flows_root/LocalDemoGalleryView.swift"
assistant_answer="$flows_root/Assistants/VisualAssistantAnswerDemoView.swift"
flight_live="$flows_root/Mobility/FlightTrackerLiveDemoView.swift"
flight_board="$flows_root/Mobility/FlightTrackerBoardDemoView.swift"
mobility_theme="$flows_root/Mobility/MobilityDemoTheme.swift"
streaming_browse="$flows_root/Entertainment/StreamingLibraryBrowseDemoView.swift"
failures=0

report() {
  print -u2 -- "E_LOCAL_DEMO_DESIGN: $1"
  failures=$((failures + 1))
}

grep -Fq '.padding(.horizontal, 16)' "$gallery" || report "catalog horizontal padding must be exactly 16 points"
grep -Fq 'dynamicTypeSize.isAccessibilitySize ? 1 : 2' "$gallery" || report "catalog must use two columns outside accessibility sizes"
grep -Fq 'GridItem(.flexible(), spacing: 12' "$gallery" || report "catalog grid gap must be exactly 12 points"
grep -Fq '.aspectRatio(4 / 3, contentMode: .fit)' "$gallery" || report "catalog thumbnails must use 4:3 composition"

expected_roots=(
  ThoughtfulChatHomeDemoView ThoughtfulChatThreadDemoView
  VisualAssistantHomeDemoView VisualAssistantAnswerDemoView
  FlightTrackerBoardDemoView FlightTrackerLiveDemoView
  CityRideSelectionDemoView CityRideTrackingDemoView
  StreamingLibraryBrowseDemoView StreamingLibraryHero
  SongFinderListeningDemoView SongFinderResultDemoView
)
for root in $expected_roots; do
  count=$(rg -l "struct $root: View" "$flows_root" --glob '*.swift' | wc -l | tr -d ' ')
  [[ "$count" == 1 ]] || report "expected exactly one root declaration for '$root', found $count"
done

for family in Assistants Mobility Entertainment; do
  if rg -n 'NavigationStack' "$flows_root/$family" --glob '*.swift' >/dev/null; then
    report "$family contains a nested NavigationStack; outer Gallery navigation owns native Back"
  fi
done

for brand in Claude Gemini Flighty Grab Netflix Shazam; do
  if rg -n -F "$brand" "$flows_root/Assistants" "$flows_root/Mobility" "$flows_root/Entertainment" --glob '*.swift' >/dev/null; then
    report "protected reference brand '$brand' appears in runtime source"
  fi
done

for old_demo in Finance Fitness Travel finance fitness travel; do
  if rg -n -w -F "$old_demo" "$flows_root" --glob '*.swift' >/dev/null; then
    report "retired local demo token '$old_demo' remains in runtime source"
  fi
done

while IFS= read -r source; do
  lines=$(wc -l < "$source" | tr -d ' ')
  (( lines <= 200 )) || report "Swift source exceeds 200 lines: ${source#$project_root/} ($lines)"
done < <(find "$flows_root" -type f -name '*.swift' -print | sort)

if rg -n '\.font\(\.caption2' "$flows_root" --glob '*.swift' >/dev/null; then
  report "caption2 is below the 12-point local-demo typography floor; use caption or larger"
fi

if rg -n '\.font\(\.system\(size:\s*[0-9]' "$flows_root" --glob '*.swift' >/dev/null; then
  report "numeric fixed system font sizes bypass semantic Dynamic Type roles"
fi

if rg -n '\.minimumScaleFactor\(0\.[0-7]' "$flows_root" --glob '*.swift' >/dev/null; then
  report "minimumScaleFactor below 0.8 violates the readable-text floor"
fi

if rg -U -n 'Button\s*\{\s*\}' "$flows_root" --glob '*.swift' >/dev/null; then
  report "empty Button actions create fake interactive controls"
fi

grep -Fq 'localDemoTransitionSource' "$flows_root/LocalDemoGalleryView.swift" || report "catalog cards must opt into native zoom transition sources"
grep -Fq 'matchedTransitionSource' "$flows_root/LocalDemoNavigationMotion.swift" 2>/dev/null || report "local-demo transition sources must bind to native matched geometry"
grep -Fq 'navigationTransition(.zoom' "$flows_root/LocalDemoNavigationMotion.swift" 2>/dev/null || report "local-demo destinations must use native zoom continuity"
grep -Fq '#available(iOS 18.0, *)' "$flows_root/LocalDemoNavigationMotion.swift" 2>/dev/null || report "native zoom motion must preserve the iOS 17 deployment target"
grep -Fq 'accessibilityReduceMotion' "$flows_root/LocalDemoNavigationMotion.swift" 2>/dev/null || report "local-demo motion must honor Reduce Motion"
grep -Fq '.snappy' "$flows_root/LocalDemoInteractionMotion.swift" 2>/dev/null || report "interactive local-demo state changes must use interruptible snappy motion"
grep -Fq 'accessibilityReduceMotion' "$flows_root/LocalDemoInteractionMotion.swift" 2>/dev/null || report "interactive local-demo motion must honor Reduce Motion"
grep -Fq 'reduceMotion ? nil : .snappy' "$flows_root/LocalDemoInteractionMotion.swift" 2>/dev/null || report "Reduce Motion must suppress layout animation instead of substituting another moving curve"

grep -Fq '.padding(.horizontal, 16)' "$mobility_theme" || report "shared Mobility sheets must use exactly 16-point horizontal gutters"
grep -Fq 'showsRoute: isMapLayerActive' "$flight_live" || report "Flight route control must bind to rendered map content"
grep -Fq 'showsWeather: isWeatherVisible' "$flight_live" || report "Flight weather control must bind to rendered map content"
grep -Fq 'accessibilityReduceTransparency' "$flight_live" || report "Flight custom translucent controls need an opaque fallback"
grep -Fq 'ForEach(Array(filteredTrips.enumerated())' "$flight_board" || report "Flight trip filters must change the rendered collection"
grep -Fq 'switch selectedTab' "$streaming_browse" || report "Streaming tabs must select rendered content, not tint alone"
grep -Fq 'ShareLink(item: answerText)' "$assistant_answer" || report "assistant Share controls must invoke native sharing"
grep -Fq 'LocalDemoPasteboard.copy(answerText)' "$assistant_answer" || report "assistant Copy must write the represented answer"
grep -Fq 'regenerationCount += 1' "$assistant_answer" || report "assistant Regenerate must change answer content"

streaming_rank="$flows_root/Entertainment/StreamingLibraryBrowseDemoView.swift"
grep -Fq '@ScaledMetric(relativeTo: .largeTitle)' "$streaming_rank" || report "Streaming rank typography must scale from a semantic role"
grep -Fq '.stroke(color: .white, lineWidth: 2)' "$streaming_rank" || report "Streaming ranks must render their large outlined numerals"
grep -Fq '.offset(x: 50)' "$streaming_rank" || report "Streaming poster must overlap its rank numeral"

transition_count=$(rg -l 'NavigationLink\(value:' "$flows_root/Assistants" "$flows_root/Mobility" "$flows_root/Entertainment" --glob '*.swift' | wc -l | tr -d ' ')
(( transition_count >= 5 )) || report "expected at least five native navigation transitions, found $transition_count"
grep -Fq 'streaming-library.scrolled-library' "$flows_root/Entertainment/StreamingLibraryBrowseDemoView.swift" || report "Streaming Library must expose its second state as a scroll position on the same page"

if (( failures > 0 )); then
  print -u2 -- "E_LOCAL_DEMO_DESIGN: $failures contract failure(s)"
  exit 1
fi

print -- "Local demo static contract passed: 12 views, native Back, semantic typography floor, state-bound controls, no-motion fallback, and 16-point catalog and Mobility gutters. Visual and owner acceptance remain separate."
