const Path = require('path')
const magic = require('magic-string')

const cwd = process.cwd()

delete require.cache[__filename]
module.exports = translate


function translate (txt, options) {
  var file = Path.relative(cwd, this.src)
  var local = options.local
  var lang = options.lang

  switch (file) {
    case 'src/views/inbox.html':
      if (lang === 'en') {
        txt = replace(txt, `Mensajería`, `-`)
        txt = replace(txt, `Buscador`, `-`)
        txt = replace(txt, `Preferencias`, `-`)
        txt = replace(txt, `Función aún no activa`, `-`)
        txt = replace(txt, `Con los filtros de control podrás:`, `-`)
        txt = replace(txt, `Denunciar`, `-`)
        txt = replace(txt, `Formatear la visualización de tus conversaciones`, `-`)
        txt = replace(txt, `Borrar historal`, `-`)
      }
      break

    case 'src/views/listing.html':
      if (lang === 'en') {
        txt = replace(txt, `Top Affinaty`, `-`)
        txt = replace(txt, `Mis Top`, `-`)
      }
      break

    case 'src/views/profile.html':
      if (lang === 'en') {
        txt = replace(txt, `Editar Perfil`, `-`)
        txt = replace(txt, `No Seguir`, `-`)
        txt = replace(txt, `Seguir`, `-`)
        txt = replace(txt, `Mensaje`, `-`)
        txt = replace(txt, `- affin`, `-`)
        txt = replace(txt, `+ affin`, `-`)
        txt = replace(txt, `Publicaciones`, `-`)
        txt = replace(txt, `Opiniones`, `-`)
        txt = replace(txt, `Siguiendo`, `-`)
        txt = replace(txt, `Seguidores`, `-`)
      }
      break

    case 'src/views/settings.html':
      if (lang === 'en') {
        txt = replace(txt, `Configuración`, `-`)
        txt = replace(txt, `Editar perfil`, `-`)
        txt = replace(txt, `Redes Sociales`, `-`)
        txt = replace(txt, `Cancelar`, `-`)
        txt = replace(txt, `Cambiar foto`, `-`)
        txt = replace(txt, `Cambia tu nombre`, `-`)
        txt = replace(txt, `Cambia tu descripción`, `-`)
        txt = replace(txt, `Cambia tu localización`, `-`)
        txt = replace(txt, `País`, `-`)
        txt = replace(txt, `Provincia`, `-`)
        txt = replace(txt, `Cambia tu fecha de nacimiento`, `-`)
        txt = replace(txt, `Cambia tu género`, `-`)
        txt = replace(txt, `Mujer`, `-`)
        txt = replace(txt, `Hombre`, `-`)
        txt = replace(txt, `Guardar`, `-`)
        txt = replace(txt, `Contraseña actual`, `-`)
        txt = replace(txt, `tu contraseña actual`, `-`)
        txt = replace(txt, `Nueva contraseña`, `-`)
        txt = replace(txt, `tu nueva contraseña`, `-`)
        txt = replace(txt, `Confimar Contraseña`, `-`)
        txt = replace(txt, `confirmar tu nueva contraseña`, `-`)
        txt = replace(txt, `Estos datos aparecen en tu perfil`, `-`)
        txt = replace(txt, `Añadir una nueva red`, `-`)
        txt = replace(txt, `No tienes ninguna red añadida.`, `-`)
      }
      break

    case 'src/partials/affinaties.html':
      if (lang === 'en') {
        txt = replace(txt, `Affines`, `-`)
        txt = replace(txt, `Aquí verás tu afinidad con usuarios a los que sigues`, `-`)
      }
      break

    case 'src/partials/are-you-sure.html':
      if (lang === 'en') {
        txt = replace(txt, `¿Seguro que quieres`, `-`)
        txt = replace(txt, `eliminar`, `-`)
        txt = replace(txt, `esta publicación`, `-`)
        txt = replace(txt, `Sí`, `-`)
        txt = replace(txt, `No`, `-`)
      }
      break

    case 'src/partials/categories.html':
      if (lang === 'en') {
        txt = replace(txt, `Categoría:`, `-`)
        txt = replace(txt, `ERROR:`, `-`)
      }
      break

    case 'src/partials/chat.html':
      if (lang === 'en') {
        txt = replace(txt, `Escribe tu comentario`, `-`)
        txt = replace(txt, `Envíar`, `-`)
      }
      break

    case 'src/partials/comment-list.html':
      if (lang === 'en') {
        txt = replace(txt, `Escribe tu comentario`, `-`)
        txt = replace(txt, `Envíar`, `-`)
      }
      break

    case 'src/partials/debate-create.html':
      if (lang === 'en') {
        txt = replace(txt, `Seleccione una categoría`, `-`)
        txt = replace(txt, `Escribe tu opinion`, `-`)
        txt = replace(txt, `Opinar`, `-`)
      }
      break

    case 'src/partials/debate-list.html':
      if (lang === 'en') {
        txt = replace(txt, `resultados`, `-`)
        txt = replace(txt, `no hay resultados`, `-`)
        txt = replace(txt, `Limpiar`, `-`)
      }
      break

    case 'src/partials/debate-sm.html':
      if (lang === 'en') {
        txt = replace(txt, `opiniones`, `-`)
        txt = replace(txt, `leer más`, `-`)
      }
      break

    case 'src/partials/debate-stats.html':
      if (lang === 'en') {
        txt = replace(txt, `Estadísticas`, `-`)
        txt = replace(txt, `Total opiniones`, `-`)
        txt = replace(txt, `Muy de acuerdo`, `-`)
        txt = replace(txt, `De acuerdo`, `-`)
        txt = replace(txt, `En desacuerdo`, `-`)
        txt = replace(txt, `Muy en desacuerdo`, `-`)
      }
      break

    case 'src/partials/debate-stats.html':
      if (lang === 'en') {
        txt = replace(txt, `Asistencia`, `-`)
        txt = replace(txt, `Blog`, `-`)
        txt = replace(txt, `Prensa`, `-`)
        txt = replace(txt, `Términos y condiciones`, `-`)
        txt = replace(txt, `Tecnología`, `-`)
        txt = replace(txt, `Privacidad`, `-`)
      }
      break

    case 'src/partials/foto-crop.html':
      if (lang === 'en') {
        txt = replace(txt, `Modificar`, `-`)
        txt = replace(txt, `Sí, quiero esta foto`, `-`)
      }
      // if (local === 'mx'){
      //   txt = replace(txt, `sí, quiero esta foto`, `sí guey, esta foto es chula`)
      // }
      break

    case 'src/partials/header.html':
      if (lang === 'en') {
        txt = replace(txt, `Opina`, `-`)
        txt = replace(txt, `Da tu opinión`, ``)
        txt = replace(txt, `Pide opinión`, ``)
        txt = replace(txt, `Perfil`, `-`)
        txt = replace(txt, `Ajustes`, `-`)
        txt = replace(txt, `Salir`, `-`)
        txt = replace(txt, `Buscar publicaciones`, `-`)
      }
      break

    case 'src/partials/mis-top.html':
      if (lang === 'en') {
        // txt = replace(txt, `Publicaciones`, `-`)
        // txt = replace(txt, `Opiniones`, `-`)
        // txt = replace(txt, `no hay nuevas opiniones.`, `-`)
        // txt = replace(txt, `tienes q esperar un poco`, `-`)
        // txt = replace(txt, `en`, `-`)
        // txt = replace(txt, `Ver mis top`, `-`)
      }
      break

    case 'src/partials/notification-list.html':
      if (lang === 'en') {
        txt = replace(txt, `ERROR:`, `-`)
        txt = replace(txt, `no tienes notificaciones`, `-`)
      }
      break

    case 'src/partials/opinion-list.html':
      if (lang === 'en') {
        txt = replace(txt, `Cargando...`, `-`)
      }
      break

    case 'src/partials/opinion-sm.html':
      if (lang === 'en') {
        txt = replace(txt, `De acuerdo`, `-`)
        txt = replace(txt, `Muy de acuerdo`, `-`)
        txt = replace(txt, `Muy en desacuerdo`, `-`)
        txt = replace(txt, `En desacuerdo`, `-`)
        txt = replace(txt, `Cancelar`, `-`)
      }
    break

    case 'src/partials/poll-create.html':
      if (lang === 'en') {
        txt = replace(txt, `Seleccione una categoría`, `-`)
        txt = replace(txt, `Escribe texto de tu encuesta...`, `-`)
        txt = replace(txt, `Escribe una opción`, `-`)
        txt = replace(txt, `Escribe más opciones`, `-`)
        txt = replace(txt, `Pide opinión`, `-`)
      }
    break

    case 'src/partials/poll-sm.html':
      if (lang === 'en') {
        txt = replace(txt, `votos`, `-`)
        txt = replace(txt, `sin votos`, `-`)
        txt = replace(txt, `leer más`, `-`)
        txt = replace(txt, `¿Qué opinas?`, `-`)
      }
      break

    case 'src/partials/poll-stats.html':
      if (lang === 'en') {
        txt = replace(txt, `Estadísticas`, `-`)
        txt = replace(txt, `Total opiniones`, `-`)
      }
      break

    case 'src/partials/pop-tag-list.html':
      if (lang === 'en') {
        txt = replace(txt, `Populares`, `-`)
        txt = replace(txt, `opiniones`, `-`)
        txt = replace(txt, `Ver más`, `-`)
      }
      break

    case 'src/partials/relation-list.html':
      if (lang === 'en') {
        txt = replace(txt, `no tiene relaciones`, `-`)
      }
      break

    case 'src/partials/relation-sm.html':
      if (lang === 'en') {
        txt = replace(txt, `No Seguir`, `-`)
        txt = replace(txt, `Seguir`, `-`)
      }
      break

    case 'src/partials/set-up.html':
      if (lang === 'en') {
        txt = replace(txt, `No Seguir`, `-`)
        txt = replace(txt, `Para que funcionen bien las estadisticas, necesitamos que rellenes los datos indicados antes de opinar.`, `-`)
        txt = replace(txt, `País`, `-`)
        txt = replace(txt, `Provincia`, `-`)
        txt = replace(txt, `Mujer`, `-`)
        txt = replace(txt, `Hombre`, `-`)
        txt = replace(txt, `Votar`, `-`)
        txt = replace(txt, `Vente y opina`, `-`)
        txt = replace(txt, `Sube tu foto de perfil`, `-`)
      }
    break

    case 'src/partials/sex-stats.html':
      if (lang === 'en') {
        txt = replace(txt, `Mujeres`, `-`)
        txt = replace(txt, `Hombres`, `-`)
      }
      break

    case 'src/partials/sign-in.html':
      if (lang === 'en') {
        txt = replace(txt, `Correo Electrónico`, `-`)
        txt = replace(txt, `Contraseña`, `-`)
        txt = replace(txt, `Recuérdame`, `-`)
        txt = replace(txt, `¿Olvidaste la contraseña?`, `-`)
        txt = replace(txt, `Entrar`, `-`)
        txt = replace(txt, `Entra con tu red social`, `-`)
        txt = replace(txt, `función aún no disponible`, `-`)
        txt = replace(txt, `¿No tienes cuenta?`, `-`)
        txt = replace(txt, `Regístrate`, `-`)
        txt = replace(txt, `Vente y opina!`, `-`)
      }
      break

    case 'src/partials/sign-up.html':
      if (lang === 'en') {
        txt = replace(txt, `Nombre de usuario`, `-`)
        txt = replace(txt, `Correo electrónico`, `-`)
        txt = replace(txt, `Contraseña`, `-`)
        txt = replace(txt, `Confirmar contraseña`, `-`)
        txt = replace(txt, `Vente y opina`, `-`)
        txt = replace(txt, `Al registrarte, aceptas las Condiciones del servicio y la Política de privacidad`, `-`)
      }
      break

    case 'src/partials/social-sm.html':
      if (lang === 'en') {
        txt = replace(txt, `Comentar`, `-`)
        txt = replace(txt, `Eliminar`, `-`)
      }
      break
}
  return txt
}


function replace (s,a,b) {
	var x = 0
	var x1 = s.indexOf(a, x)
	if (x1 < 0) return s
	var R = '', L = s.length, AL = a.length
	while (x < L) {
		var o = s.substr(x, x1-x)
		R += o
		R += b
		x = x1 + AL
		x1 = s.indexOf(a, x)
		if (x1 < 0) break
	}
	R += s.slice(x)
	return R
}
