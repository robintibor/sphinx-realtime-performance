numToStrWithLength = (number, length) ->
    numberAsString = number.toString()
    if (numberAsString.length < length)
        whiteSpaces = Array(length - numberAsString.length).join(' ')
        return whiteSpaces + numberAsString
    else
        return numberAsString

exports.numToStrWithLength = numToStrWithLength