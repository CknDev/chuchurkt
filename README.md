# ChuChuRockt

![status](https://img.shields.io/badge/status-aborted-lightgrey.svg)
[![game jam lisp](https://img.shields.io/badge/gamejam-true-ff69b4.svg)][gamejam]
[![license](https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=2592000)][licence]

Clone of [ChuChuRocket][chuchurocket], a Dreamcast game by the Sonic Team.

Made in [lispyscript][lispyscript], for the [Spring Lisp Game Jam 2016][gamejam].


# How to 

## Launch game

The compiled files are shipped with in ``./dist/``, the game is playable
by opening ``./ìndex.html``

## Play game

### During edit mode: 

+ Move with ``arrows``.
+ To put a direction press ``SPACE`` then the ``arrow`` 
  corresponding to the direction.


## Development

You will need [nodejs][nodejs] and [npm][npm] installed, in order to compile
the game.

Source are located in ``./src/``.

To compile, do:

```bash
# from ./src/main.lsp to ./dist/main.js
$ npm run lisp
```

[chuchurocket]: https://en.wikipedia.org/wiki/ChuChu_Rocket!
[lispyscript]: http://lispyscript.com/
[gamejam]: https://itch.io/jam/spring-2016-lisp-game-jam
[nodejs]: https://nodejs.org
[npm]: https://www.npmjs.com
[licence]: https://github.com/CknDev/chuchurkt/blob/master/LICENSE
