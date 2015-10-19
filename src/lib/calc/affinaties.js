import calcAffinaty from './affinaty'

export default function calcAffinaties (opinions) {
  var diaspora, coinciding, affinaties, nodup, duplicates, j, len$, opinion, dk, debate_id, o_diaspora, ooo, max, len, j, k, k, opinion_j, opinion_k, affinaty, key, calc
  diaspora = {}
  coinciding = {}
  affinaties = {}
  nodup = {}
  duplicates = []
  for (j = 0, len$ = opinions.length; j < len$; ++j) {
    opinion = opinions[j]
    dk = opinion.debate + ':' + opinion.creator
    if (typeof nodup[dk] !== 'undefined') {
      duplicates.push(opinion)
      continue
    }
    nodup[dk] = opinion.pos
    debate_id = opinion.debate + ''
    o_diaspora = diaspora[debate_id]
    if (typeof o_diaspora === 'undefined') {
      diaspora[debate_id] = [opinion]
    } else if (typeof (ooo = coinciding[debate_id]) === 'undefined') {
      coinciding[debate_id] = o_diaspora.concat(opinion)
      diaspora[debate_id] = null
    } else {
      coinciding[debate_id].push(opinion)
    }
  }
  max = 0
  for (debate_id in coinciding) {
    opinions = coinciding[debate_id]
    len = opinions.length
    max += 2
    for (j = 0; j < len; ++j) {
      for (k = 0; k < len; ++k) {
        opinion_j = opinions[j]
        opinion_k = opinions[k]
        affinaty = affinaties[key = opinion_j.creator + '::§::' + opinion_k.creator] || 0
        calc = calcAffinaty(opinion_j.pos, opinion_k.pos)
        affinaty += calc
        affinaties[key] = affinaty
      }
    }
  }
  return {
    diaspora: diaspora,
    coinciding: coinciding,
    affinaties: affinaties
  }
}
