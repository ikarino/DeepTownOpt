import tables
import data

type
  MiningStation* = ref object
    floor: Natural
    lv: Natural
    offline: bool
    speed: float
    available: Table[Item, float]
    count: Natural

proc newMiningStation*(floor: Natural, lv: Natural,
    offline: bool = false): MiningStation =
  MiningStation(
    floor: floor,
    lv: lv,
    offline: offline,
    speed: miningStationRpm[lv-1],
    available: getMiningStationAvailable(floor)
  )

proc tick(m: MiningStation, s: var Store) =


