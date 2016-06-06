import polarToCartesian from '../calc/polarToCartesian'


export default function describeConeSection(x, y, radius, radius2, start_angle, end_angle) {
  var deg = (end_angle - start_angle)
  var arc_sweep = deg <= 180 ? 0 : 1

  // dumb hack to make sure 360° cone sections show up as 359.99999° cone sections
  if (deg >= 360) end_angle -= 0.001

  var start = polarToCartesian(x, y, radius, end_angle)
  var end = polarToCartesian(x, y, radius, start_angle)

  var start2 = polarToCartesian(x, y, radius2, end_angle)
  var end2 = polarToCartesian(x, y, radius2, start_angle)

  return [
      "M", start.x, start.y,
      "A", radius, radius, 0, arc_sweep, 0, end.x, end.y,
      "L", end2.x, end2.y,
      "A", radius2, radius2, 0, arc_sweep, 1, start2.x, start2.y,
      "L", start.x, start.y,
  ].join(' ')
}
