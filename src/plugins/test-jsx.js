import h from '../lib/dom/hyper-hermes'

var lala =
<div id="body">
  <div id="head" style="background-image: url('./media/images/topbar-bg.jpg'); background-repeat: repeat-x;">
    <div class="wrapper">
      <span><a href="http://mudcu.be/"><img src="./media/images/logo.gif"/></a></span>
      <ul id="nav">
        <li>
          <a href="#"><img src="./media/images/Settings.png" style="position: relative; top: -5px" /></a>
          <ul>
            <li>
              <a href="#">Colors</a>
              <ul>
                <li><a href="#" onclick="sphere.setDotType('dot', this);">Show as Dots</a></li>
                <li><a href="#" class="selected" onclick="sphere.setDotType('num', this);">Show as Numbers</a></li>
              </ul>
            </li>
            <li>
              <a href="#">Mode</a>
              <ul>
               <li><a href="#" onclick="sphere.setColorSpace('RGB', this);">RGB (Red-Green-Blue)</a></li>
               <li><a href="#" class="selected" onclick="sphere.setColorSpace('RYB', this);">RYB (Red-Yellow-Blue)</a></li>
              </ul>
           </li>
           <li><a href="#">Theme</a>
            <ul>
             <li><a href="#" class="selected" onclick="sphere.setTheme('dark', this);">Dark</a></li>
             <li><a href="#" onclick="sphere.setTheme('light', this);">Light</a></li>
            </ul>
           </li>
          </ul>
       </li>
       <li><a href="#"><img src="./media/images/Save.png" style="position: relative; top: -5px" /></a>
      <ul>
       <li><a href="#" onmouseover="sphere.updateURL(this, 'ai')">Illustrator (.AI)</a></li>
       <li><a href="#" onmouseover="sphere.updateURL(this, 'aco')">Photoshop (.ACO)</a></li>
       <li><a href="#" onmouseover="sphere.updateURL(this, 'colrd')">Palette Creator (ColRD)</a></li>
       <li><a href="#" onmouseover="sphere.updateURL(this, 'sphere')">Get this URL…</a></li>
      </ul>
 </li>
 <li><a href="#">Harmony</a>
<ul>
 <li><a href="#" class="selected" onclick="sphere.setHarmony(this.innerHTML, this)">Neutral</a></li>
 <li><a href="#" onclick="sphere.setHarmony(this.innerHTML, this)">Analogous</a></li>
 <li><a href="#" onclick="sphere.setHarmony(this.innerHTML, this)">Clash</a></li>
 <li><a href="#" onclick="sphere.setHarmony(this.innerHTML, this)">Complementary</a></li>
 <li><a href="#" onclick="sphere.setHarmony(this.innerHTML, this)">Split-Complementary</a></li>
 <li><a href="#" onclick="sphere.setHarmony(this.innerHTML, this)">Triadic</a></li>
 <li><a href="#" onclick="sphere.setHarmony(this.innerHTML, this)">Tetradic</a></li>
 <li><a href="#" onclick="sphere.setHarmony(this.innerHTML, this)">Four-Tone</a></li>
 <li><a href="#" onclick="sphere.setHarmony(this.innerHTML, this)">Five-Tone</a></li>
 <li><a href="#" onclick="sphere.setHarmony(this.innerHTML, this)">Six-Tone</a></li>
</ul>
 </li>
 <li><a href="#">Vision</a>
<ul>
 <li><a href="#" class="selected" onclick="sphere.setVision(this.innerHTML, this)">Normal</a></li>
 <li><a href="#" onclick="sphere.setVision(this.innerHTML, this)">Protanopia</a></li>
 <li><a href="#" onclick="sphere.setVision(this.innerHTML, this)">Protanomaly</a></li>
 <li><a href="#" onclick="sphere.setVision(this.innerHTML, this)">Deuteranopia</a></li>
 <li><a href="#" onclick="sphere.setVision(this.innerHTML, this)">Deuteranomaly</a></li>
 <li><a href="#" onclick="sphere.setVision(this.innerHTML, this)">Tritanopia</a></li>
 <li><a href="#" onclick="sphere.setVision(this.innerHTML, this)">Tritanomaly</a></li>
 <li><a href="#" onclick="sphere.setVision(this.innerHTML, this)">Achromatopsia</a></li>
 <li><a href="#" onclick="sphere.setVision(this.innerHTML, this)">Achromatomaly</a></li>
</ul>
 </li>
 <li><a href="#">Quantize</a>
<ul>
 <li><a href="#" class="selected" onclick="sphere.setQuantize(0, this)">Spectrum</a></li>
 <li><a href="#" onclick="sphere.setQuantize(17, this)">Websmart</a></li>
 <li><a href="#" onclick="sphere.setQuantize(51, this)">Websafe</a></li>
</ul>
 </li>
</ul>
</div>
</div>
<div id="content">
<div id="degree">0°</div>
<div id="hexcodes">
  <div style="position: relative; left: 580px; width: 100px; top: 92px; padding-bottom: 53.3333px; height: 30px; font-size: 24px; z-index: 2; color: rgb(255, 255, 255);">#FF0000</div>
  <div style="position: relative; left: 580px; width: 100px; top: 92px; padding-bottom: 53.3333px; height: 30px; font-size: 24px; z-index: 2; color: rgb(255, 255, 255);">#FF2200</div>
  <div style="position: relative; left: 580px; width: 100px; top: 92px; padding-bottom: 53.3333px; height: 30px; font-size: 24px; z-index: 2; color: rgb(255, 255, 255);">#FF4800</div>
  <div style="position: relative; left: 580px; width: 100px; top: 92px; padding-bottom: 53.3333px; height: 30px; font-size: 24px; z-index: 2; color: rgb(0, 0, 0);">#FF6E00</div>
  <div style="position: relative; left: 580px; width: 100px; top: 92px; padding-bottom: 53.3333px; height: 30px; font-size: 24px; z-index: 2; color: rgb(0, 0, 0);">#FF9000</div>
  <div style="position: relative; left: 580px; width: 100px; top: 92px; padding-bottom: 53.3333px; height: 30px; font-size: 24px; z-index: 2; color: rgb(0, 0, 0);">#FFAE00</div>
</div>
  <canvas id="sphere_bg" width="700" height="577"></canvas>
  <canvas id="points" width="700" height="577"></canvas>
  <canvas height="500" width="500" style="left: 50px; width: 500px; z-index: 0; top: 62px;"></canvas>
  <div id="ColorPicker">
    <div title="Hue" class="selector">
      <input max="360" min="0" class="input" type="text" style="top: 17.5px;" />
      <div class="controller" style="height: 68px; left: 363px;"><div style="height: 66px;"></div></div>
      <canvas height="58" width="300" style="background: url(&quot;data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAL0lEQVQ4T2PU0ND4z4AH3LhxA580A+OoAcMiDBgYGPCmAw0NDfzpYNQABsahHwYAkDErwfNVqwgAAAAASUVORK5CYII=&quot;);"></canvas>
      <div class="name" style="top: 20px;">HUE</div>
    </div>
    <div title="Saturation" class="selector">
      <input max="100" min="0" class="input" type="text" style="top: 17.5px;" />
      <div class="controller" style="height: 68px; left: 62px;"><div style="height: 66px;"></div></div>
      <canvas height="58" width="300" style="background: url(&quot;data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAL0lEQVQ4T2PU0ND4z4AH3LhxA580A+OoAcMiDBgYGPCmAw0NDfzpYNQABsahHwYAkDErwfNVqwgAAAAASUVORK5CYII=&quot;);"></canvas>
      <div class="name" style="top: 20px;">SATURATION</div>
    </div>
    <div title="Luminance" class="selector">
      <input max="100" min="0" class="input" type="text" style="top: 17.5px;" />
      <div class="controller" style="height: 68px; left: 212px;"><div style="height: 66px;"></div></div>
      <canvas height="58" width="300" style="background: url(&quot;data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAL0lEQVQ4T2PU0ND4z4AH3LhxA580A+OoAcMiDBgYGPCmAw0NDfzpYNQABsahHwYAkDErwfNVqwgAAAAASUVORK5CYII=&quot;);"></canvas>
      <div class="name" style="top: 20px;">LUMINANCE</div>
    </div>
    <div style="clear: both; width: 100%; display: block; height: 41px;"></div>
    <div title="Red" class="selector">
      <input max="255" min="0" class="input" type="text" style="top: 17.5px;" />
      <div class="controller" style="height: 68px; left: 62px;"><div style="height: 66px;"></div></div>
      <canvas height="58" width="300" style="background: url(&quot;data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAL0lEQVQ4T2PU0ND4z4AH3LhxA580A+OoAcMiDBgYGPCmAw0NDfzpYNQABsahHwYAkDErwfNVqwgAAAAASUVORK5CYII=&quot;);"></canvas>
      <div class="name" style="top: 20px;">RED</div>
    </div>
    <div title="Green" class="selector">
      <input max="255" min="0" class="input" type="text" style="top: 17.5px;" />
      <div class="controller" style="height: 68px; left: 363px;"><div style="height: 66px;"></div></div>
      <canvas height="58" width="300" style="background: url(&quot;data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAL0lEQVQ4T2PU0ND4z4AH3LhxA580A+OoAcMiDBgYGPCmAw0NDfzpYNQABsahHwYAkDErwfNVqwgAAAAASUVORK5CYII=&quot;);"></canvas>
      <div class="name" style="top: 20px;">GREEN</div>
    </div>
    <div title="Blue" class="selector">
      <input max="255" min="0" class="input" type="text" style="top: 17.5px;" />
      <div class="controller" style="height: 68px; left: 363px;"><div style="height: 66px;"></div></div>
      <canvas height="58" width="300" style="background: url(&quot;data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAL0lEQVQ4T2PU0ND4z4AH3LhxA580A+OoAcMiDBgYGPCmAw0NDfzpYNQABsahHwYAkDErwfNVqwgAAAAASUVORK5CYII=&quot;);"></canvas>
      <div class="name" style="top: 20px;">BLUE</div>
    </div>
  </div>
    </div>
    <br style="clear:both" />

<footer style="display: none;">
Download at the <a href="https://chrome.google.com/webstore/detail/knomilfbnhpkmibhmleppnkmcempglag">Chrome Web Store</a> or for <a href="http://www.apple.com/downloads/dashboard/reference/colortheory.html">OSX Dashboard</a>.
</footer>
</div>

window.addEventListener('DOMContentLoaded', function () {
  document.body.appendChild(lala)
}, false)
