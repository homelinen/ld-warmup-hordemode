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

        robotSprite = new Sprite {
            image: "img/robot.png", 
            x: jaws.width - blockSize, 
            y: playerLevel - blockSize
        }
        robot = new Creature robotSprite, 5, "right"
        robot.turn("left")
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

        robot.turn(moveTowardsPlayer robot)

        if doCollide(player, robot)
            console.log "Hurt Player"

        if !player.alive
            jaws.switchGameState(MenuState)
        return
    @draw = ->
        jaws.clear() 
        blocks.draw()
        player.sprite.draw()
        robot.sprite.draw()
        return
    
    moveTowardsPlayer = (creature) ->
        # Move an enemy closer to the player
        # creature The sprite to be moved

        playX = player.sprite.x
        sprX = creature.sprite.x

        #This is the speed of the movement
        xVal = 1

        if playX < sprX
            #Move Left, as player is left
            xVal = -xVal
            dir = "left"
        else if playX == sprX
            xVal = 0
            dir = "right"

        creature.move xVal, 0
        dir
        
    doCollide = (creature1, creature2) ->

        minx1 = creature1.sprite.x
        minx2 = creature2.sprite.x

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
        @alive = true

    hurt: (damage) ->
        @health = @health - damage
        if @health < 1
            @alive = false

    turn: (dir) -> 
        speed = @sprite.rect.width

        console.log speed
        if dir == "right"
            speed = -speed

        if @direction != dir
            @sprite.flip()
            @direction = dir

            @sprite.move(speed, 0)

    move: (x, y) ->
        @sprite.move x, y

    rotate: (angle) ->
        # Extend this to make rotation work properly
        @sprite.rotate(angle)

MenuState = ->
    items = [
        "Start",
        "Highscore"
    ]
    index = 0

    @setup = ->
        index = 0
        jaws.on_keydown(["down", "s"], ->
            if (index + 1) < items.length
                index++
        )
        jaws.on_keydown(["up", "w"], ->
            if (index - 1) >= 0
                index--
        )
        jaws.on_keydown(["enter", "space"], ->
            if items[index] == "Start"
                jaws.switchGameState(PushPop)
        )
        return

    @draw = ->
        jaws.context.clearRect(0,0,jaws.width,jaws.height)
        jaws.context.font = "bold 50pt Serif"
        jaws.context.lineWidth = 10
        jaws.context.fillStyle = "Black"
        jaws.context.strokeStyle = "rgba(200,200,200, 0.0)"
        i = 0
        colour = ""
        for item in items
            colour = if i == index then "Red" else "Black"
            jaws.context.fillStyle = colour 
            jaws.context.fillText(item, 30, 100 + i * 60)
            i++
        return

    @

jaws.onload = ->
    jaws.unpack()
    jaws.assets.add("img/block.png")
    jaws.assets.add("img/shotgun.png")
    jaws.assets.add("img/robot.png")
    jaws.start MenuState
    return
