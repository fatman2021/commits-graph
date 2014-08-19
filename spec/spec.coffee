assert = require 'assert'

generateGraphData = require '../coffee/commits-graph'

input = require './input.json'
expectedOutput = require './output'

actualOutput = generateGraphData(input)

assert.deepEqual(actualOutput, expectedOutput)

console.log('pass')
