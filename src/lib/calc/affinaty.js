export default function calcAffinaty (v1, v2) {
  var c, cc
  if ((c = Math.abs(v2 - v1)) >= 2) {
    return -c
  } else if ((cc = c + 4) > 4) {
    return cc - 2
  } else {
    return cc
  }
}
