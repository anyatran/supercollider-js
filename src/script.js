import './style.css'
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import * as dat from 'dat.gui'
import waterVertex from './shaders/water/vertex.glsl'
import waterFragment from './shaders/water/fragment.glsl'
import Synth from './synth.js'

/**
 * Base
 */
// Debug
const gui = new dat.GUI({ width: 340 })
const debugObj = {}

// Canvas
const canvas = document.querySelector('canvas.webgl')

// Scene
const scene = new THREE.Scene()

/**
 * Water
 */
// Geometry
const waterGeometry = new THREE.PlaneGeometry(2, 2, 512, 512)

// Color
debugObj.depthColor = '#186691'
debugObj.surfaceColor = '#9bd8ff'

// Material
const waterMaterial = new THREE.ShaderMaterial({
  vertexShader: waterVertex,
  fragmentShader: waterFragment,
  uniforms: {
    uTime: { value: 0 },
    uStartTime: { value: 0 },

    uBigWavesElevation: { value: 0.2 },
    uBigWavesSpeed: { value: 0.75 },
    uBigWavesFrequency: { value: new THREE.Vector2(4, 1.5) },

    uSmallWavesElevation: { value: 0.15 },
    uPrevSmallWavesElevation: { value: 0.15 },
    uSmallWavesSpeed: { value: 0.2 },
    uSmallWavesFrequency: { value: 3.0 },
    uSmallIterations: { value: 4.0 },

    uDepthColor: { value: new THREE.Color(debugObj.depthColor) },
    uSurfaceColor: { value: new THREE.Color(debugObj.surfaceColor) },
    uColorOffset: { value: 0.08 },
    uColorMultiplier: { value: 4 },
  }
})

// Debug
gui.add(waterMaterial.uniforms.uBigWavesElevation, 'value')
  .min(0)
  .max(1)
  .step(0.001)
  .name('uBigWavesElevation')

gui.add(waterMaterial.uniforms.uBigWavesSpeed, 'value')
  .min(0)
  .max(4)
  .step(0.001)
  .name('uBigWavesSpeed')

gui.add(waterMaterial.uniforms.uBigWavesFrequency.value, 'x')
  .min(0)
  .max(10)
  .step(0.001)
  .name('frequencyX')

gui.add(waterMaterial.uniforms.uBigWavesFrequency.value, 'y')
  .min(0)
  .max(10)
  .step(0.001)
  .name('frequencyY')

gui.add(waterMaterial.uniforms.uSmallWavesElevation, 'value')
  .min(0)
  .max(1)
  .step(0.001)
  .name('uSmallWavesElevation')

gui.add(waterMaterial.uniforms.uSmallWavesSpeed, 'value')
  .min(0)
  .max(4)
  .step(0.001)
  .name('uSmallWavesSpeed')

gui.add(waterMaterial.uniforms.uSmallWavesFrequency, 'value')
  .min(0)
  .max(30)
  .step(0.001)
  .name('uSmallWavesFrequency')

gui.add(waterMaterial.uniforms.uSmallIterations, 'value')
  .min(0)
  .max(5)
  .step(1)
  .name('uSmallIterations')


gui.add(waterMaterial.uniforms.uColorOffset, 'value')
  .min(0)
  .max(1)
  .step(0.001)
  .name('uColorOffset')

gui.add(waterMaterial.uniforms.uColorMultiplier, 'value')
  .min(0)
  .max(10)
  .step(0.001)
  .name('uColorMultiplier')

gui.addColor(debugObj, 'depthColor')
  .name('depthColor')
  .onChange(() => { waterMaterial.uniforms.uDepthColor.value.set(debugObj.depthColor) })

gui.addColor(debugObj, 'surfaceColor')
  .name('surfaceColor')
  .onChange(() => { waterMaterial.uniforms.uSurfaceColor.value.set(debugObj.surfaceColor) })

// Mesh
const water = new THREE.Mesh(waterGeometry, waterMaterial)
water.rotation.x = - Math.PI * 0.5
scene.add(water)

/**
 * Sizes
 */
const sizes = {
  width: window.innerWidth,
  height: window.innerHeight
}

window.addEventListener('resize', () => {
  // Update sizes
  sizes.width = window.innerWidth
  sizes.height = window.innerHeight

  // Update camera
  camera.aspect = sizes.width / sizes.height
  camera.updateProjectionMatrix()

  // Update renderer
  renderer.setSize(sizes.width, sizes.height)
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
})

/**
 * Camera
 */
// Base camera
const camera = new THREE.PerspectiveCamera(75, sizes.width / sizes.height, 0.1, 100)
camera.position.set(1, 1, 1)
scene.add(camera)

// Controls
const controls = new OrbitControls(camera, canvas)
controls.enableDamping = true

/**
 * Renderer
 */
const renderer = new THREE.WebGLRenderer({
  canvas: canvas
})
renderer.setSize(sizes.width, sizes.height)
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))

/**
 * Animate
 */
const clock = new THREE.Clock()

const tick = () => {
  const elapsedTime = clock.getElapsedTime()

  // Update time
  waterMaterial.uniforms.uTime.value = elapsedTime;
  // Update controls
  controls.update()

  // Render
  renderer.render(scene, camera)

  // Call tick again on the next frame
  window.requestAnimationFrame(tick)
}

tick()

// Serialize synth data
// const serialize = (msg) => {
//   const {address, args} = msg
//   if (address.includes('bell_1')) {

//   }

// }
// Synth events
const onListen = (msg) => {
  console.log('message', msg);
  const { address, args } = msg
  if (address.includes('bell_2')) {
    const freq = args[1]
    const elevation = (Math.log(freq) / Math.log(2) - 8) / 3
    // TODO figure out elnvelope
    // TODO figure out the time
    waterMaterial.uniforms.uStartTime.value = clock.getElapsedTime()
    waterMaterial.uniforms.uPrevSmallWavesElevation.value = waterMaterial.uniforms.uSmallWavesElevation.value
    waterMaterial.uniforms.uSmallWavesElevation.value = elevation
    console.log({uStartTime: waterMaterial.uniforms.uStartTime.value, 
      uTime: waterMaterial.uniforms.uTime.value});
  }
}
// Loading synth
const synth = new Synth(onListen)
