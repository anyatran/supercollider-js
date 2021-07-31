# Threejs client

## Run Threejs
``` bash
# Install dependencies (only the first time)
npm install

# Run the local server at localhost:8080
npm run dev

# Build for production in the dist/ directory
npm run build

# Rebuild dist when save
npm run build.watch
```

## Run SC UDP server
[example here](https://github.com/colinbdclark/osc.js-examples/tree/master/browser)
* Install dependencies in web as well
``` bash
cd ./web && npm install
```
* Run node . in the Terminal
* Open http://localhost:8081 in your browser
* Control the synth using OSC messages sent from Lemur or another OSC server
