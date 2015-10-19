'use strict'

import CropAreaCircle from './crop-area-circle'
import CropAreaSquare from './crop-area-square'
import EXIF from './crop-exif'

// Get Element's Offset
var getElementOffset = function (elem) {
  var box = elem.getBoundingClientRect()

  var body = document.body
  var docElem = document.documentElement

  var scrollTop = window.pageYOffset || docElem.scrollTop || body.scrollTop
  var scrollLeft = window.pageXOffset || docElem.scrollLeft || body.scrollLeft

  var clientTop = docElem.clientTop || body.clientTop || 0
  var clientLeft = docElem.clientLeft || body.clientLeft || 0

  var top = box.top + scrollTop - clientTop
  var left = box.left + scrollLeft - clientLeft

  return { top: Math.round(top), left: Math.round(left) }
}

function CropHost (elCanvas, opts, events) {
  /* PRIVATE VARIABLES */

  var cropEXIF = new EXIF

  // Object Pointers
  var ctx = null
  var image = null
  var theArea = null

  // Dimensions
  var minCanvasDims = [100, 100]
  var maxCanvasDims = [300, 300]

  // Result Image size
  var resImgSize = 200

  // Result Image type
  var resImgFormat = 'image/png'

  // Result Image quality
  var resImgQuality = null

  /* PRIVATE FUNCTIONS */

  // Draw Scene
  function drawScene () {
    // clear canvas
    ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height)

    if (image !== null) {
      // draw source image
      ctx.drawImage(image, 0, 0, ctx.canvas.width, ctx.canvas.height)

      ctx.save()

      // and make it darker
      ctx.fillStyle = 'rgba(0, 0, 0, 0.65)'
      ctx.fillRect(0, 0, ctx.canvas.width, ctx.canvas.height)

      ctx.restore()

      // draw Area
      theArea.draw()
    }
  }

  // Resets CropHost
  var resetCropHost = function () {
    if (image !== null) {
      theArea.setImage(image)
      var imageDims = [image.width, image.height],
        imageRatio = image.width / image.height,
        canvasDims = imageDims

      if (canvasDims[0] > maxCanvasDims[0]) {
        canvasDims[0] = maxCanvasDims[0]
        canvasDims[1] = canvasDims[0] / imageRatio
      } else if (canvasDims[0] < minCanvasDims[0]) {
        canvasDims[0] = minCanvasDims[0]
        canvasDims[1] = canvasDims[0] / imageRatio
      }
      if (canvasDims[1] > maxCanvasDims[1]) {
        canvasDims[1] = maxCanvasDims[1]
        canvasDims[0] = canvasDims[1] * imageRatio
      } else if (canvasDims[1] < minCanvasDims[1]) {
        canvasDims[1] = minCanvasDims[1]
        canvasDims[0] = canvasDims[1] * imageRatio
      }

      elCanvas.width = canvasDims[0]
      elCanvas.height = canvasDims[1]
      // elCanvas.style.marginLeft = -canvasDims[0] / 2 + 'px'
      // elCanvas.style.marginTop = -canvasDims[1] / 2 + 'px'

      theArea.setX(ctx.canvas.width / 2)
      theArea.setY(ctx.canvas.height / 2)
      theArea.setSize(Math.min(200, ctx.canvas.width / 2, ctx.canvas.height / 2))
    } else {
      elCanvas.width = 0
      elCanvas.height = 0
      elCanvas.style.marginTop = 0
    }

    drawScene()
  }

  // Returns event.changedTouches directly if event is a TouchEvent.
  // If event is a jQuery event, return changedTouches of event.originalEvent

  var getChangedTouches = function (event) {
    if (event.changedTouches != null) {
      return event.changedTouches
    } else {
      return event.originalEvent.changedTouches
    }
  }

  var onMouseMove = function (e) {
    if (image !== null) {
      var offset = getElementOffset(ctx.canvas),
        pageX, pageY
      if (e.type === 'touchmove') {
        pageX = getChangedTouches(e)[0].pageX
        pageY = getChangedTouches(e)[0].pageY
      } else {
        pageX = e.pageX
        pageY = e.pageY
      }
      theArea.processMouseMove(pageX - offset.left, pageY - offset.top)
      drawScene()
    }
  }

  var onMouseDown = function (e) {
    e.preventDefault()
    e.stopPropagation()
    if (image !== null) {
      var offset = getElementOffset(ctx.canvas),
        pageX, pageY
      if (e.type === 'touchstart') {
        pageX = getChangedTouches(e)[0].pageX
        pageY = getChangedTouches(e)[0].pageY
      } else {
        pageX = e.pageX
        pageY = e.pageY
      }
      theArea.processMouseDown(pageX - offset.left, pageY - offset.top)
      drawScene()
    }
  }

  var onMouseUp = function (e) {
    if (image !== null) {
      var offset = getElementOffset(ctx.canvas),
        pageX, pageY
      if (e.type === 'touchend') {
        pageX = getChangedTouches(e)[0].pageX
        pageY = getChangedTouches(e)[0].pageY
      } else {
        pageX = e.pageX
        pageY = e.pageY
      }
      theArea.processMouseUp(pageX - offset.left, pageY - offset.top)
      drawScene()
    }
  }

  this.getResultImageDataURI = function () {
    var temp_ctx, temp_canvas
    temp_canvas = document.createElement('canvas')
    temp_ctx = temp_canvas.getContext('2d')
    temp_canvas.width = resImgSize
    temp_canvas.height = resImgSize
    if (image !== null) {
      temp_ctx.drawImage(image, (theArea.getX() - theArea.getSize() / 2) * (image.width / ctx.canvas.width), (theArea.getY() - theArea.getSize() / 2) * (image.height / ctx.canvas.height), theArea.getSize() * (image.width / ctx.canvas.width), theArea.getSize() * (image.height / ctx.canvas.height), 0, 0, resImgSize, resImgSize)
    }
    if (resImgQuality !== null) {
      return temp_canvas.toDataURL(resImgFormat, resImgQuality)
    }
    return temp_canvas.toDataURL(resImgFormat)
  }

  this.setNewImageSource = function (imageSource) {
    image = null
    resetCropHost()
    events.emit('image-updated')
    if (!!imageSource) {
      var newImage = new Image()
      if (imageSource.substring(0, 4).toLowerCase() === 'http') {
        newImage.crossOrigin = 'anonymous'
      }
      newImage.onload = function () {
        events.emit('load-done')

        cropEXIF.getData(newImage, function () {
          var orientation = cropEXIF.getTag(newImage, 'Orientation')

          if ([3, 6, 8].indexOf(orientation) > -1) {
            var canvas = document.createElement('canvas'),
              ctx = canvas.getContext('2d'),
              cw = newImage.width, ch = newImage.height, cx = 0, cy = 0, deg = 0
            switch (orientation) {
              case 3:
                cx = -newImage.width
                cy = -newImage.height
                deg = 180
                break
              case 6:
                cw = newImage.height
                ch = newImage.width
                cy = -newImage.height
                deg = 90
                break
              case 8:
                cw = newImage.height
                ch = newImage.width
                cx = -newImage.width
                deg = 270
                break
            }

            canvas.width = cw
            canvas.height = ch
            ctx.rotate(deg * Math.PI / 180)
            ctx.drawImage(newImage, cx, cy)

            image = new Image()
            image.src = canvas.toDataURL('image/png')
          } else {
            image = newImage
          }
          resetCropHost()
          events.emit('image-updated')
        })
      }
      newImage.onerror = function () {
        events.emit('load-error')
      }
      events.emit('load-start')
      newImage.src = imageSource
    }
  }

  this.setMaxDimensions = function (width, height) {
    maxCanvasDims = [width, height]

    if (image !== null) {
      var curWidth = ctx.canvas.width,
        curHeight = ctx.canvas.height

      var imageDims = [image.width, image.height],
        imageRatio = image.width / image.height,
        canvasDims = imageDims

      if (canvasDims[0] > maxCanvasDims[0]) {
        canvasDims[0] = maxCanvasDims[0]
        canvasDims[1] = canvasDims[0] / imageRatio
      } else if (canvasDims[0] < minCanvasDims[0]) {
        canvasDims[0] = minCanvasDims[0]
        canvasDims[1] = canvasDims[0] / imageRatio
      }
      if (canvasDims[1] > maxCanvasDims[1]) {
        canvasDims[1] = maxCanvasDims[1]
        canvasDims[0] = canvasDims[1] * imageRatio
      } else if (canvasDims[1] < minCanvasDims[1]) {
        canvasDims[1] = minCanvasDims[1]
        canvasDims[0] = canvasDims[1] * imageRatio
      }
      elCanvas.prop('width', canvasDims[0]).prop('height', canvasDims[1]).css({'margin-left': -canvasDims[0] / 2 + 'px', 'margin-top': -canvasDims[1] / 2 + 'px'})

      var ratioNewCurWidth = ctx.canvas.width / curWidth,
        ratioNewCurHeight = ctx.canvas.height / curHeight,
        ratioMin = Math.min(ratioNewCurWidth, ratioNewCurHeight)

      theArea.setX(theArea.getX() * ratioNewCurWidth)
      theArea.setY(theArea.getY() * ratioNewCurHeight)
      theArea.setSize(theArea.getSize() * ratioMin)
    } else {
      elCanvas.prop('width', 0).prop('height', 0).css({'margin-top': 0})
    }

    drawScene()

  }

  this.setAreaMinSize = function (size) {
    size = parseInt(size, 10)
    if (!isNaN(size)) {
      theArea.setMinSize(size)
      drawScene()
    }
  }

  this.setResultImageSize = function (size) {
    size = parseInt(size, 10)
    if (!isNaN(size)) {
      resImgSize = size
    }
  }

  this.setResultImageFormat = function (format) {
    resImgFormat = format
  }

  this.setResultImageQuality = function (quality) {
    quality = parseFloat(quality)
    if (!isNaN(quality) && quality >= 0 && quality <= 1) {
      resImgQuality = quality
    }
  }

  this.getRect = function () {
    return {
      size: theArea.getSize(),
      x: theArea.getX(),
      y: theArea.getY(),
      w: ctx.canvas.width,
      h: ctx.canvas.height
    }
  }

  this.setAreaType = function (type) {
    var curSize = theArea.getSize(),
      curMinSize = theArea.getMinSize(),
      curX = theArea.getX(),
      curY = theArea.getY()

    var AreaClass = CropAreaCircle
    if (type === 'square') {
      AreaClass = CropAreaSquare
    }
    theArea = new AreaClass(ctx, events)
    theArea.setMinSize(curMinSize)
    theArea.setSize(curSize)
    theArea.setX(curX)
    theArea.setY(curY)

    // resetCropHost()
    if (image !== null) {
      theArea.setImage(image)
    }

    drawScene()
  }

  /* Life Cycle begins */

  // Init Context var
  ctx = elCanvas.getContext('2d')

  // Init CropArea
  theArea = new CropAreaCircle(ctx, events)

  // Init Mouse Event Listeners
  document.addEventListener('mouseup', onMouseUp)
  document.addEventListener('mousemove', onMouseMove)
  elCanvas.addEventListener('mousedown', onMouseDown)

  // Init Touch Event Listeners
  document.addEventListener('touchend', onMouseUp)
  document.addEventListener('touchmove', onMouseMove)
  elCanvas.addEventListener('touchstart', onMouseDown)

  // CropHost Destructor
  this.destroy = function () {
    document.removeEventListener('mouseup', onMouseMove)
    document.removeEventListener('mousemove', onMouseMove)
    elCanvas.removeEventListener('mousedown', onMouseDown)

    document.removeEventListener('touchend', onMouseMove)
    document.removeEventListener('touchmove', onMouseMove)
    elCanvas.removeEventListener('touchstart', onMouseDown)

    elCanvas.parentNode.removeChild(elCanvas)
  }
}

export default CropHost
