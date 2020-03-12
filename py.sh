# windows
nim c --threads:on --app:lib --out:python/pyDeepTown.pyd src/pyDeepTown.nim
# linux
# nim c -d:release --tlsEmulation:off --app:lib --out:python/pyDeepTown.so src/pyDeepTown.nim
