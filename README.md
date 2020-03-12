# DeepTownOpt

Rock Bites Game "Deep town" emulator written in [Nim](https://nim-lang.org).  
And also, optimizer powered by [DEAP](https://github.com/DEAP/deap).

I'm now on 677m, so not all conditions are covered.

# Install

```bash
git clone https://github.com/ikarino/DeepTownOpt
nimble build
```

# Usage

## Emulator

```bash
$ deeptown --help
Usage:
  deeptown [required&optional-params]
Options:
  -h, --help                           print this cligen-erated help
  --help-syntax                        advanced: prepend,plurals,..
  -s=, --seconds=    int     86400     time to run[s]
  -i=, --inputfile=  string  REQUIRED  set inputfile
```

Please check out [inp1.json](https://github.com/ikarino/DeepTownOpt/blob/master/inputs/inp1.json).  
Almost all inputs are listed there.

## Optimizer

Currently not documented.

Please check out [test2.py](https://github.com/ikarino/DeepTownOpt/blob/master/python/test2.py) !

# Implementation

## Supported Bot tasks

- Boost Smelting
- Boost Crafting
- Boost Gardening
- Mine Resources
- Boost Jewelcrafting
- Boost Chemistry Floor production

## Calculation formula for duration time with Bot boost

Currently, the formula of crafting duration is as follows.

```nim
numBot = 2
duration = 60
boostedDuration = round(duration.float / 1.205^numBot).Natural
```

This formula satisfies the table below.

| Item       | Original[s] | Single Boost[s] | Double Boost[s] |
| :--------- | ----------: | --------------: | --------------: |
| CopperBar  |          10 |               8 |               6 |
| IronBar    |          15 |              12 |              10 |
| SteelBar   |          45 |              37 |              31 |
| GoldBar    |          60 |              49 |              41 |
| SteelPlate |         120 |              99 |              83 |

## Boosting with crystals

Not supported eternally.

# TODO

- [ ] emulator
  - [x] MiningStation
  - [x] ChemicalMining
  - [x] Smelting
  - [x] Crafting
  - [x] Chemistry
  - [x] JewelCrafting
  - [x] Greenhouse
  - [x] Bots
  - [ ] ~~OilPump~~
  - [ ] ~~WaterCollector~~
  - [x] Online/Offline
  - [ ] input cheker
- [ ] optimizer
  - [x] coin optimizer
  - [ ] guild event optimizer
