# # Specification for the monadic laws

/** ^
 * Copyright (c) 2014 Quildreen Motta
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation files
 * (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge,
 * publish, distribute, sublicense, and/or sell copies of the Software,
 * and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

# Before we define the specification, we need to set up the specs
# libraries, and grab a hold of our data structure and the laws we want
# to verify.
spec = (require 'hifive')!
laws = require 'laws'
{forAll, data} = require 'claire'
assert = require 'assert'

{Cons, Nil, to-array, from-array, iterate} = require '../../src/'

# And to use the laws, we need to provide a constructor function, that
# given a single argument will return a new data structure containing
# that argument. We also make sure that the constructor for our
# semigroup implementation lifts the value into a non empty list, so we
# can concatenate the values.
make = (a) -> Cons.of a

# Then we provide the specification for the test runner. As we're using
# Hifive here, it expects that each definition for the specification to
# have a function that will throw exceptions on failures. We use the
# `asTest` property from Claire that returns exactly what Hifive (and
# Mocha & other testing libraries) expect.
module.exports = spec 'Algebraic laws' (o, spec) ->

  spec ': Semigroup' (o) ->
    o '1. Associativity' laws.semigroup.associativity(make).as-test!

  spec ': Monoid' (o) ->
    o '1. Right identity' laws.monoid.right-identity(make).as-test!
    o '2. Left identity'  laws.monoid.left-identity(make).as-test!
 
  spec ': Functor' (o) ->
    o '1. Identity'     laws.functor.identity(make).as-test!
    o '2. Composition'  laws.functor.composition(make).as-test!

  spec ': Applicative' (o) ->
    o '1. Identity'     laws.applicative.identity(make).as-test!
    o '2. Composition'  laws.applicative.composition(make).as-test!
    o '3. Homomorphism' laws.applicative.homomorphism(make).as-test!
    o '4. Interchange'  laws.applicative.interchange(make).as-test!
 
  spec ': Chain' (o) ->
    o '1. Associativity' laws.chain.associativity(make).as-test!
 
  spec ': Monad' (o) ->
    o '1. Left identity'  laws.monad.left-identity(make).as-test!
    o '2. Right identity' laws.monad.right-identity(make).as-test!

  spec ': to-array' (o) ->
    o '1. Left inverse', (for-all(data.Array(data.Int)).satisfy (list) ->
      casted = to-array(from-array(list))
      assert.deepEqual(to-array(from-array(list)), list)
      true
    ).as-test!
    o '2. Right inverse', (for-all(data.Array(data.Int)).satisfy (list) ->
      seq = from-array(list)
      seq.is-equal(from-array(to-array(seq)))
    ).as-test!

  spec ': reduce-right' (o) ->
    o '1. Identity with Nil and Cons', (forAll(data.Array(data.Int)).satisfy (list) ->
      seq = from-array(list)
      reduced = seq.reduce-right Nil, (x, y) -> new Cons x, y
      seq.is-equal(reduced)
    ).as-test!

    o '2. Well-behaved with infinite streams', ->
      seq = iterate (1+), 0
      result = seq.reduce-right 0, (el, next) ->
        if el > 4 then el else next() + el

      assert.equal(result, 15)
