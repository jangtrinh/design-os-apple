/// A semantic color intent for custom content.
public struct DesignOSColorRole: Hashable, Sendable {
  internal enum Identifier: Hashable, Sendable {
    case labelPrimary
    case labelSecondary
    case labelTertiary
    case labelQuaternary
    case backgroundPrimary
    case backgroundSecondary
    case backgroundTertiary
    case groupedBackgroundPrimary
    case groupedBackgroundSecondary
    case groupedBackgroundTertiary
    case fillPrimary
    case fillSecondary
    case fillTertiary
    case fillQuaternary
    case separator
    case red
    case orange
    case yellow
    case green
    case mint
    case teal
    case cyan
    case blue
    case indigo
    case purple
    case pink
    case brown
    case gray
  }

  internal let identifier: Identifier

  internal init(_ identifier: Identifier) {
    self.identifier = identifier
  }

  /// The primary semantic label color.
  public static let labelPrimary = Self(.labelPrimary)
  /// The secondary semantic label color.
  public static let labelSecondary = Self(.labelSecondary)
  /// The tertiary semantic label color.
  public static let labelTertiary = Self(.labelTertiary)
  /// The quaternary semantic label color.
  public static let labelQuaternary = Self(.labelQuaternary)
  /// The primary semantic background color.
  public static let backgroundPrimary = Self(.backgroundPrimary)
  /// The secondary semantic background color.
  public static let backgroundSecondary = Self(.backgroundSecondary)
  /// The tertiary semantic background color.
  public static let backgroundTertiary = Self(.backgroundTertiary)
  /// The primary semantic grouped background color.
  public static let groupedBackgroundPrimary = Self(.groupedBackgroundPrimary)
  /// The secondary semantic grouped background color.
  public static let groupedBackgroundSecondary = Self(.groupedBackgroundSecondary)
  /// The tertiary semantic grouped background color.
  public static let groupedBackgroundTertiary = Self(.groupedBackgroundTertiary)
  /// The primary semantic fill color.
  public static let fillPrimary = Self(.fillPrimary)
  /// The secondary semantic fill color.
  public static let fillSecondary = Self(.fillSecondary)
  /// The tertiary semantic fill color.
  public static let fillTertiary = Self(.fillTertiary)
  /// The quaternary semantic fill color.
  public static let fillQuaternary = Self(.fillQuaternary)
  /// The semantic separator color.
  public static let separator = Self(.separator)
  /// The semantic red spectrum color.
  public static let red = Self(.red)
  /// The semantic orange spectrum color.
  public static let orange = Self(.orange)
  /// The semantic yellow spectrum color.
  public static let yellow = Self(.yellow)
  /// The semantic green spectrum color.
  public static let green = Self(.green)
  /// The semantic mint spectrum color.
  public static let mint = Self(.mint)
  /// The semantic teal spectrum color.
  public static let teal = Self(.teal)
  /// The semantic cyan spectrum color.
  public static let cyan = Self(.cyan)
  /// The semantic blue spectrum color.
  public static let blue = Self(.blue)
  /// The semantic indigo spectrum color.
  public static let indigo = Self(.indigo)
  /// The semantic purple spectrum color.
  public static let purple = Self(.purple)
  /// The semantic pink spectrum color.
  public static let pink = Self(.pink)
  /// The semantic brown spectrum color.
  public static let brown = Self(.brown)
  /// The semantic gray spectrum color.
  public static let gray = Self(.gray)
}
