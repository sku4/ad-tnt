.PHONY: rocks
rocks:
	tarantoolctl rocks install --tree=./.rocks --only-deps .rocks/ad-tnt-scm-3.rockspec
