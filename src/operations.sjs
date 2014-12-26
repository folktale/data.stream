/**
 * Common stream operations.
 *
 * @module data.stream/lib/operations
 */

// -- Dependencies -----------------------------------------------------
var { curry } = require('core.lambda');
var Maybe = require('data.maybe');
var Stream = require('./stream');
var { Cons, Nil } = Stream;


// -- Constructing streams ---------------------------------------------

/**
 * Constructs an infinite stream by applying a function to a seed.
 *
 * @method
 * @summary (α → β) → α → Stream(β)
 */
exports.iterate = curry(2, iterate);
function iterate(f, a) {
  return new Cons(a, λ[iterate(f, f(a))]);
}


/**
 * Constructs an infinite stream by repeating an element.
 *
 * @method
 * @summary α → Stream(α)
 */
exports.repeat = repeat;
function repeat(a) {
  return iterate(λ[a], a);
}


/**
 * Replicates a value N times.
 *
 * @method
 * @summary α → Stream(α)
 */
exports.replicate = curry(2, replicate);
function replicate(n, a) {
  return take(n, repeat(a));
}

/**
 * Constructs an infinite stream by cycling the elements of a stream.
 *
 * @method
 * @summary Stream(α) → Stream(α)
 */
exports.cycle = cycle;
function cycle(as) {
  var ys = Stream._concat(as, λ[ys.concat(ys)]);
  return ys;
}


/**
 * Constructs a finite stream from an array.
 *
 * @method
 * @summary [α] → Stream(α)
 */
exports.fromArray = fromArray;
function fromArray(xs) {
  return xs.reduceRight(function(ys, x) {
    return new Cons(x, λ[ys]);
  }, Nil);
}


// -- Slicing streams --------------------------------------------------

/**
 * Takes the first N elements of a stream.
 *
 * @method
 * @summary Int → Stream(α) → Stream(α)
 */
exports.take = curry(2, take);
function take(size, xs) {
  if (size === 0 || xs === Nil) {
    return Nil
  } else {
    return new Cons(xs.first(), λ[take(size - 1), xs.rest()])
  }
}


/**
 * Takes the first elements of a stream for which a predicate holds.
 *
 * @method
 * @summary (α → Boolean) → Stream(α) → Stream(α)
 */
exports.takeWhile = curry(2, takeWhile);
function takeWhile(p, xs) {
  if (xs === Nil) {
    return Nil;
  } else {
    var x = xs.first();
    if (!p(x)) {
      return Nil;
    } else {
      return new Cons(x, λ[takeWhile(p, xs.rest())]);
    }
  }
}


/**
 * Drops the first N elements of a stream.
 *
 * @method
 * @summary Int → Stream(α) → Stream(α)
 */
exports.drop = curry(2, drop);
function drop(size, xs) {
  while (size > 0 && xs !== Nil) {
    xs = xs.rest();
    size = size - 1;
  }
  return xs
}


/**
 * Drops the first elements of a stream to pass a predicate test.
 *
 * @method
 * @summary (α → Boolean) → Stream(α) → Stream(α)
 */
exports.dropWhile = curry(2, dropWhile);
function dropWhile(p, xs) {
  while (xs !== Nil) {
    var x = xs.first();
    if (p(x)) {
      xs = xs.rest();
    } else {
      break;
    }
  }

  return xs;
}


/**
 * Returns the first element of a stream.
 *
 * @method
 * @summary Stream(α) → Maybe(α)
 */
function first(xs) {
  return xs === Nil?  Maybe.Nothing()
  :      /* _ */      Maybe.Just(xs.head);
}


/**
 * Returns the rest of a stream.
 *
 * @method
 * @summary Stream(α) → Maybe(Stream(α))
 */
function rest(xs) {
  return xs === Nil?  Maybe.Nothing()
  :      /* _ */      Maybe.Just(xs.rest());
}


// -- Conversions ------------------------------------------------------

/**
 * Converts a finite stream to an array.
 *
 * @method
 * @summary Stream(α) → [α]
 */
exports.toArray = toArray;
function toArray(xs) {
  var result = [];
  while (xs !== Nil) {
    result.push(xs.first());
    xs = xs.rest();
  }
  return result;
}


// -- Transformations --------------------------------------------------

/**
 * Transforms a values with a 1:1 function.
 *
 * @method
 * @summary (α → β) → Stream(α) → Stream(β)
 */
exports.map = curry(2, map);
function map(f, xs) {
  return xs.map(f);
}


/**
 * Transforms values with a 1:N function.
 *
 * @method
 * @summary (α → Stream(β)) → Stream(α) → Stream(β)
 */
exports.flatMap = curry(2, flatMap);
function flatMap(f, xs) {
  return xs.chain(f);
}


/**
 * Filters the items of a stream.
 *
 * @method
 * @summary (α → Boolean) → Stream(α) → Stream(α)
 */
exports.filter = curry(2, filter);
function filter(p, xs) {
  if (xs === Nil) {
    return Nil;
  } else {
    var x = xs.first();

    return p(x)?    new Cons(x, λ[filter(p, xs.rest())])
    :      /* _ */  filter(p, xs.rest());
  }
}


/**
 * Merges two streams together.
 *
 * @method
 * @summary (α → β → γ) → Stream(α) → Stream(β) → Stream(γ)
 */
exports.zipWith = curry(3, zipWith);
function zipWith(f, xs, ys) {
  if (xs === Nil || ys === Nil) {
    return Nil;
  } else {
    return new Cons(f(xs.first(), ys.first()), λ[zipWith(f, xs.rest(), ys.rest())]);
  }
}


/**
 * Merges two streams together by tupling their values.
 *
 * @method
 * @summary Stream(α) → Stream(β) → Stream(α × β);
 */
exports.zip = zipWith(λ(a, b) -> [a, b]);
