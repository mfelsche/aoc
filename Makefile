today: aoc2024
	./aoc2024 --day $$(date +'%e')

lock.json: corral.json
	corral fetch

aoc2024: $(wildcard 2024/*.pony) $(wildcard 2024/*/*.pony) lock.json
	
	corral run -- ponyc --debug --bin-name $@ 2024
