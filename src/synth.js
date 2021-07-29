const freqTransform = (value) => {
  return (value * 6000) + 60;
};

const identityTransform = (value) => {
  return value;
};

const carrierSpec = {
  freq: {
    inputPath: 'carrier.freq.value',
    transform: freqTransform
  },
  mul: {
    inputPath: 'carrier.mul',
    transform: identityTransform
  }
};

const modulatorSpec = {
  freq: {
    inputPath: 'modulator.freq.value',
    transform: freqTransform
  },
  mul: {
    inputPath: 'modulator.mul',
    transform: freqTransform
  }
};

class Synth {
  constructor(onListen) {
    this.synth = null;
    this.oscPort = new osc.WebSocketPort({
      url: 'ws://localhost:8081'
    });
    this.listen(onListen);
    this.oscPort.open();

    this.oscPort.socket.onmessage = (e) => {
      console.log('message', e);
    };

    this.valueMap = {
      '/knobs/0': carrierSpec.freq,
      '/fader1/out': carrierSpec.freq,

      '/knobs/1': carrierSpec.mul,
      '/fader2/out': carrierSpec.mul,

      '/knobs/2': modulatorSpec.freq,
      '/fader3/out': modulatorSpec.freq,

      '/knobs/3': modulatorSpec.mul,
      '/fader4/out': modulatorSpec.mul
    };
  }
  createSynth = () => {
    if (this.synth) {
      return;
    }

    this.synth = flock.synth({
      synthDef: {
        id: 'carrier',
        ugen: 'flock.ugen.sin',
        freq: {
          ugen: 'flock.ugen.value',
          rate: 'audio',
          value: 400,
          add: {
            id: 'modulator',
            ugen: 'flock.ugen.sin',
            freq: {
              ugen: 'flock.ugen.value',
              rate: 'audio',
              value: 124
            },
            mul: 100
          }
        },
        mul: 0.3
      }
    });
  };

  play = () => {
    this.synth.play();
  };

  pause =  () => {
    this.synth.pause();
  };

  mapMessage =  (oscMessage) => {
    $('#message').text(fluid.prettyPrintJSON(oscMessage));

    const address = oscMessage.address;
    const value = oscMessage.args[0];
    const transformSpec = this.valueMap[address];

    if (transformSpec) {
      const transformed = transformSpec.transform(value);
      this.synth.set(transformSpec.inputPath, transformed);
    }
  };

  listen = (onListen) => {
    var that = this;
    // TODO update button
    $('button').click(() => {
      that.createSynth();
      that.play();
    });

    this.oscPort.on('message', this.mapMessage);
    this.oscPort.on('message', (msg) => {
      onListen(msg);
    });
    this.oscPort.on('close', this.pause);
  };
}
export default Synth;
