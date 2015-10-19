
let Pikaday = require('pikaday')

function pikaday (node, keypath, save_keypath) {
  let setting = false
  let ractive = this
  let bday = new Date(this.get(keypath)).valueOf()
  let maxDate = new Date('11-11-2011').valueOf()
  let minDate = new Date('01-01-1930').valueOf()
  let pika = new Pikaday({
    field: node,
    bound: true,
    yearRange: [1930, 2011],
    defaultDate: new Date(bday > maxDate ? maxDate : bday < minDate ? minDate : bday),
    setDefaultDate: true,
    maxDate: maxDate,
    minDate: minDate,
    format: 'D MMM YYYY',
    i18n: {
      previousMonth: 'Mes Anterior',
      nextMonth: 'Próximo Mes',
      months: ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Augusto','Septiembre','Octubre','Noviembre','Diciembre'],
      weekdays: ['Domingo','Lunes','Martes','Miercoles','Jueves','Viernes','Sabado'],
      weekdaysShort: ['Dom','Lun','Mar','Mie','Jue','Vie','Sab']
    },
    onSelect () {
      let d = this.getMoment().valueOf()
      if (d) ractive.set(save_keypath || keypath, d)
    }
  })
  this.on('pikaday', () => { pika.show() })

  this.observe(keypath, function (date) {
    if (setting) return
    pika.setDate(date)
  })

  return {
    teardown () {
      pika.destroy()
    }
  }
}

export default pikaday
