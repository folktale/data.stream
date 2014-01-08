# # Lazy structures support

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

{Cons, Nil} = require './stream'

export iterate = (f, a) -->
  new Cons a, -> iterate f, (f a)

export repeat = (a) -> iterate (-> a), a

export replicate = (n, a) --> take n <| repeat a

export cycle = (xs) -> ys = xs._concat -> ys.concat ys

export take = (n, xs) -->
  if (n is 0) or (xs is Nil) => return Nil
  return new Cons xs.first!, -> take (n - 1), xs.rest!

export take-while = (p, xs) -->
  if xs is Nil => return Nil
  x = xs.first!
  if not (p x) => return Nil
  return new Cons x, -> take-while p, xs.rest!

export drop-while = (p, xs) -->
  x = null
  while xs isnt Nil
    x := xs.first!
    if not (p x) => return xs
    else         => xs := xs.rest!
  return xs

export drop = (n, xs) -->
  while (n > 0) and (xs isnt Nil)
    xs := xs.rest!
    n  := n - 1
  return xs

export to-array = (xs) ->
  result = []
  while xs isnt Nil
    result.push xs.first!
    xs := xs.rest!
  return result

make-thunk = (x) -> (-> x)

export from-array = (array) ->
  seq = Nil
  for e in array by -1
    seq := new Cons e, make-thunk(seq)
  seq

export first = (xs) -> xs.first!

export rest = (xs) -> xs.rest!
    
export is-empty = (xs) -> xs is Nil

export map = (f, xs) --> xs.map f

export flat-map = (f, xs) --> xs.chain f

export foldl = (f, initial, xs) --> xs.reduce initial, f

export concat = (++)

export filter = (p, xs) -->
  if xs is Nil => return Nil
  x = xs.first!
  if not (p x) => xs.rest!
  else         => new Cons x, -> filter p, xs.rest!

export reverse = (xs) -> xs.reduce Nil, (ys, x) -> new Cons x, -> ys

export interpose = (a, xs) -->
  if xs is Nil => Nil
  else         => new Cons xs.first!, -> (new Cons a, -> interpose a, xs.rest!)
  
export interleave = (xs, ys) -->
  if ys is Nil => Nil
  else         => ((Cons.of ys.first!).concat xs)._concat -> interleave xs, ys.rest!
  
export zip-with = (f, xs, ys) -->
  if (xs is Nil) or (ys is Nil) => Nil
  else => new Cons (f xs.first!, ys.first!), -> zip-with f, xs.rest!, ys.rest!

export zip = zip-with (a, b) -> [a, b]
