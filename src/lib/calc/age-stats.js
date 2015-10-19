
let moment = require('moment')

let ages = [18, 25, 35, 45]

function subtract(me, stats, d) {
  let pos = d.pos
  if (!pos) return
  let age_with_opinion = moment(me.birthdate).subtract(Date.now() - d.created).valueOf() + 3629124000000
  // transform -2 -> 0, ... 2 -> 3
  pos = pos > 0 ? pos + 1 : pos + 2
  let k = '>'

  for (let i = 0; i < ages.length; i++) {
    let age = ages[i]
    var age_ms = moment().subtract(age * 365.25 * 24 * 60 * 60 * 1000).valueOf() + 3629124000000
    if (age_ms < age_with_opinion) {
      k = age
      break
    }
  }

  k = k + '-' + me.planet + pos
  console.info('subtract', pos, k)
  stats[k]--
}

function add(me, stats, d) {
  let pos = d.pos
  if (!pos) return
  let age_with_opinion = moment(me.birthdate).subtract(Date.now() - d.created).valueOf() + 3629124000000
  // transform -2 -> 0, ... 2 -> 3
  pos = pos > 0 ? pos + 1 : pos + 2
  let k = '>'

  for (let i = 0; i < ages.length; i++) {
    let age = ages[i]
    var age_ms = moment().subtract(age * 365.25 * 24 * 60 * 60 * 1000).valueOf() + 3629124000000
    if (age_ms < age_with_opinion) {
      k = age
      break
    }
  }

  k = k + '-' + me.planet + pos
  console.info('add', pos, k)
  stats[k] = (stats[k] + 1) || 1
}

export default { add, subtract }
