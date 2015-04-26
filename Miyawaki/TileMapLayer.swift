
import SpriteKit

class TileMapLayer : SKNode {
  
  let tileSize: CGSize
  var atlas: SKTextureAtlas?
  let gridSize: CGSize
  let layerSize: CGSize
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("NSCoding not supported")
  }
  
  init(tileSize: CGSize, gridSize: CGSize,
      layerSize: CGSize? = nil) {
    self.tileSize = tileSize
    self.gridSize = gridSize
    if layerSize != nil {
      self.layerSize = layerSize!
    } else {
      self.layerSize =
        CGSize(width: tileSize.width * gridSize.width,
               height: tileSize.height * gridSize.height)
    }
    super.init()
  }
  
  convenience init(atlasName: String, tileSize: CGSize,
    tileCodes: [String]) {
    self.init(tileSize: tileSize,
              gridSize: CGSize(width: count(tileCodes[0]),
              height: tileCodes.count))
    
    atlas = SKTextureAtlas(named: atlasName)
    
    for row in 0..<tileCodes.count {
      let line = tileCodes[row]
      for (col, code) in enumerate(line) {
        if let tile = nodeForCode(code) {
          tile.position = positionForRow(row, col: col)
          addChild(tile)
        }
      }
    }
  }
  
  func nodeForCode(tileCode: Character) -> SKNode? {
    // 1
    if atlas == nil {
      return nil
    }
    // 2
    var tile: SKNode?
    switch tileCode {
      case "=":
        tile = SKSpriteNode(texture: atlas!.textureNamed("pink"))
        tile!.name = "background"
      
      case "o":
        tile = SKSpriteNode(texture: atlas!.textureNamed("green"))
        tile!.name = "background"
        
      case "w":
        tile = SKSpriteNode(texture: atlas!.textureNamed(
        CGFloat.random() < 0.1 ? "water2" : "water1"))

        if let t = tile as? SKSpriteNode {
          t.physicsBody = SKPhysicsBody(rectangleOfSize: t.size)
          t.physicsBody!.categoryBitMask = PhysicsCategory.Water
          t.physicsBody!.dynamic = false
          t.physicsBody!.friction = 0
        }
      
      case ".":
        return nil
      
      case "b":
        tile = Dog()

      case "p":
        tile = Player()

      case "t":
        if CGFloat.random() < 0.33 {
          tile = Breakable(wholeTexture: atlas!.textureNamed("shortcake"),
          brokenTexture: atlas!.textureNamed("green"),
          flyAwayTexture: atlas!.textureNamed("shortcake-flyaway"))
        } else if 0.33...0.66 ~= CGFloat.random() {
          tile = Breakable(wholeTexture: atlas!.textureNamed("choco"),
          brokenTexture: atlas!.textureNamed("green"),
          flyAwayTexture: atlas!.textureNamed("choco-flyaway"))
        } else {
          tile = Breakable(wholeTexture: atlas!.textureNamed("house"),
          brokenTexture: atlas!.textureNamed("green"),
          flyAwayTexture: atlas!.textureNamed("house-flyaway"))
        }
    
      case "u":
        if CGFloat.random() < 0.5 {
          tile = Breakable(wholeTexture: atlas!.textureNamed("applepie"),
          brokenTexture: atlas!.textureNamed("pink"),
          flyAwayTexture: atlas!.textureNamed("applepie-flyaway"))
        } else {
          tile = Breakable(wholeTexture: atlas!.textureNamed("montblanc"),
          brokenTexture: atlas!.textureNamed("pink"),
          flyAwayTexture: atlas!.textureNamed("montblanc-flyaway"))
        }

      case "f":
        tile = RedDog()

      case "1":
        tile = SKSpriteNode(texture: atlas!.textureNamed("wall-1"))
        
        if let t = tile as? SKSpriteNode {
            t.physicsBody = SKPhysicsBody(rectangleOfSize: t.size)
            t.physicsBody!.categoryBitMask = PhysicsCategory.Wall
            t.physicsBody!.dynamic = false
            t.physicsBody!.friction = 0
        }
        
      case "2":
        tile = SKSpriteNode(texture: atlas!.textureNamed("wall-2"))
        
        if let t = tile as? SKSpriteNode {
            t.physicsBody = SKPhysicsBody(rectangleOfSize: t.size)
            t.physicsBody!.categoryBitMask = PhysicsCategory.Wall
            t.physicsBody!.dynamic = false
            t.physicsBody!.friction = 0
        }
        
      case "3":
        tile = SKSpriteNode(texture: atlas!.textureNamed("wall-3"))
        
        if let t = tile as? SKSpriteNode {
            t.physicsBody = SKPhysicsBody(rectangleOfSize: t.size)
            t.physicsBody!.categoryBitMask = PhysicsCategory.Wall
            t.physicsBody!.dynamic = false
            t.physicsBody!.friction = 0
        }

      case "4":
        tile = SKSpriteNode(texture: atlas!.textureNamed("wall-4"))
        
        if let t = tile as? SKSpriteNode {
            t.physicsBody = SKPhysicsBody(rectangleOfSize: t.size)
            t.physicsBody!.categoryBitMask = PhysicsCategory.Wall
            t.physicsBody!.dynamic = false
            t.physicsBody!.friction = 0
        }
        
      case "5":
        tile = SKSpriteNode(texture: atlas!.textureNamed("wall-5"))
        
        if let t = tile as? SKSpriteNode {
            t.physicsBody = SKPhysicsBody(rectangleOfSize: t.size)
            t.physicsBody!.categoryBitMask = PhysicsCategory.Wall
            t.physicsBody!.dynamic = false
            t.physicsBody!.friction = 0
        }
        
      case "6":
        tile = SKSpriteNode(texture: atlas!.textureNamed("wall-6"))
        
        if let t = tile as? SKSpriteNode {
            t.physicsBody = SKPhysicsBody(rectangleOfSize: t.size)
            t.physicsBody!.categoryBitMask = PhysicsCategory.Wall
            t.physicsBody!.dynamic = false
            t.physicsBody!.friction = 0
        }
        
      case "7":
        tile = SKSpriteNode(texture: atlas!.textureNamed("wall-7"))
        
        if let t = tile as? SKSpriteNode {
            t.physicsBody = SKPhysicsBody(rectangleOfSize: t.size)
            t.physicsBody!.categoryBitMask = PhysicsCategory.Wall
            t.physicsBody!.dynamic = false
            t.physicsBody!.friction = 0
        }
        
      case "8":
        tile = SKSpriteNode(texture: atlas!.textureNamed("wall-8"))
        
        if let t = tile as? SKSpriteNode {
            t.physicsBody = SKPhysicsBody(rectangleOfSize: t.size)
            t.physicsBody!.categoryBitMask = PhysicsCategory.Wall
            t.physicsBody!.dynamic = false
            t.physicsBody!.friction = 0
        }
        
      case "9":
        tile = SKSpriteNode(texture: atlas!.textureNamed("wall-9"))
        
        if let t = tile as? SKSpriteNode {
            t.physicsBody = SKPhysicsBody(rectangleOfSize: t.size)
            t.physicsBody!.categoryBitMask = PhysicsCategory.Wall
            t.physicsBody!.dynamic = false
            t.physicsBody!.friction = 0
        }

      case "i":
        tile = SKSpriteNode(texture: atlas!.textureNamed("wall-i"))
        
        if let t = tile as? SKSpriteNode {
            t.physicsBody = SKPhysicsBody(rectangleOfSize: t.size)
            t.physicsBody!.categoryBitMask = PhysicsCategory.Wall
            t.physicsBody!.dynamic = false
            t.physicsBody!.friction = 0
        }
        
      case "j":
        tile = SKSpriteNode(texture: atlas!.textureNamed("wall-j"))
        
        if let t = tile as? SKSpriteNode {
            t.physicsBody = SKPhysicsBody(rectangleOfSize: t.size)
            t.physicsBody!.categoryBitMask = PhysicsCategory.Wall
            t.physicsBody!.dynamic = false
            t.physicsBody!.friction = 0
        }
        
      case "k":
        tile = SKSpriteNode(texture: atlas!.textureNamed("wall-k"))
        
        if let t = tile as? SKSpriteNode {
            t.physicsBody = SKPhysicsBody(rectangleOfSize: t.size)
            t.physicsBody!.categoryBitMask = PhysicsCategory.Wall
            t.physicsBody!.dynamic = false
            t.physicsBody!.friction = 0
        }
        
      case "l":
        tile = SKSpriteNode(texture: atlas!.textureNamed("wall-l"))
        
        if let t = tile as? SKSpriteNode {
            t.physicsBody = SKPhysicsBody(rectangleOfSize: t.size)
            t.physicsBody!.categoryBitMask = PhysicsCategory.Wall
            t.physicsBody!.dynamic = false
            t.physicsBody!.friction = 0
        }
        
      case "m":
        tile = SKSpriteNode(texture: atlas!.textureNamed("wall-m"))
        
        if let t = tile as? SKSpriteNode {
            t.physicsBody = SKPhysicsBody(rectangleOfSize: t.size)
            t.physicsBody!.categoryBitMask = PhysicsCategory.Wall
            t.physicsBody!.dynamic = false
            t.physicsBody!.friction = 0
        }
        
      case "n":
        tile = SKSpriteNode(texture: atlas!.textureNamed("wall-n"))
        
        if let t = tile as? SKSpriteNode {
            t.physicsBody = SKPhysicsBody(rectangleOfSize: t.size)
            t.physicsBody!.categoryBitMask = PhysicsCategory.Wall
            t.physicsBody!.dynamic = false
            t.physicsBody!.friction = 0
        }
        
      default:
        println("Unknown tile code \(tileCode)")
    }
    // 3
    if let sprite = tile as? SKSpriteNode {
      sprite.blendMode = .Replace
      sprite.texture?.filteringMode = .Nearest
    }
    return tile
  }
  
  func positionForRow(row: Int, col: Int) -> CGPoint {
    let x = CGFloat(col) * tileSize.width + tileSize.width / 2
    let y = CGFloat(row) * tileSize.height + tileSize.height / 2
    return CGPoint(x: x, y: layerSize.height - y)
  }
  
  func isValidTileCoord(coord: CGPoint) -> Bool {
    return (
      coord.x >= 0 &&
      coord.y >= 0 &&
      coord.x < gridSize.width &&
      coord.y < gridSize.height)
  }
  
  func coordForPoint(point: CGPoint) -> CGPoint {
    return CGPoint(x: Int(point.x / tileSize.width),
                   y: Int((point.y - layerSize.height) / -tileSize.height))
  }
  
  func pointForCoord(coord: CGPoint) -> CGPoint {
    return positionForRow(Int(coord.y), col: Int(coord.x))
  }
  
  func tileAtCoord(coord: CGPoint) -> SKNode? {
    return tileAtPoint(pointForCoord(coord))
  }
  
  func tileAtPoint(point: CGPoint) -> SKNode? {
    var node : SKNode? = nodeAtPoint(point)
    while node !== self && node?.parent !== self {
      node = node?.parent
    }
    return node?.parent === self ? node : nil
  }

  func textureNamed(name: String) -> SKTexture {
    return atlas!.textureNamed(name)
  }
}

