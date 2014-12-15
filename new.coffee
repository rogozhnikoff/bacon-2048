_ = require('./vendor/lodash.js')
Immutable = require('./vendor/immutable.min.js')
require('./vendor/array.find.js')

# shift([0, 2, 2, 0])


notZero = (num) ->
  return num isnt 0

shift = (vector) ->
  console.log '123', vector, vector.length
  return Immutable.Vector([]) if vector.length is 0

  first = vector[0]
  tail = vector[1..]

  if first is 0
    # ищем ближайший не ноль
    firstNonEmptyInTail = tail.find(notZero)

  else
    # возвращаем shift(tail)




#    if first is firstNonEmptyInTail

#    if firstNonEmptyInTail?


tests = [
  [[1, 2], []]
  [[0,0], [0,0]]
  [[0,2], [2,0]]
  [[2,2], [4,0]]
  [[2,0,2], [4,0,0]]
  [[0,2,2], [4,0,0]]
  [[2,2,2,2], [4,4,0,0]]
]


for test in tests
  try
    ret = shift(Immutable.Vector(test[0]))
    if ret is Immutable.Vector(test[1])
      console.log('+ ok')
    else
      console.log("- error in #{test}", "| test return #{ret}", "but must #{test[1]}")
  catch err
    console.error('---- some error', err)