data.stream
===========

[![Build Status](https://secure.travis-ci.org/folktale/data.stream.png?branch=master)](https://travis-ci.org/folktale/data.stream)
[![NPM version](https://badge.fury.io/js/data.stream.png)](http://badge.fury.io/js/data.stream)
[![Dependencies Status](https://david-dm.org/folktale/data.stream.png)](https://david-dm.org/folktale/data.stream)
[![experimental](http://hughsk.github.io/stability-badges/dist/experimental.svg)](http://github.com/hughsk/stability-badges)


Lazy generic streams


## Example

```js
var Stream = require('data.stream')

var naturals = Stream.iterate(function(n){ return n + 1 }, 0)
var squared  = naturals.map(function(n){ return n * n })

Stream.toArray(Stream.take(10)(squared))
// => [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]

var fibs = new Cons(1, function(){
  return new Cons(2, function() {
    return Stream.zipWith(function(a, b){ return a + b })(fibs)(fibs.rest())
  })
})

Stream.toArray(Stream.take(10)(fibs))
// => [ 1, 1, 2, 3, 5, 8, 13, 21, 34, 55 ]
```


## Installing

The easiest way is to grab it from NPM. If you're running in a Browser
environment, you can use [Browserify][]

    $ npm install data.stream


### Using with CommonJS

If you're not using NPM, [Download the latest release][release], and require
the `data.stream.umd.js` file:

```js
var Stream = require('data.stream')
```


### Using with AMD

[Download the latest release][release], and require the `data.stream.umd.js`
file:

```js
require(['data.stream'], function(Stream) {
  ( ... )
})
```


### Using without modules

[Download the latest release][release], and load the `data.stream.umd.js`
file. The properties are exposed in the global `folktale.data.Stream` object:

```html
<script src="/path/to/data.stream.umd.js"></script>
```


### Compiling from source

If you want to compile this library from the source, you'll need [Git][],
[Make][], [Node.js][], and run the following commands:

    $ git clone git://github.com/folktale/data.stream.git
    $ cd data.stream
    $ npm install
    $ make bundle
    
This will generate the `dist/data.stream.umd.js` file, which you can load in
any JavaScript environment.

    
## Documentation

You can [read the documentation online][docs] or build it yourself:

    $ git clone git://github.com/folktale/data.stream.git
    $ cd data.stream
    $ npm install
    $ make documentation

Then open the file `docs/literate/index.html` in your browser.


## Platform support

This library assumes an ES5 environment, but can be easily supported in ES3
platforms by the use of shims. Just include [es5-shim][] :)


## Licence

Copyright (c) 2013 Quildreen Motta.

Released under the [MIT licence](https://github.com/folktale/data.stream/blob/master/LICENCE).

<!-- links -->
[Fantasy Land]: https://github.com/fantasyland/fantasy-land
[Browserify]: http://browserify.org/
[Git]: http://git-scm.com/
[Make]: http://www.gnu.org/software/make/
[Node.js]: http://nodejs.org/
[es5-shim]: https://github.com/kriskowal/es5-shim
[docs]: http://folktale.github.io/data.stream
<!-- [release: https://github.com/folktale/data.stream/releases/download/v$VERSION/data.stream-$VERSION.tar.gz] -->
[release]: https://github.com/folktale/data.stream/releases/download/v0.0.0/data.stream-0.0.0.tar.gz
<!-- [/release] -->
