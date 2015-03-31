s.boot;

(
SynthDef(\woodBlock, {|freq = 220, amp = 0.1, sustain = 1, bright = 1, pan = 0, out=0|
	var partials = [1, 2.572, 4.644, 6.984, 9.723, 12];
	var sig = Array.fill(6, {|i|
		var i_sig = SinOsc.ar(partials[i]*freq, rrand(0,2pi), (1+(bright*((i/5)-1)))/(i**2.5+1));
		var i_env = EnvGen.kr(Env.perc(0.06/(i+1), sustain/(i+1), amp/2), doneAction: (i==0).asInt * 2);
		i_sig*i_env
    }).sum;
	Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

(
//ENVIRONMENT VARIABLES
~speed = 30;
~width = 400;
~height = 600;
~sides = 7;
~elasticity = 0.6;
~pitchList = [1, 2.572, 2.072, 4.644];
~root = 82.5;
~detune = 0.01;
~trigger = false;
)


(

//ACTION
var polygon = Polygon(~sides, ~width, ~height);
var ball = Ball2(0@0, 0.7.rand2 @ 0.7.rand2);
var chime = WindChime(ball, polygon);
var oldPosition = Point.new();
var sector = 0;
var klang = true;

var playFunc = {|loudness, brightness, side|
	Synth(\woodBlock, [
		\freq, ~pitchList.wrapAt(side) * (1 + rand2(~detune)) * ~root,
		\amp, 2*loudness,
		\bright, brightness,
		\pan, rrand(-0.8,0.8),
		\sustain, [1, 2, 4].choose])
};

var w = Window("WindChime", Rect(100, 100, ~width+240, ~height+60), false).front;
var u = UserView(w, w.view.bounds.insetBy(120,30));

w.background_(Color.white);
u.background_(Color.green(0.9, 0.05));

u.animate = true;

u.drawFunc = {
	Pen.translate(~width/2, ~height/2);  //Move origin to center
	//Pen.rotate(u.frame*0.001);
	Pen.alpha = 0.5;

	oldPosition = ball.position;
	ball.updatePosition(~speed);
	sector = chime.getSector;

	if( chime.isOutside(sector), {
		chime.updateVelocity(sector, ~elasticity);
		ball.position = oldPosition;
		playFunc.value(chime.loudness, chime.brightness, sector);
		klang = true }, { klang = false }
	);

	Pen.fillColor = Color.blue;
	Pen.fillOval(Rect.aboutPoint(ball.position, 20, 20));

	Pen.width = 20;
	Pen.strokeColor = Color.red;
    polygon.points.size.do({|i|
        Pen.moveTo(polygon.points[i]);
        Pen.lineTo(polygon.points.wrapAt(i+1));
		if ( klang && sector == i, { Pen.alpha=1 }, { Pen.alpha=0.3 } );
		Pen.stroke;
	});

};

)
