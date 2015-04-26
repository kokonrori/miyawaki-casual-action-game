
import SpriteKit

class AnimatingSprite : SKSpriteNode {
  
  enum SpriteDirection : Int {
    case Forward, Back, Left, Right
  }
  
  var facingForwardAnim : SKAction?
  var facingBackAnim : SKAction?
  var facingSideAnim : SKAction?
 
  var facingDirection: SpriteDirection = .Forward {
    didSet {
      switch facingDirection {
        case .Forward:
          runAction(facingForwardAnim)
        case .Back:
          runAction(facingBackAnim)
        case .Left:
          runAction(facingSideAnim)
        case .Right:
          runAction(facingSideAnim)
      }
      // 4
      if facingDirection == .Right && xScale > 0 ||
        facingDirection != .Right && xScale < 0  {
        xScale *= -1
      }
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("NSCoding not supported")
  }
  
  init(texture: SKTexture) {
    super.init(texture: texture, color: nil, size: texture.size())
  }
    
  class func createAnimWithPrefix(prefix: String,
                                  suffix: String) -> SKAction {
    let atlas = SKTextureAtlas(named: "characters")
  
    let textures = [atlas.textureNamed("\(prefix)_\(suffix)1"),
                    atlas.textureNamed("\(prefix)_\(suffix)2")]
  
    textures[0].filteringMode = .Nearest
    textures[1].filteringMode = .Nearest
  
    return SKAction.repeatActionForever(
      SKAction.animateWithTextures(textures, timePerFrame:0.20))
  }
}
