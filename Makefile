.PHONY: deps
deps:
	luarocks install lua-resty-oss-0.01-0.rockspec --tree deps --only-deps


.PHONY: clean
clean:
	rm -rf ./deps
