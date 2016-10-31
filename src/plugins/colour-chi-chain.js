typeof Color == "undefined" && (Color = {});
if (typeof Color.Blind == "undefined") Color.Blind = {};
(function () {
  var f = {
    protan: {
      x: 0.7465,
      y: 0.2535,
      m: 1.273463,
      yi: -0.073894
    },
    deutan: {
      x: 1.4,
      y: -0.4,
      m: 0.968437,
      yi: 0.003331
    },
    tritan: {
      x: 0.1748,
      y: 0,
      m: 0.062921,
      yi: 0.292119
    },
    custom: {
      x: 0.735,
      y: 0.265,
      m: -1.059259,
      yi: 1.026914
    }
  };
  Color.Blind = function (i, b, j) {
    if (b === "achroma") {
      b = i.R * 0.212656 + i.G * 0.715158 + i.B * 0.072186;
      b = {
        R: b,
        G: b,
        B: b
      };
      if (j) {
        var j = 1.75,
          c = j + 1;
        b.R = (j * b.R + i.R) / c;
        b.G = (j * b.G + i.G) / c;
        b.B = (j * b.B + i.B) / c
      }
      return b
    }
    var b = f[b],
      c = Color.Space.XYZ_xyY(Color.Space.RGB_XYZ(i)),
      d = (c.y - b.y) / (c.x - b.x),
      k = c.y - c.x * d;
    dx = (b.yi - k) /
      (d - b.m);
    dy = d * dx + k;
    dY = 0;
    b = {};
    b.X = dx * c.Y / dy;
    b.Y = c.Y;
    b.Z = (1 - (dx + dy)) * c.Y / dy;
    d = 0.358271 * c.Y / 0.329016;
    dX = 0.312713 * c.Y / 0.329016 - b.X;
    dZ = d - b.Z;
    c = Color.Space.XYZ_RGB_Matrix;
    dR = dX * c[0] + dY * c[3] + dZ * c[6];
    dG = dX * c[1] + dY * c[4] + dZ * c[7];
    dB = dX * c[2] + dY * c[5] + dZ * c[8];
    b.R = b.X * c[0] + b.Y * c[3] + b.Z * c[6];
    b.G = b.X * c[1] + b.Y * c[4] + b.Z * c[7];
    b.B = b.X * c[2] + b.Y * c[5] + b.Z * c[8];
    d = ((b.R < 0 ? 0 : 1) - b.R) / dR;
    k = ((b.G < 0 ? 0 : 1) - b.G) / dG;
    c = ((b.B < 0 ? 0 : 1) - b.B) / dB;
    d = d > 1 || d < 0 ? 0 : d;
    k = k > 1 || k < 0 ? 0 : k;
    c = c > 1 || c < 0 ? 0 : c;
    d = d > k ? d : k;
    c > d && (d = c);
    b.R += d * dR;
    b.G += d * dG;
    b.B += d * dB;
    b.R = 255 * (b.R <= 0 ? 0 : b.R >= 1 ? 1 : Math.pow(b.R, 1 / Color.Space.Gamma));
    b.G = 255 * (b.G <= 0 ? 0 : b.G >= 1 ? 1 : Math.pow(b.G, 1 / Color.Space.Gamma));
    b.B = 255 * (b.B <= 0 ? 0 : b.B >= 1 ? 1 : Math.pow(b.B, 1 / Color.Space.Gamma));
    if (j) j = 1.75, c = j + 1, b.R = (j * b.R + i.R) / c, b.G = (j * b.G + i.G) / c, b.B = (j * b.B + i.B) / c;
    return b
  }
})();
typeof Color == "undefined" && (Color = {});
if (typeof Color.Harmony == "undefined") Color.Harmony = {};
Color.Harmony.data = {
  Neutral: [0, 15, 30, 45, 60, 75],
  Analogous: [0, 30, 60, 90, 120, 150],
  Clash: [0, 90, 270],
  Complementary: [0, 180],
  "Split-Complementary": [0, 150, 210],
  Triadic: [0, 120, 240],
  Tetradic: [0, 90, 180, 270],
  "Four-Tone": [0, 60, 180, 240],
  "Five-Tone": [0, 115, 155, 205, 245],
  "Six-Tone": [0, 30, 120, 150, 240, 270]
};
Color.Harmony.scheme = function (f, i) {
  var b = [],
    j = 0,
    c;
  for (c in i) b[j++] = {
    H: (f.H + i[c]) % 360,
    S: f.S,
    L: f.L
  };
  return b
};
Color.Harmony.rotate = function (f, i) {
  i = (f.H + i) % 360;
  return {
    H: i > 0 ? i : i + 360,
    S: f.S,
    L: f.L
  }
};
typeof Color == "undefined" && (Color = {});
if (typeof Color.Space == "undefined") Color.Space = {};
(function () {
  var f = Math.PI / 180,
    i = 1 / f,
    b = {},
    j = {
      "RGB>STRING": "RGB>HEX>STRING",
      "STRING>RGB": "STRING>HEX>RGB"
    },
    c = Color.Space = function (a, e) {
      j[e] && (e = j[e]);
      if (b[e]) return b[e](a);
      var n = e.split(">");
      if (typeof a == "object" && a[0] >= 0) {
        for (var h = g.split("_")[0], o = {}, g = 0; g < h.length; g++) {
          var d = h.substr(g, 1);
          o[d] = a[g]
        }
        a = o
      }
      for (var h = "color", o = 1, g = n[0]; o < n.length; o++) {
        o > 1 && (g = g.substr(g.indexOf("_") + 1)),
        g += (o == 0 ? "" : "_") + n[o],
        a = c[g](a), h = "Color.Space." + g + "(" + h + ")";
      }
      var fn = new Function("color", "return " + h);
      // b[e] = eval("(function (color) { console.log('inside', color); return " + h + " })");
      b[e] = fn;
      return a
    };
  c.RGB_W3RGBA = c.RGBA_W3RGBA = function (a) {
    return "rgba(" + (a.R >> 0) + "," + (a.G >> 0) + "," + (a.B >> 0) + "," + (typeof a.A == "number" ? a.A : 1) + ")"
  };
  c.RYB_Hue = function (a) {
    var e = a >> 0,
      n = d[e % 360],
      c = d[(a + 1 >> 0) % 360];
    c < n && (c = 360);
    return n + (c - n) * (e > 0 ? a % e : 0)
  };
  c.Hue_RYB = function (a) {
    var e = a >> 0,
      n = k[e % 360],
      c = k[(a + 1 >> 0) % 360];
    c < n && (c = 360);
    return n + (c - n) * (e > 0 ? a % e : 0)
  };
  c.STRING_HEX = function (a) {
    return parseInt("0x" + a)
  };
  c.STRING_HEX32 = function (a) {
    return a.length === 6 ? parseInt("0xFF" + a) : parseInt("0x" + a)
  };
  c.HEX_STRING = function (a, e) {
    e || (e = 6);
    a || (a = 0);
    for (var c = a.toString(16), h = c.length; h < e;) c = "0" + c, h++;
    for (h = c.length; h > e;) c = c.substr(1), h--;
    return c
  };
  c.HEX32_STRING = function (a) {
    return c.HEX_STRING(a, 8)
  };
  c.HEX_RGB = function (a) {
    return {
      R: a >> 16,
      G: a >> 8 & 255,
      B: a & 255
    }
  };
  c.HEX32_RGBA = function (a) {
    return {
      R: a >>> 16 & 255,
      G: a >>> 8 & 255,
      B: a & 255,
      A: a >>> 24
    }
  };
  c.RGBA_HEX32 = function (a) {
    return (a.A << 24 | a.R << 16 | a.G << 8 | a.B) >>> 0
  };
  c.RGB_HEX = function (a) {
    if (a.R < 0) a.R = 0;
    if (a.G < 0) a.G = 0;
    if (a.B < 0) a.B = 0;
    if (a.R > 255) a.R = 255;
    if (a.G > 255) a.G = 255;
    if (a.B > 255) a.B = 255;
    return a.R << 16 |
      a.G << 8 | a.B
  };
  c.RGB_CMY = function (a) {
    return {
      C: 1 - a.R / 255,
      M: 1 - a.G / 255,
      Y: 1 - a.B / 255
    }
  };
  c.RGB_HSL = function (a) {
    var e = a.R / 255,
      c = a.G / 255,
      a = a.B / 255,
      h = Math.min(e, c, a),
      b = Math.max(e, c, a),
      g = b - h,
      d, l = (b + h) / 2;
    if (g == 0) h = d = 0;
    else {
      var h = l < 0.5 ? g / (b + h) : g / (2 - b - h),
        f = ((b - e) / 6 + g / 2) / g,
        m = ((b - c) / 6 + g / 2) / g,
        g = ((b - a) / 6 + g / 2) / g;
      e == b ? d = g - m : c == b ? d = 1 / 3 + f - g : a == b && (d = 2 / 3 + m - f);
      d < 0 && (d += 1);
      d > 1 && (d -= 1)
    }
    return {
      H: d * 360,
      S: h * 100,
      L: l * 100
    }
  };
  c.RGB_HSV = function (a) {
    var e = a.R / 255,
      c = a.G / 255,
      a = a.B / 255,
      h = Math.min(e, c, a),
      b = Math.max(e, c, a),
      g = b - h,
      d;
    if (g == 0) h =
      d = 0;
    else {
      var h = g / b,
        l = ((b - e) / 6 + g / 2) / g,
        f = ((b - c) / 6 + g / 2) / g,
        g = ((b - a) / 6 + g / 2) / g;
      e == b ? d = g - f : c == b ? d = 1 / 3 + l - g : a == b && (d = 2 / 3 + f - l);
      d < 0 && (d += 1);
      d > 1 && (d -= 1)
    }
    return {
      H: d * 360,
      S: h * 100,
      V: b * 100
    }
  };
  c.RGB_XYZ = function (a) {
    c.RGB_XYZ_Matrix || c.getProfile("sRGB");
    var e = c.RGB_XYZ_Matrix,
      b = {},
      h = a.R / 255,
      d = a.G / 255,
      a = a.B / 255;
    c.Profile == "sRGB" ? (h = h > 0.04045 ? Math.pow((h + 0.055) / 1.055, 2.4) : h / 12.92, d = d > 0.04045 ? Math.pow((d + 0.055) / 1.055, 2.4) : d / 12.92, a = a > 0.04045 ? Math.pow((a + 0.055) / 1.055, 2.4) : a / 12.92) : (h = Math.pow(h, c.Gamma), d = Math.pow(d, c.Gamma),
    a = Math.pow(a, c.Gamma));
    b.X = h * e[0] + d * e[3] + a * e[6];
    b.Y = h * e[1] + d * e[4] + a * e[7];
    b.Z = h * e[2] + d * e[5] + a * e[8];
    return b
  };
  c.CMY_RGB = function (a) {
    var e = (1 - a.C) * 255,
      c = (1 - a.M) * 255,
      a = (1 - a.Y) * 255;
    return ({
          R: e < 0 ? 0 : e,
          G: c < 0 ? 0 : c,
          B: a < 0 ? 0 : a
        })
  };
  c.CMY_CMYK = function (a) {
    var e = a.C,
      c = a.M,
      a = a.Y,
      b = Math.min(a, c, e, 1),
      e = (e - b) / (1 - b) * 100 + 0.5 >> 0,
      c = (c - b) / (1 - b) * 100 + 0.5 >> 0,
      a = (a - b) / (1 - b) * 100 + 0.5 >> 0;
    return {
      C: e,
      M: c,
      Y: a,
      K: b * 100 + 0.5 >> 0
    }
  };
  c.CMYK_CMY = function (a) {
    return {
      C: a.C * (1 - a.K) + a.K,
      M: a.M * (1 - a.K) + a.K,
      Y: a.Y * (1 - a.K) + a.K
    }
  };
  c.HSL_RGB = function (a) {
    var e =
      a.H / 360,
      c = a.S / 100,
      a = a.L / 100,
      b, d, g;
    c == 0 ? c = a = e = a : (d = a < 0.5 ? a * (1 + c) : a + c - c * a, b = 2 * a - d, g = e + 1 / 3, g < 0 && (g += 1), g > 1 && (g -= 1), c = 6 * g < 1 ? b + (d - b) * 6 * g : 2 * g < 1 ? d : 3 * g < 2 ? b + (d - b) * (2 / 3 - g) * 6 : b, g = e, g < 0 && (g += 1), g > 1 && (g -= 1), a = 6 * g < 1 ? b + (d - b) * 6 * g : 2 * g < 1 ? d : 3 * g < 2 ? b + (d - b) * (2 / 3 - g) * 6 : b, g = e - 1 / 3, g < 0 && (g += 1), g > 1 && (g -= 1), e = 6 * g < 1 ? b + (d - b) * 6 * g : 2 * g < 1 ? d : 3 * g < 2 ? b + (d - b) * (2 / 3 - g) * 6 : b);
    return ({
          R: c * 255,
          G: a * 255,
          B: e * 255
        })
  };
  c.HSV_RGB = function (a) {
    var e = a.H / 360,
      c = a.S / 100,
      a = a.V / 100,
      b, d, g;
    if (c == 0) b = d = g = a * 255 + 0.5 >> 0;
    else switch (e >= 1 && (e = 0), e *= 6, D = e - e >> 0, A = 255 *
      a * (1 - c) + 0.5 >> 0, g = 255 * a * (1 - c * D) + 0.5 >> 0, C = 255 * a * (1 - c * (1 - D)) + 0.5 >> 0, a = 255 * a + 0.5 >> 0, e >> 0) {
      case 0:
        b = a;
        d = C;
        g = A;
        break;
      case 1:
        b = g;
        d = a;
        g = A;
        break;
      case 2:
        b = A;
        d = a;
        g = C;
        break;
      case 3:
        b = A;
        d = g;
        g = a;
        break;
      case 4:
        b = C;
        d = A;
        g = a;
        break;
      case 5:
        b = a, d = A
    }
    return {
      R: b,
      G: d,
      B: g
    }
  };
  c.XYZ_RGB = function (a) {
    c.XYZ_RGB_Matrix || c.getProfile("sRGB");
    var e = c.XYZ_RGB_Matrix,
      b, d;
    b = a.X * e[0] + a.Y * e[3] + a.Z * e[6];
    d = a.X * e[1] + a.Y * e[4] + a.Z * e[7];
    a = a.X * e[2] + a.Y * e[5] + a.Z * e[8];
    c.Profile == "sRGB" ? (b = b > 0.0031308 ? 1.055 * Math.pow(b, 1 / 2.4) - 0.055 : 12.92 * b, d = d > 0.0031308 ?
      1.055 * Math.pow(d, 1 / 2.4) - 0.055 : (12.92 * d, a = a > 0.0031308) ? 1.055 * Math.pow(a, 1 / 2.4) - 0.055 : 12.92 * a) : (b = Math.pow(b, 1 / c.Gamma), d = Math.pow(d, 1 / c.Gamma), a = Math.pow(a, 1 / c.Gamma));
    return {
      R: b * 255 + 0.5 >> 0,
      G: d * 255 + 0.5 >> 0,
      B: a * 255 + 0.5 >> 0
    }
  };
  c.XYZ_xyY = function (a) {
    var e = a.X + a.Y + a.Z;
    return e == 0 ? ({
          x: 0,
          y: 0,
          Y: a.Y
        }) : ({
          x: a.X / e,
          y: a.Y / e,
          Y: a.Y
        })
  };
  c.XYZ_HLab = function (a) {
    var e = Math.sqrt(a.Y);
    return {
      L: 10 * e,
      a: 17.5 * ((1.02 * a.X - a.Y) / e),
      b: 7 * ((a.Y - 0.847 * a.Z) / e)
    }
  };
  c.XYZ_Lab = function (a) {
    var e = a.X / c.WPScreen.X,
      b = a.Y / c.WPScreen.Y,
      a = a.Z / c.WPScreen.Z,
      e = e > 0.008856 ? Math.pow(e, 1 / 3) : 7.787 * e + 16 / 116,
      b = b > 0.008856 ? Math.pow(b, 1 / 3) : 7.787 * b + 16 / 116,
      a = a > 0.008856 ? Math.pow(a, 1 / 3) : 7.787 * a + 16 / 116;
    return {
      L: 116 * b - 16,
      a: 500 * (e - b),
      b: 200 * (b - a)
    }
  };
  c.XYZ_Luv = function (a) {
    var e = c.WPScreen,
      b = 4 * a.X / (a.X + 15 * a.Y + 3 * a.Z),
      d = 9 * a.Y / (a.X + 15 * a.Y + 3 * a.Z);
    a.Y = a.Y > 0.008856 ? Math.pow(a.Y, 1 / 3) : 7.787 * a.Y + 16 / 116;
    a = 116 * a.Y - 16;
    return {
      L: a,
      u: 13 * a * (b - 4 * e.X / (e.X + 15 * e.Y + 3 * e.Z)) || 0,
      v: 13 * a * (d - 9 * e.Y / (e.X + 15 * e.Y + 3 * e.Z)) || 0
    }
  };
  c.xyY_XYZ = function (a) {
    return {
      X: a.x * a.Y / a.y,
      Y: a.Y,
      Z: (1 - a.x - a.y) * a.Y / a.y
    }
  };
  c.HLab_XYZ =
    function (a) {
      var e = a.L / 10;
      e *= e;
      return {
        X: (a.a / 17.5 * (a.L / 10) + e) / 1.02,
        Y: e,
        Z: -(a.b / 7 * (a.L / 10) - e) / 0.847
      }
    };
  c.Lab_XYZ = function (a) {
    var e = c.WPScreen,
      b = (a.L + 16) / 116,
      d = b * b * b,
      l = a.a / 500 + b,
      g = l * l * l,
      a = b - a.b / 200,
      f = a * a * a;
    return {
      X: e.X * (g > 0.008856 ? g : (l - 16 / 116) / 7.787),
      Y: e.Y * (d > 0.008856 ? d : (b - 16 / 116) / 7.787),
      Z: e.Z * (f > 0.008856 ? f : (a - 16 / 116) / 7.787)
    }
  };
  c.Lab_LCHab = function (a) {
    var e = Math.atan2(a.b, a.a) * i;
    e < 0 ? e += 360 : e > 360 && (e -= 360);
    return {
      L: a.L,
      C: Math.sqrt(a.a * a.a + a.b * a.b),
      H: e
    }
  };
  c.Luv_XYZ = function (a) {
    var e = c.WPScreen,
      b = (a.L + 16) /
      116,
      d = b * b * b,
      b = d > 0.008856 ? d : (b - 16 / 116) / 7.787,
      d = a.u / (13 * a.L) + 4 * e.X / (e.X + 15 * e.Y + 3 * e.Z),
      a = a.v / (13 * a.L) + 9 * e.Y / (e.X + 15 * e.Y + 3 * e.Z),
      e = -(9 * b * d) / ((d - 4) * a - d * a);
    return {
      X: e,
      Y: b,
      Z: (9 * b - 15 * a * b - a * e) / (3 * a)
    }
  };
  c.Luv_LCHuv = function (a) {
    var e = Math.atan2(a.v, a.u) * i;
    e < 0 ? e += 360 : e > 360 && (e -= 360);
    return {
      L: a.L,
      C: Math.sqrt(a.u * a.u + a.v * a.v),
      H: e
    }
  };
  c.LCHab_Lab = function (a) {
    var e = a.H * f;
    return {
      L: a.L,
      a: Math.cos(e) * a.C,
      b: Math.sin(e) * a.C
    }
  };
  c.LCHuv_Luv = function (a) {
    var e = a.H * f;
    return {
      L: a.L,
      u: Math.cos(e) * a.C,
      v: Math.sin(e) * a.C
    }
  };
  c.RGB_HSI =
    function (a) {
      var e = a.R,
        b = a.G,
        a = a.B,
        c = 0.5 * (2 * e - b - a),
        d = Math.sqrt(3) * (b - a);
      I = (e + b + a) / 3;
      (I > 0) ? (S = 1 - Math.min(e, b, a) / I, H = Math.atan2(d, c) * i, H < 0 && (H += 360)) : H = S = 0;
      return {
        H: H,
        S: S * 100,
        I: I
      }
    };
  c.HSI_RGB = function (a) {
    var b = a.H,
      c = a.S / 100,
      a = a.I,
      d, l, g;
    b -= 360 * (b / 360 >> 0);
    b < 120 ? (g = a * (1 - c), d = a * (1 + c * Math.cos(b * f) / Math.cos((60 - b) * f)), l = 3 * a - d - g) : b < 240 ? (b -= 120, d = a * (1 - c), l = a * (1 + c * Math.cos(b * f) / Math.cos((60 - b) * f)), g = 3 * a - d - l) : (b -= 240, l = a * (1 - c), g = a * (1 + c * Math.cos(b * f) / Math.cos((60 - b) * f)), d = 3 * a - l - g);
    return {
      R: d,
      G: l,
      B: g
    }
  };
  c.getAdaption =
    function (a, b) {
      var d = {
          "XYZ scaling": {
            A: [
              [1, 0, 0],
              [0, 1, 0],
              [0, 0, 1]
            ],
            Z: [
              [1, 0, 0],
              [0, 1, 0],
              [0, 0, 1]
            ]
          },
          "Von Kries": {
            A: [
              [0.40024, -0.2263, 0],
              [0.7076, 1.16532, 0],
              [-0.08081, 0.0457, 0.91822]
            ],
            Z: [
              [1.859936, 0.361191, 0],
              [-1.129382, 0.638812, 0],
              [0.219897, -6.0E-6, 1.089064]
            ]
          },
          Bradford: {
            A: [
              [0.8951, 0.2664, -0.161399],
              [-0.750199, 1.7135, 0.0367],
              [0.038899, -0.0685, 1.0296]
            ],
            Z: [
              [0.986993, -0.14705399, 0.15996299],
              [0.43230499, 0.51836, 0.0492912],
              [-0.00852866, 0.0400428, 0.96848699]
            ]
          }
        },
        l = c.WPSource,
        f = c.WPScreen,
        g = d[b].A,
        d = d[b].Z,
        f = p(g, [
          [f.X],
          [f.Y],
          [f.Z]
        ]),
        l = p(g, [
          [l.X],
          [l.Y],
          [l.Z]
        ]),
        g = p(d, p([
          [f[0] / l[0], 0, 0],
          [0, f[1] / l[1], 0],
          [0, 0, f[2] / l[2]]
        ], p(g, [
          [a.X],
          [a.Y],
          [a.Z]
        ])));
      return {
        X: g[0][0],
        Y: g[1][0],
        Z: g[2][0]
      }
    };
  c.getProfile = function (a) {
    function b(a) {
      return c.getAdaption(c.xyY_XYZ(a), "Bradford")
    }
    var d = q[a];
    c.Profile = a;
    c.ICCProfile = d;
    c.Gamma = d[0];
    c.WPSource = c.getIlluminant("2", d[1]);
    var a = b({
        x: d[2],
        y: d[3],
        Y: d[4]
      }),
      l = b({
        x: d[5],
        y: d[6],
        Y: d[7]
      }),
      d = b({
        x: d[8],
        y: d[9],
        Y: d[10]
      });
    c.RGB_XYZ_Matrix = [a.X, a.Y, a.Z, l.X, l.Y, l.Z, d.X, d.Y, d.Z];
    c.XYZ_RGB_Matrix =
      m(c.RGB_XYZ_Matrix)
  };
  c.getIlluminant = function (a, b) {
    var d = l[b],
      d = a == "2" ? ({
              x: d[0],
              y: d[1],
              Y: 1
            }) : ({
              x: d[2],
              y: d[3],
              Y: 1
            });
    return c.xyY_XYZ(d)
  };
  var d = [],
    k = [];
  (function () {
    for (var a = [
        [0, 0],
        [15, 8],
        [30, 17],
        [45, 26],
        [60, 34],
        [75, 41],
        [90, 48],
        [105, 54],
        [120, 60],
        [135, 81],
        [150, 103],
        [165, 123],
        [180, 138],
        [195, 155],
        [210, 171],
        [225, 187],
        [240, 204],
        [255, 219],
        [270, 234],
        [285, 251],
        [300, 267],
        [315, 282],
        [330, 298],
        [345, 329],
        [360, 0]
      ], b = 0; b < 360; b++)
      for (var c = !1, l = !1, f = 0; f < 24; f++) {
        var g = a[f],
          m = a[f + 1];
        m && m[1] < g[1] && (m[1] += 360);
        !c && g[0] <= b &&
          m[0] > b && (k[b] = (g[1] + (m[1] - g[1]) * (b - g[0]) / (m[0] - g[0])) % 360, c = !0);
        !l && g[1] <= b && m[1] > b && (d[b] = (g[0] + (m[0] - g[0]) * (b - g[1]) / (m[1] - g[1])) % 360, l = !0);
        if (c == !0 && l == !0) break
      }
  })();
  var q = {
      "Adobe (1998)": [2.2, "D65", 0.64, 0.33, 0.297361, 0.21, 0.71, 0.627355, 0.15, 0.06, 0.075285],
      "Apple RGB": [1.8, "D65", 0.625, 0.34, 0.244634, 0.28, 0.595, 0.672034, 0.155, 0.07, 0.083332],
      BestRGB: [2.2, "D50", 0.7347, 0.2653, 0.228457, 0.215, 0.775, 0.737352, 0.13, 0.035, 0.034191],
      "Beta RGB": [2.2, "D50", 0.6888, 0.3112, 0.303273, 0.1986, 0.7551, 0.663786, 0.1265,
        0.0352, 0.032941
      ],
      "Bruce RGB": [2.2, "D65", 0.64, 0.33, 0.240995, 0.28, 0.65, 0.683554, 0.15, 0.06, 0.075452],
      "CIE RGB": [2.2, "E", 0.735, 0.265, 0.176204, 0.274, 0.717, 0.812985, 0.167, 0.0090, 0.010811],
      ColorMatch: [1.8, "D50", 0.63, 0.34, 0.274884, 0.295, 0.605, 0.658132, 0.15, 0.075, 0.066985],
      DonRGB4: [2.2, "D50", 0.696, 0.3, 0.27835, 0.215, 0.765, 0.68797, 0.13, 0.035, 0.03368],
      eciRGB: [1.8, "D50", 0.67, 0.33, 0.32025, 0.21, 0.71, 0.602071, 0.14, 0.08, 0.077679],
      "Ekta Space PS5": [2.2, "D50", 0.695, 0.305, 0.260629, 0.26, 0.7, 0.734946, 0.11, 0.0050, 0.004425],
      "Generic RGB": [1.8, "D65", 0.6295, 0.3407, 0.232546, 0.2949, 0.6055, 0.672501, 0.1551, 0.0762, 0.094952],
      "HDTV (HD-CIF)": [1.95, "D65", 0.64, 0.33, 0.212673, 0.3, 0.6, 0.715152, 0.15, 0.06, 0.072175],
      NTSC: [2.2, "C", 0.67, 0.33, 0.298839, 0.21, 0.71, 0.586811, 0.14, 0.08, 0.11435],
      "PAL / SECAM": [2.2, "D65", 0.64, 0.33, 0.222021, 0.29, 0.6, 0.706645, 0.15, 0.06, 0.071334],
      ProPhoto: [1.8, "D50", 0.7347, 0.2653, 0.28804, 0.1596, 0.8404, 0.711874, 0.0366, 1.0E-4, 8.6E-5],
      SGI: [1.47, "D65", 0.625, 0.34, 0.244651, 0.28, 0.595, 0.67203, 0.155, 0.07, 0.083319],
      "SMPTE-240M": [1.92,
        "D65", 0.63, 0.34, 0.212413, 0.31, 0.595, 0.701044, 0.155, 0.07, 0.086543
      ],
      "SMPTE-C": [2.2, "D65", 0.63, 0.34, 0.212395, 0.31, 0.595, 0.701049, 0.155, 0.07, 0.086556],
      sRGB: [2.2, "D65", 0.64, 0.33, 0.212656, 0.3, 0.6, 0.715158, 0.15, 0.06, 0.072186],
      "Wide Gamut": [2.2, "D50", 0.7347, 0.2653, 0.258187, 0.1152, 0.8264, 0.724938, 0.1566, 0.0177, 0.016875]
    },
    l = {
      A: [0.44757, 0.40745, 0.45117, 0.40594, 2856],
      B: [0.34842, 0.35161, 0.3498, 0.3527, 4874],
      C: [0.31006, 0.31616, 0.31039, 0.31905, 6774],
      D50: [0.34567, 0.3585, 0.34773, 0.35952, 5003],
      D55: [0.33242, 0.34743,
        0.33411, 0.34877, 5503
      ],
      D65: [0.31271, 0.32902, 0.31382, 0.331, 6504],
      D75: [0.29902, 0.31485, 0.29968, 0.3174, 7504],
      E: [1 / 3, 1 / 3, 1 / 3, 1 / 3, 5454],
      F1: [0.3131, 0.33727, 0.31811, 0.33559, 6430],
      F2: [0.37208, 0.37529, 0.37925, 0.36733, 4230],
      F3: [0.4091, 0.3943, 0.41761, 0.38324, 3450],
      F4: [0.44018, 0.40329, 0.4492, 0.39074, 2940],
      F5: [0.31379, 0.34531, 0.31975, 0.34246, 6350],
      F6: [0.3779, 0.38835, 0.3866, 0.37847, 4150],
      F7: [0.31292, 0.32933, 0.31569, 0.3296, 6500],
      F8: [0.34588, 0.35875, 0.34902, 0.35939, 5E3],
      F9: [0.37417, 0.37281, 0.37829, 0.37045, 4150],
      F10: [0.34609,
        0.35986, 0.3509, 0.35444, 5E3
      ],
      F11: [0.38052, 0.37713, 0.38541, 0.37123, 4E3],
      F12: [0.43695, 0.40441, 0.44256, 0.39717, 3E3]
    };
  c.Profile = "RGB";
  c.RGB_XYZ_Matrix = "";
  c.XYZ_RGB_Matrix = "";
  c.Gamma = "";
  c.WPScreen = c.getIlluminant("2", "D65");
  var p = function (a, b) {
      var c = a.length,
        d = c,
        l, g, f = b[0].length,
        m, i = a[0].length,
        j = [],
        p, k, v;
      do {
        l = d - c;
        j[l] = [];
        g = f;
        do {
          m = f - g;
          p = 0;
          k = i;
          do v = i - k, p += a[l][v] * b[v][m]; while (--k);
          j[l][m] = p
        } while (--g)
      } while (--c);
      return j
    },
    m = function (a) {
      var b = 1 / (a[0] * (a[4] * a[8] - a[5] * a[7]) - a[1] * (a[3] * a[8] - a[5] * a[6]) + a[2] *
        (a[3] * a[7] - a[4] * a[6]));
      return [b * (a[4] * a[8] - a[5] * a[7]), b * -1 * (a[1] * a[8] - a[2] * a[7]), b * (a[1] * a[5] - a[2] * a[4]), b * -1 * (a[3] * a[8] - a[5] * a[6]), b * (a[0] * a[8] - a[2] * a[6]), b * -1 * (a[0] * a[5] - a[2] * a[3]), b * (a[3] * a[7] - a[4] * a[6]), b * -1 * (a[0] * a[7] - a[1] * a[6]), b * (a[0] * a[4] - a[1] * a[3])]
    }
})();
window.Color || (Color = {});
(function () {
  var f = Color.W3C = {
    getBrightness: function (f, b) {
      return Math.abs((f.R * 299 + f.G * 587 + f.B * 114) / 1E3 - (b.R * 299 + b.G * 587 + b.B * 114) / 1E3)
    },
    getDifference: function (f, b) {
      var j = Math.max(f.R, b.R) - Math.min(f.R, b.R),
        c = Math.max(f.G, b.G) - Math.min(f.G, b.G),
        b = Math.max(f.B, b.B) - Math.min(f.B, b.B);
      return j + c + b
    },
    test: function (i, b) {
      var j = f.getBrightness(i, b) < 125,
        c = f.getDifference(i, b) < 500;
      return j && c
    }
  }
})();
typeof Event == "undefined" && (Event = {});
Event.dragElement = function (f) {
  function i(b, a) {
    typeof a == "undefined" && (a = "move");
    var c = XY(b);
    switch (f.type) {
      case "move":
        f.callback(b, {
          x: c.x + d - l,
          y: c.y + k - p
        }, a, j);
        break;
      case "difference":
        f.callback(b, {
          x: c.x - d,
          y: c.y - k
        }, a, j);
        break;
      case "relative":
        f.callback(b, {
          x: c.x - l,
          y: c.y - p
        }, a, j);
        break;
      default:
        f.callback(b, {
          x: c.x,
          y: c.y
        }, a, j)
    }
  }

  function b(b) {
    j.cancel();
    i(b, "up")
  }
  var j = {
      cancel: function () {
        window.removeEventListener("mousemove", i, !1);
        window.removeEventListener("mouseup", b, !1)
      }
    },
    c = abPos(f.element || document.body),
    d = c.x,
    k = c.y,
    c = f.event,
    q = XY(c),
    l = q.x,
    p = q.y;
  window.addEventListener("mousemove", i, !1);
  window.addEventListener("mouseup", b, !1);
  i(c, "down")
};
var XY = window.ActiveXObject ? (function (f) {
    return ({
          x: f.clientX + document.documentElement.scrollLeft,
          y: f.clientY + document.documentElement.scrollTop
        })
  }) : (function (f) {
      return ({
            x: f.pageX,
            y: f.pageY
          })
    }),
  abPos = function (f) {
    for (var f = typeof f == "object" ? f : document.getElementById(f), i = {
        x: 0,
        y: 0
      }; f != null;) i.x += f.offsetLeft, i.y += f.offsetTop, f = f.offsetParent;
    return i
  };
typeof Event == "undefined" && (Event = {});
(function () {
  var f = navigator.userAgent.toLowerCase(),
    i = 0,
    b = function (b) {
      if (b == window) return "#window";
      if (b == document) return "#document";
      b || (b = {});
      if (!b.uniqueID) b.uniqueID = "id" + i++;
      return b.uniqueID
    },
    j = {},
    c = function (c, d, f, a) {
      c = c + b(d) + "." + b(f);
      j[c] || f && (j[c] = function (b) {
        return f.call(a, b)
      });
      return j[c]
    },
    d = function (b) {
      return !document.addEventListener ? "on" + b : b == "mousewheel" && f.indexOf("firefox") != -1 ? "DOMMouseScroll" : b
    },
    k = document.addEventListener ? "addEventListener" : "attachEvent",
    q = document.addEventListener ?
    "removeEventListener" : "detachEvent";
  Event.add = function (b, f, m, a) {
    b[k](d(f), c(f, b, m, a || b), !1);
    return m
  };
  Event.remove = function (b, f, m, a) {
    b[q](d(f), c(f, b, m, a || b), !1);
    return m
  };
  Event.stopPropagation = function (b) {
    b.stopPropagation ? b.stopPropagation() : b.cancelBubble = !0
  };
  Event.preventDefault = function (b) {
    b.preventDefault ? b.preventDefault() : b.returnValue = !1
  }
})();
window.Color || (Color = {});
(function () {
  Color.Picker = function (b) {
    var j = i(8, "rgba(40,40,40,1)", "rgba(0,0,0,1)");
    b || (b = {});
    if (!b.id) b.id = "ColorPicker";
    var c = b.parentNode || document.body,
      d = this;
    this.canvasWidth = b.canvasWidth || 405;
    this.canvasHeight = b.canvasHeight || 35;
    this.elements = {};
    this.callback = b.callback;
    this.update = function (b, c, f, a) {
      var e = d[b],
        j;
      for (j in c) e.values[j] = c[j];
      if (b == "HSL") b = d.RGB.values.A, d.RGB.values = Color.Space.HSL_RGB(e.values), d.RGB.values.A = b;
      else if (b == "RGB") d.HSL.values = Color.Space.RGB_HSL(e.values);
      d.run(f, a)
    };
    this.run = function (b, c) {
      var f = d.RGB.values,
        a = d.HSL.values,
        e = f.A / 100,
        j = {
          Hue: [
            [0, [0, a.S, a.L]],
            [0.15, [300, a.S, a.L]],
            [0.3, [240, a.S, a.L]],
            [0.5, [180, a.S, a.L]],
            [0.65, [120, a.S, a.L]],
            [0.85, [60, a.S, a.L]],
            [1, [0, a.S, a.L]]
          ],
          Saturation: [
            [0, [a.H, 100, a.L]],
            [1, [a.H, 0, a.L]]
          ],
          Luminance: [
            [0, [a.H, a.S, 100]],
            [0.5, [a.H, a.S, 50]],
            [1, [a.H, a.S, 0]]
          ],
          Red: [
            [0, [255, f.G, f.B, e]],
            [1, [0, f.G, f.B, e]]
          ],
          Green: [
            [0, [f.R, 255, f.B, e]],
            [1, [f.R, 0, f.B, e]]
          ],
          Blue: [
            [0, [f.R, f.G, 255, e]],
            [1, [f.R, f.G, 0, e]]
          ],
          Alpha: [
            [0, [f.R, f.G, f.B, 1]],
            [1, [f.R, f.G, f.B,
              0
            ]]
          ]
        },
        h = d.elements.Red,
        i = h.canvas.offsetLeft - h.control.firstChild.offsetWidth,
        g;
      for (g in j)
        if (d.elements[g] && (h = d.elements[g].canvas, h.getContext)) {
          for (var h = h.getContext("2d"), k = h.createLinearGradient(0, 0, d.canvasWidth, 0), s = 0, u = j[g].length; s < u; s++) {
            var t = j[g][s];
            if (d.HSL.named[g]) {
              var r = Color.Space.HSL_RGB({
                H: t[1][0],
                S: t[1][1],
                L: t[1][2]
              });
              k.addColorStop(t[0], "rgba(" + (r.R >> 0) + "," + (r.G >> 0) + "," + (r.B >> 0) + ", " + e + ")")
            } else r = t[1], k.addColorStop(t[0], "rgba(" + (r[0] >> 0) + "," + (r[1] >> 0) + "," + (r[2] >> 0) + ", " + r[3] +
              ")")
          }
          h.clearRect(0, 0, d.canvasWidth, d.canvasHeight);
          h.fillStyle = k;
          h.fillRect(0, 0, d.canvasWidth, d.canvasHeight);
          d.HSL.named[g] ? (k = Math.round(a[g.substr(0, 1)]), s = k / d.HSL.named[g]) : (k = Math.round(f[g.substr(0, 1)]), s = k / d.RGB.named[g]);
          u = d.canvasWidth + 1;
          h = d.elements[g];
          h.control.style.left = parseInt(u - s * u + i) + "px";
          if (parseInt(h.input.value) != k) h.input.value = k
        }
      this.callback && this.callback(f, a, c, b);
      return f
    };
    this.reset = function () {
      this.HSL = cloneObject(k);
      this.RGB = cloneObject(q)
    };
    this.destroy = function () {
      c.removeChild(this.picker);
      this.reset()
    };
    this.build = function (f) {
      var i = {};
      if (f.indexOf("HSL") !== -1) i.Hue = "HSL", i.Saturation = "HSL", i.Luminance = "HSL";
      if (f.indexOf("RGB") !== -1) i.Red = "RGB", i.Green = "RGB", i.Blue = "RGB";
      if (f.indexOf("RGBA") !== -1) i.Alpha = "RGB";
      this.picker = document.getElementById(b.id);
      if (!this.picker) {
        this.picker = document.createElement("div");
        this.picker.id = b.id;
        c.appendChild(this.picker);
        for (var k in i) {
          var f = d[i[k]],
            a = document.createElement("div");
          a.title = k;
          a.className = "selector";
          if (k == "Red") {
            var e = document.createElement("div");
            e.style.cssText = "clear: both; width: 100%; display: block; height: 41px;";
            this.picker.appendChild(e)
          }
          var e = document.createElement("input"),
            n = function (a) {
              var b = this.parentNode.title,
                c = d[i[b]],
                e = 0;
              a.type == "keydown" && (a.keyCode == 40 ? e = -1 * (a.shiftKey ? 10 : 1) : a.keyCode == 38 && (e = 1 * (a.shiftKey ? 10 : 1)));
              var f = parseInt(this.value.replace(/[^0-9]/g, "")),
                f = Math.max(0, Math.min(this.max, f + e));
              c.values[b.substr(0, 1)] = f;
              if (f != parseInt(this.pvalue)) this.pvalue = f, d.update(c.type);
              a.keyCode == 27 && this.blur()
            };
          Event.add(e,
            "click", n);
          Event.add(e, "keydown", n);
          Event.add(e, "keyup", n);
          Event.add(e, "keypress", n);
          Event.add(e, "change", n);
          e.max = f.max[k.substr(0, 1)];
          e.min = 0;
          e.className = "input";
          e.setAttribute("type", "text");
          c.appendChild(e);
          e.style.top = d.canvasHeight / 2 - e.offsetHeight / 2 - 2 + "px";
          a.appendChild(e);
          n = (function (a, b, c) {
                      return function (e) {
                        Event.dragElement({
                          type: "absolute",
                          event: e,
                          element: d.elements[a].control,
                          callback: function (e, f, h) {
                            Event.stopPropagation(e);
                            Event.preventDefault(e);
                            window.focused && window.focused.blur();
                            var j = d.elements[a].canvas,
                              e = abPos(j).x,
                              j = j.offsetWidth,
                              f = 1 - (f.x - e + 1 < 0 ? 0 : f.x - e + 1 > j ? j : f.x - e + 1) / j;
                            b.values[a.substr(0, 1)] = Math.round(f * b.named[a]);
                            d.update(i[a], b.values, a, h);
                            c.focus()
                          }
                        })
                      }
                    })(k, f, e);

          f = document.createElement("div");
          Event.add(f, "mousedown", n);
          f.className = "controller";
          f.style.height = d.canvasHeight + 10 + "px";
          var h = document.createElement("div");
          h.style.height = d.canvasHeight + 8 + "px";
          f.appendChild(h);
          a.appendChild(f);
          h = document.createElement("canvas");
          Event.add(h, "mousedown", n);
          h.style.cssText =
            "background: url(" + j.data + ")";
          h.height = d.canvasHeight;
          h.width = d.canvasWidth;
          a.appendChild(h);
          var o = document.createElement("div");
          Event.add(o, "mousedown", n);
          o.className = "name";
          o.innerHTML = k.toUpperCase();
          c.appendChild(o);
          o.style.top = d.canvasHeight / 2 - o.offsetHeight / 2 + "px";
          a.appendChild(o);
          this.picker.appendChild(a);
          d.elements[k] = {
            input: e,
            canvas: h,
            control: f
          }
        }
      }
    };
    var k = {
        type: "HSL",
        named: {
          Hue: 360,
          Saturation: 100,
          Luminance: 100
        },
        values: {
          H: 0,
          S: 100,
          L: 50
        },
        max: {
          H: 360,
          S: 100,
          L: 100
        }
      },
      q = {
        type: "RGBA",
        named: {
          Red: 255,
          Green: 255,
          Blue: 255,
          Alpha: 100
        },
        values: {
          R: 255,
          G: 0,
          B: 0,
          A: 100
        },
        max: {
          R: 255,
          G: 255,
          B: 255,
          A: 100
        }
      };
    this.HSL = f(k);
    this.RGB = f(q);
    this.build("HSL+RGB");
    this.update();
    return this
  };
  var f = function (b) {
      if (!b || typeof b != "object") return b;
      var j = new b.constructor,
        c;
      for (c in b) j[c] = f(b[c]);
      return j
    },
    i = function (b, f, c) {
      var d = document.createElement("canvas").getContext("2d");
      d.canvas.width = b * 2;
      d.canvas.height = b * 2;
      d.fillStyle = f;
      d.fillRect(0, 0, b, b);
      d.fillStyle = c;
      d.fillRect(b, 0, b, b);
      d.fillStyle = c;
      d.fillRect(0, b, b, b);
      d.fillStyle =
        f;
      d.fillRect(b, b, b, b);
      b = d.createPattern(d.canvas, "repeat");
      b.data = d.canvas.toDataURL();
      return b
    }
})();
