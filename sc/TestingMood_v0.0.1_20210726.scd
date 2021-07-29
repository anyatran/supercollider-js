////// 0
(
~targetAddress = NetAddr("127.0.0.1", 1234);  // Change port 1234 to the one of the target application
~baseMessage = "/fromSuperCollider/";

GlobalParams.setSeedSafe(1923);  // Change this number to randomize the path
GlobalParams.makeLinkClock(1.2);  // Tempo in beats per second (change live with GlobalParams.linkClock.tempo = 1.5)

~basefreq = 40.midicps*2; // 40=E2
)

////// 1
(  // Sending the definition of each instrument to the server
SynthDef(\prayer_bell_in, { |out, t_trig = 1, sing_switch = 0, in, in_amp_mallet = 0, in_amp_sing = 0, freq = 2434, amp = 0.5, hold_target = 1, startdecay = 100, sing_forever = 0, decayscale = 1, lag = 10, i_doneAction = 0|
  var sig, input, first, freqscale, mallet, sing, trig, sing_env, delayed_sing_env, decay_time, in_sound, in_sound_trig, in_trig;
  freqscale = freq / 2434;
  freqscale = Lag3.kr(freqscale, lag);
  decayscale = Lag3.kr(decayscale, lag);

	trig = Trig.ar(t_trig, SampleDur.ir);
	in_sound = In.ar(in);
	decay_time = startdecay.pow(0.6)*decayscale.pow(0.3);
	sing_env = EnvGen.kr(Env(levels: [1, hold_target, 0], times: [startdecay, decay_time], curve: \sin), gate: trig) - 1 + Latch.kr(1, trig) + sing_forever;
	delayed_sing_env = EnvGen.kr(Env(levels: [0.5, 1, hold_target, 0], times: [decay_time/2, startdecay, decay_time], curve: \sin), gate: trig) - 0.5 + Latch.kr(0.5, trig) + sing_forever;

	in_sound_trig = in_sound.abs;
	in_trig = Trig.ar(OnePole.ar(in_sound_trig, (0.8.pow(GlobalParams.refSampleRate / SampleRate.ir))*LFNoise1.kr(Rand(0.1,0.2)).abs) - (3*OnePole.ar(in_sound_trig, 0.9999.pow(GlobalParams.refSampleRate / SampleRate.ir))), SampleDur.ir);
	mallet = LPF.ar((trig + (in_amp_mallet*in_trig*sing_env))!2, 10000 * freqscale);

  sing = LPF.ar(
    LPF.ar(
      {
				(PinkNoise.ar * Integrator.kr(sing_switch * sing_env * 0.001, 0.999).linexp(0, 1, 0.01, 1) * amp)
      } ! 2,
      2434 * freqscale
		) + Dust.ar(0.1/sing_env.clip(0.01, 1))+ (in_amp_sing*in_sound), 10000 * freqscale
	) * LFNoise1.kr(Rand(0.4,0.6)/delayed_sing_env).range(-45, -30).dbamp;
	input = mallet + (sing_switch.clip(0, 1) * sing * delayed_sing_env);


  sig = DynKlank.ar(`[
    [
      (first = LFNoise1.kr(0.5).range(2424, 2444)) + Line.kr(20, 0, 0.5),
      first + LFNoise1.kr(0.5).range(1,3),
      LFNoise1.kr(1.5).range(5435, 5440) - Line.kr(35, 0, 1),
      LFNoise1.kr(1.5).range(5480, 5485) - Line.kr(10, 0, 0.5),
      LFNoise1.kr(2).range(8435, 8445) + Line.kr(15, 0, 0.05),
      LFNoise1.kr(2).range(8665, 8670),
      LFNoise1.kr(2).range(8704, 8709),
      LFNoise1.kr(2).range(8807, 8817),
      LFNoise1.kr(2).range(9570, 9607),
      LFNoise1.kr(2).range(10567, 10572) - Line.kr(20, 0, 0.05),
      LFNoise1.kr(2).range(10627, 10636) + Line.kr(35, 0, 0.05),
      LFNoise1.kr(2).range(14689, 14697) - Line.kr(10, 0, 0.05)
    ],
    [
      LFNoise1.kr(1).range(-10, -5).dbamp,
      LFNoise1.kr(1).range(-20, -10).dbamp,
      LFNoise1.kr(1).range(-12, -6).dbamp,
      LFNoise1.kr(1).range(-12, -6).dbamp,
      -20.dbamp,
      -20.dbamp,
      -20.dbamp,
      -25.dbamp,
      -10.dbamp,
      -20.dbamp,
      -20.dbamp,
      -25.dbamp
    ],
    ([
      20 * freqscale.pow(0.2),
      20 * freqscale.pow(0.2),
      5,
      5,
      0.6,
      0.5,
      0.3,
      0.25,
      0.4,
      0.5,
      0.4,
      0.6
		] * freqscale.reciprocal.pow(0.5))
  ], input, freqscale, 0, decayscale) * (GlobalParams.refSampleRate / SampleRate.ir); //TODO: have a class with global info like default SR
	DetectSilence.ar(Impulse.ar(0) + sig, doneAction: i_doneAction);
  Out.ar(out, sig);
}).add;

SynthDef(\prayer_bell, { |outbus, t_trig = 1, sing_switch = 0, freq = 2434, amp = 0.5, hold_target = 1, startdecay = 100, sing_forever = 0, decayscale = 1, lag = 10, i_doneAction = 0|
  var sig, input, first, freqscale, mallet, sing, trig, sing_env;
  freqscale = freq / 2434;
  freqscale = Lag3.kr(freqscale, lag);
  decayscale = Lag3.kr(decayscale, lag);

	trig = Trig.ar(t_trig, SampleDur.ir);
  mallet = LPF.ar(trig!2, 10000 * freqscale);
	sing_env =EnvGen.kr(Env(levels: [1, hold_target, 0], times: [startdecay, startdecay.pow(0.5)*decayscale.pow(0.3)], curve: \sin), gate: trig) - 1 + Latch.kr(1, trig) + sing_forever;
  sing = LPF.ar(
    LPF.ar(
      {
				PinkNoise.ar * Integrator.kr(sing_switch * sing_env * 0.001, 0.999).linexp(0, 1, 0.01, 1) * amp
      } ! 2,
      2434 * freqscale
		) + Dust.ar(0.1/sing_env.clip(0.01, 1)), 10000 * freqscale
  ) * LFNoise1.kr(0.5).range(-45, -30).dbamp;
	input = mallet + (sing_switch.clip(0, 1) * sing * sing_env.clip(0, 0.01) * 100);


  sig = DynKlank.ar(`[
    [
      (first = LFNoise1.kr(0.5).range(2424, 2444)) + Line.kr(20, 0, 0.5),
      first + LFNoise1.kr(0.5).range(1,3),
      LFNoise1.kr(1.5).range(5435, 5440) - Line.kr(35, 0, 1),
      LFNoise1.kr(1.5).range(5480, 5485) - Line.kr(10, 0, 0.5),
      LFNoise1.kr(2).range(8435, 8445) + Line.kr(15, 0, 0.05),
      LFNoise1.kr(2).range(8665, 8670),
      LFNoise1.kr(2).range(8704, 8709),
      LFNoise1.kr(2).range(8807, 8817),
      LFNoise1.kr(2).range(9570, 9607),
      LFNoise1.kr(2).range(10567, 10572) - Line.kr(20, 0, 0.05),
      LFNoise1.kr(2).range(10627, 10636) + Line.kr(35, 0, 0.05),
      LFNoise1.kr(2).range(14689, 14697) - Line.kr(10, 0, 0.05)
    ],
    [
      LFNoise1.kr(1).range(-10, -5).dbamp,
      LFNoise1.kr(1).range(-20, -10).dbamp,
      LFNoise1.kr(1).range(-12, -6).dbamp,
      LFNoise1.kr(1).range(-12, -6).dbamp,
      -20.dbamp,
      -20.dbamp,
      -20.dbamp,
      -25.dbamp,
      -10.dbamp,
      -20.dbamp,
      -20.dbamp,
      -25.dbamp
    ],
    ([
      20 * freqscale.pow(0.2),
      20 * freqscale.pow(0.2),
      5,
      5,
      0.6,
      0.5,
      0.3,
      0.25,
      0.4,
      0.5,
      0.4,
      0.6
		] * freqscale.reciprocal.pow(0.5))
  ], input, freqscale, 0, decayscale) * (GlobalParams.refSampleRate / SampleRate.ir);
	DetectSilence.ar(Impulse.ar(0) + sig, doneAction: i_doneAction);
  Out.ar(outbus, sig);
}).add;

SynthDef("rain_and_thunder_v1.0", {|out, out2, amp = 0.1, amp2 = 0.5, dustfactor=1|
	var sig, dust;
	dust = LPF.ar(dustfactor.pow(0.75)*Dust2.ar(dustfactor*LFNoise1.kr(0.2).range(40,50)),7000*LFNoise1.kr(dustfactor*0.61).range(0.7, 1.6));
    sig = Limiter.ar(
        tanh(
            3 * GVerb.ar(
                HPF.ar(
					PinkNoise.ar(dustfactor.sqrt*(0.08+LFNoise1.kr(0.3,0.02))) + dust,
					400
                ),
                250,100,0.25,drylevel:0.3
            ) * Line.kr(0,1,10)
        ) + (
            GVerb.ar(
                LPF.ar(
                    10 * HPF.ar(PinkNoise.ar(LFNoise1.kr(3).clip(0,1)*LFNoise1.kr(2).clip(0,1) ** 1.8), 20)
                    ,LFNoise1.kr(1).exprange(100,2500)
                ).tanh,
               270,30,0.7,drylevel:0.5
            ) * Line.kr(0,0.7,30/dustfactor)
        )
    );
	Out.ar(out, dust*amp);
	Out.ar(out2, (sig * amp2)!2);  // Stereoize this sound
}).add;
)

////// 2
(  // Organisation of sound elements and useful functions
~bell_group = Group.new(s);
~rnt_bus = Bus.audio(s);

~fade_val = {|synth, param, endVal, dur=10, clock|
Routine({
	var curVal;
	var numSteps = 1000;
	synth.get(param.asSymbol, {|val| curVal = val});
	0.5.wait;
	for(1, numSteps, {|i|
		synth.set(param.asSymbol, curVal + (i/numSteps*(endVal - curVal)));
		(dur/numSteps).wait;
	});}).play(clock);
};

~oscTransmitter =
	Pfunc({|ev|
		var oscArray = [~baseMessage ++ (ev.id ?? '') ];

		// Construct the osc array from the Pbind's keys
		ev.keysValuesDo{|k,v|
			// Filter out the 'destination' and 'id' keys
			(k != 'destination' and: {k != 'id'}).if{
				oscArray = oscArray ++ k ++ [v];
			}
		};

		// And send
	//ev.destination.sendMsg(oscArray)
	ev.destination.sendBundle(~latency, oscArray)
	});
)

////// 3
(  // Defining the patterns making the notes
Pdef(\bell_1,
  Pbind(\instrument, \prayer_bell_in,
		\dur, Pseq([8, 20], inf),
		\decayscale, Pkey(\dur).pow(0.25)/2,
		\startdecay, Pkey(\dur)/2,
		\freq, Pseq([125/6*~basefreq, 175/24*~basefreq, 5*7/11*~basefreq], inf) + Pwhite(-30, 30),
		\hold_target, Pwhite(0.7, 0.97),
		\amp, 0.1,
		\lag, 0,
		\trig, Pseq([0.1], inf) * Pwhite(0.5, 1, inf) * Pwrand([0, 1], [1, 5].normalizeSum, inf),
		\sing_switch, Pseq(([0,1]!2).flatten ++ ([0,1,0]!2).flatten, inf)*0.5,
		\doneAction, 2,
		\group, ~bell_group,
		\in, ~rnt_bus,
		\in_amp_mallet, 0.5,
		\in_amp_sing, 0,
		\destination, ~targetAddress,
		\id, 'bell_1',
		\sendOSC, ~oscTransmitter,
  )
);

Pdef(\bell_2,
  Pbind(\instrument, \prayer_bell_in,
		\dur, Pwhite(8, 20, inf),
		\decayscale, Pkey(\dur).sqrt/4,
		\freq, Prand((2, 3 .. 16)*~basefreq, inf),
		\startdecay, Pkey(\dur)*Pkey(\freq).sqrt/19,
		\hold_target, Pwhite(0.9, 0.99),
		\trig, Pwhite(0.05, 0.09),
		\sing_switch, Pwrand([0, 1], [5, 3].normalizeSum, inf),
		\amp, 0.1,
		\doneAction, 2,
		\group, ~bell_group,
		\in, ~rnt_bus,
		\in_amp_mallet, 1,
		\in_amp_sing, 0,
		\destination, ~targetAddress,
		\id, 'bell_2',
		\sendOSC, ~oscTransmitter,
  )
);

Pdef(\bell_3,
  Ppar([
    Pmono(\prayer_bell,
      \freq, ~basefreq,
      \dur, 1,
      \trig, 0,
	\sing_forever, 1,
      \sing_switch, Pwrand([0, 1], [10, 3].normalizeSum, inf),
      \amp, Pwhite(0.1, 0.5),
		\group, ~bell_group,
    ),
    Pmono(\prayer_bell,
			\freq, ~basefreq/2 + Pgbrown(-1*~basefreq/40, ~basefreq/40, step: 0.01),
      \dur, 1,
      \trig, 0,
	\sing_forever, 1,
      \sing_switch, Pwrand([0, 1], [10, 3].normalizeSum, inf),
      \amp, Pwhite(0.1, 0.5),
		\group, ~bell_group,
    ),
    Pmono(\prayer_bell,
      \freq, ~basefreq/4,
      \dur, 1,
      \trig, 0,
	\sing_forever, 1,
      \sing_switch, Pwrand([0, 1], [10, 3].normalizeSum, inf),
      \amp, Pwhite(0.1, 0.5),
		\group, ~bell_group,
    )
  ])
);
)

////// 4
(  // These routines start and stop the sounds and send OSC value messages
~make_storm = {~rnt ?? {~rnt = Synth.before(~bell_group, "rain_and_thunder_v1.0", [out: ~rnt_bus, out2:0, amp:0, amp2:0, dustfactor:0])}};
~free_storm = {~rnt.free};

~mood_start = Routine({
	~targetAddress.sendMsg("/fromSuperCollider/run_bell_1/", 1);
	Pdef(\bell_1).play;
	8.wait;
	~targetAddress.sendMsg("/fromSuperCollider/run_bell_2/", 1);
	Pdef(\bell_2).play;
	4.wait;
	~make_storm.value;
	7.wait;
	~targetAddress.sendMsg("/fromSuperCollider/amp_rain_thunder/", 0.2);  // Remark that these values are only reached after the time the message is sent, but this can be fixed
	~fade_val.value(~rnt, \amp2, 0.2, 30, GlobalParams.linkClock);
	21.wait;
	~targetAddress.sendMsg("/fromSuperCollider/rain_factor/", 0.02);
	~fade_val.value(~rnt, \dustfactor, 0.02, 30, GlobalParams.linkClock);
	20.wait;
	~targetAddress.sendMsg("/fromSuperCollider/rain_hits_bells/", 0.8);
	~fade_val.value(~rnt, \amp, 0.8, 130, GlobalParams.linkClock);
	30.wait;
	~targetAddress.sendMsg("/fromSuperCollider/rain_factor/", 0.7);
	~fade_val.value(~rnt, \dustfactor, 0.7, 107, GlobalParams.linkClock);
	20.wait;
	~targetAddress.sendMsg("/fromSuperCollider/run_bell_3/", 1);  // Same, this is often not synchronized because of the quant argument (starts 1st beat of 4/4 bar)
	Pdef(\bell_3).play(GlobalParams.linkClock, quant: 4);
	180.wait;
	loop {
		var rand_beats = 90.rand;
		var rand_rain_factor = 1.2.rand;
		~targetAddress.sendMsg("/fromSuperCollider/rain_factor/", rand_rain_factor);
		~fade_val.value(~rnt, \dustfactor, rand_rain_factor, rand_beats*(0.5 + 0.25.rand), GlobalParams.linkClock);
		Pbindef(\bell_1, \hold_target, (0.2 + rand_rain_factor)*Pwhite(0.7, 0.97));
		Pbindef(\bell_2, \in_amp_mallet, 1/(0.2 + rand_rain_factor));
		rand_beats.wait;
	};
});

~mood_stop = Routine({
	~mood_start.stop;
	~fade_val.value(~rnt, \dustfactor, 0, 20, GlobalParams.linkClock);
	11.wait;
	~fade_val.value(~rnt, \amp, 0, 10, GlobalParams.linkClock);
	~fade_val.value(~rnt, \amp2, 0, 20, GlobalParams.linkClock);
	10.wait;
	Pbindef(\bell_3, \amp, 0.05);
	5.wait;
	Pbindef(\bell_3, \amp, 0.01);
	10.wait;
	Pdef(\bell_1).stop;
	Pdef(\bell_2).stop;
	Pdef(\bell_3).stop;
});
)
~mood_start.play(GlobalParams.linkClock, quant: 4);
// Increase volume by clicking on the green numbers down-right

~mood_stop.play(GlobalParams.linkClock, quant: 4);
~free_storm.value;
// To continue running properly, call Pattern block (#3) again

