/**
 * Base stream implementation.
 *
 * @module data.stream/lib/stream
 */

// -- Dependencies -----------------------------------------------------
var show = require('core.inspect');
var { Base, Cata } = require('adt-simple');


// -- Helpers ----------------------------------------------------------

/**
 * Lazily concatenates a Stream.
 *
 * @method
 * @private
 * @summary Stream(α), (Void → Stream(α)) → Stream(α)
 */
function lazyConcat(xs, ys) {
  if (xs === Nil) {
    return ys();
  } else {
    return new Cons(xs.head, λ[xs.rest().concat(ys())])
  }
}

/**
 * Constructs a lazy value.
 *
 * @method
 * @private
 * @summary (Void → α) → Lazy(Void → α)
 */
function lazy(a) {
  return new Lazy(a)
}

/**
 * Not implemented.
 *
 * @method
 * @private
 * @summary (...) → Void :: throws
 */
function unimplemented() {
  throw new Error('Not implemented.');
}

/**
 * Represents a Lazy value.
 *
 * Lazy values are delayed computations that may be forced once, from
 * there onwards it always yields the same result without performing
 * the computation again.
 *
 * @class
 * @private
 * @summary Lazy(Void → α)
 */
function Lazy(computation) {
  this._computation = computation;
  this._forced = false;
  this._value = null;
}

/**
 * Returns the value represented by this lazy computation.
 *
 * @method
 * @summary @Lazy(Void → α) => Void → α
 */
Lazy::value = function() {
  if (this._forced) {
    return this._value;
  } else {
    this._forced = true;
    this._value = this._computation();
    return this._value;
  }
};

// -- Public interface -------------------------------------------------

/**
 * Represents a (potentially infinite) stream of lazy values.
 *
 * @class
 * @summary
 * type Stream(α) {
 *   | Cons { head: α, tail: Void → Stream(α) }
 *   | Nil
 * }
 */
union Stream {
  Cons { head: *, tail: lazy },
  Nil
} deriving (Base, Cata);



// -- Semigroup
/**
 * Concatenates two streams.
 *
 * @method
 * @summary @Stream(α) => Stream(α) → Stream(α)
 */
Stream::concat = unimplemented;
Stream._concat = lazyConcat;

Cons::concat = function(bs) {
  var self = this;

  if (self === Nil) {
    return bs;
  } else {
    return new Cons(self.head, λ[self.rest().concat(bs)])
  }
};

Nil.concat = function(bs) {
  return bs;
}


// -- Monoid
/**
 * Returns an empty stream.
 *
 * @method
 * @summary @Stream(α) => Stream(α)
 */
Stream::empty = function(){
  return Nil;
};
Stream.empty = Stream::empty;


// -- Functor
/**
 * Transforms the values in the Stream using the a 1:1 function.
 *
 * @method
 * @summary @Stream(α) => (α → β) → Stream(β)
 */
Stream::map = unimplemented;

Cons::map = function(f) {
  var self = this;

  return new Cons(f(self.head), λ[self.rest().map(f)])
};

Nil.map = function(f) {
  return Nil;
}


// -- Applicative
/**
 * Applies the function in the stream to another stream.
 *
 * @method
 * @summary @Stream(α → β) => Stream(α) → Stream(β)
 */
Stream::ap = unimplemented;

Cons::ap = function(bs) {
  return this.chain(function(f) {
    return bs.map(f)
  })
};

Nil.ap = function(bs) {
  return bs
}


/**
 * Constructs a new Stream with one value.
 *
 * @method
 * @summary @Stream(α) => β → Stream(β)
 */
Stream::of = function(a) {
  return new Cons(a, λ[Nil])
};
Stream.of = Stream::of;


// -- Chain
/**
 * Transforms the values in the Stream using a 1:N function.
 *
 * @method
 * @summary @Stream(α) => (α → Stream(β)) → Stream(β)
 */
Stream::chain = unimplemented;

Cons::chain = function(f) {
  var self = this;
  
  return lazyConcat(f(self.head), λ[self.rest().chain(f)]);
}

Nil.chain = function(f) {
  return Nil;
}


// -- Access
/**
 * Returns the first item of the stream.
 *
 * @method
 * @summary @Stream(α) => Void → α  :: partial, throws
 */
Stream::first = unimplemented;

Cons::first = function() {
  return this.head;
}

Nil.first = function() {
  throw new Error("Can't take the first element of an empty Stream.");
}

/**
 * Returns the rest of the stream.
 *
 * @method
 * @summary @Stream(α) => Void → Stream(α)  :: partial, throws
 */
Stream::rest = unimplemented;

Cons::rest = function() {
  return this.tail.value();
}

Nil.rest = function() {
  throw new Error("Can't take the rest of an empty Stream.");
}


// -- Show
/**
 * Returns a String representation of the stream.
 *
 * @method
 * @summary @Stream(α) => Number → String
 */
Stream::toString = unimplemented;

Cons::toString = function(size) {
  return "Stream(" + repr(this, size || 10) + ")";

  function repr(xs, size) {
    if (xs === Nil) {
      return xs.toString();
    } else if (size <= 0) {
      return "(...)"
    } else {
      return show(xs.head) + ", " +repr(xs.rest(), size - 1);
    }
  }
}

Nil.toString = function() {
  return "Stream.Nil"
}



// -- Exports ----------------------------------------------------------
module.exports = Stream
