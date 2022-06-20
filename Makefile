all: fhp.lua fhp example

fhp:
	echo "#!/usr/bin/env lua" >> fhp
	cat fhp.lua >> fhp

fhp.lua: fhp.fnl
	fennel --require-as-include -c fhp.fnl > fhp.lua

example: fhp.lua
	cp fhp.lua example/lib/fhp.lua

clean:
	rm fhp.lua
	rm fhp

