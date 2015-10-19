

## bugs

 - all `existing` objs should update.
  - grab observable-array and make it part of that.
 - option text length for add & existing
 - age list is in my.opinion (api/opinion.js) && api/age-stats.js
 - set-up should put your foto if it already exists
 - (maybe) affinaty for new debates not calculated correctly.
 - separate out opinion-list from debate-list (and also the infinte scroll)
  - the bug happens that `this.op` stays set between views


## short-term goals

 - inbox panel in the profile messenger
 - put the [me](-Affinaty-)[you] bar in profile
 - immediately get debates I have out of local storage when going to /home (listing)
  - integrate this with the Ractive api containers
 - da-funk put into the lib
 - new message notifications
 - add `Ambition` containers to api for each db collection
  - `debate`
  - `relation`
 - add functions to `Ambition` containers to add / remove / update (for sync with the database)
 - clean up settings page
  - I have two versions of pikaday (use the decorator)
  - use the standard form validation methods


## still to be done

 - when modifying option selection, update the age/sex stats (requires parsing the stats like in debate stats)
 - search showing results
 - change api over to an `Ambition` container
 - setup some proxies inside of node modules from sector-11
 - build out codemirror on sector-9 (and other frontend-dev stuff)
 - home is the whole website, not just the people you are following
 - infinite scroll
  - downward for appending more debates to the list
  - upward for messaging
  - skip value separated in scroll function for debates / polls
  - skip function based on d.created
  - make scroll on both sides.
   - get objects <= time -> cursor. {debate: 'xxx', order: '+created:'+Date.now()}
    - the server gives back based on skip greater that that date
   - later, we update by fetching without skip >= Date.now()
   - when reaching the top, reset skip & ask for >= last date (and stick them on the top)
 - write tests in karma
  - another option is to just use ractive.toHTML to check each componentx
 - foto-upload add button: no quiero esta foto - o `x`)


## server stuff

 - cron job to constantly update the tag finder with the tag scores (scoring based on opinion and count)
 - list getting based on time instead of skip
 - word / id -> addScores for tag completion (when adding a new debate - or perhaps based on num opinions)
 - fix search functionality
 - migrate the api over to impress
 - automatic module recompilation saves the MODULE_VERSION into the cache file (and compares it in start)
 - delete users / etc.
 - for all o-i-d references, make sure the ref exists.
  - should be cached using redis
  - debate / poll create (especially since someone can send bogus ids)
 - when the connection comes in, save one `Date.now!` to be used throughout.
 - save the country / province
  - add missing province ids (and save user province)
 - foto upload:
  - sometimes there are rounding errors on resizing
  - gives error: `{_id: "55ad10acab60875c00a50136", action: "foto<", rect: {h: 0.95, l: 0.020833333333333332, t: 0.05, w: 0.475}}`
  - need to do perceptual hash better
  - set background color (to allow for resizing outside of the region)


## finalization things

 - integrate the scrollbar into all scrolling elements
 - write integration tests
 - rebuild font-awesome with only the icons we need
  - include with vicente's fonts as well (use cepticons)
  - rename facebook and twitter icons (fb, tw)


## later improvement


 - semantic search in spanish for search
  - while you're at it, also move `reds` into the library (without all the excess natural shit)
 - move the util functions into correct dir
 - add a loading spinner to the images
 - two column alphabetical categories
 - drop photo in photo box (need to put icon)
 - rebuild dropzone as a ractive component
 - make vicente a new place to put the fotos for his design up
 - change out chart.js (it's unnecessarily large)
  - do own svg: http://jsfiddle.net/da5LN/62/
	- have a look at more alternatives: https://github.com/sorrycc/awesome-javascript#data-visualization
	- use paper.js (it has all kinds of neat stuff for art production)
	 - https://github.com/paperjs/paper.js


tool tips:
```
let Opentip # require('opentip')
Opentip.styles.drop # {
  className: "drop",
  borderWidth: 1,
  stemLength: 12,
  stemBase: 16,
  borderRadius: 20,
  borderColor: "#c3e0e6",
  background: [ [ 0, "#f1f7f0" ], [ 1, "#d3f0f6" ] ]
}
new Opentip(box, "cool", { style: "drop", tipJoint: "top right", stem: "top right", stemLength: 30, stemBase: 20 })
```
