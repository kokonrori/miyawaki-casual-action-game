
import SpriteKit

class Breakable : SKNode {
  
  let sprite: SKSpriteNode
  let brokenTexture: SKTexture
  let flyAwayTexture: SKTexture

  required init?(coder aDecoder: NSCoder) {
    fatalError("NSCoding not supported")
  }
  
  init(wholeTexture: SKTexture, brokenTexture: SKTexture, flyAwayTexture: SKTexture) {
    sprite = SKSpriteNode(texture: wholeTexture)
    self.brokenTexture = brokenTexture
    self.flyAwayTexture = flyAwayTexture
    super.init()
    
    addChild(sprite)
    
    physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: sprite.size.width * 0.8,
        height: sprite.size.height * 0.8))
    physicsBody!.categoryBitMask = PhysicsCategory.Breakable
    physicsBody!.collisionBitMask = PhysicsCategory.None
    physicsBody!.contactTestBitMask = PhysicsCategory.Player
  }
 
  func smashBreakable() {
    physicsBody = nil
    sprite.texture = brokenTexture
    sprite.size = brokenTexture.size()
    
    let topNode = SKSpriteNode(texture: flyAwayTexture)
    addChild(topNode)
    
    // 1 move
    let upAction = SKAction.moveByX(0, y: 30, duration: 0.2)
    upAction.timingMode = .EaseOut
    
    let downAction = SKAction.moveByX(0, y: -300, duration: 0.8)
    downAction.timingMode = .EaseIn
    
    topNode.runAction(SKAction.sequence(
      [upAction, downAction, SKAction.removeFromParent()]))
    
    let direction = CGFloat.randomSign()
    let horzAction = SKAction.moveByX(100 * direction, y: 0, duration: 1.0)
    topNode.runAction(horzAction)
    
    // 2 rotate
    let rotateAction = SKAction.rotateByAngle(
      -π + CGFloat.random()*2*π, duration: 1.0)
    topNode.runAction(rotateAction)
    
    // 3 scale
    topNode.xScale = 1.5
    topNode.yScale = 1.5
    
    let scaleAction = SKAction.scaleTo(0.4, duration: 1.0)
    scaleAction.timingMode = .EaseOut
    topNode.runAction(scaleAction)
    
    // 4 alpha
    topNode.runAction(SKAction.sequence([
      SKAction.waitForDuration(0.6),
      SKAction.fadeOutWithDuration(0.4)]))

    // 5 particle
    let emitter = SKEmitterNode(fileNamed: "SweetsSmash")
    emitter.particleTexture!.filteringMode = .Nearest
    emitter.targetNode = parent
    emitter.runAction(SKAction.removeFromParentAfterDelay(1.0))
    addChild(emitter)
  }
}