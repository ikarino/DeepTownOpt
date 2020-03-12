import tables, json, strutils, random

import data, buildings

type
  Miner = ref object of RootObj
    s: Store
    mss: seq[MiningStation]
    cs: seq[Crafting]
    cms: seq[ChemicalMining]
    mrbs: seq[MineResourceBot]
    offline: bool
    tradingLevel: Natural

proc newMiner*(j: JsonNode): Miner =
  var s: Store = {Item.Coal: Natural(0)}.newTable()
  var mss: seq[MiningStation]
  var cms: seq[ChemicalMining]
  var cs: seq[Crafting]
  var mrbs: seq[MineResourceBot]

  # config -----
  let offline = j["config"].getOrDefault("offline").getBool(false)
  let tradingLevel = j["config"].getOrDefault("tradingLevel").getInt().Natural
  let seed = j["config"].getOrDefault("seed").getInt(0)

  if seed != 0:
    randomize(seed)
  else:
    randomize()

  # bot -----
  var nboost: Table[Building, Natural] = {
    Building.Smelting: Natural(0),
    Building.Crafting: Natural(0),
    Building.Chemistry: Natural(0),
    Building.JewelCrafting: Natural(0),
    Building.Greenhouse: Natural(0)
  }.toTable()
  for node in j["bots"].getElems():
    let action = parseEnum[BotAction](node["action"].getStr())
    if action == BotAction.BoostSmelting:
      nboost[Building.Smelting] += 1
    elif action == BotAction.BoostCrafting:
      nboost[Building.Crafting] += 1
    elif action == BotAction.BoostChemistryFloorProduction:
      nboost[Building.Chemistry] += 1
    elif action == BotAction.BoostJewelCrafting:
      nboost[Building.JewelCrafting] += 1
    elif action == BotAction.BoostGardening:
      nboost[Building.Greenhouse] += 1

  # spots -----
  for node in j["MiningStation"].getElems():
    mss.add(newMiningStation(
      node["floor"].getInt().Natural,
      node["lv"].getInt().Natural,
      offline
    ))

  for node in j["ChemicalMining"].getElems():
    cms.add(newChemicalMining(
      parseEnum[Item](node["product"].getStr()),
      node["lv"].getInt().Natural
    ))

  for node in j["Crafting"].getElems():
    let product = parseEnum[Item](node.getStr())
    let r = getRecipe(product)
    cs.add(newCrafting(
      product,
      nboost[r.building]
    ))

  # init warehosue -----
  for k in j["InitialStore"].getFields().keys:
    let item = parseEnum[Item](k)
    let num = j["InitialStore"][k].getInt().Natural
    s[item] = num

  s.init(mss, cms, cs, mrbs)

  Miner(
    s: s,
    mss: mss,
    cms: cms,
    cs: cs,
    mrbs: mrbs,
    offline: offline,
    tradingLevel: tradingLevel
  )

proc tick(miner: Miner) =
  for ms in miner.mss:
    ms.tick(miner.s)
  for cm in miner.cms:
    cm.tick(miner.s)
  for c in miner.cs:
    c.tick(miner.s)

proc calcCoin*(m: Miner, seconds = 60*60*12): float =
  for t in 1..seconds:
    m.tick()

  m.s.toCoin(m.tradingLevel).float / seconds.float
