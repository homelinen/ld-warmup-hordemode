# Simple Game in CoffeeScript

PushPop = ->
    blocks = new SpriteList
    player = new Sprite {x:0, y: 0}
    robot = new Sprite {x:0, y: 0}
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
        player = new Sprite {image: "img/shotgun.png", x: blockSize, y: playerLevel , anchor: "top-left"}
        player.flip()
        playerFacing = "right"

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
            if playerFacing == "right"
                player.flip()
                playerFacing = "left"
                player.move(-blockSize, 0)

            player.move(-2, 0)
        if (pressed("right")) 
            if playerFacing == "left"
                player.flip()
                playerFacing = "right"
                player.move(blockSize, 0)
                
            player.move(2, 0)
        if pressed("up") 
            player.rotate(-5)
        if pressed("down")
            player.rotate(5)
        if pressed("space")
            console.log "Shoot!"

        moveTowardsPlayer robot

        if robot.x == player.x
            console.log "Hurt Player"
        return
    @draw = ->
        jaws.clear() 
        blocks.draw()
        player.draw()
        robot.draw()
        return
    
    moveTowardsPlayer = (sprite) ->
        # Move an enemy closer to the player
        # sprite The sprite to be moved

        playX = player.x
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
        
    turnSprite = (sprite) ->
        direction = - 1
        sprite.flip()
        sprite.move(blockSize * direction)
    
    return @

jaws.onload = ->
    jaws.unpack()
    jaws.assets.add("img/block.png")
    jaws.assets.add("img/shotgun.png")
    jaws.assets.add("img/robot.png")
    jaws.start PushPop
    return
