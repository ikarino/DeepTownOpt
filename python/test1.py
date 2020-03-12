#!/usr/bin/env python
'''
just import and run pyDeepTown emulator
'''
import pyDeepTown

with open("../inputs/inp1.json") as f:
    text = f.read()

result = pyDeepTown.run(text)
print(result)
