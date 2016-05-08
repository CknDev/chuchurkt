;; console.log to display
(var display (function (value) (console.log value)))

;; console.warn to wanr
(var warn (function (value) (console.warn value)))

;; newline
(var newline (function () (console.log "")))

;; round a position
(var round (function (value)
                     (parseInt value 10)))

;; flip a fn
(var flip (function (fn) (function (a b) (fn b a))))

;; always false 
(var f (function () false))

;; always true
(var t (function () true))

;; list : array to list
(var list (function (...args) (array ...args)))


;; cons : push an element to a list
(var cons (function (element l)
                    (l.push element)
                    l))

;; concat : concat 2 lists in one 
(var concat (function (a b acc)
                      (each a (function (element) (acc.push element)))
                      (each b (function (element) (acc.push element)))
                      acc))

;; reverse: reverse a list
(var reverse (function (list) (list.reverse)))

;; head
(var car (function (list) list[0]))

;; tail
(var cdr (function (list) (list.slice 1)))

;; listen to event
(var listen (function (name fn)
                      (document.addEventListener name (function (e) (fn e)))))

;; jquery.$
(var $ (function (element) (document.querySelector element)))

;; get context
(var ctx (function (canvas) (canvas.getContext "2d")))

;; centerize: center a canvas element 
(var centerize (function(position size)
     (var x (car position))
     (var y (car (cdr position)))
     (var w (car size))
     (var h (car (cdr size)))
     (list (round (+ x (/ w 2))) (round(+ y (/ h 2))))))

;; write text to canvas
(var write (function (text position ctx)
                     (set ctx.font "12px Verdana")
                     (var padd (/ 12 3))
                     (var x (- (car position) padd))
                     (var y (+ (car (cdr position)) padd))
                     (ctx.fillText text x y)))

;; draw a sprite
(var drawSprite (function (source destination image ctx)
                      (set [sx, sy, sw, sh] source)
                      (set [dx, dy, dw, dh] destination)
                      (ctx.drawImage image
                                     sx sy sw sh
                                     dx dy dw dh)))

;; draw a rectangle
(var rect (function (position size ctx)
                    (ctx.beginPath)
                    (ctx.rect (car position) (car (cdr position))
                              (car size) (car (cdr size)))))

;; stroke last object
(var stroke (function (ctx) (ctx.stroke)))

;; fill with color last object
(var background (function (color ctx)
                          (set ctx.fillStyle color)
                          (ctx.fill)))

;; clear canvas
(var clr (function (w h ctx) (ctx.clearRect 0 0 w h)))

;; tilify: construct a tileset
(var tilify (function(x y xMax yMax xTile yTile ctx)
                     (rect (list x y) (list xTile yTile) ctx)
                     (stroke ctx)
                     (if (= x xMax)
                         (if (= y yMax) false
                           (tilify 0 (+ y yTile) xMax yMax xTile yTile ctx))
                       (tilify (+ x xTile) y xMax yMax xTile yTile ctx))))

;; highlight current selected tile
(var select (function(position size ctx)
                        (rect position size ctx)
                        (background "green" ctx)))

;; move selection in navigation mode
(var moveSelect (function (currentDirection padd selectionBlock)
                          ;; enum direction
                          (var direction (object UP "UP"
                                                 RIGHT "RIGHT"
                                                 DOWN "DOWN"
                                                 LEFT "LEFT"))
                          (var x (car selectionBlock))
                          (var y (car (cdr selectionBlock)))
                          (var xPadd (car padd))
                          (var yPadd (car (cdr padd)))
                          (cond
                           (= currentDirection direction.UP)
                            (list x (- y yPadd))
                           (= currentDirection direction.RIGHT)
                            (list (+ x xPadd) y)
                           (= currentDirection direction.DOWN)
                            (list x (+ y yPadd))
                           (= currentDirection direction.LEFT)
                            (list (- x xPadd) y))))


;; user arrow counter 
(var hasMaxArrow (function (arrows) (if (= arrows MAX_ARROW) true false)))

;; append arrow counter to dom
(var domArrowCounter (function (arrowCounter)
                               (var el($ ".arrow-counter"))
                               (set el.innerHTML arrowCounter)))
(var domArrowMax (function (max)
                           (var el($ ".arrow-max"))
                           (set el.innerHTML max)))

;; render inventory in a separate canvas from the game' ones
(var renderInventory (function (arrowList image ctx)
                               (var arrowTileSet
                                    (object UP    (list 0 0 50 50)
                                            RIGHT (list 50 0 50 50)
                                            DOWN  (list 100 0 50 50)
                                            LEFT  (list 150 0 50 50)))
                               (var slotsPosition
                                    (list (list 0 0 50 50)
                                          (list 70 0 50 50)
                                          (list 140 0 50 50)
                                          (list 210 0 50 50)))
                               (clearInventoryCanvas)
                               (each arrowList
                                     (function (arrow index)
                                               (drawSprite arrowTileSet[arrow]
                                                           slotsPosition[index]
                                                           image
                                                           ctx)))))

;; put a direction in arrow mode
(var arrowSelect (function (currentDirection
                            image
                            sizeBlock
                            selectedBlock
                            inventory
                            board
                            inventoryCtx
                            ctx)
                           ;; arrow tileSet
                           (if (false? (hasArrow currentDirection inventory))
                              (list inventory board)
                           ((function ()
                                     (var arrowTileSet (object UP (list 0 0 50 50)
                                                               RIGHT (list 50 0 50 50)
                                                               DOWN (list 100 0 50 50)
                                                               LEFT (list 150 0 50 50)))
                                      (var x (car selectedBlock))
                                      (var y (car (cdr selectedBlock)))
                                      (set [dw, dh] sizeBlock)

                                      ;; transfer arrow from inventory to board
                                      (set transfer (toBoardArrow currentDirection
                                                                  inventory
                                                                  board))
                                      (set [inventory, board] transfer)

                                      ;; clear block where the arrow will be put
                                      (ctx.clearRect x y dw dh)
                                      (set boardArrowPosition
                                           (addArrowPosition selectedBlock
                                                             boardArrowPosition
                                                             []))

                                      ;; compute arrow collision box
                                      (set padd 5)
                                      (set center_size (list (- (car block_size)
                                                                5)
                                                             (- (car (cdr block_size))
                                                                5)))

                                      ;; render arrow
                                      (drawSprite arrowTileSet[currentDirection] 
                                                  (list x y dw dh)
                                                  image
                                                  ctx)

                                      ;; render arrow collision box
                                      ;; debug purpose
                                      ;; TODO: remove
                                      (each boardArrowPosition
                                            (function (position)
                                                      (set center
                                                           (centerize position
                                                                      center_size))
                                                      (rect center
                                                            (list 5 5)
                                                            ctx)
                                                      (background "blue" ctx)
                                                      ))


                                      ;; render inventory arrows
                                      (renderInventory inventory
                                                       image
                                                       inventoryCtx)
                                      (list inventory
                                            board
                                            (countBoard board 0)))))))

;; append select mode to dom
(var domSelectMode (function(currentMode)
                            (var el($ ".select-mode"))
                            (set el.innerHTML currentMode)))

;; toggle mode
(var toggleMode (function (currentMode)
                          (var modes (list "navigation" "arrow"))
                          (if (= currentMode (car modes))
                              (domSelectMode (car(cdr modes)))
                            (domSelectMode (car modes)))
                          (cond
                           (= currentMode (car modes)) (car (cdr modes)) 
                           (= currentMode (car (cdr modes))) (car modes))))

;; check if arrow is in the inventory
(var hasArrow (function (currentArrow arrowList)
                              (if (undefined? (car arrowList)) (f)
                                (if (= currentArrow (car arrowList))
                                    (t)
                                  (hasArrow currentArrow (cdr arrowList))))))

;; count board arrows took
(var countBoard (function (arrowList acc)
                          (if (undefined? (car arrowList))
                              acc
                            (if (!= (car arrowList) "")
                                (countBoard (cdr arrowList) (+ acc 1))
                              (countBoard (cdr arrowList) acc)))))

;; remove arrow from an arrow list
(var removeArrow (function (currentArrow arrowList acc found)
                           (if (true? found) acc
                             (if (= (car arrowList) currentArrow)
                                 (removeArrow currentArrow
                                              arrowList
                                              (concat acc (cdr arrowList) [])
                                              true)
                               (if (undefined? (car arrowList))
                                  (removeArrow currentArrow arrowList acc true)
                                 (removeArrow currentArrow
                                              (cdr arrowList)
                                              (cons (car arrowList) acc)
                                              false))))))

;; remove arrow position of the position list
(var removeArrowPosition (function (currentPosition arrowList acc found) 
                                   (set [x, y] (car arrowList))
                                   (if (true? found)
                                       acc
                                     (if (&& (= x (car currentPosition))
                                             (= y (car (cdr currentPosition))))
                                         (removeArrowPosition currentPosition
                                                              arrowList
                                                              (concat acc
                                                                      (cdr arrowList)
                                                                      [])
                                                              true)
                                       (if (undefined? (car arrowList))
                                           (removeArrowPosition currentPosition
                                                                arrowList
                                                                acc true)
                                         (removeArrowPosition currentPosition
                                                              (cdr arrowList)
                                                              (cons (car arrowList) acc)
                                                              false))))))

;; add arrow to an arrow list
;; find where the empty ("") slot is and replace by current Arrow
;; if all slots of the list are took add it to begining of the list
(var addArrow (function (currentArrow arrowList acc)
                        (cond (undefined? acc) (set acc []))
                        (if (= (car arrowList) "")
                            (concat acc
                                    (concat (list currentArrow) (cdr arrowList) [])
                                    [])
                          (if (undefined? (car arrowList))
                              (concat (list currentArrow) (cdr (reverse acc)) [])
                            (addArrow currentArrow
                                      (cdr arrowList)
                                      (concat (list (car arrowList)) acc []))))))

;; add arrow position
(var addArrowPosition (function (currentPosition arrowList acc)
                                (cond (undefined? acc) (set acc []))
                                (var defaultPosition (list -100 -100))
                                (set [x, y] (car arrowList))
                                (if (&& (= x (car defaultPosition))
                                        (= y (car (cdr defaultPosition))))
                                    (concat acc
                                            (concat (list currentPosition) (cdr arrowList) [])
                                            [])
                                  (if (undefined? (car arrowList))
                                      (concat currentPosition (cdr (reverse acc)) [])
                                    (addArrowPosition currentPosition (cdr arrowList)
                                              (concat (list (car arrowList)) acc []))))))

;; transferArrow: put an arrow from a list to another
(var transferArrow (function (arrow origin dest)
                             (var from (removeArrow arrow origin [] false))
                             (var to (addArrow arrow dest []))
                             (list from to)))


;; isEmptyInventory: check if inventory is empty
(var isEmptyInventory (function (inventory)
                            (var ln inventory.length)
                            (var index 0)
                            (each inventory
                                  (function (item)
                                            (if (= item "")
                                                (set index (+ index 1)))))
                            (if (= index ln) (t) (f))))

;; isEmptyBoard : check if board is empty
(var isEmptyBoard (function (board)
                            (var ln board.length)
                            (var index 0)
                            (each board
                                  (function (item)
                                            (if (!= (car item) -100)
                                                (set index (+ index 1)))))
                            (if (= index 0) (t) (f))))

;; toBoardArrow: pick an arrow from the inventory and put it in the board
;; return the board if (no arrow left in inventory) or (arrow not in inventory)
(var toBoardArrow (function (arrow inventory board)
                            (if (|| (true? (isEmptyInventory inventory))
                                 (false? (hasArrow arrow inventory)))
                                board
                              (transferArrow arrow inventory board))))

;; toInventoryArrow : (reverse toBoardArrow)
(var toInventoryArrow (function (arrow inventory board)
                                (if (true? (isEmptyInventory inventory))
                                    (f)
                                  (transferArrow arrow board inventory))))

;; Array.prototype.fill
(var fill (function (iteration list) (list.fill iteration)))

;; Array.prototype.length
(var length (function (list) list.length))

;; keyboard events
(var keyboard (object UP 38
                      RIGHT 39
                      DOWN 40
                      LEFT 37
                      SPACE 32))
;; arrow tileSet
(var arrowTileSet (list (object UP (list 0 0 50 0))
                        (object RIGHT (list 50 0 50 0))
                        (object DOWN (list 100 0 50 0))
                        (object LEFT (list 150 0 50 0))))

;; select mode navigation <-> arrow
(var selectMode "navigation")

(domSelectMode selectMode)

(var tileInit (function()
                         (set tileMap (new Image))
                         (set tileMap.src "./dist/assets/tileset.png")
                         tileMap))
(var TILE_SIZE (list 25 15)) ;; px
(var WIN_WIDTH 800) ;; px
(var WIN_HEIGHT 600) ;; px
(var GAME_WIDTH 270)
(var GAME_HEIGHT 130)
(var GAME_BOX (list GAME_WIDTH GAME_HEIGHT))
(var CANVAS_MAIN ($ "canvas.main"))
(var CANVAS_GROUND ($ "canvas.ground"))
(var CANVAS_SELECTION ($ "canvas.selection"))
(var CANVAS_ARROW ($ "canvas.arrow"))
(var CANVAS_INVENTORY ($ "canvas.inventory"))
(var block_size TILE_SIZE)

(var main (ctx CANVAS_MAIN))
(var ground (ctx CANVAS_GROUND))
(var selection (ctx CANVAS_SELECTION))
(var arrow (ctx CANVAS_ARROW))
(var inventory (ctx CANVAS_INVENTORY))
(main.scale 1.0 1.0)
(ground.scale 1.0 1.0)
(selection.scale 1.0 1.0)
(arrow.scale 1.0 1.0)
(inventory.scale 1.0 1.0)

(var spriteSheet (tileInit))

(var clearMainCanvas (function ()
                               (clr CANVAS_MAIN.width CANVAS_MAIN.height main)))
(var clearSelectionCanvas (function ()
                                    (clr CANVAS_SELECTION.width
                                     CANVAS_SELECTION.height
                                     selection)))
(var clearInventoryCanvas (function ()
                                    (clr CANVAS_INVENTORY.width
                                         CANVAS_INVENTORY.height
                                         inventory)))

(tilify 0 0 WIN_WIDTH WIN_HEIGHT (car TILE_SIZE) (car (cdr TILE_SIZE)) ground)
(var block_selected (list 0 0))

(var listenTo(function (e)
                       (e.preventDefault)
                       (domArrowCounter arrowCounter)
                       (cond (= e.keyCode keyboard.SPACE)
                             (set selectMode (toggleMode selectMode)))
                       (cond (= selectMode "navigation")
                             ((cond (= e.keyCode keyboard.UP)
                                    (clearSelectionCanvas
                                     (set block_selected
                                          (moveSelect "UP"
                                                      block_size
                                                      block_selected))))
                              (cond (= e.keyCode keyboard.RIGHT)
                                    (clearSelectionCanvas
                                     (set block_selected
                                          (moveSelect "RIGHT"
                                                      block_size
                                                      block_selected))))
                              (cond (= e.keyCode keyboard.DOWN)
                                    (clearSelectionCanvas
                                     (set block_selected
                                          (moveSelect "DOWN"
                                                      block_size
                                                      block_selected))))
                              (cond (= e.keyCode keyboard.LEFT)
                                    (clearSelectionCanvas
                                     (set block_selected
                                          (moveSelect "LEFT"
                                                      block_size
                                                      block_selected))))))
                       (cond (= selectMode "arrow")
                             (if (true? (hasMaxArrow arrowCounter))
                                 (f)
                               ((cond (= e.keyCode keyboard.UP)
                                      (set [inventoryArrowList,
                                           boardArrowList,
                                           arrowCounter]
                                           (arrowSelect "UP"
                                                        spriteSheet
                                                        block_size
                                                        block_selected
                                                        inventoryArrowList
                                                        boardArrowList
                                                        inventory
                                                        arrow))
                                      (= e.keyCode keyboard.RIGHT)
                                      (set [inventoryArrowList,
                                           boardArrowList,
                                           arrowCounter]
                                           (arrowSelect "RIGHT"
                                                        spriteSheet
                                                        block_size
                                                        block_selected
                                                        inventoryArrowList
                                                        boardArrowList
                                                        inventory
                                                        arrow))
                                      (= e.keyCode keyboard.DOWN)
                                      (set [inventoryArrowList,
                                           boardArrowList,
                                           arrowCounter]
                                           (arrowSelect "DOWN"
                                                        spriteSheet
                                                        block_size
                                                        block_selected
                                                        inventoryArrowList
                                                        boardArrowList
                                                        inventory
                                                        arrow))
                                      (= e.keyCode keyboard.LEFT)
                                      (set [inventoryArrowList,
                                           boardArrowList,
                                           arrowCounter]
                                           (arrowSelect "LEFT"
                                                        spriteSheet
                                                        block_size
                                                        block_selected
                                                        inventoryArrowList
                                                        boardArrowList
                                                        inventory
                                                        arrow))))))
                       false))

;; current arrow putted in the board
;; debug purpose
(var arrowCounter 0)

;; available arrows for current stage
;; immutable
(var levelArrowList (list "UP" "DOWN" "LEFT" "LEFT"))
(var MAX_ARROW levelArrowList.length)

;; stack of arrows available for the player
;; mutable
;; init to the levelArrowList
;; must match the levelArrowList length
(var inventoryArrowList levelArrowList)

;; stack of arrows putted on the board
;; mutable
;; init to list of empty items
;; must match levelArrowList length
(var boardArrowList (list "" "" "" ""))

;; positions of arrows putted on the board
;; mutable
(var boardArrowPosition (list (list -100 -100)
                              (list -100 -100)
                              (list -100 -100)
                              (list -100 -100)))

;; arrow counter
;; debug purpose
(domArrowCounter arrowCounter)

;; MAX_ARROW
;; debug purpose
(domArrowMax MAX_ARROW)


;; block init
;; debug purpose
(var mouse (list 0 120))
(set [x,y] mouse)

;; movements
(var goUp (function (y velocity)
                    (- y velocity)))
(var goLeft (function (x velocity)
                      (- x velocity)))
(var goDown (function (y velocity)
                      (+ y velocity)))
(var goRight (function(x velocity)
                      (+ x velocity)))


(var isRightCorner (function (x) (>= x GAME_WIDTH)))
(var isBottomCorner (function (y) (> y GAME_HEIGHT)))
(var isTopCorner (function (y) (<= y 0)))
(var isLeftCorner (function (x) (<= x 0)))

;; game box collision
(var checkCollideGame (function(position gameBox)
                               (set [x, y] position)
                               (set [w, h] gameBox)
                               (||
                                (|| (<= x 0) (<= y 0))
                                (|| (> x w) (> y h)))))
(var collideTopGame (function (position gameBox)
                              (set [x, y] position)
                              (set [w, h] gameBox)
                              (<= y 0)))

(var collideBottomGame (function (position gameBox)
                                 (set [x, y] position)
                                 (set [w, h] gameBox)
                                 (> y h)))

(var collideRightGame (function (position gameBox)
                                (set [x, y] position)
                                (set [w, h] gameBox)
                                (> x w)))

(var collideLeftGame (function (position gameBox)
                               (set [x, y] position)
                               (set [w, h] gameBox)
                               (<= x 0)))

;; redirectTop: redirect entity direction
;; when collide with top
;; when coming from bottom
(var redirectTop (function (position)
                              (set [x, y] position)
                              (cond
                               (true? (|| (false? (isRightCorner x))
                                          (false? (isLeftCorner x)))) "LEFT"
                              (true? (isRightCorner x)) "LEFT"
                              (true? (isLeftCorner x)) "RIGHT")))

;; redirectBottom: redirect entity direction
;; when collide with bottom
;; when coming from top
(var redirectBottom (function (position)
                              (set [x, y] position)
                              (cond
                               (true? (|| (false? (isRightCorner x))
                                       (false? (isLeftCorner x)))) "RIGHT"
                                       (true? (isRightCorner x)) "LEFT"
                                       (true? (isLeftCorner x)) "RIGHT")))

;; redirectRight: redirect entity direction
;; when collide with right
;; when coming from left
(var redirectRight (function (position)
                             (set [x, y] position)
                             (cond
                                 (true? (isBottomCorner y)) "UP"
                                 (true? (isTopCorner y))"DOWN"
                                 (true? (|| (false? (isBottomCorner y))
                                         (false? (isTopcorner y)))) "UP")))

;; redirectLeft: redirect entity direction
;; when collide with left
;; when coming from right
(var redirectLeft (function (position)
                            (set [x, y] position)
                            (cond
                             (true? (isBottomCorner y)) "UP"
                             (true? (isTopCorner y))"DOWN"
                             (true? (|| (false? (isBottomCorner y))
                                     (false? (isTopcorner y)))) "DOWN")))

;; collideEntityArrows: check collision between one entiy and a list of arrows
(var collideEntityArrows (function (ent arrows)
                                   (set [x, y] ent)
                                   (var i -1)
                                   (each arrows (function (arrow index)
                                                         (set [aX, aY] arrow)
                                                         (if (&& (= x aX)
                                                                 (= y aY))
                                                             (set i index))))
                                   i))

;; speed states 
(var resetSpeed (function () 0))
(var normalSpeed (function () 5))
(var lowSpeed (function () 1))
(var highSpeed (function() 10))

;; spawn entity
(var spawnEntity (function (spawnPosition size ctx)
                           (var spawnEntity spawnPosition)
                           (rect spawnPosition size ctx)
                           (background "red" ctx)
                           spawnEntity))

;; move entity
(var moveEntity (function (position velocity direction)
                          (var entity position)
                          (cond
                           (= direction "UP")
                           (set entity (list (car position)
                                             (goUp (car (cdr position))
                                                   (car(cdr velocity)))))
                           (= direction "RIGHT")
                           (set entity (list (goRight (car position)
                                                      (car velocity))
                                             (car (cdr position))))
                           (= direction "DOWN")
                           (set entity (list (car position)
                                             (goDown (car (cdr position))
                                                     (car (cdr velocity)))))
                           (= direction "LEFT")
                           (set entity (list (goLeft (car position)
                                                     (car velocity))
                                             (car (cdr position)))))
                          entity))
;; spawn a mouse
(var ent (spawnEntity mouse block_size main))
(var init true)
(var currentDirection -1)

;; main loop
;;;; TODO: arrow direction doesnt work since skybox collision overrides it
;;;;  indexBoard will go to 0 for a sec then go back
;;;;  to the direction of the skybox collision
;;;; We want it to keep the velocity to the direction of arrowDirection 
(var update (function () (setInterval
             (function()
                      (clearMainCanvas)
                      (if (> (car (cdr ent)) GAME_HEIGHT) (clearInterval update)
                        (if (true? init)
                        (set ent (moveEntity ent
                                             (list (normalSpeed) (normalSpeed))
                                             "RIGHT"))))
                      (when (true? (checkCollideGame ent GAME_BOX))
                        (set init false)

                        (when (false? (isEmptyBoard boardArrowPosition))
                          (set indexBoard (collideEntityArrows ent
                                                               boardArrowPosition))
                          (cond (!= indexBoard -1)
                                (set currentDirection indexBoard)))

                        (cond
                         (true? (collideBottomGame ent GAME_BOX))
                         (set ent (moveEntity ent
                                              (list (normalSpeed) (resetSpeed))
                                              (redirectBottom ent))))
                        (cond
                         (true? (collideLeftGame ent GAME_BOX))
                         (set ent (moveEntity ent
                                              (list (resetSpeed) (normalSpeed))
                                              (redirectLeft ent))))
                        (cond
                         (true? (collideTopGame ent GAME_BOX))
                         (set ent (moveEntity ent
                                              (list (normalSpeed) (resetSpeed))
                                              (redirectTop ent))))
                        (cond
                         (true? (collideRightGame ent GAME_BOX))
                         (set ent (moveEntity ent
                                              (list (resetSpeed) (normalSpeed))
                                              (redirectRight ent)))))


                      (when (!= -1 currentDirection)
                        (set ent (moveEntity ent 
                                             ;; TODO: conditional based on currentDirection
                                             (list (normalSpeed) (resetSpeed))
                                             boardArrowList[currentDirection])))

                      (when (false? (isEmptyBoard boardArrowPosition))
                        (set indexBoard (collideEntityArrows ent
                                                             boardArrowPosition))
                        (cond (!= indexBoard -1)
                              (set currentDirection indexBoard)))

                      (select block_selected block_size selection)
                      (rect ent block_size main)
                      (background "red" main))
             100)))

;; load sprites then init game
;; (var renderInventory (function (arrowList image ctx)
(set spriteSheet.onload (function ()
                                  (renderInventory inventoryArrowList
                                                   spriteSheet
                                                   inventory)
                                  (listen "keyup" (function (e) (listenTo e)))
                                  (update)))

