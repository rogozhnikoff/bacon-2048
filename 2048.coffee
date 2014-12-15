# points = [0..16]
# points = (new Point(opt) for opt in points)
LINE_LENGTH = 4


class Desk
  constructor: (@points) ->
    length = points.length
    isReallySquare = not(false in (pointRow.length is length for pointRow in points))
    throw 'Not a square!' unless isReallySquare

  @empty: ->
    new Desk([
      [0, 0, 0, 0]
      [0, 0, 0, 0]
      [0, 0, 0, 0]
      [0, 0, 0, 0]
    ])

  pointsClone: ->
    return _(@points).clone()

class Projection
  constructor: (@line) ->

  # get :: Desk -> Array[Int]
  get: (deskInstance) ->

  # set :: (Desk, Array[Int]) -> Desk
  set: (deskInstance, value) ->

class HorizontalProjection extends Projection
  get: (deskInstance) ->
    return deskInstance.points[@line]

  set: (deskInstance, value) ->
    newPoints = deskInstance.pointsClone()
    newPoints[@line] = value
    return new Desk(newPoints)

class VerticalProjection extends Projection
  get: (deskInstance) ->
    return (pointRow[@line] for pointRow in deskInstance.points)

  set: (deskInstance, value) ->
    newPoints = deskInstance.pointsClone()
    pointRow[@line] = value[i] for pointRow, i in newPoints
    return new Desk(newPoints)


numberGenerator = -> if Math.random() < 0.9 then 2 else 4
genPos = -> Math.floor(Math.random() * LINE_LENGTH)

# generateDefaults :: Desk -> Desk
generateDefaults = (deskInstance, count = 1) ->
  newPoints = deskInstance.pointsClone()
  pasted = 0
  while pasted < count
    x = genPos()
    y = genPos()

    if newPoints[x][y] is 0
      newPoints[x][y] = numberGenerator()
      pasted++

  new Desk(newPoints)

# mkMove :: (Desk, Movement) -> Desk
mkMove = (deskInstance, move) ->
  newDesk = Desk.empty()
  for num in [0..LINE_LENGTH]
    projection = do ->
      if Movement.isVertical(move)
        return new VerticalProjection(num)
      else if Movement.isHorizontal(move)
        return new HorizontalProjection(num)
      else throw "undefined direction #{move}, #{num}"

    vector = do (vector = projection.get(deskInstance), needReverse = Movement.direction(move))->
      vector = vector.reverse() if needReverse
      vector = shiftVector(vector)
      vector = vector.reverse() if needReverse # reverse to start position, after shifting
      return vector

    newDesk = projection.set(newDesk, vector)
  newDesk

# shiftVector :: Array[int] -> Array[int]
# vector = [0, 2, 2, 4]
shiftVector = (vector) ->
  curPos = 0
  while curPos < vector.length
    if vector[curPos] is 0
      innerPos = curPos + 1
      while innerPos < vector.length
        unless vector[innerPos] is 0
          vector[curPos] = vector[innerPos] # Shift element from position in inner cycle to position in outer cycle
          vector[innerPos] = 0 # and flush element from inner cycle
          break # Exit from inner cycle
        else innerPos++ # Move to next pos in inner cycle

        if innerPos is vector.length - 1 then curPos++ # Detected end of inner cycle; in situations when all zeros
    else
      innerPos = curPos + 1
      for innerPos in [(curPos + 1)..vector.length]
        unless vector[innerPos] is 0
          if vector[innerPos] is vector[curPos]
            vector[curPos] *= 2
            vector[innerPos] = 0
          break
      curPos++
  vector

### test-cases
[] -> []
00 -> 00
02 -> 20
22 -> 40
202 -> 400
022 -> 400
2222 -> 4400
###
class Movement
  @UP = 'up'
  @DOWN = 'down'
  @LEFT = 'left'
  @RIGHT = 'right'

  # isHorizontal :: Movement -> Bool
  @isHorizontal = (move) -> move in [Movement.LEFT, Movement.RIGHT]

  # isVertical :: Movement -> Bool
  @isVertical = (move) -> move in [Movement.UP, Movement.DOWN]

  # direction :: Movement -> Int
  @direction = (move) -> if move in [Movement.RIGHT, Movement.DOWN] then 1 else -1

# deskStream :: Bacon.Bus[Movement]
movementStream = (new Bacon.Bus())
  .log("Movement")


setInterval(->
  random = _(['left', 'up', 'down', 'right']).shuffle().value()[0]
  movementStream.push(random)
, 4000)

# deskStream :: Bacon.Bus[Desk]
deskStream = (new Bacon.Bus())
  .toProperty(generateDefaults(Desk.empty(), 2))
  .combine(movementStream, mkMove)
  .log("State")

deskStream.onValue -> null
