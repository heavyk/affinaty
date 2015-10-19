export default function camelize (str) {
  var idx = str.indexOf("-")
  while (~idx) {
    str = str.slice(0, idx) + str.charAt(idx + 1).toUpperCase() + str.slice(idx + 2)
    idx = str.indexOf("-")
  }
  return str;
}
