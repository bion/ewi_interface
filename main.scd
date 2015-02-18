/* EWI Interface

Button to start server with specific server options
Then create objects that do particular things all processing incoming audio

*/

(


var 	window, text1, text2, text3, text4, synths, scope, meter,

//buttons
onButton,
buttonA, button1, button2, button2b, button3, button4, button5, button6, button7, button8, button9, button10, button11, button12, button13, button14, button15, button16, button17, button18, button19, button20,

//Faders
fader1, fader2, fader3, fader4,

//Objects (synths)
object1, object2, object2b, object3, object3rec, object3out, object4, object5, object6, object7, object8, object9, object10, object10rec, object10out,
object11, object12, object13, object14, object15,  object16, object17, object18, object19, tinkly, object20, pluckSynth, pluckRoutine,

//Buffers
buffer1, buffer1b, buffer2, buffer3, buffer4, buffer5, buffer6,

//Misc
nothing, micbuffer, mixerA, autotime;


~controlwindow = Window.new;
~controlwindow.front;
~controlwindow.bounds_(Rect(1000, 670, 280, 100));

~button1 = Button(~controlwindow,Rect(20, 10, 240, 30));
~button1.states = [
	["Start Server", Color.fromHexString("#ffffff"), Color.fromHexString("#666a78")],
	["Launch (Wait for server to boot)", Color.fromHexString("#ffffff"), Color.fromHexString("#4d5e65")],
	["Click to restart the patch", Color.white, Color.gray]
			];
~button1.action = { arg butt;
			if (butt.value ==1,
				{
				s.quit;
				s.options.memSize = 57344*2;
				s.options.maxNodes = 1024*2;
				s.boot;
			    //s.scope;
			    //s.meter;
				s.recHeaderFormat_('AIFF');
				s.recSampleFormat_('int16');
				s.recChannels_(2);

				});
			if (butt.value ==2,
				{

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//GUI Size
window = Window.new;
window.front;
window.bounds_(Rect(160, 100, 1100, 800));
window.background_(Color.fromHexString("#2f3140"));
window.name_("EWI Performance Interface");

			//Synths text
			synths = StaticText(window, Rect(40, 510, 720, 10));
			synths.string = "Synths that dont require audio in";
			synths.background_(Color.fromHexString("#20222C"));
			synths.stringColor_(Color.white);
			synths.align = \center;
			synths.font = Font("Helvetica", 10);

			//Add a scope to the interface
			scope = CompositeView(window, Rect(800, 80, 300, 400));
			Stethoscope.new(s, 4, view:scope);
			window.onClose = {scope.free}; // frees scope

			/*//Add Meter window to interface
			meter = CompositeView(window, Rect(800, 500, 300, 400));
			ServerMeter.new(s, 6, 6);
			window.onClose = {meter.free}; //frees meter
*/

//Microphone & Buffers (Pre outlet1)
buffer1 = Buffer.alloc(s, 44100 * 1.0, 1);
buffer1b = Buffer.alloc(s, 44100 * 1.3, 1);
buffer2 = Buffer.alloc(s, 44100 * 1.0, 1);
buffer3 = Buffer.alloc(s, 44100 * 3.0, 1);
buffer4 = Buffer.alloc(s, 44100 * 3.0, 1);
buffer5 = Buffer.alloc(s, 44100 * 3.0, 1);
buffer6 = Buffer.alloc(s, 44100 * 1.0, 1);

SynthDef("MicBuffer",{
		arg micout = 99;
		var mic;

		mic = HPF.ar( AudioIn.ar([1,2]),100);
		mic = Mix.new(mic*([0.dbamp,0.dbamp])); // multiply gain when not using preamp
		Out.ar(micout, mic);
	}).send(s);


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Object1 = Pitch Shift With Env PITCH VARIATION
SynthDef("Object1",{arg  outlet1=101, gate =1;
			var playbuf, pshift, panstereo, env, envelop, lfo;

			env = Env.new([0.0001, 0.05, 0.95],[0.2, 0.6], 'exponential' );
			envelop = EnvGen.kr(env, timeScale:10);

			playbuf = In.ar(99,1);
			pshift = PitchShift.ar(playbuf, 2.0, 1.0, 0.3+envelop, 1.7);

			//experiment here with 4 channels-------------------------------------------------------------
				panstereo = Pan4.ar(pshift, SinOsc.ar(0.5+SinOsc.kr(0.4, mul:1.5)),SinOsc.ar(0.5+SinOsc.kr(0.4, mul:1.5)));
				Out.ar([0,1], panstereo*EnvGen.kr(Env.asr(0.1, 0.8, 1.3), gate, doneAction:2));
			}).send(s);

//Button1
button1 = Button(window, Rect(40, 80, 200, 30));
button1.states = [
			["1. Pitch Variation On", Color.white, Color.fromHexString("#333366");],
			["Pitch Variation Off", Color.black, Color.white],
			["Click to Reset", Color.white, Color.black]
			];
button1.action =
			{ arg butt;
				if (butt.value ==1,
					{object1 = Synth.before (mixerA,"Object1")});
				if (butt.value ==2,
					{object1.release(2)});
				if (butt.value ==3,
					nothing=1);
			};

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Object2 = Pitch Shift With Env & Buffer LOOPING PITCH VARIATION ON

SynthDef("Object2",{arg outlet1=101, gate =1,recstop=1;
			var playbuf,pshift,panstereo, env, envelop;

			RecordBuf.ar(In.ar(99,1), buffer1.bufnum, run:recstop);

			env = Env.new([ 0.0001, 0.3,1.7],[0.4,1.6], 'exponential' );
			envelop = EnvGen.kr(env,timeScale:10);

			playbuf = PlayBuf.ar(1,buffer1.bufnum,loop:1);
			pshift = PitchShift.ar(playbuf,1.0,1.4,0.3+envelop,0.5);
			panstereo = Pan2.ar(pshift,SinOsc.ar(0.5+SinOsc.kr(0.4,mul:1.5)));
			Out.ar(outlet1, panstereo*EnvGen.kr(Env.asr(0.1, 0.8, 1.3), gate, doneAction:2));
			}).send(s);

//Button2
button2 = Button(window,Rect(40,120,200,30));
button2.states = [
			["2. Looping Pitch Var On",Color.white,Color.fromHexString("#333366");],
			["Looping Pitch Var Loop",Color.black,Color.green],
			["Looping Pitch Var Off",Color.black,Color.white],
			["Click to Reset",Color.white,Color.black]
			];
button2.action =
			{ arg butt;
				if (butt.value ==1,
					{object2 = Synth.before(mixerA,"Object2")});
				if (butt.value==2,
					{
						Routine({
						var repeats =3,counter =1, wtime,counterx;
						repeats.do({
								("Loop Count:  "++counterx).postln;
								if(counter == repeats, {object2.set(\recstop,0)});
								counter =counter+1;
								counterx = repeats-counter;
								wtime = 1.0;
								wtime.wait
					});
			}).play

					}
				    );
				if (butt.value ==3,
					{object2.release(4)});
				if (butt.value ==4,
					nothing=1);
			};

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Object2b = Pitch Shift With Env & Buffer - LOOPING PITCH VARIATION

SynthDef("Object2b",{arg outlet1=101, gate =1,recstop=1;
			var playbuf,pshift,panstereo, env, envelop;

			RecordBuf.ar(In.ar(99,1), buffer1b.bufnum, run:recstop);

			env = Env.new([ 0.0001, 0.4,5.7],[0.4,1.56], 'exponential' );
			envelop = EnvGen.kr(env,timeScale:10);

			playbuf = PlayBuf.ar(1,buffer1b.bufnum,loop:1);
			pshift = PitchShift.ar(playbuf,1.0,1.4,0.3+envelop,0.7);
			panstereo = Pan2.ar(pshift,SinOsc.ar(0.5+SinOsc.kr(0.4,mul:1.5)));
			Out.ar(outlet1, panstereo*EnvGen.kr(Env.asr(0.1, 0.8, 1.3), gate, doneAction:2));
			}).send(s);

//Button2b
button2b = Button(window,Rect(40,160,200,30));
button2b.states = [
			["3. Looping Pitch Var2 On",Color.white,Color.fromHexString("#333366");],
			["Looping Pitch Var2 Loop",Color.black,Color.green],
			["Looping Pitch Var2 Off",Color.black,Color.white],
			["Click to Reset",Color.white,Color.black]
			];
button2b.action =
			{ arg butt;
				if (butt.value ==1,
					{object2b = Synth.before(mixerA,"Object2b")});
				if (butt.value==2,
					{
						Routine({
						var repeats =3,counter =1, wtime,counterx;
						repeats.do({
								("Loop II Count:  "++counterx).postln;
								if(counter == repeats, {object2b.set(\recstop,0)});
								counter =counter+1;
								counterx = repeats-counter;
								wtime = 1.0;
								wtime.wait
					});
			}).play

					}
				    );
				if (butt.value ==3,
					{object2b.release(4)});
				if (butt.value ==4,
					nothing=1);
			};


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Object3 = Pitch Shift With Env & Buffer & Spawn -- SPAWN

SynthDef("Object3Rec",{arg recstop=1;
			RecordBuf.ar(In.ar(99,1), buffer2.bufnum, run:recstop);
			}).send(s);

SynthDef("Object3",{arg outlet2=110, gate =1,spawnvar=0.0;

			var playbuf,pshift,panstereo, env, envelop;

			env = Env.new([ 0.0001, 0.3,0.7],[0.4,1.6], 'exponential' );
			envelop = EnvGen.kr(env,timeScale:4);

			playbuf = PlayBuf.ar(1,buffer2.bufnum,loop:1);
			pshift = PitchShift.ar(playbuf,1.0,2.0,0.3+envelop+spawnvar,0.5);
			panstereo = Pan2.ar(pshift,SinOsc.ar(0.3));

			Out.ar(outlet2, panstereo*EnvGen.kr(Env.asr(0.1, 0.8, 1.3), gate, doneAction:2));
			}).send(s);

SynthDef("Object3Out",{arg outlet1=101,gate=1;
			var playbuf,env,envelop;
			playbuf=Limiter.ar(In.ar(110,2),0.75,0.1);

			Out.ar(outlet1, playbuf*EnvGen.kr(Env.asr(0.1, 0.8, 1.3), gate, doneAction:2));
			}).send(s);

//Button3
button3 = Button(window,Rect(40,200,200,30));
button3.states = [
			["4. Spawning PitchVar On",Color.white,Color.fromHexString("#333366");],
			["Spawning PitchVar Loop",Color.black,Color.green],
			["Spawning PitchVar Spawn",Color.black,Color.green],
			["Spawning PitchVar Off",Color.black,Color.white],
			["Click to Reset ",Color.white,Color.black]
			];
button3.action =
{ arg butt;
var repeats;
	if (butt.value ==1,
		{object3rec=Synth.before(mixerA,"Object3Rec");
		object3 = Synth.before(mixerA,"Object3");
		object3out=Synth.before(mixerA,"Object3Out")
		};

		);
	if (butt.value==2,
		{object3rec.set(\recstop,0)});
	if (butt.value ==3,
		{
			repeats = 30; //--------- This determines how many times Object3 will spawn
			r =Routine({
			var counter =1, wtime,rrate0,rrate,vvol;
			repeats.do({
			("Spawn # :  "++counter).postln;
			if(counter == repeats, {("Last ONE!!!".postln)});
			counter = counter+1;

			rrate0 = 5.rand2;
			rrate = (rrate0*0.1)+0.8;
			vvol = 0.5.rand;
			Synth.new("Object3", [\spawnvar,2.0.rand]);
			wtime = 1.0+(3.rand);
			wtime.wait
			});
			}).play
		});
	if (butt.value ==4,
		{object3out.release(7)});
	if (butt.value ==5,
		{
		object3rec.free;
		object3.free;
		object3out.free})
};

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Object4 = Large Grain With Env ----- GRAINY SOUND


SynthDef("Object4",{arg  outlet1=101, gate =1;
			var playbuf,pshift,pshift2,panstereo,panstereo2, mix,env, envelop, grainSize;
				grainSize = 0.5;

			env = Env.new([ 0.9, 0.05, 0.95],[0.0001,5], 'exponential' );
			envelop = EnvGen.kr(env,timeScale:10);

			playbuf = In.ar(99,1);
				pshift = PitchShift.ar(playbuf, 0.02, Line.kr(0.1, 4, 10), 0, envelop);
			//pshift = PitchShift.ar(playbuf,2,0.3,0.3,0.1+envelop);
				//pshift2 = PitchShift.ar(pshift, 0.02, Line.kr(0.1, 7, 10), 0, 0.0001);
			pshift2 = PitchShift.ar(pshift, 3, 0.2, 0.4, 0.7);
			panstereo = Pan2.ar(pshift,SinOsc.ar(16));
			panstereo2 = Pan2.ar(pshift2,SinOsc.ar(14.5));
			mix = Mix.new([panstereo,panstereo2]);
			Out.ar(outlet1, 1.4*mix*EnvGen.kr(Env.asr(0.1, 0.8, 1.3), gate, doneAction:2));
			}).send(s);

//Button4
button4 = Button(window, Rect(300, 80, 200, 30));
button4.states = [
			["5. Grainy Sound On",Color.white,Color.fromHexString("#333366");],
			["Grainy Sound Off",Color.black,Color.white],
			["Click to Reset",Color.white,Color.black]
			];
button4.action =
			{ arg butt;
				if (butt.value ==1,
					{object4 = Synth.before(mixerA,"Object4")});
				if (butt.value ==2,
					{object4.release(2)});
				if (butt.value ==3,
					nothing=1);
			};

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Object5 = Delay Evolving PShift - MECHANICAL POPCORN

SynthDef("Object5", {
	arg out = 101,gate =1,recstop=1;
	var playbuf,delay1,delay2,delay3,delay4, dtime1, dtime2,dtime3,time,
	    mix, mix2,decay,
	    env,env2,pshift,pshift2,pvar,
	    toscil,toscil2,toscil3,filter;

	RecordBuf.ar(In.ar(99,1), buffer3.bufnum, run:recstop);
	time = 10; //sets evolution time

	dtime1 = XLine.kr(0.58,0.007,time*0.6);
	dtime2 = XLine.kr(0.43,0.005,time*0.8);
	dtime3 = XLine.kr(0.24,0.005,time*0.7);

	toscil = Dust.kr(16,mul:0.006);
	toscil2 = Dust.kr(9,mul:0.006);
	toscil3 = Dust.kr(5,mul:0.006);

	playbuf = PlayBuf.ar(1,buffer3.bufnum,loop:1);
	playbuf = Pan2.ar(playbuf,0);

	delay1 = CombC.ar(playbuf,1.0,
				[dtime1+toscil,dtime2+toscil2],0.5);
	delay2 = PitchShift.ar(delay1,3.0,1.0,0.3,1.0);

	delay3 = CombC.ar(playbuf,1.0,
				toscil3,0.5);
	delay4 = PitchShift.ar(delay3,3.0,1.0,0.7,1.0);
	delay4 = Pan2.ar(delay4,0);

	decay = XLine.kr(0.4,0.002,50);
	mix = Mix.new([playbuf*decay,delay2*0.8,delay4*0.7]);
	filter = BPF.ar(mix, 2000,0.1,add:mix);
	mix2 = Limiter.ar(filter,0.8,0.03);
	Out.ar(out, 0.7*mix2* EnvGen.kr(Env.asr(0.1, 0.8, 1.3), gate, doneAction:2))
}).send(s);

//Button5
button5 = Button(window,Rect(300,120,200,30));
button5.states = [
			["6. Mechanical Popcorn On",Color.white,Color.fromHexString("#333366");],
			["Mechanical Popcorn Loop",Color.black,Color.green],
			["Mechanical Popcorn Off",Color.black,Color.white],
			["Click to Reset",Color.white,Color.black]
			];
button5.action =
			{ arg butt;
				if (butt.value ==1,
					{object5 = Synth.before(mixerA,"Object5")});
				if (butt.value==2,
					{object5.set(\recstop,0)});
				if (butt.value ==3,
					{object5.release(15)});
				if (butt.value ==4,
					nothing=1);
			};

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Object 6 = Delay Evolving Pshift II - MECHANICAL PHRASER

SynthDef("Object6", {
			arg out = 101,gate =1, recstop=1;
			var kin, playbuf,delay1,dtime1, mix,mix2,filter,
			env,env2,pshift,pshift2,pvar,toscil,toscil2, dryline;

			kin = In.kr(99,1);
			RecordBuf.ar(In.ar(99,1), buffer4.bufnum, run:recstop);

			playbuf = PlayBuf.ar(1,buffer4.bufnum,loop:1);
			env = Env.new([ 2.0, 0.8,0.1,0.05,0.013  ],[0.2,0.3,0.1,0.4], 'exponential' );
			dtime1 = EnvGen.kr(env, timeScale:24); //determines evolution time

			delay1 = CombC.ar(playbuf,4.0,dtime1,0.4);

			env2 = Env.new([ 0.01, 0.01,3.0],[0.4,0.6], 'exponential' );
			pvar  = EnvGen.kr(env2,timeScale:60);
			toscil = SinOsc.kr(0.2,mul:0.007);
			toscil2 = SinOsc.kr(0.2,mul:0.007);
			pshift = CombC.ar(delay1, 4.2, [(dtime1*2)+toscil,(dtime1*2.002)+toscil2],0.05);
			pshift2 = PitchShift.ar(pshift,2.15,1.0,pvar,2.12);
			dryline = XLine.kr(0.9,0.07,80);

			mix = Mix.new([playbuf*0.9,delay1*0.9,pshift*0.7]);
			mix = Mix.new([mix*dryline,pshift2]);
			mix = LPF.ar(mix, 20000);
			filter = BPF.ar(mix, 1800,0.2,1.8,mix);
			mix2 = Limiter.ar(filter,0.9,0.03);

			Out.ar(out, 0.4*mix2 * EnvGen.kr(Env.asr(0.1, 0.8, 1.3), gate, doneAction:2));
		}).send(s);

//Button6
button6 = Button(window,Rect(300,160,200,30));
button6.states = [
			["7. Mechanical Phraser On",Color.white,Color.fromHexString("#333366");],
			["Mechanical Phraser Loop",Color.black,Color.green],
			["Mechanical Phraser Off",Color.black,Color.white],
			["Click to Reset",Color.white,Color.black]
			];
button6.action =
			{ arg butt;
				if (butt.value ==1,
					{object6 = Synth.before(mixerA,"Object6")});
				if (butt.value==2,
					{object6.set(\recstop,0)});
				if (butt.value ==3,
					{object6.release(18)});
				if (butt.value ==4,
					nothing=1);
			};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Object7 = amp controlled noise - DRASTIC PITCH MOD

SynthDef("Object7",{ arg out =101, gate =1;
	var input, bufferx,buffer7,modulator, modulator2,process;

	input = In.ar(99,1);

	//you could put a whole chain of modulaters here ------------------------------------------------
	modulator = SinOsc.ar([0.2,0.3],mul:[9,10],add:10);
	modulator2 = SinOsc.ar(modulator,[0,180],mul:[1.5,1.4]);

	process =  PitchShift.ar(input,[0.02,0.043],1.6+modulator2);
	Out.ar(out,[process.at(0),process.at(1)],EnvGen.kr(Env.asr(15, 0.8, 1.3), gate, doneAction:2));

}).send(s);

//button7
button7 = Button(window,Rect(550,80,200,30));
button7.states = [
			["10. Drastic Pitch Mod warble On",Color.white,Color.fromHexString("#333366");],
			["Drastic Pitch Mod Off",Color.black,Color.white],
			["Click to Reset",Color.white,Color.black]
			];
button7.action =
			{ arg butt;
				if (butt.value ==1,
					{object7 = Synth.before(mixerA,"Object7")});
				if (butt.value ==2,
					{object7.release(6)});
				if (butt.value ==3,
					nothing=1);
			};

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Object8 = Low Thump -- FOR LONG TONE

		SynthDef("Object8",{arg outlet1=101, gate =1;
			var playbuf,pshift,panstereo1,panstereo2,mix, env, envelop,
			     modulation;

			playbuf = In.ar(99,1);
			playbuf = HPF.ar(playbuf,100);
			pshift = PitchShift.ar(playbuf,0.2,[0.2,0.1],0.04,0.05);
			pshift = PitchShift.ar(playbuf,0.2,1,[0.04,0.06],[0.18,0.19]);

			Out.ar(outlet1,pshift*EnvGen.kr(Env.asr(0.2, 0.8, 1.3), gate, doneAction:2));
			}).send(s);

//Button8
button8 = Button(window,Rect(550,120,200,30));
button8.states = [
			["11. For Long Tone On",Color.white,Color.fromHexString("#333366");],
			["For Long Tone Off",Color.black,Color.white],
			["Click to Reset",Color.white,Color.black]
			];
button8.action =
			{ arg butt;
				if (butt.value ==1,
					{object8 = Synth.before(mixerA,"Object8")});
				if (butt.value ==2,
					{object8.release(5)});
				if (butt.value ==3,
					nothing=1);
			};

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Object9 = Reverse (Good for speech) -- LOOPING REVERSE

SynthDef("Object9",{arg outlet1=101, gate =1,recstop=1;
			var playbuf,pshift,panstereo1,panstereo2,mix, env, envelop;

			RecordBuf.ar(In.ar(99,1), buffer5.bufnum, run:recstop);

			env = Env.new([ 0.0001, 0.3,0.7],[0.001,0.2], 'exponential' );
			envelop = EnvGen.kr(env,timeScale:10);

			playbuf = PlayBuf.ar(1,buffer5.bufnum,-1,loop:1);
			pshift = PitchShift.ar(playbuf,1.0,[0.7,0.6],envelop,0.5);
			panstereo1 = Pan2.ar(pshift.at(0),SinOsc.ar(5));
			panstereo1 = CombC.ar(panstereo1*0.5,2.0,1.5,0.2,add:panstereo1*0.8);
			panstereo2 = Pan2.ar(pshift.at(1),SinOsc.ar(7));
			panstereo2 = CombC.ar(panstereo2*0.5,2.0,1.88,0.4,add:panstereo2*0.8);
			mix =Mix.new([panstereo1,panstereo2]);
			Out.ar(outlet1, mix*EnvGen.kr(Env.asr(0.1, 0.8, 1.3), gate, doneAction:2));
			}).send(s);

//Button9
button9 = Button(window,Rect(550,160,200,30));
button9.states = [
			["12. Looping Reverse On",Color.white,Color.fromHexString("#333366");],
			["Looping Revers Loop",Color.black,Color.green],
			["Looping Revers Off",Color.black,Color.white],
			["Click to Reset",Color.white,Color.black]
			];
button9.action =
			{ arg butt;
				if (butt.value ==1,
					{object9 = Synth.before(mixerA,"Object9")});
				if (butt.value==2,
					{object9.set(\recstop,0)});
				if (butt.value ==3,
					{object9.release(8)});
				if (butt.value ==4,
					nothing=1);
			};

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Object11 = Large Grain With Env GRAINY HIGH SOUND

SynthDef("Object11",{arg  outlet1=101, gate =1;
			var playbuf,pshift,pshift2,panstereo,panstereo2, mix,env, envelop;

			env = Env.new([ 0.0001, 0.05,1.5],[0.0001,0.1], 'exponential' );
			envelop = EnvGen.kr(env,timeScale:8);

			playbuf = In.ar(99,1);
			pshift = PitchShift.ar(playbuf,0.1,2.0,1.3,0.1+envelop);
			pshift2 = PitchShift.ar(pshift,0.14,2.0,0.5,0.05);
			panstereo = Pan2.ar(pshift,SinOsc.ar(3));
			panstereo2 = Pan2.ar(pshift2,SinOsc.ar(2.7));

			mix = Mix.new([panstereo,panstereo2]);
			Out.ar(outlet1, 0.7*mix*EnvGen.kr(Env.asr(0.1, 0.8, 1.3), gate, doneAction:2));
			}).send(s);

//Button11
button11 = Button(window,Rect(300,200,200,30));
button11.states = [
			["8. Grainy SoundHigh On",Color.white,Color.fromHexString("#333366");],
			["Grainy SoundHigh Off",Color.black,Color.white],
			["Click to Reset",Color.white,Color.black]
			];
button11.action =
			{ arg butt;
				if (butt.value ==1,
					{object11 = Synth.before(mixerA,"Object11")});
				if (butt.value ==2,
					{object11.release(7)});
				if (butt.value ==3,
					nothing=1);
			};

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Object12 = Large Grain With Env -- GRAINY LOW SOUND

SynthDef("object12",{arg  outlet1=101, gate =1;
			var playbuf, pshift, pshift2, panstereo, panstereo2, mix, env, envelop;

			env = Env.new([ 0.0001, 0.05,1.5],[0.0001,0.1], 'exponential' );
			envelop = EnvGen.kr(env,timeScale:8);

			playbuf = In.ar(99,1);

			pshift = PitchShift.ar(playbuf,0.2,0.8,0.3,0.1+envelop);
			pshift2 = PitchShift.ar(pshift,0.24,1.0,0.5,0.05);
			panstereo = Pan2.ar(pshift,SinOsc.ar(3.3));
			panstereo2 = Pan2.ar(pshift2,SinOsc.ar(7.54));

			mix = Mix.new([panstereo,panstereo2]);
			Out.ar(outlet1, mix*EnvGen.kr(Env.asr(0.1, 0.8, 1.3), gate, doneAction:2));
			}).send(s);

//Button12
button12 = Button(window,Rect(300,240,200,30));
button12.states = [
			["9. Grainy SoundLow On",Color.white,Color.fromHexString("#333366");],
			["Grainy SoundLow Off",Color.black,Color.white],
			["Click to Reset",Color.white,Color.black]
			];
button12.action =
			{ arg butt;
				if (butt.value == 1, {object12 = Synth.before(mixerA,"object12")}, button12.value.postln);
				if (butt.value == 2, {object12.release(5)});
				if (butt.value == 3, nothing = 1);
			};


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Object13 = Pitch Shift With Env -- PITCH MODULATION ON

SynthDef("Object13",{arg  outlet1=101, gate =1;
			var playbuf, pshift, panstereo, env, envelop, lfo;

			playbuf = In.ar(99,1);

			lfo = SinOsc.ar(0.34,mul:0.7);
			pshift = PitchShift.ar(playbuf,0.1,1.3+lfo);

			panstereo = Pan2.ar(pshift, 0.0+(SinOsc.kr(2.3,mul:0.3)));
			Out.ar(outlet1, panstereo*EnvGen.kr(Env.asr(0.1, 0.8, 1.3), gate, doneAction:2));
			}).send(s);

//Button13
button13 = Button(window, Rect(550, 200, 200, 30));
button13.states = [
			["13. Pitch Modulation On",Color.white,Color.fromHexString("#333366");],
			["Pitch Modulation Off",Color.black,Color.white],
			["Click to Reset",Color.white,Color.black]
			];
button13.action =
			{ arg butt;
				if (butt.value ==1,
					{object13 = Synth.before(mixerA,"Object13")});
				if (butt.value ==2,
					{object13.release(2)});
				if (butt.value ==3,
					nothing=1);
			};


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Object 14 - Pitch Shifter from EWI Processing.scd file

SynthDef("Object14", {arg outlet1 = 101, gate = 1;
				var delay, verb, out, decimate, panstereo;
				a = SoundIn.ar([0,1,2,3,4,5]);
				b = PitchShift.ar(a, 3, 0.5, 4, 0.2, 0.5);
				c = PitchShift.ar(b, 0.7, 0.5, 0.5, 0.7, 0.5);

				//decimate = Decimator.ar([b,c], 4100, 0.7);


				out = Mix.ar([b, c]);
				verb = FreeVerb.ar(out, 0.3, 0.9, 0.2);
				//panstereo = Pan2.ar(out, 0.0+(SinOsc.kr(2.3,mul:0.3)));
				Out.ar([0,1,2,3,4,5], Pan2.ar(out + verb, 0));
			}).send(s);


//Button14
button14 = Button(window,Rect(550,300,200,30));
button14.states = [
			["14. New Pitch Shifter On",Color.white,Color.fromHexString("#336666");],
			["New Pitch Shifter Off",Color.black,Color.white],
			["Click to Reset",Color.white,Color.black]
			];
button14.action =
			{ arg butt;
				if (butt.value ==1,
					{object14 = Synth.before(mixerA,"Object14")}, button14.value.postln);
				if (butt.value ==2,
					{object14.release(2)});
				if (butt.value ==3,
					nothing=1);
			};

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Object 15 - little freqshift with shit ton of reverb

SynthDef("Object15", {arg outlet1 = 101, gate = 1;
	var in, fs, out;
	in = SoundIn.ar([0,1]);
	fs = FreqShift.ar(in, 200, 2);
	out = PitchShift.ar(in, 0.4, 1);
	Out.ar([0, 1, 2, 3], GVerb.ar(out, 50, 30));
			}).send(s);


//Button15
button15 = Button(window, Rect(550,340,200,30));
button15.states = [
			["15. FreqShit shit ton of verb On",Color.white,Color.fromHexString("#336666");],
			["FreqShit shit ton of verb Off",Color.black,Color.white],
			["Click to Reset",Color.white,Color.black]
			];
button15.action =
			{ arg butt;
				if (butt.value ==1,
					{object15 = Synth.before(mixerA,"Object15")});
				if (butt.value ==2,
					{object15.release(2)});
				if (butt.value ==3,
					nothing=1);
			};


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Object 16 - sparkly reverb
SynthDef("Object16", {arg dur = 100, midiRatio;
			var env, src, chain, ps, out, sound;
            env = EnvGen.kr(Env([0.01, 0.3, 0.5, 0], [0.01, 0.6, 0.2].normalizeSum, \sin), timeScale: dur);
			src = SoundIn.ar(1);
	        //c = Limiter.ar(src, 0.1, 0.5);
			chain = FFT(LocalBuf(2048), src);
            chain = PV_BinScramble(chain, 0.3, 0.7, 1);
			//chain = PV_SpectralEnhance(chain, 32, 2, 0.4);
	//chain = PV_MagFreeze(chain, LFPulse.kr(1, 0.75));
			//chain = PV_Compander(chain, 50, 0.5, 1);

	        ps = PitchShift.ar(src, 0.78, 2, 4, 5, 0.7);
			out = IFFT(chain);

	        //sound = Mix.ar(Mix.ar(sound));
			Out.ar(0, Pan4.ar(out, 0) + GVerb.ar(out, 150, 25, 0.05, 1, 25, 0.01, 0.2, 0.5, 1200) * env);
	        Out.ar(0, ps);
			}).send(s);


//Button16
button16 = Button(window, Rect(550,380,200,30));
button16.states = [
			["16. think of name here On",Color.white,Color.fromHexString("#336666");],
			["think of name here Off",Color.black,Color.white],
			["Click to Reset",Color.white,Color.black]
			];
button16.action =
			{ arg butt;
				if (butt.value ==1,
					{object16 = Synth.before(mixerA,"Object16")});
				if (butt.value ==2,
					{object16.release(2)});
				if (butt.value ==3,
					nothing=1);
			};



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Object 17 - Super sparkly

SynthDef("Object17", {arg dur = 10, midiRatio;
			var env, src, chain, ps, out, sound, fs;
env = EnvGen.kr(Env([0.01, 0.3, 0.5, 0], [0.01, 0.6, 0.2].normalizeSum, \sin), timeScale: dur);
			src = SoundIn.ar(1);
	        //c = Limiter.ar(src, 0.1, 0.5);
			chain = FFT(LocalBuf(2048), src);
            chain = PV_BinScramble(chain, 0.9, 0.2, 1);
			chain = PV_SpectralEnhance(chain, 8, 2, 0.1);
	       //chain = PV_MagFreeze(chain, LFPulse.kr(1, 0.75));


	        //ps = PitchShift.ar(src, 0.78, 2, 4, 5, 0.7);
	ps = PitchShift.ar(src, 0.4, 1);
	fs = FreqShift.ar(src, 200, 2);
			out = IFFT(chain);

	        //sound = Mix.ar(Mix.ar(sound));
	Out.ar(0, Pan4.ar(out, 0) + (out + fs + ps) * env + GVerb.ar(out, 50, 30));
	//Out.ar(0, ps+fs + Gverb.ar(out, 50, 20));
				}).send(s);


//Button17
button17 = Button(window, Rect(550,420,200,30));
button17.states = [
			["17. Super Sparkle On",Color.white,Color.fromHexString("#336666");],
			["Super Sparkle Off",Color.black,Color.white],
			["Click to Reset",Color.white,Color.black]
			];
button17.action =
			{ arg butt;
				if (butt.value ==1,
					{object17 = Synth.before(mixerA,"Object17")});
				if (butt.value ==2,
					{object17.release(2)});
				if (butt.value ==3,
					nothing=1);
			};


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Object 18 - Less sizzle more verb

SynthDef("Object18", {arg dur = 100, midiRatio;
			var env, src, chain, ps, out, sound;
            env = EnvGen.kr(Env([0.01, 0.3, 0.5, 0], [0.01, 0.6, 0.2].normalizeSum, \sin), timeScale: dur);
			src = SoundIn.ar(1);
	        //c = Limiter.ar(src, 0.1, 0.5);
			chain = FFT(LocalBuf(2048), src);
            //chain = PV_BinScramble(chain, 0.3, 0.7, 1);
			//chain = PV_SpectralEnhance(chain, 32, 2, 0.4);
	        chain = PV_MagFreeze(chain, LFPulse.kr(1, 0.75));
			//chain = PV_Compander(chain, 50, 0.5, 1);

	        ps = PitchShift.ar(src, 0.78, 2, 4, 5, 0.7);
			out = IFFT(chain);

	        //sound = Mix.ar(Mix.ar(sound));
			Out.ar(0, Pan4.ar(out, 0) + GVerb.ar(out, 150, 25, 0.05, 1, 25, 0.01, 0.2, 0.5, 1200) * env);
	        Out.ar(0, ps);
				}).send(s);


//Button18
button18 = Button(window, Rect(550, 460, 200, 30));
button18.states = [
			["18. Less Sizzle On",Color.white,Color.fromHexString("#336666");],
			["Less Sizzle Off",Color.black,Color.white],
			["Click to Reset",Color.white,Color.black]
			];
button18.action =
			{ arg butt;
				if (butt.value == 1,
					{object18 = Synth.before(mixerA,"Object18")});
				if (butt.value == 2,
					{object18.release(2)});
				if (butt.value == 3,
					nothing=1);
			};


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Object 19 - tinkle synth



tinkly = CtkSynthDef(\test, {arg dur;
		var sig, env;
		env = EnvGen.kr(Env([0, 0.6, 0], [0.0, 0.8].normalizeSum, \sin), timeScale: dur);
	    sig = {Mix.fill(64, {Resonz.ar(Dust2.ar (0.1.rand, 40, 9.9.rand), 9+99.rand.nthPrime * SinOsc.kr([0.7, 1.9] * 0.001).range([52, 2], [2, 15]), 0.0004, 10)})};
		Out.ar(0, Pan2.ar(sig * env))
	}).send(s);


//Button19
button19 = Button(window, Rect(40, 550, 200, 30));
button19.states = [
			["19. Tinkly On",Color.white,Color.fromHexString("#36454f");],
			["Tinkly Off",Color.black,Color.white],
			["Click to Reset",Color.white,Color.black]
			];
button19.action =
			{ arg butt;
				if (butt.value == 1,
					{object19 = Synth.before(mixerA,"Object19")};
					tinkly.note(0.1, 30).dur_(30).play);
				if (butt.value == 2,
					{object19.release(2)});
				if (butt.value == 3,
					nothing=1);
			};


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Object 20 - plucky Synth



pluckSynth = CtkSynthDef(\plucksynth, {arg beat = 1.0, dec = 1.0, pitch = 60, amp = 0.5;
	var sig, delay, trig, source, env, moveEnv, out, mix;
	env = EnvGen.kr(Env([0, 1, 0], [0.01, 10], \sin));
	moveEnv = EnvGen.kr(Env([-1, 0, 1, 0, -1, 0, 1], [0.2, 0.1, 0.4, 0.2, 0.4, 0.1], \lin));
	// calculate the delay time from MIDI pitch:
	delay = pitch.midicps.reciprocal;
	trig = Impulse.ar(beat);
	source = GrayNoise.ar(amp);
	sig = Decay2.ar(trig, 0.003, 0.05, source);
	// comb filter (delay with feedback) on the percussive signal:
	sig = CombL.ar(sig, 0.9, [delay, delay * 1.5], dec);//*********you can really change the tuning of the synth by changing the delay * number
	// remove the DC offset that comes from the comb:
	sig = LeakDC.ar(sig);
	mix = Mix(sig);
	Out.ar(0, Pan4.ar(mix, FSinOsc.kr(2), FSinOsc.kr(1.2)) * moveEnv + FreeVerb.ar(mix, 0.46, 20));
	});


// routine to create and play notes
pluckRoutine = Routine({
	30.do({arg i;
		pluckSynth.note(0.1, 20).beat_(0.4).dec_(10).pitch_([60, 60.1, 60.3, 61, 64, 65].choose).amp_(0.07).play;
		0.8.wait;
		pluckSynth.note(6, 20).beat_(0.2).dec_(10).pitch_([65, 67, 69].choose).amp_(0.07).play;
		1.3.wait;
		pluckSynth.note(10, 20).beat_(0.5.rand(1)).dec_(10).pitch_([70, 71, 72, 73, 74, 75].choose).amp_(0.07).play;
		2.4.wait;
		pluckSynth.note(15, 20).beat_(0.5.rand(1)).dec_(10).pitch_([73, 74, 75, 76, 77].choose).amp_(0.07).play;
		1.8.wait;
	})
});



//Button20
button20 = Button(window, Rect(40, 590, 200, 30));
button20.states = [
			["20. Plucky On",Color.white,Color.fromHexString("#36454f");],
			["Tinkly Off",Color.black,Color.white],
			["Click to Reset",Color.white,Color.black]
			];
button20.action =
			{ arg butt;
				if (butt.value == 1,
					{object20 = Synth.before(mixerA,"Object20")};
					pluckRoutine.play);
				if (butt.value == 2,
					{object20.release(2)});
				if (butt.value == 3,
					nothing=1);
			};


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MixerA

SynthDef("MixerA",{
			arg out = 0, micbal = 1.0, revbal = 0.0, mastervol = 1.0;
			var 	micin, inlet1, drymic, drymix, wetmix, mix, output;

			micin=In.ar(99,1);
			inlet1= In.ar (101,2);

			drymix = Mix.new([micin * micbal, inlet1 * 1.4]);
			wetmix = drymix;
			7.do({ wetmix = AllpassN.ar(wetmix, 0.043, [0.038.rand,0.036.rand], 3.5) });

			//drymic = AudioIn.ar(1)*micbal;

			output = Mix.new([wetmix*revbal,drymix*(1.0-revbal)]);
			output = HPF.ar(output, 150);

			Out.ar(out, output * mastervol)
		}).send(s);

//ButtonA
buttonA = Button(window,Rect(250, 20, 300, 30));
buttonA.states = [
			["Go!",Color.white,Color.fromHexString("336666")],
			["Stop!",Color.black,Color.white],
			["Click to Reset",Color.white,Color.black]
			];
buttonA.action =
			{ arg butt;
				if (butt.value ==1,
					{mixerA = Synth("MixerA");
					micbuffer = Synth("MicBuffer");
					//~network.sendMsg(\videoindex,2);~network.sendMsg(\texton,0);
					});
				if (butt.value ==2,
					{mixerA.free;
					//~network.sendMsg(\videoindex,0)
					});
				if (butt.value ==3,
					nothing=1);
			};



//Fader1
text1 = 	TextField(window,Rect(30,440,50,30));
text1.string = "Mic";

fader1 = Slider(window, Rect(40, 250, 34, 180));
fader1.action = { arg slider;
NodeControl(mixerA, 1).value = slider.value};

//Fader2
text2 = 	TextField(window,Rect(100,440,50,30));
text2.string = "Reverb";

fader2 = Slider(window, Rect(110, 250, 34, 180));
fader2.action = { arg slider;
NodeControl(mixerA, 2).value = slider.value};

//Fader3
text3 = 	TextField(window,Rect(170,440,50,30));
text3.string = "Master";

fader3 = Slider(window, Rect(180, 250, 34, 180));
fader3.action = { arg slider;
NodeControl(mixerA, 3).value = slider.value};

				});
			if (butt.value == 2,
				{
				"".postln
				});
			};

)