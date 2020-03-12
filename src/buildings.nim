import tables, random, math
import data

type
  Crafting* = ref object of RootObj
    product: Item
    recipe*: Recipe
    count: Natural
    nboost: Natural
  MiningStation* = ref object of RootObj
    floor: Natural
    lv: Natural
    offline: bool
    speed: float
    count: Natural
    available: Table[Item, float]
    second: Natural
  ChemicalMining* = ref object of RootObj
    product: Item
    lv: Natural
    speed: Natural
    second: Natural
  MineResourceBot* = ref object of RootObj
    product: Item
    duration: Natural
    second: Natural
  BotAction* = enum
    BoostSmelting = "BoostSmelting"
    BoostCrafting = "BoostCrafting"
    BoostGardening = "BoostGardening"
    MineResources = "MineResources"
    BoostJewelcrafting = "BoostJewelcrafting"
    BoostChemistryFloorProduction = "BoostChemistryFloorProduction"

# -----------------------------------------------------------------------------

proc newCrafting*(product: Item, nboost: Natural = 0): Crafting =
  Crafting(
    product: product,
    recipe: getRecipe(product),
    count: 0,
    nboost: nboost
  )

proc tick*(b: Crafting, s: Store) =
  if b.count > 0:
    b.count -= 1
    if b.count == 0:
      for k, v in b.recipe.product.mpairs:
        s[k] += v
  else:
    for k, v in b.recipe.material.mpairs:
      if s[k] < v:
        return
    for k, v in b.recipe.material.mpairs:
      s[k] -= v
    b.count = round(b.recipe.duration.float / 1.205^b.nboost).Natural

proc cancel*(b: Crafting, s: Store) =
  if b.count > 0:
    for k, v in b.recipe.material.mpairs:
      s[k] += v

proc init*(
  s: var Store,
  mss: seq[MiningStation],
  cms: seq[ChemicalMining],
  cs: seq[Crafting],
  mrbs: seq[MineResourceBot]
  ) =
  for ms in mss:
    for item in ms.available.keys:
      if not s.hasKey(item):
        s[item] = 0
  for cm in cms:
    if not s.hasKey(cm.product):
      s[cm.product] = 0
  for c in cs:
    for item in c.recipe.material.keys:
      if not s.hasKey(item):
        s[item] = 0
    for item in c.recipe.product.keys:
      if not s.hasKey(item):
        s[item] = 0
  for mrb in mrbs:
    if not s.hasKey(mrb.product):
      s[mrb.product] = 0


# -----------------------------------------------------------------------------

proc newMiningStation*(floor: Natural, lv: Natural,
    offline: bool = false): MiningStation =
  MiningStation(
    floor: floor,
    lv: lv,
    offline: offline,
    speed: MiningStationRpm[lv-1],
    available: getMiningStationAvailable(floor),
    second: 0,
    count: 0
  )

proc getMaterial*(m: MiningStation): Item =
  let r = rand(100.0)
  var ptot = 0.0
  for item, p in m.available.mpairs:
    ptot += p
    if r < ptot:
      return item
  raise newException(DeepTownError, "proc getMaterial Failed: " & $m.floor)

proc tick*(m: MiningStation, s: var Store) =
  m.second += 1
  if m.second.float >= (m.count+1).float*60/m.speed:
    m.count += 1
    let item = m.getMaterial()
    s[item] += 1

  if m.second == 60:
    m.second = 0
    m.count = 0

# -----------------------------------------------------------------------------

proc newChemicalMining*(product: Item, lv: Natural): ChemicalMining =
  ChemicalMining(
    product: product,
    lv: lv,
    speed: ChemicalMiningRp10m[product][lv-1],
    second: 0,
  )

proc tick*(cm: ChemicalMining, s: var Store) =
  cm.second += 1
  if cm.second == 10*60:
    s[cm.product] += cm.speed
    cm.second = 0

# -----------------------------------------------------------------------------

proc newMineResouceBot*(product: Item, offline: bool): MineResourceBot =
  var duration: Natural
  if offline:
    duration = 20
  else:
    duration = 3
  MineResourceBot(
    product: product,
    duration: duration,
    second: 0
  )

proc tick*(mrb: MineResourceBot, s: var Store) =
  mrb.second += 1
  if mrb.second == mrb.duration:
    s[mrb.product] += 1
    mrb.second = 0
