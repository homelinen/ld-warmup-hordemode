# Simple Game in CoffeeScript

LEFT = -1
RIGHT = 1

PushPop = (menu) ->
    blocks = new SpriteList
    player = null
    robot = null
    bulletSprite = null
    bullets = []
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
        player = new Creature playerSprite, 10, LEFT
        player.turn(RIGHT)

        robotSprite = new Sprite {
            image: "img/robot.png", 
            x: jaws.width - blockSize, 
            y: playerLevel - blockSize
        }
        robot = new Creature robotSprite, 5, RIGHT
        robot.turn LEFT
        jaws.preventDefaultKeys ["up", "down", "left", "right", "space"]

        bulletSprite = new Sprite { image: "img/bullet.png", x: 0, y: 0 }
        return

    @update = ->
        if (pressed("left")) 
            player.turn(LEFT)
            player.move(-2, 0)
        if (pressed("right")) 
            player.turn(RIGHT)
            player.move(2, 0)
        if pressed("up") 
            player.rotate(-5)
        if pressed("down")
            player.rotate(5)
        if pressed("space")
            tempBullet = bulletSprite
            tempBullet.moveTo player.sprite.x, player.sprite.y
            bullets.push { sprite: tempBullet, direction: player.direction }
            console.log "Shoot!"

        robot.turn(moveTowardsPlayer robot)

        if doCollide(player, robot)
            player.hurt(1)

        for bullet in bullets
            bullet.sprite.move(bullet.direction, 0)

        if !player.alive
            jaws.switchGameState(menu)
        return

    @draw = ->
        jaws.clear() 
        blocks.draw()
        player.sprite.draw()
        robot.sprite.draw()

        for bullet in bullets
            bullet.sprite.draw()
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
            dir = LEFT
        else if playX == sprX
            xVal = 0
            dir = RIGHT

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

        if dir == RIGHT
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

class Menu
    constructor: (@items) ->
        console.log "Items: #{items}"
        @index = 0;

    setup: ->
        console.log "Setup, items: #{@items}"
        @index = 0
        jaws.preventDefaultKeys ["up", "down", "left", "right", "space"]
        return

    update: ->

        if pressed "down" || pressed "s"
            if (@index + 1) < @items.length
                @index++
        if pressed "up" || pressed "w"
            if (@index - 1) >= 0
                @index--
        if pressed "enter" || pressed "space"
            jaws.switchGameState(@items[@index].func) if @items[@index].func?
    draw: ->
        jaws.context.clearRect(0,0,jaws.width,jaws.height)
        jaws.context.font = "bold 50pt Serif"
        jaws.context.lineWidth = 10
        jaws.context.fillStyle = "Black"
        jaws.context.strokeStyle = "rgba(200,200,200, 0.0)"
        i = 0
        colour = ""
        for item in @items
            colour = if i == @index then "Red" else "Black"
            jaws.context.fillStyle = colour 
            jaws.context.fillText(item.name, 30, 100 + i * 60)
            i++
        return

    addMenu:(menu) ->
        # Add a menu item to the end of the list
        @items.push menu
        return

jaws.onload = ->

    MenuState = new Menu([
        {name: "Start", func: ->
            PushPop(HighScore)
        }
    ])

    HighScore = new Menu([
        {name: "Score 1: 5", func: null},
        { name: "Main Menu", func: MenuState }
    ])

    MenuState.addMenu { name: "Highscore", func: HighScore }
    jaws.unpack()
    jaws.assets.add("img/block.png")
    jaws.assets.add("img/shotgun.png")
    jaws.assets.add("img/robot.png")
    jaws.start MenuState
    return
