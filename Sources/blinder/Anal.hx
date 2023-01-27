package blinder;

import armory.trait.internal.UniformsManager;
import iron.Scene;
import iron.math.Vec4;
import iron.object.MeshObject;
import iron.system.Input.Mouse;
import iron.system.Input;
import js.Browser.document;
import js.Browser.window;
import js.html.audio.AnalyserNode;
import js.html.audio.AudioContext;
import js.lib.Float32Array;
import js.lib.Uint8Array;
import kha.System;

class Anal extends iron.Trait {

    static final URI = "https://webradio.bubuit.net/orangeicebear.ogg";

    var audioElement : js.html.AudioElement;
    var audio : AudioContext;
    var analyser : AnalyserNode;
    var timeData : Uint8Array;
    //var freqData : Uint8Array;
    var freqData : Float32Array;
    var started = false;
    var cube : MeshObject;
    var plane : MeshObject;
    var monkey : MeshObject;

    public function new() {
        super();
        notifyOnInit(()-> {

            cube = Scene.active.getMesh('Cube');
            plane = Scene.active.getMesh('Plane');
            monkey = Scene.active.getMesh('Suzanne');

            audioElement = document.createAudioElement();
            audioElement.preload = "none";
            audioElement.crossOrigin = "anonymous";
			audioElement.controls = false;
			audioElement.autoplay = false;
            audioElement.volume = 0.2;

            var sourceElement = document.createSourceElement();
			sourceElement.type = 'application/ogg';
			sourceElement.src = URI;
			audioElement.append( sourceElement );
			audioElement.play();

            audioElement.onplaying = function() {

                audio = new AudioContext();
                analyser = audio.createAnalyser();
                analyser.fftSize = 1024;

                analyser.connect( audio.destination );

                var source = audio.createMediaElementSource(audioElement);
                source.connect( analyser );

                timeData = new Uint8Array( analyser.frequencyBinCount );
                //freqData = new Uint8Array( analyser.frequencyBinCount );
                freqData = new js.lib.Float32Array( analyser.frequencyBinCount );
                started = true;
            }
        });

        notifyOnUpdate(update);
        notifyOnRender2D(render2d);
    }

    function update() {
        if(started) {
            analyser.getByteTimeDomainData( timeData );
            analyser.getFloatFrequencyData( freqData );
        } else {
            var mouse = Input.getMouse();
            if(mouse.started('left')) {
                audioElement.play();
            }
        }
    }

    function render2d(g: kha.graphics2.Graphics) {
        if(timeData != null) {
            final sw = System.windowWidth();
            final sh = System.windowHeight();
            g.color = 0xffff0000;
            var barWidth = sw / analyser.frequencyBinCount;
            var barHeight = 0;
            var x = 0.0;
            var s = 0.0;
            for(i in 0...analyser.frequencyBinCount) {
                if(i==50) {
                    g.color = 0xff0000ff;
                    s = freqData[i] / 100; //255; 
                    //var v = freqData[i] / 255;
                    //UniformsManager.setVec3Value(plane.materials[0], plane, "RGB", new Vec4(
                    UniformsManager.setVec3Value(plane.materials[0], monkey, "RGB", new Vec4(
                        1+s,
                        1+s,
                        1+s,
                        0
                    ));
                } else {
                    g.color = 0xff000000;
                }
                /* barHeight = freqData[i]; */
                /* g.fillRect(x, sh - barHeight, barWidth, barHeight); */
                /* x += barWidth; */

                monkey.transform.scale.x = -s;
                monkey.transform.scale.y = -s;
                monkey.transform.scale.z = -s;
                monkey.transform.buildMatrix();
            }

            /*
            g.color = 0xffff0000;
            var x = 0.0;
            var y = 0.0;
            var hw = sw / 2;
            var hh = sh / 2;
            var v : Float;
            for(i in 0...analyser.frequencyBinCount) {
                v = i / 180 * Math.PI; 
                x = Math.cos(v) * timeData[i];
                y = Math.sin(v) * timeData[i];
                g.drawLine(hw, hh, hw + x, hh+y);
            }
            */
            /*
            var dx = sw / analyser.frequencyBinCount;
            var px = 0;
            for(i in 0...analyser.frequencyBinCount) {
                var v = timeData[i];
                //v *= 2;
                px = Math.floor(px + dx);
                g.drawLine(px, 0, px, v);
            }
            */
        }
    }

}
