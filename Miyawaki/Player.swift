
import SpriteKit

class Player : SKNode {
  
  let sprite : AnimatingSprite
  let emitter: SKEmitterNode
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("NSCoding not supported")
  }
  
  override init() {
    let atlas = SKTextureAtlas(named: "characters")
    let texture = atlas.textureNamed("player_ft1")
    texture.filteringMode = .Nearest
  
    sprite = AnimatingSprite(texture: texture)
    emitter = SKEmitterNode(fileNamed: "PlayerTrail")
    
    super.init()
  
    addChild(sprite)
    name = "player"
  
    // 1
    var minDiam = min(sprite.size.width, sprite.size.height)
    minDiam = max(minDiam-16.0, 4.0)
    let physicsBody = SKPhysicsBody(circleOfRadius: minDiam/2.0)
    // 2
    physicsBody.usesPreciseCollisionDetection = true
    // 3
    physicsBody.allowsRotation = false
    physicsBody.restitution = 1
    physicsBody.friction = 0
    physicsBody.linearDamping = 0
    physicsBody.categoryBitMask = PhysicsCategory.Player
    physicsBody.contactTestBitMask = PhysicsCategory.All
    physicsBody.collisionBitMask = PhysicsCategory.Boundary |
      PhysicsCategory.Wall | PhysicsCategory.Water | PhysicsCategory.RedDog
    // 4
    self.physicsBody = physicsBody
    
    sprite.facingForwardAnim =
      AnimatingSprite.createAnimWithPrefix("player", suffix: "ft")
    sprite.facingBackAnim =
      AnimatingSprite.createAnimWithPrefix("player", suffix: "bk")
    sprite.facingSideAnim =
      AnimatingSprite.createAnimWithPrefix("player", suffix: "lt")
  }
    
  func moveToward(target: CGPoint) {
    let targetVector = (target - position).normalized() * 350.0
    physicsBody?.velocity = CGVector(point: targetVector)
    faceCurrentDirection()
  }
  
  func faceCurrentDirection() {
    let dir = physicsBody!.velocity
    if abs(dir.dy) > abs(dir.dx) {
      sprite.facingDirection = dir.dy < 0 ? .Forward : .Back
    }
    else {
      sprite.facingDirection = dir.dx > 0 ? .Right : .Left
    }
  }
  
  func start() {
    emitter.particleTexture!.filteringMode = .Nearest
    emitter.targetNode = parent
    emitter.zPosition = zPosition - 1
    addChild(emitter)
  }
}
