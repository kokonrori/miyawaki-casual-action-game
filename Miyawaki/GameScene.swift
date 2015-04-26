
import SpriteKit
import QuartzCore

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  var worldNode: SKNode!  // contain all elements
  var backgroundLayer: TileMapLayer!
  var player: Player!
  var dogLayer: TileMapLayer!
  private var dogsToRemove: [Dog] = []
  var breakableLayer: TileMapLayer?
  var gameState = GameState.StartingLevel
  var currentLevel = 0
  var levelTimeLimit = 0.0
  var timerLabel : SKLabelNode!
  
  var currentTime = 0.0
  var startTime = 0.0
  var elapsedTime = 0.0
  
  let hitWallSound = SKAction.playSoundFileNamed("HitWall.mp3", waitForCompletion: false)
  let hitWaterSound = SKAction.playSoundFileNamed("HitWater.mp3", waitForCompletion: false)
  let hitSweetsSound = SKAction.playSoundFileNamed("HitSweets.wav", waitForCompletion: false)
  let hitRedDogSound = SKAction.playSoundFileNamed("HitRedDog.mp3", waitForCompletion: false)
  let playerMoveSound = SKAction.playSoundFileNamed("PlayerMove.mp3", waitForCompletion: false)
  let tickTockSound = SKAction.playSoundFileNamed("TickTock.mp3", waitForCompletion: true)
  let winSound = SKAction.playSoundFileNamed("Win.mp3", waitForCompletion: false)
  let loseSound = SKAction.playSoundFileNamed("Lose.mp3", waitForCompletion: false)
  var killDogSounds = [SKAction]()
  
  var lastComboTime: CFTimeInterval = 0
  var comboCounter = 0
  
  var tickTockPlaying = false

  required init?(coder aDecoder: NSCoder) {
    fatalError("NSCoding not supported")
  }
  
  override init(size: CGSize) {
    super.init(size: size)
  }
  
  init(size: CGSize, level: Int) {
    currentLevel = level
    super.init(size: size)
  }
  
  func createScenery(
    levelData: [String:AnyObject]) -> TileMapLayer?
  {
    let layerFiles: AnyObject? = levelData["layers"]
    if let dict = layerFiles as? [String:String] {
      return tileMapLayerFromFileNamed(dict["background"]!)
    }
    return nil
  }

  override func didMoveToView(view: SKView) {
    if worldNode != nil {
      return
    }
    
    let config = NSDictionary(contentsOfFile:
      NSBundle.mainBundle().pathForResource("Maps", ofType: "plist")!)!
    let levels = config["levels"] as! [[String:AnyObject]]
    if currentLevel >= levels.count {
      currentLevel = 0
    }
    
    let levelData = levels[currentLevel]
    
    createWorld(levelData)
    createCharacters(levelData)
    centerViewOn(player.position)
    
    levelTimeLimit = (levelData["timeLimit"] as! NSNumber).doubleValue
    
    createUserInterface()
    
    if gameState == GameState.StartingLevel {
      paused = true
    }
    
    for i in 1...12 {
      killDogSounds.append(SKAction.playSoundFileNamed(
        "KillDog-\(i).mp3", waitForCompletion: false))
    }
    
    SKTAudio.sharedInstance().playBackgroundMusic("Majisuka Fight.mp3")
  }

  func createWorld(levelData: [String:AnyObject]) {
//    backgroundColor = SKColorWithRGB(89, 133, 39)
    backgroundColor = SKColorWithRGBA(130, 200, 210, 255)
    backgroundLayer = createScenery(levelData)
    
    worldNode = SKNode()
    worldNode.addChild(backgroundLayer)
    addChild(worldNode)
    
    anchorPoint = CGPointMake(0.5, 0.5)
    
    // fit the world node position to the center of the scene
    worldNode.position =
      CGPointMake(-backgroundLayer.layerSize.width / 2,
                  -backgroundLayer.layerSize.height / 2)
    
    self.physicsWorld.gravity = CGVector.zeroVector
    
    let bounds = SKNode()
    bounds.physicsBody =
      SKPhysicsBody(edgeLoopFromRect:
        CGRect(x: 0, y: 0,
               width: backgroundLayer.layerSize.width,
               height: backgroundLayer.layerSize.height))
    bounds.physicsBody!.categoryBitMask = PhysicsCategory.Boundary
    bounds.physicsBody!.friction = 0
    worldNode.addChild(bounds)
    
    physicsWorld.contactDelegate = self
    
    breakableLayer = createBreakables(levelData)
    if let definiteLayer = breakableLayer {
      definiteLayer.zPosition = 9
      worldNode.addChild(definiteLayer)
    }
  }
  
  // moving the camera
  func centerViewOn(centerOn: CGPoint) {
    worldNode.position = getCenterPointWithTarget(centerOn)
  }
  
  override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    switch gameState {
      case .StartingLevel:
        childNodeWithName("msgLabel")!.hidden = true
        gameState = .Playing

        paused = false
        timerLabel.hidden = false
    
        startTime = currentTime
        
        player.start()
        fallthrough
        
      case .Playing:
        let touch = touches.first as! UITouch
        let loc = touch.locationInNode(worldNode)
        tapEffectsForTouchAtLocation(loc)
        player.moveToward(loc)

      case .InLevelMenu:
        let touch = touches.first as! UITouch
        let loc = touch.locationInNode(self)
    }
  }
  
  func createCharacters(levelData:[String:AnyObject]) {
    let layerFiles : AnyObject? = levelData["layers"]
    if let dict = layerFiles as? [String:String] {
      dogLayer = tileMapLayerFromFileNamed(dict["dogs"]!)
    }

    dogLayer.zPosition = 10
    worldNode.addChild(dogLayer)
    
    player = dogLayer.childNodeWithName("player") as! Player
    player.removeFromParent()
    player.zPosition = 50
    worldNode.addChild(player)
    
    dogLayer.enumerateChildNodesWithName(
      "dog",
      usingBlock: { node, _ in
        if let dog = node as? Dog {
          dog.start()
        }
      })
  }

  override func didSimulatePhysics() {
    let target = getCenterPointWithTarget(player.position)
    
    // move the camera from its current position toward the target position
    // the 10% is what makes the camera appear to lag behind the player
    // the camera is always trying to catch up to where the player is but never quite gets there
    worldNode.position += (target - worldNode.position) * 0.1
    
    if !dogsToRemove.isEmpty {
      for dog in dogsToRemove {
        dogHitEffects(dog)
      }
      dogsToRemove.removeAll()
    }
  }
  
  // clamp the camera position
  func getCenterPointWithTarget(target: CGPoint) -> CGPoint {
    let x = target.x.clamped(
      size.width / 2,
      backgroundLayer.layerSize.width - size.width / 2)
    let y = target.y.clamped(
      size.height / 2,
      backgroundLayer.layerSize.height - size.height / 2)
    
    // return the minus value because of the world node's anchor point
    return CGPoint(x: -x, y: -y)
  }
  
  func didBeginContact(contact:SKPhysicsContact) {
    let other =
      (contact.bodyA.categoryBitMask == PhysicsCategory.Player ?
       contact.bodyB : contact.bodyA)
    
    switch other.categoryBitMask {
      case PhysicsCategory.Dog:
        dogsToRemove.append(other.node as! Dog)
      case PhysicsCategory.Breakable:
        let breakable = other.node as! Breakable
        breakable.smashBreakable()
        runAction(hitSweetsSound)
      case PhysicsCategory.RedDog:
        let redDog = other.node as! RedDog
        redDogHitEffects()
        redDog.kickDog()
      case PhysicsCategory.Boundary, PhysicsCategory.Wall, PhysicsCategory.Water:
        wallHitEffects(other.node!)
      default:
        break;
    }
  }
  
  func tileAtCoord(coord: CGPoint,
                   hasAnyProps props: UInt32) -> Bool {
    return tileAtPoint(backgroundLayer.pointForCoord(coord), hasAnyProps: props)
  }
  
  func tileAtPoint(point: CGPoint,
                   hasAnyProps props: UInt32) -> Bool {
    var tile = breakableLayer?.tileAtPoint(point)
    if tile == nil {
      tile = backgroundLayer.tileAtPoint(point)
    }
    
    if let categoryMask = tile?.physicsBody?.categoryBitMask {
      return categoryMask & props != 0
    }
    return false
  }
  
  func didEndContact(contact:SKPhysicsContact) {
    let other =
      (contact.bodyA.categoryBitMask == PhysicsCategory.Player ?
       contact.bodyB : contact.bodyA)
    
    if other.categoryBitMask &
      player.physicsBody!.collisionBitMask != 0 {
      player.faceCurrentDirection()
    }
  }
  
  func createBreakables(
    levelData: [String:AnyObject]) -> TileMapLayer? {
    let layerFiles : AnyObject? = levelData["layers"]
    if let dict = layerFiles as? [String:String] {
      if let layer = dict["breakables"] {
        return tileMapLayerFromFileNamed(layer)
      }
    }
    return nil
  }
    
  func createUserInterface() {
    let startMsg = SKLabelNode(fontNamed: "Hiragino Kaku Gothic ProN W6")
    startMsg.name = "msgLabel"
    startMsg.text = "道を空けろよ！"
    startMsg.fontSize = 32
    startMsg.position = CGPoint(x: 0, y: 0)
    startMsg.zPosition = 100
    startMsg.fontColor = SKColor.blackColor()
    addChild(startMsg)
    
    timerLabel = SKLabelNode(fontNamed: "Marker Felt")
    timerLabel.text =
      String(format: "Time Remaining: %2.2f", levelTimeLimit)
    timerLabel.fontSize = 18
    timerLabel.horizontalAlignmentMode = .Left
    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
      // different placement on iPad
      timerLabel.position = CGPoint(x: 150, y: size.height / 2 - 40)
    } else {
      timerLabel.position = CGPoint(x: 0, y: size.height / 2 - 30)
    }
    timerLabel.zPosition = 100
    timerLabel.fontColor = SKColor.blackColor()
    addChild(timerLabel)
    
    timerLabel.hidden = true
  }
  
  override func update(currentTime: CFTimeInterval) {
    
    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
        // different placement on iPad
        timerLabel.position = CGPoint(x: 150, y: size.height / 2 - 40)
    } else {
        timerLabel.position = CGPoint(x: 0, y: size.height / 2 - 30)
    }
    
    self.currentTime = currentTime
    
    if gameState == .StartingLevel && !paused {
      paused = true
    }
    
    if gameState != .Playing {
      return
    }
    
    elapsedTime = currentTime - startTime
    
    var timeRemaining = levelTimeLimit - elapsedTime
    if timeRemaining < 0 {
      timeRemaining = 0
    }
    timerLabel.text =
      String(format: "Time Remaining: %2.2f", timeRemaining)

    if timeRemaining < 10 && timeRemaining > 0 && !tickTockPlaying {
      tickTockPlaying = true
      runAction(tickTockSound, withKey: "tickTock")
    }

    if elapsedTime >= levelTimeLimit {
      endLevelWithSuccess(false)
    } else if dogLayer.childNodeWithName("dog") == nil {
      endLevelWithSuccess(true)
    }
  }
  
  func endLevelWithSuccess(won: Bool) {
    removeActionForKey("tickTock")
    
    let label = childNodeWithName("msgLabel") as! SKLabelNode
    label.text = won ? "やりましたね!" : "私の負けだ。。。"
    label.hidden = false
    
    player.physicsBody!.linearDamping = 1
    
    gameState = .InLevelMenu

    SKTAudio.sharedInstance().pauseBackgroundMusic()
    runAction(won ? winSound : loseSound)
  }
    
  func wallHitEffects(node: SKNode) {
    let side = sideForCollisionWithNode(node)
    squashPlayerForSide(side)
    dogJelly()
    // 1
    if node.physicsBody!.categoryBitMask & PhysicsCategory.Boundary != 0 {
      screenShakeForSide(side, power: 20)
    } else {
      // 2
      node.zPosition += 1
      node.runAction(SKAction.afterDelay(1.2, runBlock: {
        node.zPosition -= 1
      }))
      // 3
      scaleWall(node)
      moveWall(node, onSide: side)
      screenShakeForSide(side, power: 8)
      showParticlesForWall(node, onSide: side)
    }
    
    if node.physicsBody!.categoryBitMask & PhysicsCategory.Water != 0 {
        runAction(hitWaterSound)
    } else {
      runAction(hitWallSound)
    }
  }
  
  func scaleWall(node: SKNode) {
    if node.actionForKey("scaling") == nil {
      let oldScale = CGPoint(x: node.xScale, y: node.yScale)
      let newScale = oldScale * 1.2
      
      let scaleEffect = SKTScaleEffect(node: node, duration: 1.2,
        startScale: newScale, endScale: oldScale)
      
      scaleEffect.timingFunction = SKTCreateShakeFunction(4)
      
      let action = SKAction.actionWithEffect(scaleEffect)
      
      node.runAction(action, withKey: "scaling")
    }
  }
  
  func sideForCollisionWithNode(node: SKNode) -> Side {
    // Did the player hit the screen bounds?
    if node.physicsBody!.categoryBitMask & PhysicsCategory.Boundary != 0 {
      if player.position.x < 20 {
        return .Left
      } else if player.position.y < 20 {
        return .Bottom
      } else if player.position.x > size.width - 20 {
        return .Right
      } else {
        return .Top
      }
    } else {  // The player hit a regular node
      let diff = node.position - player.position
      let angle = diff.angle
      
      if angle > -π/4 && angle <= π/4 {
        return .Right
      } else if angle > π/4 && angle <= 3*π/4 {
        return .Top
      } else if angle <= -π/4 && angle > -3*π/4 {
        return .Bottom
      } else {
        return .Left
      }
    }
  }
  
  func moveWall(node: SKNode, onSide side: Side) {
    if node.actionForKey("moving") == nil {
      let offsets = [
        CGPoint(x:  4.0, y:  0.0 ),
        CGPoint(x:  0.0, y:  4.0 ),
        CGPoint(x: -4.0, y:  0.0 ),
        CGPoint(x:  0.0, y: -4.0 ),
      ]
      
      let oldPosition = node.position
      let offset = offsets[side.rawValue]
      let newPosition = node.position + offset
      
      let moveEffect = SKTMoveEffect(node: node, duration: 0.6,
        startPosition: newPosition, endPosition: oldPosition)
      
      moveEffect.timingFunction = SKTTimingFunctionBackEaseOut
      
      let action = SKAction.actionWithEffect(moveEffect)
      node.runAction(action, withKey: "moving")
    }
  }
  
  func tapEffectsForTouchAtLocation(location: CGPoint) {
    stretchPlayerWhenMoved()
    showTapAtLocation(location)
    player.runAction(playerMoveSound)
  }
  
  func stretchPlayerWhenMoved() {
    let oldScale = CGPoint(x: player.sprite.xScale,
      y: player.sprite.yScale)
    let newScale = oldScale * 1.4
    
    let scaleEffect = SKTScaleEffect(node: player.sprite,
      duration: 0.2, startScale: newScale, endScale: oldScale)
    
    scaleEffect.timingFunction = SKTTimingFunctionSmoothstep
    
    player.sprite.runAction(
      SKAction.actionWithEffect(scaleEffect))
  }
  
  func squashPlayerForSide(side: Side) {
    if player.sprite.actionForKey("squash") != nil {
      return
    }
    let oldScale = CGPoint(x: player.sprite.xScale,
      y: player.sprite.yScale)
    var newScale = oldScale
    let scaleFactor: CGFloat = 1.6
    
    if side == Side.Top || side == Side.Bottom {
      newScale.x *= scaleFactor
      newScale.y /= scaleFactor
    } else {
      newScale.x /= scaleFactor
      newScale.y *= scaleFactor
    }
    
    let scaleEffect = SKTScaleEffect(node: player.sprite,
      duration: 0.2, startScale:newScale, endScale: oldScale)
    
    scaleEffect.timingFunction = SKTTimingFunctionQuadraticEaseOut
    
    player.sprite.runAction(
      SKAction.actionWithEffect(scaleEffect), withKey: "squash")
  }
  
  func dogJelly() {
    dogLayer.enumerateChildNodesWithName("dog") { node, stop in
      let dog = node as! Dog
      
      let scaleEffect = SKTScaleEffect(node: dog.sprite, duration: 1.0, startScale: CGPoint(x: 1.2, y: 1.2), endScale:CGPoint(x: 1.0, y: 1.0))
      scaleEffect.timingFunction = SKTTimingFunctionElasticEaseOut
      
      dog.sprite.runAction(SKAction.actionWithEffect(scaleEffect), withKey: "scale")
    }
  }
  
  func dogHitEffects(dog: Dog) {
    let now = CACurrentMediaTime()
    if now - lastComboTime < 0.5 {
      ++comboCounter
    } else {
      comboCounter = 0
    }
    lastComboTime = now

    dog.physicsBody = nil
    dog.removeAllActions()
    dog.sprite.removeAllActions()
    
    let duration = 1.3
    dog.runAction(SKAction.removeFromParentAfterDelay(duration))
    
    scaleDog(dog, duration: duration)
    rotateDog(dog, duration: duration)
    fadeDog(dog, duration: duration)
    bounceDog(dog, duration: duration)
    
    // tinting
    dog.sprite.color = SKColorWithRGB(128, 128, 128)
    dog.sprite.colorBlendFactor = 1.0
    
    let maskNode = SKSpriteNode(texture: dog.sprite.texture)
    flashDog(dog, mask: maskNode)
    
    worldNode.runAction(
      SKAction.screenShakeWithNode(worldNode,
        amount: CGPoint(x: 0, y: -12), oscillations: 3,
        duration: 1.0))
    
    dog.runAction(killDogSounds[min(11, comboCounter)])
    showParticlesForDog(dog)
  }
  
  func scaleDog(node: SKNode, duration: NSTimeInterval) {
    let scaleFactor = 1.5 + CGFloat(comboCounter) * 0.25
    
    let scaleUp = SKAction.scaleTo(scaleFactor, duration: duration * 0.16667)
    scaleUp.timingMode = .EaseIn
    
    let scaleDown = SKAction.scaleTo(0.0, duration: duration * 0.83335)
    scaleDown.timingMode = .EaseIn
    
    node.runAction(SKAction.sequence([scaleUp, scaleDown]))
  }
  
  func rotateDog(node: SKNode, duration: NSTimeInterval) {
    let rotateAction = SKAction.rotateByAngle(6*π, duration: duration)
    node.runAction(rotateAction)
  }
  
  func fadeDog(node: SKNode, duration: NSTimeInterval) {
    let fadeAction = SKAction.fadeOutWithDuration(duration * 0.75)
    fadeAction.timingMode = .EaseIn
    node.runAction(SKAction.afterDelay(duration * 0.25, performAction: fadeAction))
  }
  
  func bounceDog(dog: Dog, duration: NSTimeInterval) {
    let oldPosition = dog.position
    let upPosition = oldPosition + CGPoint(x: 0, y: 80)
    
    let upEffect = SKTMoveEffect(node: dog, duration:1.2,
      startPosition: oldPosition, endPosition: upPosition)
    
    upEffect.timingFunction = { t in
      pow(2, -3 * t) * fabs(sin(t * π * 3))
    }
    
    let upAction = SKAction.actionWithEffect(upEffect)
    dog.runAction(upAction)
  }
  
  // mask a dog
  func flashDog(dog: Dog, mask: SKNode) {
    let cropNode = SKCropNode()
    cropNode.maskNode = mask
    cropNode.zPosition = dog.zPosition + 1
    
    let whiteNode =
    SKSpriteNode(color: SKColor.whiteColor(),
      size: CGSize(width: 50, height: 50))
    cropNode.addChild(whiteNode)
    
    cropNode.runAction(SKAction.sequence([
      SKAction.fadeInWithDuration(0.05),
      SKAction.fadeOutWithDuration(0.3)]))
    dog.addChild(cropNode)
  }

  func redDogHitEffects() {
    let blink = SKAction.sequence([
      SKAction.fadeOutWithDuration(0.0),
      SKAction.waitForDuration(0.1),
      SKAction.fadeInWithDuration(0.0),
      SKAction.waitForDuration(0.1)])
    
    player.sprite.runAction(SKAction.repeatAction(blink, count:4))

    worldNode.runAction(
      SKAction.screenZoomWithNode(worldNode,
        amount: CGPoint(x: 1.05, y: 1.05), oscillations: 6,
        duration: 2.0))
    
    colorGlitch()
    runAction(hitRedDogSound)
  }
  
  func colorGlitch() {
    
    // 1 hidden background nodes from color glitch
    let backgroundNodes =
    (backgroundLayer.children as! [SKNode]).filter({node in
      node.name == "background"})
    for node in backgroundNodes {
      node.hidden = true
    }
    // 2 add color glitch
    let glitchAction = SKAction.colorGlitchWithScene(self,
      originalColor: SKColorWithRGBA(130, 200, 210, 255), duration: 0.1)
    
    // 3 restore hidden nodes
    let restoreAction = SKAction.runBlock {
      for node in backgroundNodes {
        node.hidden = false
      }
    }
    runAction(SKAction.sequence([glitchAction, restoreAction]))
  }
  
  func screenShakeForSide(side: Side, power: CGFloat) {
    let offsets = [
      CGPoint(x:  1.0, y:  0.0 ),
      CGPoint(x:  0.0, y:  1.0 ),
      CGPoint(x: -1.0, y:  0.0 ),
      CGPoint(x:  0.0, y: -1.0 ),
    ]
    
    let amount = offsets[side.rawValue] * power
    
    let action = SKAction.screenShakeWithNode(worldNode,
      amount: amount, oscillations: 3, duration: 1.0)
    
    worldNode.runAction(action)
  }
  
  func showParticlesForWall(node: SKNode, onSide side: Side) {
    var position = player.position
    switch side {
    case .Right:
      position.x = node.position.x - backgroundLayer.tileSize.width/2
    case .Left:
      position.x = node.position.x + backgroundLayer.tileSize.width/2
    case .Top:
      position.y = node.position.y - backgroundLayer.tileSize.height/2
    case .Bottom:
      position.y = node.position.y + backgroundLayer.tileSize.height/2
    }
    
    let emitter = SKEmitterNode(fileNamed: "PlayerHitWall")
    if node.physicsBody!.categoryBitMask &
      PhysicsCategory.Water != 0 {
        emitter.particleTexture = SKTexture(imageNamed: "WaterDrop")
    }
    
    emitter.particleTexture!.filteringMode = .Nearest
    emitter.position = position
    emitter.zPosition = node.zPosition + 1
    
    emitter.runAction(SKAction.removeFromParentAfterDelay(1.0))
    backgroundLayer.addChild(emitter)
  }
  
  // show a white circle at tap position
  func showTapAtLocation(point: CGPoint) {
    let path = UIBezierPath(ovalInRect:
      CGRect(x: -3, y: -3, width: 6, height: 6))
    
    let shapeNode = SKShapeNode()
    shapeNode.path = path.CGPath
    shapeNode.position = point
    shapeNode.strokeColor = SKColorWithRGBA(255, 255, 255, 196)
    shapeNode.lineWidth = 1
    shapeNode.antialiased = false
    shapeNode.zPosition = 90
    worldNode.addChild(shapeNode)
    
    let duration = 0.6
    let scaleAction = SKAction.scaleTo(6.0, duration: duration)
    scaleAction.timingMode = .EaseOut
    shapeNode.runAction(SKAction.sequence(
      [scaleAction, SKAction.removeFromParent()]))
    
    let fadeAction = SKAction.fadeOutWithDuration(duration)
    fadeAction.timingMode = .EaseOut
    shapeNode.runAction(fadeAction)
  }
  
  func showParticlesForDog(dog: SKNode) {
    let emitter = SKEmitterNode(fileNamed: "DogSplatter")
    
    emitter.particleTexture!.filteringMode = .Nearest
    emitter.position = dog.position
    
    emitter.runAction(SKAction.removeFromParentAfterDelay(0.4))
    backgroundLayer.addChild(emitter)
  }
}
