# Conway Game of Life IOS

The Game of Life, also known simply as Life, is a cellular automaton devised by the British mathematician John Horton Conway in 1970.[1]


## Getting Started

This game follow the rules based on Conway's original Game of life

```
Any live cell with fewer than two live neighbours dies, as if caused by underpopulation.
Any live cell with two or three live neighbours lives on to the next generation.
Any live cell with more than three live neighbours dies, as if by overpopulation.
Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
```
![Conway Game of Life](https://ibb.co/b5vg0S)

Place your creatures into cells, play the button and watch amazing patterns forming.
```
If game world is empty cells the game ends whith a message.
If after 5 generations, game detects the same patterns repeating it stops and will not continue if there isn't any evolution on the creatures.
```

![Conway Game of Life](https://ibb.co/hHpVun)

### Prerequisites

Requires IOS 10 or earlier, tested on Iphone 6, 6S, SE, 8 or earlier versions.

For development requires XCode 9, Swift 4.0, MacOs High Sierra or earlier.

![XCode 9](https://ibb.co/gOiC77)


### And coding style tests

Follow Apple Coding Standards

```
public var generations: Int = 0

 enum GameStatus {
        case RUNNING
        case STOPPED
        case STABLE
        case OVER
        case PAUSED
    }
    
    func myFunc() -> Return {
        do something here...
    }
```

## Authors

* **Jose Barros** - *Initial work* - [JBarros35](https://github.com/jbarros35)

See also the list of [contributors](https://github.com/jbarros35/conwaygameoflife/contributors) who participated in this project.

## License

This project is licensed under the Apache 2.0 License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Game is open sourced and intended for educational purposes and fun.
