
import SpriteKit

class RedDog : Dog {
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init() {
    super.init()

    physicsBody!.categoryBitMask = PhysicsCategory.RedDog
    physicsBody!.collisionBitMask =
      PhysicsCategory.Player | PhysicsCategory.Wall | PhysicsCategory.Breakable | PhysicsCategory.Boundary
    physicsBody!.linearDamping = 1
    physicsBody!.angularDamping = 1
    
    sprite.color = SKColor.redColor()
    sprite.colorBlendFactor = 0.45
  }

  func kickDog() {
    removeAllActions()
    runAction(SKAction.sequence([
      SKAction.waitForDuration(1),
      SKAction.runBlock(resumeAfterKick)]))
  }
  
  func resumeAfterKick() {
    physicsBody!.velocity = CGVector.zeroVector

    let gameScene = scene as! GameScene
    let tileLayer = parent as! TileMapLayer
    let tileCoord = tileLayer.coordForPoint(position)
    
    if gameScene.tileAtCoord(tileCoord, hasAnyProps: PhysicsCategory.Water) {
      let drown = SKAction.group(
        [SKAction.rotateByAngle(4.0*π, duration:1),
         SKAction.scaleTo(0, duration:1)])
      runAction(SKAction.sequence([drown, SKAction.removeFromParent()]))
    } else {
      walk()
    }
  }
}
