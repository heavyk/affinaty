const HALF_PI = Math.PI / 180

export default function polarToCartesian(centerX, centerY, radius, angleInDegrees) {
  typeof centerX === 'function' && (centerX = centerX())
  typeof centerY === 'function' && (centerY = centerY())
  typeof radius === 'function' && (radius = radius())
  typeof angleInDegrees === 'function' && (angleInDegrees = angleInDegrees())

  var angleInRadians = (angleInDegrees-90) * HALF_PI

  return {
    x: centerX + (radius * Math.cos(angleInRadians)),
    y: centerY + (radius * Math.sin(angleInRadians))
  }
}
