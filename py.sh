#!/bin/sh
# compile script for python library

# windows
nim c -d:release --threads:on --app:lib --out:python/pyDeepTown.pyd src/pyDeepTown.nim
# linux
# nim c -d:release --threads:on --app:lib --out:python/pyDeepTown.so src/pyDeepTown.nim
