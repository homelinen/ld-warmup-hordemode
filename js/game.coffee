# BotHordia
#
# Author: Calum Gilchrist 
# Site: http://CalumGilchrist.co.uk
#
# All the Main Game Logic Code

LEFT = -1
RIGHT = 1

PushPop = (menu) ->
    blocks = new SpriteList
    player = null
    robots = []
    bulletSprite = null
    bullets = []
    blockSize = 32
    playerFacing = ""
    canSpawn = true
    startTime = 0
    dT = 0.0
    lastTime = 0
    yLevel = 0
    fps = document.getElementById("fps")
    score = 0

    @setup = ->
        
        date = new Date()
        startTime = date.getTime()

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
        playerSprite = new Sprite {
            image: "img/shotgun.png", 
            x: jaws.width / 2 ,
            y: playerLevel,
            anchor: "top-left"
        }
        player = new Creature playerSprite, 10, LEFT
        player.turn(RIGHT)
        player.can_fire = true
        player.bulletMax = 6
        player.bulletCount = 6

        spawnRobot()
        jaws.preventDefaultKeys ["up", "down", "left", "right", "space"]

        bulletSprite = new Sprite { image: "img/bullet.png", x: 0, y: 0 }
        lastTime = startTime - date.getTime()

        fps.innerHTML = "FPS: #{jaws.game_loop.fps}"
        setInterval( ->
            fps.innerHTML = "FPS: #{jaws.game_loop.fps}"
        , 200)

        score = 0
        return

    @update = ->
        date = new Date()
        # Delta time
        curTime = date.getTime() - startTime
        dT = ((curTime / lastTime) - 1) * 200
        lastTime = curTime

        if (pressed("left")) 
            player.turn(LEFT)
            player.move(-2 , 0)
        if (pressed("right")) 
            player.turn(RIGHT)
            player.move(2, 0)
        if pressed("up") 
            player.rotate(-5)
        if pressed("down")
            player.rotate(5)
        if pressed("r")
            reload()
        if pressed("space")
            if player.can_fire
                if player.bulletCount < 1
                    reload()
                else
                    tempBullet = new Sprite { 
                        image: "img/bullet.png", 
                        x: player.sprite.x, 
                        y: player.sprite.y 
                    }
                    bullets.push { 
                        sprite: tempBullet,
                        direction: player.direction 
                    }
                    player.bulletCount--
                    player.can_fire = false
                    setTimeout( ->
                        player.can_fire = true 
                    , 400 * getAdjustedDT() 
                    )

        i = 0
        while i < robots.length
            robot = robots[i]
            if !robot.alive
                score++
                robots.splice(i, 1)
                i--
            if robot?
                moveTowardsPlayer robot

                if doCollide(player, robot)
                    player.hurt(1)
                    robot.alive = false

                j= 0
                while j< bullets.length
                    bullet = bullets[j]
                    if doCollide(robot, bullet)
                        robot.hurt(1)
                        bullets.splice(j, 1)
                        j--;
                    j++

            i++
        
        i = 0
        while i < bullets.length
            bullet = bullets[i]
            bulletSpeed = 5
            bullet.sprite.move(bullet.direction * bulletSpeed, 0)
            if bullet.sprite.x > jaws.width || bullet.sprite.x < 0
                bullets.splice(i, 1)
                i--;
            i++
            
        if !player.alive
            jaws.switchGameState(menu)

        spawnRobot()

        return

    @draw = ->
        jaws.clear() 
        blocks.draw()
        player.sprite.draw()
        for robot in robots
            robot.sprite.draw()

        for bullet in bullets
            bullet.sprite.draw()

        drawHud()
        return
    
    spawnRobot = ->
        # Add a robot every 2 seconds to a side of the screen

        enemyLevel = yLevel - (blockSize * 2)
        if canSpawn
            xPos = 0 - blockSize;
            if getRandBoolean()
                xPos = jaws.width
            robotSprite = new Sprite {
                image: "img/robot.png", 
                x: xPos, 
                y: enemyLevel
            }
            robot = new Creature robotSprite, 2, RIGHT
            robot.turn LEFT
            robots.push robot
            canSpawn = false

            timeout = 2000 * getAdjustedDT()

            setTimeout( ->
                canSpawn = true
            , timeout)

            return

    reload = -> 
        player.can_fire = false
        setTimeout( ->
            player.can_fire = true 
            player.bulletCount = player.bulletMax
        , 2000 * getAdjustedDT() 
        )

    moveTowardsPlayer = (creature) ->
        # Move an enemy closer to the player
        # creature The sprite to be moved

        playX = player.sprite.x
        sprX = creature.sprite.x

        #This is the speed of the movement
        xVal = 1
        dir = RIGHT

        if playX < sprX
            #Move Left, as player is left
            xVal = -xVal
            dir = LEFT

        creature.turn dir
        creature.move xVal, 0
    
    getAdjustedDT = ->
        # Adjust the Delta Time to something reasonable
        dTloc = dT
        upperLimit = 2
        lowerLimit = 0.5

        if dTloc > upperLimit
            dTloc = upperLimit
        else if dTloc < lowerLimit
            dTloc = lowerLimit
        dTloc
            
    getRandBoolean = ->
        rand = Math.random()

        if rand > 0.5
            true
        else
            false

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

    drawHud = ->
        items = ["Ammo: #{player.bulletCount}/#{player.bulletMax}", "Health: #{player.health}", "Score: #{score}"]
        jaws.context.font = "bold 12pt Serif"
        jaws.context.lineWidth = 2
        jaws.context.fillStyle = "Black"
        jaws.context.strokeStyle = "rgba(200,200,200, 0.0)"
        i = 0
        for item in items
            jaws.context.fillText(item, 10 + 120 * i, 16)
            i++
        return

    return @


class Creature
    constructor: (@sprite, @health, @direction) ->
        @alive = true
        @isHurt = false

    hurt: (damage) ->
        if !@ishurt
            @health = @health - damage
            if @health < 1
                @alive = false
            @isHurt = true
            setTimeout( -> 
                @isHurt = false
            , 500)

    turn: (dir) -> 
        speed = @sprite.rect.width

        if dir == RIGHT
            speed = 0

        if @direction != dir
            @sprite.flip()
            @direction = dir

            @sprite.move(-speed, 0)

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
