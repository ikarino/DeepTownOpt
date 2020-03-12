# DeepTownOpt

Rock Bites Game "Deep town" emulator written in [Nim](https://nim-lang.org).
And also, optimizer powered by [pyomo](http://www.pyomo.org/) is comming soon !

I'm now on 677m, so not all covered.

# Install

```bash
git clone https://github.com/ikarino/DeepTownOpt
nimble build
```

# Usage

# Implementation

## Supported Bot tasks

- Boost Crafting
- Boost Gardening
- Mine Resources
- Boost Jewelcrafting
- Boost Chemistry Floor production

## Calculation formula for duration time with Bot boost

Currently, the duration of crafting formula is as follows.

```nim
numBot = 2
duration = 60
boostedDuration = round(duration.float / (1+0.1668*numBot))
```

| Item       | Original[s] | Single Boost[s] | Double Boost[s] |
| :--------- | ----------: | --------------: | --------------: |
| CopperBar  |          10 |               8 |               6 |
| IronBar    |          15 |              12 |                 |
| SteelBar   |          45 |              37 |                 |
| GoldBar    |          60 |              49 |              41 |
| SteelPlate |         120 |             109 |                 |

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
  - [ ] OilPump
  - [ ] Bots
  - [ ] ~~WaterCollector~~
  - [x] Online/Offline
- [ ] optimizer
