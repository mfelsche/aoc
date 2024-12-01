today: aoc2024
	./aoc2024 --day $$(date +'%e')

aoc2024: $(wildcard 2024/*.pony) $(wildcard 2024/*/*.pony)
	corral run -- ponyc --debug --bin-name $@ 2024
