import tables, strformat, math

type
  DeepTownError* = object of Exception
  Store* = TableRef[Item, Natural]
  Building* {.pure.} = enum
    Smelting = "Smelting"
    Crafting = "Crafting"
    Chemistry = "Chemistry"
    JewelCrafting = "JewelCrafting"
    Greenhouse = "Greenhouse"
  Recipe* = ref object
    material*: Table[Item, Natural]
    product*: Table[Item, Natural]
    duration*: Natural
    building*: Building
    unlockArea*: Natural
  Item* {.pure.} = enum
    # available in mining station
    Coal = "Coal"
    Copper = "Copper"
    Iron = "Iron"
    Amber = "Amber"
    Aluminium = "Aluminium"
    Silver = "Silver"
    Gold = "Gold"
    Platinum = "Platinum"
    TitaniumOre = "TitaniumOre"
    Emerald = "Emerald"
    Topaz = "Topaz"
    Ruby = "Ruby"
    Sapphire = "Sapphire"
    Amethyst = "Amethyst"
    Alexandrite = "Alexandrite"
    Obsidian = "Obsidian"
    Diamond = "Diamond"
    Uranium = "Uranium"
    Helium3 = "Helium3"

    # available in chemical mining
    Silicon = "Silicon"
    Sulfur = "Sulfur"
    Sodium = "Sodium"
    Nitrogen = "Nitrogen"

    # available in water collector
    Water = "Water"

    # available in oil pump
    Oil = "Oil"

    # available in Greenhouse
    TreeSeed = "TreeSeed"
    LianaSeed = "LianaSeed"
    GrapeSeed = "GrapeSeed"
    Tree = "Tree"
    Liana = "Liana"
    Grape = "Grape"

    # available in smelting
    # coal
    CopperBar = "CopperBar"
    IronBar = "IronBar"
    Glass = "Glass"
    AluminiumBar = "AluminiumBar"
    SteelBar = "SteelBar"
    SilverBar = "SilverBar"
    GoldBar = "GoldBar"
    SteelPlate = "SteelPlate"
    SteelPipe = "SteelPipe"
    TitaniumBar = "TitaniumBar"
    MagnetiteBar = "MagnetiteBar"

    # available in crafting
    Graphite = "Graphite"
    CopperNail = "CopperNail"
    Wire = "Wire"
    Battery = "Battery"
    Circuits = "Circuits"
    Lamp = "Lamp"
    LabFlask = "LabFlask"
    AmberCharger = "AmberCharger"
    AluminiumBottle = "AluminiumBottle"
    AmberInsulation = "AmberInsulation"
    InsulatedWire = "InsulatedWire"
    AluminiumTank = "AluminiumTank"
    Mirror = "Mirror"
    MirrorLasor = "MirrorLasor"
    GreenLaser = "GreenLaser"
    DiamondCutter = "DiamondCutter"
    MotherBoard = "MotherBoard"
    SolidPropellant = "SolidPropellant"
    Accumulator = "Accumulator"
    SolarPanel = "SolarPanel"
    Gear = "Gear"
    GasCylinder = "GasCylinder"
    Bomb = "Bomb"
    Compressor = "Compressor"
    OpticFiber = "OpticFiber"
    DryIce = "DryIce"
    OxygenCylinder = "OxygenCylinder"
    Magnet = "Magnet"
    ElectricalEngine = "ElectricalEngine"
    LcdMonitor = "LcdMonitor"

    # available in chemistry
    CleanWater = "CleanWater"
    Hydrogen = "Hydrogen"
    Oxygen = "Oxygen"
    Rubber = "Rubber"
    SulfuricAcid = "SulfuricAcid"
    Ethanol = "Ethanol"
    RefinedOil = "RefinedOil"
    PlasticPlate = "PlasticPlate"
    Titanium = "Titanium"
    DiethylEther = "DiethylEther"
    GunPowder = "GunPowder"
    LiquidNitrogen = "LiquidNitrogen"
    MagnetiteOre = "MagnetiteOre"
    EnhancedHelium3 = "EnhancedHelium3"
    ToxicBomb = "ToxicBomb"

    # availabe in jewel crafting
    PolishedAmber = "PolishedAmber"
    PolishedEmerald = "PolishedEmerald"
    AmberBracelet = "AmberBracelet"
    EmeraldRing = "EmeraldRing"
    PolishedTopaz = "PolishedTopaz"
    PolishedRuby = "PolishedRuby"
    PolishedDiamond = "PolishedDiamond"
    PolishedSapphire = "PolishedSapphire"
    PolishedAmethyst = "PolishedAmethyst"
    PolishedAlexandrite = "PolishedAlexandrite"
    PolishedObsidian = "PolishedObsidian"
    SapphireCrystalGlass = "SapphireCrystalGlass"
    MayaCalender = "MayaCalender"
    Haircomb = "Haircomb"
    ObsidianKnife = "ObsidianKnife"

    # available in uranium enrichment
    UraniumRod = "UraniumRod"


const MiningStationRpm*: array[9, float] = [3.0, 4.0, 5.0, 6.0, 8.0, 12.0, 15.0, 17.0, 20.0]
const ChemicalMiningRp10m*: Table[Item, array[4, Natural]] = {
  Item.Silicon: [Natural(5), Natural(7), Natural(15), Natural(20)],
  Item.Sulfur: [Natural(5), Natural(7), Natural(15), Natural(20)],
  Item.Sodium: [Natural(5), Natural(7), Natural(15), Natural(20)],
  Item.Nitrogen: [Natural(3), Natural(4), Natural(9), Natural(12)],
}.toTable()

proc `$`*(s: Store): string =
  result = "Stored Items:\n"
  for k, v in s.pairs:
    result &= fmt"  - {k:<20}: {v}" & "\n"

proc toCoin* (s: Store, portalLevel: Natural): Natural =
  for item, num in s.mpairs:
    case item:
    of Item.Coal: result += 1*num
    of Item.Copper: result += 2*num
    of Item.Iron: result += 3*num
    of Item.Amber: result += 4*num
    of Item.Aluminium: result += 5*num
    of Item.Silver: result += 7*num
    of Item.Gold: result += 10*num
    of Item.Platinum: result += 13*num
    of Item.TitaniumOre: result += 19*num
    of Item.Emerald: result += 12*num
    of Item.Topaz: result += 14*num
    of Item.Ruby: result += 15*num
    of Item.Sapphire: result += 16*num
    of Item.Amethyst: result += 18*num
    of Item.Alexandrite: result += 19*num
    of Item.Obsidian: result += 20*num
    of Item.Diamond: result += 18*num
    of Item.Uranium: result += 22*num
    of Item.Helium3: result += 400*num
    of Item.Silicon: result += 100*num
    of Item.Sulfur: result += 100*num
    of Item.Sodium: result += 100*num
    of Item.Nitrogen: result += 300*num
    of Item.Water: result += 5*num
    of Item.Oil: result += 21*num
    of Item.TreeSeed: result += 10*num
    of Item.LianaSeed: result += 1000*num
    of Item.GrapeSeed: result += 1200*num
    of Item.Tree: result += 193*num
    of Item.Liana: result += 1700*num
    of Item.Grape: result += 1500*num
    of Item.CopperBar: result += 25*num
    of Item.IronBar: result += 40*num
    of Item.Glass: result += 450*num
    of Item.AluminiumBar: result += 50*num
    of Item.SteelBar: result += 150*num
    of Item.SilverBar: result += 200*num
    of Item.GoldBar: result += 250*num
    of Item.SteelPlate: result += 1800*num
    of Item.SteelPipe: result += 4300*num
    of Item.TitaniumBar: result += 3000*num
    of Item.MagnetiteBar: result += 137000*num
    of Item.Graphite: result += 15*num
    of Item.CopperNail: result += 7*num
    of Item.Wire: result += 15*num
    of Item.Battery: result += 200*num
    of Item.Circuits: result += 2070*num
    of Item.Lamp: result += 760*num
    of Item.LabFlask: result += 800*num
    of Item.AmberCharger: result += 4*num
    of Item.AluminiumBottle: result += 55*num
    of Item.AmberInsulation: result += 125*num
    of Item.InsulatedWire: result += 750*num
    of Item.AluminiumTank: result += 450*num
    of Item.Mirror: result += 450*num
    of Item.MirrorLasor: result += 5400*num
    of Item.GreenLaser: result += 400*num
    of Item.DiamondCutter: result += 5000*num
    of Item.MotherBoard: result += 17000*num
    of Item.SolidPropellant: result += 27000*num
    of Item.Accumulator: result += 9000*num
    of Item.SolarPanel: result += 69000*num
    of Item.Gear: result += 18500*num
    of Item.GasCylinder: result += 30000*num
    of Item.Bomb: result += 55500*num
    of Item.Compressor: result += 44000*num
    of Item.OpticFiber: result += 10500*num
    of Item.DryIce: result += 25000*num
    of Item.OxygenCylinder: result += 173_000*num
    of Item.Magnet: result += 300_000*num
    of Item.ElectricalEngine: result += 745_000*num
    of Item.LcdMonitor: result += 90_000*num
    of Item.CleanWater: result += 1200*num
    of Item.Hydrogen: result += 400*num
    of Item.Oxygen: result += 900*num
    of Item.Rubber: result += 4000*num
    of Item.SulfuricAcid: result += 3500*num
    of Item.Ethanol: result += 4200*num
    of Item.RefinedOil: result += 16_500*num
    of Item.PlasticPlate: result += 40_000*num
    of Item.Titanium: result += 260*num
    of Item.DiethylEther: result += 17_000*num
    of Item.GunPowder: result += 2500*num
    of Item.LiquidNitrogen: result += 12_500*num
    of Item.MagnetiteOre: result += 12_500*num
    of Item.EnhancedHelium3: result += 190_000*num
    of Item.ToxicBomb: result += 77_500*num
    of Item.PolishedAmber: result += 70*num
    of Item.PolishedEmerald: result += 160*num
    of Item.PolishedTopaz: result += 200*num
    of Item.PolishedRuby: result += 250*num
    of Item.PolishedDiamond: result += 300*num
    of Item.PolishedSapphire: result += 230*num
    of Item.PolishedAmethyst: result += 250*num
    of Item.PolishedAlexandrite: result += 270*num
    of Item.PolishedObsidian: result += 280*num
    of Item.SapphireCrystalGlass: result += 5000*num
    of Item.UraniumRod: result += 17_000*num
    # [TODO] formula for trading item values must be confirmed.
    of Item.AmberBracelet: result += (215*num.float*(1+0.02*(portalLevel.float-1))).round.Natural
    of Item.EmeraldRing: result += (599*num.float*(1+0.02*(portalLevel.float-1))).round.Natural
    of Item.MayaCalender: result += (4609*num.float*(1+0.02*(portalLevel.float-1))).round.Natural
    of Item.Haircomb: result += (23769*num.float*(1+0.02*(portalLevel.float-1))).round.Natural
    of Item.ObsidianKnife: result += (47520*num.float*(1+0.02*(portalLevel.float-1))).round.Natural

proc toTable* (s: Store): Table[string, int] =
  for k, v in s.pairs:
    result[k.repr] = v.int


proc `$`* (r: Recipe): string =
  result = "Recipe\n"
  result &= fmt"  - duration: {r.duration}[s]" & "\n"
  result &= fmt"  - materials:" & "\n"
  for k, v in r.material.mpairs:
    result &= fmt"    * {k:<20}: {v}" & "\n"
  result &= fmt"  - product:" & "\n"
  for k, v in r.product.mpairs:
    result &= fmt"    * {k:<20}: {v}" & "\n"

let Recipes: Table[Item, Recipe] = {
  # smelting
  Item.CopperBar: Recipe(
    material: { Item.Copper: Natural(5) }.toTable(),
    product: { Item.CopperBar: Natural(1) }.toTable(),
    duration: 10,
    building: Building.Smelting,
    unlockArea: 0
  ),
  Item.IronBar: Recipe(
    material: { Item.Iron: Natural(5) }.toTable(),
    product: { Item.IronBar: Natural(1) }.toTable(),
    duration: 15,
    building: Building.Smelting,
    unlockArea: 0
  ),
  Item.AluminiumBar: Recipe(
    material: { Item.Aluminium: Natural(5) }.toTable(),
    product: { Item.AluminiumBar: Natural(1) }.toTable(),
    duration: 15,
    building: Building.Smelting,
    unlockArea: 25
  ),
  Item.Glass: Recipe(
    material: { Item.Silicon: Natural(2) }.toTable(),
    product: { Item.Glass: Natural(1) }.toTable(),
    duration: 60,
    building: Building.Smelting,
    unlockArea: 13
  ),
  Item.SteelBar: Recipe(
    material: { Item.IronBar: Natural(1), Item.Graphite: Natural(1) }.toTable(),
    product: { Item.SteelBar: Natural(1)}.toTable(),
    duration: 45,
    building: Building.Smelting,
    unlockArea: 37
  ),
  Item.SilverBar: Recipe(
    material: { Item.Silver: Natural(5) }.toTable(),
    product: { Item.SilverBar: Natural(1) }.toTable(),
    duration: 60,
    building: Building.Smelting,
    unlockArea: 37
  ),
  Item.Coal: Recipe(
    material: { Item.Tree: Natural(1) }.toTable(),
    product: { Item.Coal: Natural(50) }.toTable(),
    duration: 60,
    building: Building.Smelting,
    unlockArea: 40
  ),
  Item.GoldBar: Recipe(
    material: { Item.Gold: Natural(5) }.toTable(),
    product: { Item.GoldBar: Natural(1) }.toTable(),
    duration: 60,
    building: Building.Smelting,
    unlockArea: 49
  ),
  Item.SteelPlate: Recipe(
    material: { Item.SteelBar: Natural(5) }.toTable(),
    product: { Item.SteelPlate: Natural(1) }.toTable(),
    duration: 120,
    building: Building.Smelting,
    unlockArea: 61
    ),
  Item.TitaniumBar: Recipe(
    material: { Item.Titanium: Natural(5) }.toTable(),
    product: { Item.TitaniumBar: Natural(1) }.toTable(),
    duration: 60,
    building: Building.Smelting,
    unlockArea: 85
  ),
  Item.MagnetiteBar: Recipe(
    material: {Item.MagnetiteOre: Natural(5)}.toTable(),
    product: {Item.MagnetiteBar: Natural(1)}.toTable(),
    duration: 60,
    building: Building.Smelting,
    unlockArea: 109
  ),

  # crafting
  Item.Graphite: Recipe(
    material: { Item.Coal: Natural(5) }.toTable(),
    product: { Item.Graphite: Natural(1 )}.toTable(),
    duration: 5,
    building: Building.Crafting,
    unlockArea: 0
  ),
  Item.CopperNail: Recipe(
    material: { Item.CopperBar: Natural(1) }.toTable(),
    product: { Item.CopperNail: Natural(10) }.toTable(),
    duration: 20,
    building: Building.Crafting,
    unlockArea: 0
  ),
  Item.Wire: Recipe(
    material: { Item.CopperBar: Natural(1) }.toTable(),
    product: { Item.Wire: Natural(5) }.toTable(),
    duration: 30,
    building: Building.Crafting,
    unlockArea: 0
  ),
  Item.Battery: Recipe(
    material: { Item.Amber: Natural(1), Item.IronBar: Natural(1), Item.CopperBar: Natural(5) }.toTable(),
    product: { Item.Battery: Natural(1) }.toTable(),
    duration: 120,
    building: Building.Crafting,
    unlockArea: 13
  ),
  Item.Circuits: Recipe(
    material: { Item.IronBar: Natural(10), Item.Graphite: Natural(50), Item.CopperBar: Natural(50) }.toTable(),
    product: { Item.Circuits: Natural(1)}.toTable(),
    duration: 180,
    building: Building.Crafting,
    unlockArea: 13
  ),
  Item.Lamp: Recipe(
    material: { Item.CopperBar: Natural(5), Item.Wire: Natural(10), Item.Graphite: Natural(20) }.toTable(),
    product: { Item.Lamp: Natural(1) }.toTable(),
    duration: 80,
    building: Building.Crafting,
    unlockArea: 13
  ),
  Item.LabFlask: Recipe(
    material: { Item.Glass: Natural(1 )}.toTable(),
    product: { Item.LabFlask: Natural(1) }.toTable(),
    duration: 60,
    building: Building.Crafting,
    unlockArea: 13
  ),
  Item.AmberCharger: Recipe(
    material: { Item.Amber: Natural(5) }.toTable(),
    product: { Item.AmberCharger: Natural(1) }.toTable(),
    duration: 5,
    building: Building.Crafting,
    unlockArea: 24
  ),
  Item.AluminiumBottle: Recipe(
    material: { Item.AluminiumBar: Natural(1) }.toTable(),
    product: { Item.AluminiumBottle: Natural(1) }.toTable(),
    duration: 30,
    building: Building.Crafting,
    unlockArea: 24
  ),
  Item.AmberInsulation: Recipe(
    material: { Item.Amber: Natural(10), Item.AluminiumBottle: Natural(1) }.toTable(),
    product: { Item.AmberInsulation: Natural(1) }.toTable(),
    duration: 20,
    building: Building.Crafting,
    unlockArea: 24
  ),
  Item.InsulatedWire: Recipe(
    material: { Item.Wire: Natural(1), Item.AmberInsulation: Natural(1) }.toTable(),
    product: { Item.InsulatedWire: Natural(1) }.toTable(),
    duration: 200,
    building: Building.Crafting,
    unlockArea: 24
  ),
  Item.AluminiumTank: Recipe(
    material: { Item.AluminiumBar: Natural(3) }.toTable(),
    product: { Item.AluminiumTank: Natural(1) }.toTable(),
    duration: 120,
    building: Building.Crafting,
    unlockArea: 37
  ),
  Item.Mirror: Recipe(
    material: { Item.Glass: Natural(1), Item.SilverBar: Natural(1) }.toTable(),
    product: { Item.Mirror: Natural(1 )}.toTable(),
    duration: 120,
    building: Building.Crafting,
    unlockArea: 37
  ),
  Item.MirrorLasor: Recipe(
    material: { Item.Battery: Natural(1), Item.Lamp: Natural(1), Item.Mirror: Natural(3) }.toTable(),
    product: { Item.MirrorLasor: Natural(1) }.toTable(),
    duration: 120,
    building: Building.Crafting,
    unlockArea: 37
  ),
  Item.GreenLaser: Recipe(
    material: { Item.PolishedEmerald: Natural(1), Item.InsulatedWire: Natural(1), Item.Lamp: Natural(1) }.toTable(),
    product: { Item.GreenLaser: Natural(5)}.toTable(),
    duration: 20,
    building: Building.Crafting,
    unlockArea: 53
  ),
  Item.DiamondCutter: Recipe(
    material: { Item.SteelPlate: Natural(1), Item.PolishedDiamond: Natural(5) }.toTable(),
    product: { Item.DiamondCutter: Natural(1 )}.toTable(),
    duration: 30,
    building: Building.Crafting,
    unlockArea: 61
  ),
  Item.MotherBoard: Recipe(
    material: { Item.Silicon: Natural(3), Item.Circuits: Natural(3), Item.GoldBar: Natural(1 )}.toTable(),
    product: { Item.MotherBoard: Natural(1) }.toTable(),
    duration: 1800,
    building: Building.Crafting,
    unlockArea: 61
  ),
  Item.SolidPropellant: Recipe(
    material: { Item.Rubber: Natural(3), Item.AluminiumBar: Natural(10 )}.toTable(),
    product: { Item.SolidPropellant: Natural(1) }.toTable(),
    duration: 1200,
    building: Building.Crafting,
    unlockArea: 61
  ),
  Item.Accumulator: Recipe(
    material: { Item.Sodium: Natural(20), Item.Sulfur: Natural(20) }.toTable(),
    product: { Item.Accumulator: Natural(1) }.toTable(),
    duration: 180,
    building: Building.Crafting,
    unlockArea: 72
  ),
  Item.SolarPanel: Recipe(
    material: { Item.Rubber: Natural(1), Item.Silicon: Natural(10), Item.Glass: Natural(50) }.toTable(),
    product: { Item.SolarPanel: Natural(1 )}.toTable(),
    duration: 60,
    building: Building.Crafting,
    unlockArea: 73
  ),
  Item.Gear: Recipe(
    material: { Item.DiamondCutter: Natural(1), Item.TitaniumBar: Natural(1) }.toTable(),
    product: { Item.Gear: Natural(1) }.toTable(),
    duration: 80,
    building: Building.Crafting,
    unlockArea: 85
  ),
  Item.Bomb: Recipe(
    material: { Item.SteelBar: Natural(5), Item.GunPowder: Natural(10) }.toTable(),
    product: { Item.Bomb: Natural(1) }.toTable(),
    duration: 180,
    building: Building.Crafting,
    unlockArea: 96
  ),
  Item.Compressor: Recipe(
    material: { Item.IronBar: Natural(5), Item.Rubber: Natural(1), Item.RefinedOil: Natural(2) }.toTable(),
    product: { Item.Compressor: Natural(1) }.toTable(),
    duration: 180,
    building: Building.Crafting,
    unlockArea: 86
  ),
  Item.OpticFiber: Recipe(
    material: { Item.PlasticPlate: Natural(1), Item.Oxygen: Natural(10), Item.Silicon: Natural(10) }.toTable(),
    product: { Item.OpticFiber: Natural(10) }.toTable(),
    duration: 120,
    building: Building.Crafting,
    unlockArea: 96
  ),
  Item.CleanWater: Recipe(
    material: {Item.LabFlask: Natural(1), Item.Water: Natural(1)}.toTable(),
    product: {Item.CleanWater: Natural(1)}.toTable(),
    duration: 10*60,
    building: Building.Chemistry,
    unlockArea: 13
  ),
  Item.Hydrogen: Recipe(
    material: {Item.CleanWater: Natural(1)}.toTable(),
    product: {Item.Hydrogen: Natural(2), Item.Oxygen: Natural(1)}.toTable(),
    duration: 15*60,
    building: Building.Chemistry,
    unlockArea: 13
  ),
  Item.Rubber: Recipe(
    material: {Item.Liana: Natural(1)}.toTable(),
    product: {Item.Rubber: Natural(2)}.toTable(),
    duration: 30*60,
    building: Building.Chemistry,
    unlockArea: 61
  ),
  Item.SulfuricAcid: Recipe(
    material: {Item.Sulfur: Natural(2), Item.CleanWater: Natural(1)}.toTable(),
    product: {Item.SulfuricAcid: Natural(1)}.toTable(),
    duration: 30*60,
    building: Building.Chemistry,
    unlockArea: 61
  ),
  Item.Ethanol: Recipe(
    material: {Item.AluminiumBottle: Natural(1), Item.Grape: Natural(2)}.toTable(),
    product: {Item.Ethanol: Natural(1)}.toTable(),
    duration: 30*60,
    building: Building.Chemistry,
    unlockArea: 61
  ),
  Item.RefinedOil: Recipe(
    material: {Item.Oil: Natural(10), Item.Hydrogen: Natural(10), Item.LabFlask: Natural(1)}.toTable(),
    product: {Item.RefinedOil: Natural(1)}.toTable(),
    duration: 30*60,
    building: Building.Chemistry,
    unlockArea: 73
  ),
  Item.PlasticPlate: Recipe(
    material: {Item.RefinedOil: Natural(1), Item.Coal: Natural(50), Item.GreenLaser: Natural(1)}.toTable(),
    product: {Item.PlasticPlate: Natural(1)}.toTable(),
    duration: 10*60,
    building: Building.Chemistry,
    unlockArea: 73
  ),
  Item.Titanium: Recipe(
    material: {Item.SulfuricAcid: Natural(1), Item.TitaniumOre: Natural(100)}.toTable(),
    product: {Item.Titanium: Natural(50)}.toTable(),
    duration: 20,
    building: Building.Chemistry,
    unlockArea: 85
  ),
  Item.DiethylEther: Recipe(
    material: {Item.SulfuricAcid: Natural(1), Item.Ethanol: Natural(1)}.toTable(),
    product: {Item.DiethylEther: Natural(1)}.toTable(),
    duration: 60,
    building: Building.Chemistry,
    unlockArea: 85
  ),
  Item.GunPowder: Recipe(
    material: {Item.DiethylEther: Natural(1), Item.SulfuricAcid: Natural(2), Item.Tree: Natural(2)}.toTable(),
    product: {Item.GunPowder: Natural(20)}.toTable(),
    duration: 2*60,
    building: Building.Chemistry,
    unlockArea: 85
  ),
  Item.LiquidNitrogen: Recipe(
    material: {Item.Nitrogen: Natural(10), Item.Compressor: Natural(1), Item.AluminiumBottle: Natural(1)}.toTable(),
    product: {Item.LiquidNitrogen: Natural(4)}.toTable(),
    duration: 2*60,
    building: Building.Chemistry,
    unlockArea: 96
  ),
  Item.MagnetiteOre: Recipe(
    material: {Item.IronBar: Natural(10), Item.Oxygen: Natural(5), Item.GreenLaser: Natural(5)}.toTable(),
    product: {Item.MagnetiteOre: Natural(1)}.toTable(),
    duration: 6*60,
    building: Building.Chemistry,
    unlockArea: 109
  ),
  Item.EnhancedHelium3: Recipe(
    material: {Item.AluminiumBottle: Natural(1), Item.Helium3: Natural(100), Item.Compressor: Natural(1)}.toTable(),
    product: {Item.EnhancedHelium3: Natural(1)}.toTable(),
    duration: 30*60,
    building: Building.Chemistry,
    unlockArea: 109
  ),
  Item.ToxicBomb: Recipe(
    material: {Item.SulfuricAcid: Natural(10)}.toTable(),
    product: {Item.ToxicBomb: Natural(10)}.toTable(),
    duration: 2*60,
    building: Building.Chemistry,
    unlockArea: 109
  ),
  Item.PolishedAmber: Recipe(
    material: {Item.Amber: Natural(5)}.toTable(),
    product: {Item.PolishedAmber: Natural(1)}.toTable(),
    duration: 30,
    building: Building.JewelCrafting,
    unlockArea: 50
  ),
  Item.PolishedEmerald: Recipe(
    material: {Item.Emerald: Natural(5)}.toTable(),
    product: {Item.PolishedEmerald: Natural(1)}.toTable(),
    duration: 30,
    building: Building.JewelCrafting,
    unlockArea: 50
  ),
  Item.PolishedTopaz: Recipe(
    material: {Item.Topaz: Natural(5)}.toTable(),
    product: {Item.PolishedTopaz: Natural(1)}.toTable(),
    duration: 60,
    building: Building.JewelCrafting,
    unlockArea: 61
  ),
  Item.PolishedRuby: Recipe(
    material: {Item.Ruby: Natural(5)}.toTable(),
    product: {Item.PolishedRuby: Natural(1)}.toTable(),
    duration: 60,
    building: Building.JewelCrafting,
    unlockArea: 61
  ),
  Item.PolishedDiamond: Recipe(
    material: {Item.Diamond: Natural(5)}.toTable(),
    product: {Item.PolishedDiamond: Natural(1)}.toTable(),
    duration: 60,
    building: Building.JewelCrafting,
    unlockArea: 61
  ),
  Item.PolishedSapphire: Recipe(
    material: {Item.Sapphire: Natural(5)}.toTable(),
    product: {Item.PolishedSapphire: Natural(1)}.toTable(),
    duration: 60,
    building: Building.JewelCrafting,
    unlockArea: 73
  ),
  Item.PolishedAmethyst: Recipe(
    material: {Item.Amethyst: Natural(5)}.toTable(),
    product: {Item.PolishedAmethyst: Natural(1)}.toTable(),
    duration: 60,
    building: Building.JewelCrafting,
    unlockArea: 73
  ),
  Item.PolishedAlexandrite: Recipe(
    material: {Item.Alexandrite: Natural(5)}.toTable(),
    product: {Item.PolishedAlexandrite: Natural(1)}.toTable(),
    duration: 60,
    building: Building.JewelCrafting,
    unlockArea: 85
  ),
  Item.PolishedObsidian: Recipe(
    material: {Item.Obsidian: Natural(5)}.toTable(),
    product: {Item.PolishedObsidian: Natural(1)}.toTable(),
    duration: 60,
    building: Building.JewelCrafting,
    unlockArea: 85
  ),
  Item.SapphireCrystalGlass: Recipe(
    material: {Item.PolishedSapphire: Natural(10)}.toTable(),
    product: {Item.SapphireCrystalGlass: Natural(1)}.toTable(),
    duration: 2*60,
    building: Building.JewelCrafting,
    unlockArea: 96
  ),
  Item.AmberBracelet: Recipe(
    material: {Item.SilverBar: Natural(1), Item.PolishedAmber: Natural(1)}.toTable(),
    product: {Item.AmberBracelet: Natural(1)}.toTable(),
    duration: 120,
    building: Building.JewelCrafting,
    unlockArea: 0
  ),
  Item.EmeraldRing: Recipe(
    material: {Item.GoldBar: Natural(1), Item.PolishedEmerald: Natural(1)}.toTable(),
    product: {Item.EmeraldRing: Natural(1)}.toTable(),
    duration: 300,
    building: Building.JewelCrafting,
    unlockArea: 0
  ),
  Item.MayaCalender: Recipe(
    material: {Item.SilverBar: Natural(2), Item.GoldBar: Natural(10)}.toTable(),
    product: {Item.MayaCalender: Natural(1)}.toTable(),
    duration: 120,
    building: Building.JewelCrafting,
    unlockArea: 0
  ),
  Item.Haircomb: Recipe(
    material: {Item.SilverBar: Natural(1), Item.PolishedAmethyst: Natural(15), Item.PolishedAlexandrite: Natural(10)}.toTable(),
    product: {Item.Haircomb: Natural(1)}.toTable(),
    duration: 120,
    building: Building.JewelCrafting,
    unlockArea: 0
  ),
  Item.ObsidianKnife: Recipe(
    material: {Item.PolishedObsidian: Natural(50), Item.Tree: Natural(2), Item.SilverBar: Natural(1)}.toTable(),
    product: {Item.ObsidianKnife: Natural(1)}.toTable(),
    duration: 120,
    building: Building.JewelCrafting,
    unlockArea: 0
  ),
  Item.Tree: Recipe(
    material: {Item.TreeSeed: Natural(1), Item.Water: Natural(10)}.toTable(),
    product: {Item.Tree: Natural(10)}.toTable(),
    duration: 30*60,
    building: Building.Greenhouse,
    unlockArea: 0
  ),
  Item.Liana: Recipe(
    material: {Item.LianaSeed: Natural(1), Item.Water: Natural(20)}.toTable(),
    product: {Item.Liana: Natural(1)}.toTable(),
    duration: 30*60,
    building: Building.Greenhouse,
    unlockArea: 0
  ),
  Item.Grape: Recipe(
    material: {Item.GrapeSeed: Natural(1), Item.Water: Natural(15)}.toTable(),
    product: {Item.Grape: Natural(2)}.toTable(),
    duration: 30*60,
    building: Building.Greenhouse,
    unlockArea: 0
  ),
}.toTable();

proc getRecipe*(item: Item): Recipe =
  try:
    result = Recipes[item]
  except KeyError:
    raise newException(DeepTownError, fmt"Recipe not implemented: {item}")

proc getMiningStationAvailable*(floor: Natural): Table[Item, float] =
  case floor:
    of 1:
      result = {
        Item.Coal: 100.00,
      }.toTable()
    of 2:
      result = {
        Item.Coal: 70.00,
        Item.Copper: 30.00,
      }.toTable()
    of 3:
      result = {
        Item.Coal: 59.50,
        Item.Copper: 28.0+1.0/3,
        Item.Iron: 9.17,
        Item.Amber: 2.50,
        Item.Gold: 0.50,
      }.toTable()
    of 4:
      result = {
        Item.Coal: 54.25,
        Item.Copper: 32.50,
        Item.Iron: 10.25,
        Item.Amber: 2.25,
        Item.Gold: 0.75,
      }.toTable()
    of 5:
      result = {
        Item.Coal: 49.00,
        Item.Copper: 36.0+2.0/3,
        Item.Iron: 11.0+1.0/3,
        Item.Amber: 2.00,
        Item.Gold: 1.00,
      }.toTable()
    of 6:
      result = {
        Item.Coal: 43.75,
        Item.Copper: 40.8+0.1/3,
        Item.Iron: 12.42,
        Item.Amber: 1.75,
        Item.Gold: 1.25,
      }.toTable()
    of 7:
      result = {
        Item.Copper: 45.00,
        Item.Coal: 38.50,
        Item.Iron: 13.50,
        Item.Gold: 1.50,
        Item.Amber: 1.50,
      }.toTable()
    of 8:
      result = {
        Item.Copper: 49.17,
        Item.Coal: 33.25,
        Item.Iron: 14.58,
        Item.Gold: 1.75,
        Item.Amber: 1.25,
      }.toTable()
    of 9:
      result = {
        Item.Copper: 53.0+1.0/3,
        Item.Coal: 28.00,
        Item.Iron: 15.0+2.0/3,
        Item.Gold: 2.00,
        Item.Amber: 1.00,
      }.toTable()
    of 10:
      result = {
        Item.Copper: 57.50,
        Item.Coal: 22.75,
        Item.Iron: 16.75,
        Item.Gold: 2.25,
        Item.Amber: 0.75,
      }.toTable()
    of 11:
      result = {
        Item.Copper: 61.0+2.0/3,
        Item.Iron: 17.8+0.1/3,
        Item.Coal: 17.50,
        Item.Gold: 2.50,
        Item.Amber: 0.50,
      }.toTable()
    of 12:
      result = {
        Item.Copper: 65.8+0.1/3,
        Item.Iron: 18.92,
        Item.Coal: 12.25,
        Item.Gold: 2.75,
        Item.Amber: 0.25,
      }.toTable()
    of 13:
      result = {
        Item.Copper: 100.00,
      }.toTable()
    of 14:
      result = {
        Item.Copper: 70.00,
        Item.Iron: 30.00,
      }.toTable()
    of 15:
      result = {
        Item.Copper: 58.0+1.0/3,
        Item.Iron: 19.50,
        Item.Amber: 10.00,
        Item.Coal: 5.8+0.1/3,
        Item.Aluminium: 3.0+1.0/3,
        Item.Gold: 2.50,
        Item.Silver: 0.50,
      }.toTable()
    of 16:
      result = {
        Item.Copper: 52.50,
        Item.Iron: 19.25,
        Item.Amber: 15.00,
        Item.Coal: 5.25,
        Item.Aluminium: 5.00,
        Item.Gold: 2.25,
        Item.Silver: 0.75,
      }.toTable()
    of 17:
      result = {
        Item.Copper: 46.0+2.0/3,
        Item.Amber: 20.00,
        Item.Iron: 19.00,
        Item.Aluminium: 6.0+2.0/3,
        Item.Coal: 4.0+2.0/3,
        Item.Gold: 2.00,
        Item.Silver: 1.00,
      }.toTable()
    of 18:
      result = {
        Item.Copper: 40.8+0.1/3,
        Item.Amber: 25.00,
        Item.Iron: 18.75,
        Item.Aluminium: 8.3+0.1/3,
        Item.Coal: 4.05 + 0.1/3,
        Item.Gold: 1.75,
        Item.Silver: 1.25,
      }.toTable()
    of 19:
      result = {
        Item.Copper: 35.00,
        Item.Amber: 30.00,
        Item.Iron: 18.50,
        Item.Aluminium: 10.00,
        Item.Coal: 3.50,
        Item.Silver: 1.50,
        Item.Gold: 1.50,
      }.toTable()
    of 20:
      result = {
        Item.Amber: 35.00,
        Item.Copper: 29.17,
        Item.Iron: 18.25,
        Item.Aluminium: 11.0+2.0/3,
        Item.Coal: 2.92,
        Item.Silver: 1.75,
        Item.Gold: 1.25,
      }.toTable()
    of 21:
      result = {
        Item.Amber: 40.00,
        Item.Copper: 23.0+1.0/3,
        Item.Iron: 18.00,
        Item.Aluminium: 13.0+1.0/3,
        Item.Coal: 2.0+1.0/3,
        Item.Silver: 2.00,
        Item.Gold: 1.00,
      }.toTable()
    of 22:
      result = {
        Item.Amber: 45.00,
        Item.Iron: 17.75,
        Item.Copper: 17.50,
        Item.Aluminium: 15.00,
        Item.Silver: 2.25,
        Item.Coal: 1.75,
        Item.Gold: 0.75,
      }.toTable()
    of 23:
      result = {
        Item.Amber: 50.00,
        Item.Iron: 17.50,
        Item.Aluminium: 16.0+2.0/3,
        Item.Copper: 11.0+2.0/3,
        Item.Silver: 2.50,
        Item.Coal: 1.17,
        Item.Gold: 0.50,
      }.toTable()
    of 24:
      #
      # Amber: 55
      # Alumm: 18
      # Iron : 17
      # ???  :  9
      result = {
        Item.Amber: 55.00,
        Item.Aluminium: 18.0+1.0/3,
        Item.Iron: 17.0 + 1.0/4,
        Item.Copper: 5.8+0.1/3,
        Item.Silver: 2.75,
        Item.Coal: 0.55 + 0.1/3,
        Item.Gold: 0.25,
      }.toTable()
    of 25:
      result = {
        Item.Amber: 100.00,
      }.toTable()
    of 26:
      result = {
        Item.Amber: 70.00,
        Item.Aluminium: 30.00,
      }.toTable()
    of 27:
      result = {
        Item.Amber: 50.00,
        Item.Aluminium: 26.0+2.0/3,
        Item.Iron: 19.17,
        Item.Silver: 4.17,
      }.toTable()
    of 28:
      result = {
        Item.Amber: 45.00,
        Item.Aluminium: 30.00,
        Item.Iron: 20.25,
        Item.Silver: 4.75,
      }.toTable()
    of 29:
      result = {
        Item.Amber: 40.00,
        Item.Aluminium: 33.0+1.0/3,
        Item.Iron: 21.0+1.0/3,
        Item.Silver: 5.0+1.0/3,
      }.toTable()
    of 30:
      result = {
        Item.Aluminium: 36.0+2.0/3,
        Item.Amber: 35.00,
        Item.Iron: 22.42,
        Item.Silver: 5.92,
      }.toTable()
    of 31:
      result = {
        Item.Aluminium: 40.00,
        Item.Amber: 30.00,
        Item.Iron: 23.50,
        Item.Silver: 6.50,
      }.toTable()
    of 32:
      result = {
        Item.Aluminium: 43.0+1.0/3,
        Item.Amber: 25.00,
        Item.Iron: 24.55 + 0.1/3,
        Item.Silver: 7.05 + 0.1/3,
      }.toTable()
    of 33:
      result = {
        Item.Aluminium: 46.0+2.0/3,
        Item.Iron: 25.0+2.0/3,
        Item.Amber: 20.00,
        Item.Silver: 7.0+2.0/3,
      }.toTable()
    of 34:
      result = {
        Item.Aluminium: 50.00,
        Item.Iron: 26.75,
        Item.Amber: 15.00,
        Item.Silver: 8.25,
      }.toTable()
    of 35:
      result = {
        Item.Aluminium: 53.0+1.0/3,
        Item.Iron: 27.8+0.1/3,
        Item.Amber: 10.00,
        Item.Silver: 8.8+0.1/3,
      }.toTable()
    of 36:
      result = {
        Item.Aluminium: 56.66+0.02/3,
        Item.Iron: 28.91+0.02/3,
        Item.Silver: 9.41+0.02/3,
        Item.Amber: 5.00,
      }.toTable()
    of 37:
      result = {
        Item.Aluminium: 100.00,
      }.toTable()
    of 38:
      result = {
        Item.Aluminium: 70.00,
        Item.Iron: 30.00,
      }.toTable()
    of 39:
      result = {
        Item.Aluminium: 50.00,
        Item.Iron: 25.00,
        Item.Silver: 11.1 + 0.2/3,
        Item.Gold: 10.00,
        Item.Emerald: 3.8+0.1/3,
      }.toTable()
    of 40:
      result = {
        Item.Aluminium: 45.00,
        Item.Iron: 22.50,
        Item.Gold: 15.00,
        Item.Silver: 11.75,
        Item.Emerald: 5.75,
      }.toTable()
    of 41:
      result = {
        Item.Aluminium: 40.00,
        Item.Iron: 20.00,
        Item.Gold: 20.00,
        Item.Silver: 12.0+1.0/3,
        Item.Emerald: 7.0+2.0/3,
      }.toTable()
    of 42:
      result = {
        Item.Aluminium: 35.00,
        Item.Gold: 25.00,
        Item.Iron: 17.50,
        Item.Silver: 12.92,
        Item.Emerald: 9.58,
      }.toTable()
    of 43:
      result = {
        Item.Gold: 30.00,
        Item.Aluminium: 30.00,
        Item.Iron: 15.00,
        Item.Silver: 13.50,
        Item.Emerald: 11.50,
      }.toTable()
    of 44:
      result = {
        Item.Gold: 35.00,
        Item.Aluminium: 25.00,
        Item.Silver: 14.08,
        Item.Emerald: 13.42,
        Item.Iron: 12.50,
      }.toTable()
    of 45:
      result = {
        Item.Gold: 40.00,
        Item.Aluminium: 20.00,
        Item.Emerald: 15.0+1.0/3,
        Item.Silver: 14.0+2.0/3,
        Item.Iron: 10.00,
      }.toTable()
    of 46:
      result = {
        Item.Gold: 45.00,
        Item.Emerald: 17.25,
        Item.Silver: 15.25,
        Item.Aluminium: 15.00,
        Item.Iron: 7.50,
      }.toTable()
    of 47:
      result = {
        Item.Gold: 50.00,
        Item.Emerald: 19.1+0.2/3,
        Item.Silver: 15.8+0.1/3,
        Item.Aluminium: 10.00,
        Item.Iron: 5.00,
      }.toTable()
    of 48:
      result = {
        Item.Gold: 55.00,
        Item.Emerald: 21.08,
        Item.Silver: 16.42,
        Item.Aluminium: 5.00,
        Item.Iron: 2.50,
      }.toTable()
    of 49:
      result = {
        Item.Gold: 100.00,
      }.toTable()
    of 50:
      result = {
        Item.Gold: 70.00,
        Item.Emerald: 30.00,
      }.toTable()
    of 51:
      result = {
        Item.Gold: 50.00,
        Item.Emerald: 25.8+0.1/3,
        Item.Silver: 14.1+0.2/3,
        Item.Ruby: 5.00,
        Item.Diamond: 3.0+1.0/3,
        Item.Topaz: 1.0+2.0/3,
      }.toTable()
    of 52:
      result = {
        Item.Gold: 45.00,
        Item.Emerald: 27.25,
        Item.Silver: 12.75,
        Item.Ruby: 7.50,
        Item.Diamond: 5.00,
        Item.Topaz: 2.50,
      }.toTable()
    of 53:
      result = {
        Item.Gold: 40.00,
        Item.Emerald: 28.0+2.0/3,
        Item.Silver: 11.0+1.0/3,
        Item.Ruby: 10.00,
        Item.Diamond: 6.0+2.0/3,
        Item.Topaz: 3.0+1.0/3,
      }.toTable()
    of 54:
      result = {
        Item.Gold: 35.00,
        Item.Emerald: 30.08,
        Item.Ruby: 12.50,
        Item.Silver: 9.92,
        Item.Diamond: 8.0+1.0/3,
        Item.Topaz: 4.17,
      }.toTable()
    of 55:
      result = {
        Item.Emerald: 31.50,
        Item.Gold: 30.00,
        Item.Ruby: 15.00,
        Item.Diamond: 10.00,
        Item.Silver: 8.50,
        Item.Topaz: 5.00,
      }.toTable()
    of 56:
      result = {
        Item.Emerald: 32.92,
        Item.Gold: 25.00,
        Item.Ruby: 17.50,
        Item.Diamond: 11.0+2.0/3,
        Item.Silver: 7.08,
        Item.Topaz: 5.8+0.1/3,
      }.toTable()
    of 57:
      result = {
        Item.Emerald: 34.0+1.0/3,
        Item.Ruby: 20.00,
        Item.Gold: 20.00,
        Item.Diamond: 13.0+1.0/3,
        Item.Topaz: 6.0+2.0/3,
        Item.Silver: 5.0+2.0/3,
      }.toTable()
    of 58:
      result = {
        Item.Emerald: 35.75,
        Item.Ruby: 22.50,
        Item.Gold: 15.00,
        Item.Diamond: 15.00,
        Item.Topaz: 7.50,
        Item.Silver: 4.25,
      }.toTable()
    of 59:
      result = {
        Item.Emerald: 37.17,
        Item.Ruby: 25.00,
        Item.Diamond: 16.0+2.0/3,
        Item.Gold: 10.00,
        Item.Topaz: 8.0+1.0/3,
        Item.Silver: 2.8+0.1/3,
      }.toTable()
    of 60:
      result = {
        Item.Emerald: 38.58,
        Item.Ruby: 27.50,
        Item.Diamond: 18.0+1.0/3,
        Item.Topaz: 9.17,
        Item.Gold: 5.00,
        Item.Silver: 1.42,
      }.toTable()
    of 61:
      result = {
        Item.Emerald: 100.00,
      }.toTable()
    of 62:
      result = {
        Item.Emerald: 70.00,
        Item.Ruby: 30.00,
      }.toTable()
    of 63:
      result = {
        Item.Emerald: 33.0+1.0/3,
        Item.Ruby: 31.0+2.0/3,
        Item.Diamond: 16.0+2.0/3,
        Item.Topaz: 13.0+1.0/3,
        Item.Sapphire: 3.0+1.0/3,
        Item.Amethyst: 1.0+2.0/3,
      }.toTable()
    of 64:
      result = {
        Item.Ruby: 32.50,
        Item.Emerald: 30.00,
        Item.Topaz: 15.00,
        Item.Diamond: 15.00,
        Item.Sapphire: 5.00,
        Item.Amethyst: 2.50,
      }.toTable()
    of 65:
      result = {
        Item.Ruby: 33.0+1.0/3,
        Item.Emerald: 26.0+2.0/3,
        Item.Topaz: 16.0+2.0/3,
        Item.Diamond: 13.0+1.0/3,
        Item.Sapphire: 6.0+2.0/3,
        Item.Amethyst: 3.0+1.0/3,
      }.toTable()
    of 66:
      result = {
        Item.Ruby: 34.17,
        Item.Emerald: 23.0+1.0/3,
        Item.Topaz: 18.0+1.0/3,
        Item.Diamond: 11.0+2.0/3,
        Item.Sapphire: 8.0+1.0/3,
        Item.Amethyst: 4.17,
      }.toTable()
    of 67:
      result = {
        Item.Ruby: 35.00,
        Item.Topaz: 20.00,
        Item.Emerald: 20.00,
        Item.Sapphire: 10.00,
        Item.Diamond: 10.00,
        Item.Amethyst: 5.00,
      }.toTable()
    of 68:
      result = {
        Item.Ruby: 35.8+0.1/3,
        Item.Topaz: 21.0+2.0/3,
        Item.Emerald: 16.0+2.0/3,
        Item.Sapphire: 11.0+2.0/3,
        Item.Diamond: 8.0+1.0/3,
        Item.Amethyst: 5.8+0.1/3,
      }.toTable()
    of 69:
      result = {
        Item.Ruby: 36.0+2.0/3,
        Item.Topaz: 23.0+1.0/3,
        Item.Sapphire: 13.0+1.0/3,
        Item.Emerald: 13.0+1.0/3,
        Item.Diamond: 6.0+2.0/3,
        Item.Amethyst: 6.0+2.0/3,
      }.toTable()
    of 70:
      result = {
        Item.Ruby: 37.50,
        Item.Topaz: 25.00,
        Item.Sapphire: 15.00,
        Item.Emerald: 10.00,
        Item.Amethyst: 7.50,
        Item.Diamond: 5.00,
      }.toTable()
    of 71:
      result = {
        Item.Ruby: 38.0+1.0/3,
        Item.Topaz: 26.0+2.0/3,
        Item.Sapphire: 16.0+2.0/3,
        Item.Amethyst: 8.0+1.0/3,
        Item.Emerald: 6.0+2.0/3,
        Item.Diamond: 3.0+1.0/3,
      }.toTable()
    of 72:
      result = {
        Item.Ruby: 39.17,
        Item.Topaz: 28.0+1.0/3,
        Item.Sapphire: 18.0+1.0/3,
        Item.Amethyst: 9.17,
        Item.Emerald: 3.0+1.0/3,
        Item.Diamond: 1.0+2.0/3,
      }.toTable()
    of 73:
      result = {
        Item.Ruby: 100.00,
      }.toTable()
    of 74:
      result = {
        Item.Ruby: 70.00,
        Item.Topaz: 30.00,
      }.toTable()
    of 75:
      result = {
        Item.Ruby: 33.0+1.0/3,
        Item.Topaz: 25.00,
        Item.Sapphire: 16.0+2.0/3,
        Item.Amethyst: 15.00,
        Item.Alexandrite: 4.50,
        Item.TitaniumOre: 3.0+1.0/3,
        Item.Uranium: 1.0+2.0/3,
        Item.Platinum: 0.50,
      }.toTable()
    of 76:
      result = {
        Item.Ruby: 30.00,
        Item.Topaz: 22.50,
        Item.Amethyst: 17.50,
        Item.Sapphire: 15.00,
        Item.Alexandrite: 6.75,
        Item.TitaniumOre: 5.00,
        Item.Uranium: 2.50,
        Item.Platinum: 0.75,
      }.toTable()
    of 77:
      result = {
        Item.Ruby: 26.0+2.0/3,
        Item.Topaz: 20.00,
        Item.Amethyst: 20.00,
        Item.Sapphire: 13.0+1.0/3,
        Item.Alexandrite: 9.00,
        Item.TitaniumOre: 6.0+2.0/3,
        Item.Uranium: 3.0+1.0/3,
        Item.Platinum: 1.00,
      }.toTable()
    of 78:
      result = {
        Item.Ruby: 23.0+1.0/3,
        Item.Amethyst: 22.50,
        Item.Topaz: 17.50,
        Item.Sapphire: 11.0+2.0/3,
        Item.Alexandrite: 11.25,
        Item.TitaniumOre: 8.0+1.0/3,
        Item.Uranium: 4.17,
        Item.Platinum: 1.25,
      }.toTable()
    of 79:
      result = {
        Item.Amethyst: 25.00,
        Item.Ruby: 20.00,
        Item.Topaz: 15.00,
        Item.Alexandrite: 13.50,
        Item.TitaniumOre: 10.00,
        Item.Sapphire: 10.00,
        Item.Uranium: 5.00,
        Item.Platinum: 1.50,
      }.toTable()
    of 80:
      result = {
        Item.Amethyst: 27.50,
        Item.Ruby: 16.0+2.0/3,
        Item.Alexandrite: 15.75,
        Item.Topaz: 12.50,
        Item.TitaniumOre: 11.0+2.0/3,
        Item.Sapphire: 8.0+1.0/3,
        Item.Uranium: 5.8+0.1/3,
        Item.Platinum: 1.75,
      }.toTable()
    of 81:
      result = {
        Item.Amethyst: 30.00,
        Item.Alexandrite: 18.00,
        Item.TitaniumOre: 13.0+1.0/3,
        Item.Ruby: 13.0+1.0/3,
        Item.Topaz: 10.00,
        Item.Uranium: 6.0+2.0/3,
        Item.Sapphire: 6.0+2.0/3,
        Item.Platinum: 2.00,
      }.toTable()
    of 82:
      result = {
        Item.Amethyst: 32.50,
        Item.Alexandrite: 20.25,
        Item.TitaniumOre: 15.00,
        Item.Ruby: 10.00,
        Item.Uranium: 7.50,
        Item.Topaz: 7.50,
        Item.Sapphire: 5.00,
        Item.Platinum: 2.25,
      }.toTable()
    of 83:
      result = {
        Item.Amethyst: 35.00,
        Item.Alexandrite: 22.50,
        Item.TitaniumOre: 16.0+2.0/3,
        Item.Uranium: 8.0+1.0/3,
        Item.Ruby: 6.0+2.0/3,
        Item.Topaz: 5.00,
        Item.Sapphire: 3.0+1.0/3,
        Item.Platinum: 2.50,
      }.toTable()
    of 84:
      result = {
        Item.Amethyst: 37.50,
        Item.Alexandrite: 24.75,
        Item.TitaniumOre: 18.0+1.0/3,
        Item.Uranium: 9.17,
        Item.Ruby: 3.0+1.0/3,
        Item.Platinum: 2.75,
        Item.Topaz: 2.50,
        Item.Sapphire: 1.0+2.0/3,
      }.toTable()
    of 85:
      result = {
        Item.Amethyst: 100.00,
      }.toTable()
    of 86:
      result = {
        Item.Amethyst: 70.00,
        Item.Alexandrite: 30.00,
      }.toTable()
    of 87:
      result = {
        Item.Amethyst: 33.0+1.0/3,
        Item.Alexandrite: 22.50,
        Item.TitaniumOre: 18.0+1.0/3,
        Item.Obsidian: 10.00,
        Item.Uranium: 8.0+1.0/3,
        Item.Platinum: 3.00,
        Item.Diamond: 2.50,
        Item.Sapphire: 2.00,
      }.toTable()
    of 88:
      result = {
        Item.Amethyst: 30.00,
        Item.Alexandrite: 20.25,
        Item.TitaniumOre: 17.50,
        Item.Obsidian: 15.00,
        Item.Uranium: 7.50,
        Item.Diamond: 3.75,
        Item.Sapphire: 3.00,
        Item.Platinum: 3.00,
      }.toTable()
    of 89:
      result = {
        Item.Amethyst: 26.0+2.0/3,
        Item.Obsidian: 20.00,
        Item.Alexandrite: 18.00,
        Item.TitaniumOre: 16.0+2.0/3,
        Item.Uranium: 6.0+2.0/3,
        Item.Diamond: 5.00,
        Item.Sapphire: 4.00,
        Item.Platinum: 3.00,
      }.toTable()
    of 90:
      result = {
        Item.Obsidian: 25.00,
        Item.Amethyst: 23.0+1.0/3,
        Item.TitaniumOre: 15.8+0.1/3,
        Item.Alexandrite: 15.75,
        Item.Diamond: 6.25,
        Item.Uranium: 5.8+0.1/3,
        Item.Sapphire: 5.00,
        Item.Platinum: 3.00,
      }.toTable()
    of 91:
      result = {
        Item.Obsidian: 30.00,
        Item.Amethyst: 20.00,
        Item.TitaniumOre: 15.00,
        Item.Alexandrite: 13.50,
        Item.Diamond: 7.50,
        Item.Sapphire: 6.00,
        Item.Uranium: 5.00,
        Item.Platinum: 3.00,
      }.toTable()
    of 92:
      result = {
        Item.Obsidian: 35.00,
        Item.Amethyst: 16.0+2.0/3,
        Item.TitaniumOre: 14.17,
        Item.Alexandrite: 11.25,
        Item.Diamond: 8.75,
        Item.Sapphire: 7.00,
        Item.Uranium: 4.17,
        Item.Platinum: 3.00,
      }.toTable()
    of 93:
      result = {
        Item.Obsidian: 40.00,
        Item.TitaniumOre: 13.0+1.0/3,
        Item.Amethyst: 13.0+1.0/3,
        Item.Diamond: 10.00,
        Item.Alexandrite: 9.00,
        Item.Sapphire: 8.00,
        Item.Uranium: 3.0+1.0/3,
        Item.Platinum: 3.00,
      }.toTable()
    of 94:
      result = {
        Item.Obsidian: 45.00,
        Item.TitaniumOre: 12.50,
        Item.Diamond: 11.25,
        Item.Amethyst: 10.00,
        Item.Sapphire: 9.00,
        Item.Alexandrite: 6.75,
        Item.Platinum: 3.00,
        Item.Uranium: 2.50,
      }.toTable()
    of 95:
      result = {
        Item.Obsidian: 50.00,
        Item.Diamond: 12.50,
        Item.TitaniumOre: 11.0+2.0/3,
        Item.Sapphire: 10.00,
        Item.Amethyst: 6.0+2.0/3,
        Item.Alexandrite: 4.50,
        Item.Platinum: 3.00,
        Item.Uranium: 1.0+2.0/3,
      }.toTable()
    of 96:
      result = {
        Item.Obsidian: 55.00,
        Item.Diamond: 13.75,
        Item.Sapphire: 11.00,
        Item.TitaniumOre: 10.8+0.1/3,
        Item.Amethyst: 3.0+1.0/3,
        Item.Platinum: 3.00,
        Item.Alexandrite: 2.25,
        Item.Uranium: 0.8+0.1/3,
      }.toTable()
    of 97:
      result = {
        Item.Obsidian: 100.00,
      }.toTable()
    of 98:
      result = {
        Item.Obsidian: 70.00,
        Item.Diamond: 30.00,
      }.toTable()
    of 99:
      result = {
        Item.Obsidian: 50.00,
        Item.Diamond: 12.50,
        Item.Iron: 11.00,
        Item.Sapphire: 10.00,
        Item.TitaniumOre: 8.0+1.0/3,
        Item.Coal: 3.0+1.0/3,
        Item.Platinum: 2.50,
        Item.Silver: 2.00,
        Item.Helium3: 0.0+1.0/3,
      }.toTable()
    of 100:
      result = {
        Item.Obsidian: 45.00,
        Item.Iron: 16.50,
        Item.Diamond: 11.25,
        Item.Sapphire: 9.00,
        Item.TitaniumOre: 7.50,
        Item.Coal: 5.00,
        Item.Silver: 3.00,
        Item.Platinum: 2.25,
        Item.Helium3: 0.50,
      }.toTable()
    of 101:
      result = {
        Item.Obsidian: 40.00,
        Item.Iron: 22.00,
        Item.Diamond: 10.00,
        Item.Sapphire: 8.00,
        Item.TitaniumOre: 6.0+2.0/3,
        Item.Coal: 6.0+2.0/3,
        Item.Silver: 4.00,
        Item.Platinum: 2.00,
        Item.Helium3: 0.0+2.0/3,
      }.toTable()
    of 102:
      result = {
        Item.Obsidian: 35.00,
        Item.Iron: 27.50,
        Item.Diamond: 8.75,
        Item.Coal: 8.0+1.0/3,
        Item.Sapphire: 7.00,
        Item.TitaniumOre: 5.8+0.1/3,
        Item.Silver: 5.00,
        Item.Platinum: 1.75,
        Item.Helium3: 0.8+0.1/3,
      }.toTable()
    of 103:
      result = {
        Item.Iron: 33.00,
        Item.Obsidian: 30.00,
        Item.Coal: 10.00,
        Item.Diamond: 7.50,
        Item.Silver: 6.00,
        Item.Sapphire: 6.00,
        Item.TitaniumOre: 5.00,
        Item.Platinum: 1.50,
        Item.Helium3: 1.00,
      }.toTable()
    of 104:
      result = {
        Item.Iron: 38.50,
        Item.Obsidian: 25.00,
        Item.Coal: 11.0+2.0/3,
        Item.Silver: 7.00,
        Item.Diamond: 6.25,
        Item.Sapphire: 5.00,
        Item.TitaniumOre: 4.17,
        Item.Platinum: 1.25,
        Item.Helium3: 1.17,
      }.toTable()
    of 105:
      result = {
        Item.Iron: 44.00,
        Item.Obsidian: 20.00,
        Item.Coal: 13.0+1.0/3,
        Item.Silver: 8.00,
        Item.Diamond: 5.00,
        Item.Sapphire: 4.00,
        Item.TitaniumOre: 3.0+1.0/3,
        Item.Helium3: 1.0+1.0/3,
        Item.Platinum: 1.00,
      }.toTable()
    of 106:
      result = {
        Item.Iron: 49.50,
        Item.Obsidian: 15.00,
        Item.Coal: 15.00,
        Item.Silver: 9.00,
        Item.Diamond: 3.75,
        Item.Sapphire: 3.00,
        Item.TitaniumOre: 2.50,
        Item.Helium3: 1.50,
        Item.Platinum: 0.75,
      }.toTable()
    of 107:
      result = {
        Item.Iron: 55.00,
        Item.Coal: 16.0+2.0/3,
        Item.Silver: 10.00,
        Item.Obsidian: 10.00,
        Item.Diamond: 2.50,
        Item.Sapphire: 2.00,
        Item.TitaniumOre: 1.0+2.0/3,
        Item.Helium3: 1.0+2.0/3,
        Item.Platinum: 0.50,
      }.toTable()
    of 108:
      result = {
        Item.Iron: 60.50,
        Item.Coal: 18.0+1.0/3,
        Item.Silver: 11.00,
        Item.Obsidian: 5.00,
        Item.Helium3: 1.8+0.1/3,
        Item.Diamond: 1.25,
        Item.Sapphire: 1.00,
        Item.TitaniumOre: 0.8+0.1/3,
        Item.Platinum: 0.25,
      }.toTable()
    of 109:
      result = {
        Item.Iron: 66.00,
        Item.Coal: 20.00,
        Item.Silver: 12.00,
        Item.Helium3: 2.00,
      }.toTable()
    of 110:
      result = {
        Item.Iron: 66.0+1.0/3,
        Item.Coal: 18.0+1.0/3,
        Item.Silver: 11.00,
        Item.Helium3: 4.0+1.0/3,
      }.toTable()
    of 111:
      result = {
        Item.Iron: 66.0+2.0/3,
        Item.Coal: 16.0+2.0/3,
        Item.Silver: 10.00,
        Item.Helium3: 6.0+2.0/3,
      }.toTable()
    of 112:
      result = {
        Item.Iron: 67.00,
        Item.Coal: 15.00,
        Item.Silver: 9.00,
        Item.Helium3: 9.00,
      }.toTable()
    of 113:
      result = {
        Item.Iron: 67.0+1.0/3,
        Item.Coal: 13.0+1.0/3,
        Item.Helium3: 11.0+1.0/3,
        Item.Silver: 8.00,
      }.toTable()
    of 114:
      result = {
        Item.Iron: 67.0+2.0/3,
        Item.Helium3: 13.0+2.0/3,
        Item.Coal: 11.0+2.0/3,
        Item.Silver: 7.00,
      }.toTable()
    of 115:
      result = {
        Item.Iron: 68.00,
        Item.Helium3: 16.00,
        Item.Coal: 10.00,
        Item.Silver: 6.00,
      }.toTable()
    of 116:
      result = {
        Item.Iron: 68.0+1.0/3,
        Item.Helium3: 18.0+1.0/3,
        Item.Coal: 8.0+1.0/3,
        Item.Silver: 5.00,
      }.toTable()
    of 117:
      result = {
        Item.Iron: 68.0+2.0/3,
        Item.Helium3: 20.0+2.0/3,
        Item.Coal: 6.0+2.0/3,
        Item.Silver: 4.00,
      }.toTable()
    of 118:
      result = {
        Item.Iron: 69.00,
        Item.Helium3: 23.00,
        Item.Coal: 5.00,
        Item.Silver: 3.00,
      }.toTable()
    of 119:
      result = {
        Item.Iron: 100.00,
      }.toTable()
    of 120:
      result = {
        Item.Iron: 50.00,
        Item.Coal: 50.00,
      }.toTable()
    else:
      raise newException(DeepTownError, fmt"invalid floor: {floor}")
