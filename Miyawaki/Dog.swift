
import SpriteKit

class Dog : SKNode {

  struct Animations {
    static let facingForwardAnim : SKAction =
      AnimatingSprite.createAnimWithPrefix("dog", suffix: "ft")
    static let facingBackAnim : SKAction =
      AnimatingSprite.createAnimWithPrefix("dog", suffix: "ft")
    static let facingSideAnim : SKAction =
      AnimatingSprite.createAnimWithPrefix("dog", suffix: "ft")
  }
  
  let sprite : AnimatingSprite
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("NSCoding not supported")
  }
  
  override init() {
    let atlas = SKTextureAtlas(named: "characters")
    let texture = atlas.textureNamed("dog_ft1")
    texture.filteringMode = .Nearest
    
    sprite = AnimatingSprite(texture: texture)
    
    super.init()
    
    addChild(sprite)
    name = "dog"
    
    var radius = min(sprite.size.width, sprite.size.height) / 2
    physicsBody = SKPhysicsBody(circleOfRadius: radius)
    physicsBody!.categoryBitMask = PhysicsCategory.Dog
    physicsBody!.collisionBitMask = PhysicsCategory.None
    
    sprite.facingForwardAnim = Animations.facingForwardAnim
    sprite.facingBackAnim = Animations.facingBackAnim
    sprite.facingSideAnim = Animations.facingSideAnim
  }
  
  func walk() {
    // 1
    let tileLayer = parent as! TileMapLayer
    // 2
    let tileCoord = tileLayer.coordForPoint(position)
    let randomX = CGFloat(Int.random(min: -1, max: 1))
    let randomY = CGFloat(Int.random(min: -1, max: 1))
    let randomCoord = CGPoint(x: tileCoord.x + randomX, y: tileCoord.y + randomY)
    // 3
    var didMove = false
    let gameScene = scene as! GameScene
    if tileLayer.isValidTileCoord(randomCoord) &&
      !gameScene.tileAtCoord(randomCoord,
                             hasAnyProps: PhysicsCategory.Wall | PhysicsCategory.Water) {
      // 4
      didMove = true
      let randomPos = tileLayer.pointForCoord(randomCoord)
      let moveToPos = SKAction.sequence([
        SKAction.moveTo(randomPos, duration: 1),
        SKAction.runBlock(walk)])
      runAction(moveToPos)
                              
      faceDirection(CGVector(dx: randomX, dy: randomY))
    }
    // 5
    if !didMove {
      let pause = SKAction.waitForDuration(0.25, withRange: 0.15)
      let retry = SKAction.runBlock(walk)
      runAction(SKAction.sequence([pause, retry]))
    }
  }
  
  func start() {
      walk()
  }
  
  func faceDirection(dir:CGVector) {
    // 1
    if dir.dy != 0 && dir.dx != 0 {
      // 2
      sprite.facingDirection = dir.dy < 0 ? .Back : .Forward
      zRotation = dir.dy < 0 ? π / 4.0 : -π / 4.0
      if dir.dx > 0 {
        zRotation *= -1
      }
    }
    else {
      // 3
      zRotation = 0
      // 4
      switch dir {
        case _ where dir.dx > 0:
          sprite.facingDirection = .Right
        case _ where dir.dx < 0:
          sprite.facingDirection = .Left
        case _ where dir.dy < 0:
          sprite.facingDirection = .Back
        case _ where dir.dy > 0:
          sprite.facingDirection = .Forward
        default:
          break;
      }
    }
  }
}
