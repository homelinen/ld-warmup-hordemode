# Simple Game in CoffeeScript

PushPop = ->
    blocks = new SpriteList
    player = null
    robot = null
    blockSize = 32
    playerFacing = ""

    @setup = ->

        jaws.log(jaws.width)
        block = "img/block.png"
        yLevel = 7 * blockSize
        arenaLength = (jaws.width / blockSize) - 1
        # Skip the 5th block
        for xPos in [0..arenaLength] 
            blocks.push new Sprite { image: block, x: (xPos * blockSize), y: yLevel }

        jaws.log "Blocks: #{blocks}"
        tile_map = new TileMap { cell_size: [32,32]}
        jaws.log "Reached: #{tile_map}"
        tile_map.push blocks

        jaws.log "#{tile_map}"
        playerLevel = yLevel - blockSize
        playerSprite = new Sprite {image: "img/shotgun.png", x: blockSize, y: playerLevel , anchor: "top-left"}
        player = new Creature playerSprite, 10, "left"
        player.turn("right")

        robot = new Sprite {
            image: "img/robot.png", 
            x: jaws.width - blockSize, 
            y: playerLevel - blockSize
        }
        robot.flip()
        jaws.preventDefaultKeys ["up", "down", "left", "right", "space"]
        return

    @update = ->
        if (pressed("left")) 
            player.turn("left")
            player.move(-2, 0)
        if (pressed("right")) 
            player.turn("right")
            player.move(2, 0)
        if pressed("up") 
            player.rotate(-5)
        if pressed("down")
            player.rotate(5)
        if pressed("space")
            console.log "Shoot!"

        moveTowardsPlayer robot

        if doCollide(player, robot)
            console.log "Hurt Player"
        return
    @draw = ->
        jaws.clear() 
        blocks.draw()
        player.sprite.draw()
        robot.draw()
        return
    
    moveTowardsPlayer = (sprite) ->
        # Move an enemy closer to the player
        # sprite The sprite to be moved

        playX = player.sprite.x
        sprX = sprite.x

        #This is the speed of the movement
        xVal = 1

        if playX < sprX
            #Move Left, as player is left
            xVal = -xVal
        else if playX == sprX
            xVal = 0

        sprite.move xVal, 0
        return
        
    doCollide = (sprite1, sprite2) ->

        minx1 = sprite1.x
        minx2 = sprite2.x

        maxx1 = minx1 + blockSize
        maxx2 = minx2 + blockSize

        if minx1 < maxx2 && minx1 > minx2
            true
        else if minx2 < maxx1 && minx2 > minx1
            true
        else 
            false

    return @

class Creature
    constructor: (@sprite, @health, @direction) ->

    hurt: (damage) ->
        @health = @health - damage

    turn: (dir) -> 
        speed = @sprite.rect.width
        if @direction != dir
            @sprite.flip()
            @direction = dir
            @sprite.move(-speed, 0)

    move: (x, y) ->
        @sprite.move x, y

    rotate: (angle) ->
        # Extend this to make rotation work properly
        @sprite.rotate(angle)

jaws.onload = ->
    jaws.unpack()
    jaws.assets.add("img/block.png")
    jaws.assets.add("img/shotgun.png")
    jaws.assets.add("img/robot.png")
    jaws.start PushPop
    return
