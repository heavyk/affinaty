
var shortformRegex = /^#?([a-f\d])([a-f\d])([a-f\d])$/i,
  longformRegex = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i

export default function (hex) {
  var rgbParts

  if (hex.length < 5) hex = hex.replace(shortformRegex, function (m, r, g, b) {
    return r + r + g + g + b + b
  })

  rgbParts = longformRegex.exec(hex)

  // return rgbParts ? [ parseInt(rgbParts[1], 16), parseInt(rgbParts[2], 16), parseInt(rgbParts[3], 16) ] : [ 0, 0, 0 ]
  return new Uint8Array(rgbParts ? [ parseInt(rgbParts[1], 16), parseInt(rgbParts[2], 16), parseInt(rgbParts[3], 16) ] : [ 0, 0, 0 ])
}
