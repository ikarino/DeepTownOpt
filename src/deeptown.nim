# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.

import json
import miner


when isMainModule:
  let j = "./inputs/inp1.json".parseFile()
  let m = newMiner(j)
  echo m.calcCoin()
