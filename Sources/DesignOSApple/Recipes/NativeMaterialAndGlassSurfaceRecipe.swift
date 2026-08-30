/// Metadata for direct native material and availability-gated glass surfaces.
///
/// Client call sites keep controls above native material and use glass only on
/// the iOS/macOS 26 availability branch; iOS/iPadOS 17 and macOS 14 retain
/// material. The surface is not an accessibility element and does not redraw
/// system blur, refraction, scroll edges, or control chrome.
public enum NativeMaterialAndGlassSurfaceRecipe {}
