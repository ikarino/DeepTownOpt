import tables, json, strutils

import data, buildings

type
  Miner = ref object of RootObj
    s: Store
    mss: seq[MiningStation]
    cs: seq[Crafting]
    cms: seq[ChemicalMining]
    offline: bool
    tradingLevel: Natural

proc newMiner*(j: JsonNode): Miner =
  var s: Store = {Item.Coal: Natural(0)}.newTable()
  var mss: seq[MiningStation]
  var cms: seq[ChemicalMining]
  var cs: seq[Crafting]

  let offline = j["config"]["offline"].getBool()

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
    cs.add(newCrafting(
      parseEnum[Item](node.getStr())
    ))

  for k in j["InitialStore"].getFields().keys:
    let item = parseEnum[Item](k)
    let num = j["InitialStore"][k].getInt().Natural
    s[item] = num

  s.init(mss, cms, cs)

  Miner(
    s: s,
    mss: mss,
    cms: cms,
    cs: cs,
    offline: offline
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

  m.s.toCoin().float / seconds.float
