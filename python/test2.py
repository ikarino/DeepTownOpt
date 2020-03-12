#!/usr/bin/env python
'''
'''
import json, itertools, random, pprint, math
from deap import creator, base, tools, algorithms
import pyDeepTown

def gl(n):
    return math.ceil(math.log10(n)/math.log10(2))

MINES = {
    6: 3,
    7: 14,
    8: 1
}
CMS = {
    2: 1,
    3: 1,
    4: 6
}
AREA_MAX = 75
N_SMELTING = 8
N_CRAFTING = 8
N_JEWEL = 8
N_CHEM = 3
N_GH = 2

P_CM = ["Silicon", "Sulfur", "Sodium", "Nitrogen"]

P_SMELTING = [
    "CopperBar",
    "IronBar",
    "AluminiumBar",
    "Glass",
    "SteelBar",
    "SilverBar",
    "GoldBar",
    "SteelPlate",
    # "TitaniumBar",
    # "MagnetiteBar"
]
P_CRAFTING = [
    "Graphite",
    "CopperNail",
    "Wire",
    "Battery",
    "Circuits",
    "Lamp",
    "LabFlask",
    "AmberCharger",
    "AluminiumBottle",
    "AmberInsulation",
    "InsulatedWire",
    "AluminiumTank",
    "Mirror",
    "MirrorLasor",
    "GreenLaser",
    "DiamondCutter",
    "MotherBoard",
    "SolidPropellant",
    "Accumulator",
    "SolarPanel",
    # "Gear",
    # "Bomb",
    # "Compressor",
    # "OpticFiber",
]
P_JEWEL = [
    "PolishedAmber",
    "PolishedEmerald",
    "PolishedTopaz",
    "PolishedRuby",
    "PolishedDiamond",
    "PolishedSapphire",
    "PolishedAmethyst",
    # "PolishedAlexandrite",
    # "PolishedObsidian",
    # "SapphireCrystalGlass",
    "AmberBracelet",
    "EmeraldRing",
    "MayaCalender",
    # "Haircomb",
    # "ObsidianKnife",
]
P_CHEM = [
    "CleanWater",
    "Hydrogen",
    "Rubber",
    "SulfuricAcid",
    "Ethanol",
    "RefinedOil",
    "PlasticPlate",
    # "Titanium",
    # "DiethylEther",
    # "GunPowder",
    # "LiquidNitrogen",
    # "MagnetiteOre",
    # "EnhancedHelium3",
    # "ToxicBomb",
]
P_GH = [
    "Tree",
    "Liana",
    "Grape"
]

N_GENE = \
    7*sum(MINES.values()) + \
    2*sum(CMS.values()) + \
    gl(len(P_SMELTING))*N_SMELTING + \
    gl(len(P_CRAFTING))*N_CRAFTING + \
    gl(len(P_CHEM))*N_CHEM + \
    gl(len(P_JEWEL))*N_JEWEL + \
    gl(len(P_GH))*N_GH
print(N_GENE)

def create_inp(gene):
    geneNow = 0
    def getGene(step):
        nonlocal geneNow
        geneNow += step
        return int("".join(map(str, gene[geneNow-step:geneNow])), 2)

    mining_stations = []
    for level, num in MINES.items():
        for _ in range(num):
            floor = getGene(7) % AREA_MAX + 1
            mining_stations.append(
                { "floor": floor, "lv": level },
            )
    chemical_minings = []
    for level, num in CMS.items():
        for _ in range(num):
            product = P_CM[getGene(2)]
            chemical_minings.append(
                {"product": product, "lv": level}
            )
    craftings = []
    for _ in range(N_SMELTING):
        product = P_SMELTING[getGene(gl(len(P_SMELTING))) % len(P_SMELTING)]
        craftings.append(product)
    for _ in range(N_CRAFTING):
        product = P_CRAFTING[getGene(gl(len(P_CRAFTING))) % len(P_CRAFTING)]
        craftings.append(product)
    for _ in range(N_CHEM):
        product = P_CHEM[getGene(gl(len(P_CHEM))) % len(P_CHEM)]
        craftings.append(product)
    for _ in range(N_JEWEL):
        product = P_JEWEL[getGene(gl(len(P_JEWEL))) % len(P_JEWEL)]
        craftings.append(product)
    for _ in range(N_GH):
        product = P_GH[getGene(gl(len(P_GH))) % len(P_GH)]
        craftings.append(product)

    jsonDict = {
      "InitialStore": {
          "Water": 500,
          "TreeSeed": 500,
          "LianaSeed": 500,
          "GrapeSeed": 500,
      },
      "MiningStation": mining_stations,
      "ChemicalMining": chemical_minings,
      "Crafting": craftings,
      "bots": [],
      "config": {
        "seed": 200
      }
    }
    return jsonDict

def wrapper():
    result = {}
    def run(gene):
        nonlocal result
        key = "".join(map(str, gene))
        if key in result:
            return result[key]

        jsonDict = create_inp(gene)
        if jsonDict is None:
            return (-100,)
        return pyDeepTown.runCoin(json.dumps(jsonDict)),
    return run

def main():
    creator.create("FitnessMax", base.Fitness, weights=(1.0,))
    creator.create("Individual", list, fitness=creator.FitnessMax)

    toolbox = base.Toolbox()

    toolbox.register("attr_bool", random.randint, 0, 1)
    toolbox.register("individual", tools.initRepeat, creator.Individual, toolbox.attr_bool, n=N_GENE)
    toolbox.register("population", tools.initRepeat, list, toolbox.individual)

    run = wrapper()
    toolbox.register("evaluate", run)
    toolbox.register("mate", tools.cxTwoPoint)
    toolbox.register("mutate", tools.mutFlipBit, indpb=0.05)
    toolbox.register("select", tools.selTournament, tournsize=3)

    population = toolbox.population(n=100)
    NGEN=40
    for gen in range(NGEN):
        offspring = algorithms.varAnd(population, toolbox, cxpb=0.5, mutpb=0.1)
        fits = toolbox.map(toolbox.evaluate, offspring)
        for fit, ind in zip(fits, offspring):
            ind.fitness.values = fit
        population = toolbox.select(offspring, k=len(population))

        print("===== GEN %02d =====" % gen)
        gene = tools.selBest(population, k=1)[0]
        print(run(gene))
        pprint.pprint(create_inp(gene))
    top10 = tools.selBest(population, k=10)
    print(top10)

if __name__ == "__main__":
    main()
