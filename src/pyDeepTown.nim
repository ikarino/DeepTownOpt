import tables, json
import nimpy
import miner, data

proc run(jsonString: string): tuple[coin: float, store: Table[string, int]] {.exportpy.} =
  let m = newMiner(jsonString.parseJson)
  let coins = m.calcCoin()

  result = (coin: coins, store: m.s.toTable())
