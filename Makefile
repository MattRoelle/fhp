all: fhp.lua fhp example

fhp:
	echo "#!/usr/bin/env lua" >> fhp
	fennel --require-as-include -c cli.fnl >> fhp
	chmod a+x fhp

fhp.lua: fhp.fnl
	fennel --require-as-include -c fhp.fnl > fhp.lua

example: fhp.lua
	cp fhp.lua example/lib/fhp.lua

clean:
	rm fhp.lua
	rm fhp

