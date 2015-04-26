
struct PhysicsCategory {
  static let None      : UInt32 = 0
  static let All       : UInt32 = UInt32.max
  static let Boundary  : UInt32 = 0b1       // 1
  static let Player    : UInt32 = 0b10      // 2
  static let Dog       : UInt32 = 0b100     // 4
  static let Wall      : UInt32 = 0b1000    // 8
  static let Water     : UInt32 = 0b10000   // 16
  static let Breakable : UInt32 = 0b100000  // 32
  static let RedDog    : UInt32 = 0b1000000 // 64
}

enum GameState : Int {
  case StartingLevel
  case Playing
  case InLevelMenu
}

enum Side: Int {
  case Right = 0
  case Left = 2
  case Top = 1
  case Bottom = 3
}
