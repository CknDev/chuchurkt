;; console.log to display
(var display (function (value) (console.log value)))

;; console.warn to wanr
(var warn (function (value) (console.warn value)))

;; round a position
(var round (function (value)
                     (parseInt value 10)))


;; array : array to list
(var list (function (...args) (array ...args)))

;; head
(var car (function (list) list[0]))

;; listen to event
(var listen (function (name fn)
                      (document.addEventListener name (function (e) (fn e)))))

;; tail
(var cdr (function (list) (list.slice 1)))

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
;; select mode navigation <-> arrow
(var selectMode "navigation")
(domSelectMode selectMode)

(var tileInit (function()
                         (set tileSet (new Image))
                         (set tileSet.src "./dist/assets/tileset.png")
                         tileSet))
(var TILE_SIZE (list 25 15)) ;; px
(var WIN_WIDTH 800) ;; px
(var WIN_HEIGHT 600) ;; px
(var CANVAS_MAIN ($ "canvas.main"))
(var CANVAS_GROUND ($ "canvas.ground"))
(var CANVAS_SELECTION ($ "canvas.selection"))
(var CANVAS_ARROW ($ "canvas.arrow"))
(var block_size TILE_SIZE)

(var main (ctx CANVAS_MAIN))
(var ground (ctx CANVAS_GROUND))
(var selection (ctx CANVAS_SELECTION))
(var arrow (ctx CANVAS_ARROW))
(main.scale 1.0 1.0)
(ground.scale 1.0 1.0)
(selection.scale 1.0 1.0)
(arrow.scale 1.0 1.0)

(var spriteSheet (tileInit))
(set spriteSheet.onload (function () (arrow.drawImage spriteSheet 50 0 50 50 0 0 25 15)))

(var clearMainCanvas (function ()
                               (clr CANVAS_MAIN.width CANVAS_MAIN.height main)))
(var clearSelectionCanvas (function ()
                                    (clr
                                     CANVAS_SELECTION.width
                                     CANVAS_SELECTION.height
                                     selection)))

(tilify 0 0 WIN_WIDTH WIN_HEIGHT (car TILE_SIZE) (car (cdr TILE_SIZE)) ground)
(var block_selected (list 0 0))
(write "^" (centerize (list (* 4 (car block_size)) 0) block_size) arrow)
(display (centerize (list 0 0) block_size))

(listen "keyup" (function (e)
                          (e.preventDefault)
                          (cond (= e.keyCode keyboard.SPACE)
                                (set selectMode (toggleMode selectMode)))
                          (cond (= e.keyCode keyboard.UP)
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


(var x 0)
(var update (setInterval
             (function()
                      (clearMainCanvas)
                      (set x (+ x 15)) ;; vel.x
                      (if (= x 800) (clearInterval update))
                      (rect (list x 0) block_size main)
                      (select block_selected block_size selection)
                      (background "red" main))
             100))
