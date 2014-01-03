# # Stream

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


class Thunk
  (@value) -> @forced = false

  force: ->
    if @forced => @value
    else       => do
                  @forced = true
                  @value  = @value!


export class Cons
  (@head, tail) -> @tail = new Thunk(tail)

  ### Semigroup
  _concat: (as) ->
    if as is Nil => this
    else         => new Cons @head, ~> @tail.force!concat as!

  concat: (as) -> @_concat -> as
  

  ### Monoid
  empty: -> Nil

  ### Functor
  map: (f) -> new Cons do
                       * f @head
                       * ~> @tail.force!map f

  ### Applicative
  ap: (b) -> b.map @head

  @of = (a) -> new Cons a, -> Nil
  of: (a) -> Cons.of a

  ### Chain
  chain: (f) -> (f @head)._concat ~> @tail.force!chain f

  ### Accessing
  first: -> @head
  rest: -> @tail.force!

  ### Foldable
  reduce: (acc, f) ->
    xs   = this
    tail = null
    while xs isnt Nil
      acc  := f acc, xs.head
      tail := xs.tail.force!
      if tail is Nil => break
      else           => xs := tail
    return acc
      

  ### Show
  to-string: -> "Stream(#{@head}, #{@rest!})"

export Nil = new class extends Cons
  concat: (as) -> as
  map: (f) -> this
  ap: (b) -> b
  chain: (f) -> this
  first: -> throw new Error "Can't take the first element of an empty Stream."
  rest: -> throw new Error "Can't take the rest of an empty Stream."
  to-string: -> "Stream.Nil"
