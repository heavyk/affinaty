export default function mod360 (e) {
  e < 0 ? e += 360 : e > 360 && (e -= 360)
  return e
}
