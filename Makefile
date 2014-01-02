bin        = $(shell npm bin)
lsc        = $(bin)/lsc
browserify = $(bin)/browserify
groc       = $(bin)/groc
uglify     = $(bin)/uglifyjs
VERSION    = $(shell node -e 'console.log(require("./package.json").version)')


lib: src/*.ls
	$(lsc) -o lib -c src/*.ls

dist:
	mkdir -p dist

dist/data.stream.umd.js: compile dist
	$(browserify) lib/index.js --standalone folktale.data.Stream > $@

dist/data.stream.umd.min.js: dist/data.stream.umd.js
	$(uglify) --mangle - < $^ > $@

# ----------------------------------------------------------------------
bundle: dist/data.stream.umd.js

minify: dist/data.stream.umd.min.js

compile: lib

documentation:
	$(groc) --index "README.md"                                              \
	        --out "docs/literate"                                            \
	        src/*.ls test/*.ls test/specs/**.ls README.md

clean:
	rm -rf dist build lib

test:
	$(lsc) test/tap.ls

package: compile documentation bundle minify
	mkdir -p dist/data.stream-$(VERSION)
	cp -r docs/literate dist/data.stream-$(VERSION)/docs
	cp -r lib dist/data.stream-$(VERSION)
	cp dist/*.js dist/data.stream-$(VERSION)
	cp package.json dist/data.stream-$(VERSION)
	cp README.md dist/data.stream-$(VERSION)
	cp LICENCE dist/data.stream-$(VERSION)
	cd dist && tar -czf data.stream-$(VERSION).tar.gz data.stream-$(VERSION)

publish: clean
	npm install
	npm publish

bump:
	node tools/bump-version.js $$VERSION_BUMP

bump-feature:
	VERSION_BUMP=FEATURE $(MAKE) bump

bump-major:
	VERSION_BUMP=MAJOR $(MAKE) bump


.PHONY: test
