# Simple Game in CoffeeScript

PushPop = ->
    blocks = []
    tile_map = {}
    viewport = {}
    @setup = ->

        blockSize = 32
        blocks = new SpriteList
        block = "img/block.png"
        yLevel = 7 * blockSize
        for xPos in [0,1,2,3,4,6,7,8,9] 
            blocks.push(new Sprite({ image: block, x: (xPos * blockSize), y: yLevel }))

        blocks.push(new Sprite({ image: block, x: 5 * blockSize, y: yLevel + blockSize}))
        tile_map = new TileMap({ size: [10, 10], cell_size: [32,32]})
        tile_map.push blocks
        return

    @update = ->
        #What's wrong with you?
        a = 1
        return

    @draw = ->
        jaws.clear()
        
        blocks.draw()
        new Rect(0,0,20,20).draw
        return

    return @

jaws.onload = ->
    jaws.unpack()
    jaws.assets.add("img/block.png")
    jaws.start PushPop
    return
