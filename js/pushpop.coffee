# Simple Game in CoffeeScript

PushPop = ->
    blocks = new SpriteList
    player = new Sprite {x:0, y: 0}
    blockSize = 32
    playerFacing = ""

    @setup = ->

        block = "img/block.png"
        yLevel = 7 * blockSize
        # Skip the 5th block
        for xPos in [0,1,2,3,4,6,7,8,9] 
            blocks.push new Sprite { image: block, x: (xPos * blockSize), y: yLevel }

        blocks.push new Sprite { image: block, x: 5 * blockSize, y: yLevel + blockSize}
        tile_map = new TileMap { size: [10, 10], cell_size: [32,32]}
        tile_map.push blocks

        player = new Sprite {image: "img/shotgun.png", x: blockSize, y: yLevel - blockSize , anchor: "top-left"}
        player.flip()
        playerFacing = "right"

        jaws.preventDefaultKeys ["up", "down", "left", "right", "space"]
        return

    @update = ->
        if (pressed("left")) 
            if playerFacing == "right"
                player.flip()
                playerFacing = "left"
                player.move(-blockSize, 0)

            player.move(-1, 0)
        if (pressed("right")) 
            if playerFacing == "left"
                player.flip()
                playerFacing = "right"
                player.move(blockSize, 0)
                
            player.move(1, 0)
        if pressed("up") 
            player.rotate(-5)
        if pressed("down")
            player.rotate(5)
        if pressed("space")
            console.log "Shoot!"

        return
    @draw = ->
        jaws.clear() 
        blocks.draw()
        player.draw()
        return

    return @

jaws.onload = ->
    jaws.unpack()
    jaws.assets.add("img/block.png")
    jaws.assets.add("img/shotgun.png")
    jaws.start PushPop
    return
