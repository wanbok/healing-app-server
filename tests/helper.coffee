module.exports.deepEquals = (o1, o2) ->
  k1 = Object.keys(o1).sort()
  k2 = Object.keys(o2).sort()
  return false if (k1.length != k2.length)
  return k1.zip(k2, (keyPair) ->
    if (typeof o1[keyPair[0]] == typeof o2[keyPair[1]] == "object")
      return deepEquals(o1[keyPair[0]], o2[keyPair[1]])
    else
      return o1[keyPair[0]] == o2[keyPair[1]]
  ).all()