# This is just an example to get you started. A typical binary package
# uses this file as the main entry point of the application.

import json, strformat
import miner, data

proc run(seconds = 60*60*24, inputfile: string) =
  let j = inputfile.parseFile()
  let m = newMiner(j)
  let coins = m.calcCoin(seconds)
  echo fmt"coins: {coins:>.1f}/sec"
  echo m.s

when isMainModule:
  import cligen
  dispatch(run, help = {
    "seconds": "time to run[s]"
  })
