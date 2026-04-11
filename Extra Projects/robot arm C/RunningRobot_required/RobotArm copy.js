/*
 * Course: CS 4722
 * Section: .....
 * Name: ......
 * Professor: ......
 * Assignment #: Module #8, Assignment #1
 */

"use strict";

var canvas;
var gl;

var NumVertices = 36;

var points = [];
var colors = [];

var vertices = [
    vec4(-0.5, -0.5, 0.5, 1.0),
    vec4(-0.5, 0.5, 0.5, 1.0),
    vec4(0.5, 0.5, 0.5, 1.0),
    vec4(0.5, -0.5, 0.5, 1.0),
    vec4(-0.5, -0.5, -0.5, 1.0),
    vec4(-0.5, 0.5, -0.5, 1.0),
    vec4(0.5, 0.5, -0.5, 1.0),
    vec4(0.5, -0.5, -0.5, 1.0)
];

// RGBA colors
var vertexColors = [
    vec4(0.0, 1.0, 0.0, 1.0),  // green
    vec4(0.0, 0.0, 0.0, 1.0),  // black
    vec4(0.0, 0.0, 1.0, 1.0),  // blue
    vec4(1.0, 0.0, 0.0, 1.0),  // red
    vec4(1.0, 1.0, 0.0, 1.0),  // yellow
    vec4(1.0, 1.0, 1.0, 1.0),  // white
    vec4(1.0, 0.0, 1.0, 1.0),  // magenta
    vec4(0.0, 1.0, 1.0, 1.0)   // cyan
];

// New constants for the robot arm
const ARM1_HEIGHT = 2.5;
const ARM1_WIDTH = 1.5;
const ARM2_HEIGHT = 2.5;
const ARM2_WIDTH = 1.5;
const ARM3_HEIGHT = 2.5;
const ARM3_WIDTH = 1.5;
const ARM4_HEIGHT = 2.5;
const ARM4_WIDTH1 = 0.5;
const ARM4_WIDTH2 = 1.7;

const redColor = vec4(1, 0, 0, 1);
const blueColor = vec4(0, 1, 0, 1);
const greenColor = vec4(0, 0, 1, 1);
const yellowColor = vec4(1, 1, 0, 1);
var drawColorLoc;

const arm1Theta = 0;
const arm2Theta = 1;
const arm3Theta = 2;
var arm4Scale = 1;

var yOff = 0.0;
var xOff = 0.0;

var isOrtho = true;
var fovy = 140;
var up = vec3(0.0, 1.0, 0.0);
var at = vec3(0.0, 0.0, 0.0);
var eye = vec3(0.0, 0.0, 0.0);

var near = 0.1;
var far = 40;
var left = -10;
var right = 10;
var ytop = 10;
var bottom = -10;
var radius = 4;

var projectionLoc;
var cameraMode = false;
var phi = 0;

// Shader transformation matrices
var modelViewMatrix, projectionMatrix;

// Array of rotation angles (in degrees) for each rotation axis
var theta = [0, 0, 0];

var angle = 0;

var modelViewMatrixLoc;

var vBuffer, cBuffer;

window.onload = function init() {

    canvas = document.getElementById("gl-canvas");

    gl = canvas.getContext( 'webgl2', {} );
    if ( !gl ) { alert( "WEBGL2 is not available" ); }

    gl.viewport(0, 0, canvas.width, canvas.height);

    gl.clearColor(1.0, 1.0, 1.0, 1.0);
    gl.enable(gl.DEPTH_TEST);

    //
    //  Load shaders and initialize attribute buffers
    //
    let program = initShaders(gl, "vertex-shader", "fragment-shader");
    gl.useProgram(program);

    colorCube();

    // Load shaders and use the resulting shader program

    program = initShaders(gl, "vertex-shader", "fragment-shader");
    gl.useProgram(program);

    // Create and initialize  buffer objects

    vBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, vBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, flatten(points), gl.STATIC_DRAW);

    let vPosition = gl.getAttribLocation(program, "vPosition");
    gl.vertexAttribPointer(vPosition, 4, gl.FLOAT, false, 0, 0);
    gl.enableVertexAttribArray(vPosition);

    cBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, cBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, flatten(colors), gl.STATIC_DRAW);

    let vColor = gl.getAttribLocation(program, "vColor");
    gl.vertexAttribPointer(vColor, 4, gl.FLOAT, false, 0, 0);
    gl.enableVertexAttribArray(vColor);

    modelViewMatrixLoc = gl.getUniformLocation(program, "modelViewMatrix");

    projectionMatrix = ortho(-10, 10, -10, 10, -10, 10);
    projectionLoc = gl.getUniformLocation(program, "projectionMatrix");
    gl.uniformMatrix4fv(projectionLoc, false, flatten(projectionMatrix));

    drawColorLoc = gl.getUniformLocation(program, "drawColor");

    document.addEventListener("keydown",
      function (event) {
          let keyCode = 0;
          if (event.key != null && event.key.length > 0) {
              switch (event.key) {
                  case "ArrowLeft": keyCode = 37; break;
                  case "ArrowUp": keyCode = 38; break;
                  case "ArrowRight": keyCode = 39; break;
                  case "ArrowDown": keyCode = 40; break;
                  case "PageUp": keyCode = 33; break;
                  case "PageDown": keyCode = 34; break;
                  default:
                      keyCode = (event.key.length > 1) ?  0 :
                          event.key.toUpperCase().charCodeAt(0);
              }
          }

          if (keyCode == 81) {   // Q
              theta[arm1Theta] -= 5;
          }
          if (keyCode == 87) {   // W
              theta[arm1Theta] += 5;
          }

          if (keyCode == 65) {   // A
              theta[arm2Theta] -= 5;
              if (theta[arm2Theta] < -45) theta[arm2Theta] = -45;
          }
          if (keyCode == 83) {   // S
              theta[arm2Theta] += 5;
              if (theta[arm2Theta] > 45) theta[arm2Theta] = 45;
          }

          if (keyCode == 90) {   // Z
              theta[arm3Theta] -= 5;
              if (theta[arm3Theta] < -45) theta[arm3Theta] = -45;
          }
          if (keyCode == 88) {   // X
              theta[arm3Theta] += 5;
              if (theta[arm3Theta] > 45) theta[arm3Theta] = 45;
          }

          if (keyCode == 68) {   // D
              yOff -= 0.5;
          }
          if (keyCode == 69) {   // E
              yOff += 0.5;
          }

          if (keyCode == 82) {   // R
              xOff -= 0.5;
          }
          if (keyCode == 84) {   // T
              xOff += 0.5;
          }

          if (keyCode == 72) {   // H
              if (arm4Scale == 1) {
                  arm4Scale = ARM4_WIDTH2 / ARM4_WIDTH1;
              } else {
                  arm4Scale = 1;
              }
          }

          if (keyCode == 80) {   // P
              isOrtho = !isOrtho;
          }

          if (keyCode == 77) {   // M
              cameraMode = !cameraMode;
              if (cameraMode) {
                  // First person mode - looking down at arm
                  radius = 0.1;
                  phi = 89 * Math.PI / 180;  // Almost straight down
                  up = vec3(0.0, 0.0, -1.0);
              } else {
                  // Third person mode - default view
                  radius = 4;
                  phi = 0;
                  up = vec3(0.0, 1.0, 0.0);
              }
          }

          if (keyCode == 37) {   // Left Arrow
              angle -= 0.1;
          }

          if (keyCode == 39) {   // Right Arrow
              angle += 0.1;
          }

          if (keyCode == 38) {   // Up Arrow
              if (!cameraMode) {  // Only zoom in 3rd person mode
                  radius -= 0.5;
                  if (radius < 0.5) radius = 0.5;
              }
          }

          if (keyCode == 40) {   // Down Arrow
              if (!cameraMode) {  // Only zoom in 3rd person mode
                  radius += 0.5;
                  if (radius > 20) radius = 20;
              }
          }

      }, false);

    render();
}

function quad(a, b, c, d) {
    colors.push(vertexColors[c]);
    points.push(vertices[a]);
    colors.push(vertexColors[c]);
    points.push(vertices[b]);
    colors.push(vertexColors[c]);
    points.push(vertices[c]);
    colors.push(vertexColors[c]);
    points.push(vertices[a]);
    colors.push(vertexColors[c]);
    points.push(vertices[c]);
    colors.push(vertexColors[c]);
    points.push(vertices[d]);
}

function colorCube() {
    quad(1, 0, 3, 2);
    quad(2, 3, 7, 6);
    quad(3, 0, 4, 7);
    quad(5, 1, 2, 6);
    quad(4, 5, 6, 7);
    quad(5, 4, 0, 1);
}

function arm1() {
    let s = scalem(ARM1_WIDTH, ARM1_HEIGHT, ARM1_WIDTH);
    let instanceMatrix = mult(translate(0.0, 0.5 * -ARM1_HEIGHT, 0.0), s);
    let t = mult(modelViewMatrix, instanceMatrix);
    gl.uniformMatrix4fv(modelViewMatrixLoc, false, flatten(t));
    gl.drawArrays(gl.TRIANGLES, 0, NumVertices);
}

function arm2() {
    let s = scalem(ARM2_WIDTH, ARM2_HEIGHT, ARM2_WIDTH);
    let instanceMatrix = mult(translate(0.0, 0.5 * -ARM2_HEIGHT, 0.0), s);
    let t = mult(modelViewMatrix, instanceMatrix);
    gl.uniformMatrix4fv(modelViewMatrixLoc, false, flatten(t));
    gl.drawArrays(gl.TRIANGLES, 0, NumVertices);
}

function arm3() {
    let s = scalem(ARM3_WIDTH, ARM3_HEIGHT, ARM3_WIDTH);
    let instanceMatrix = mult(translate(0.0, 0.5 * -ARM3_HEIGHT, 0.0), s);
    let t = mult(modelViewMatrix, instanceMatrix);
    gl.uniformMatrix4fv(modelViewMatrixLoc, false, flatten(t));
    gl.drawArrays(gl.TRIANGLES, 0, NumVertices);
}

function arm4() {
    let s = scalem(ARM4_WIDTH1, ARM4_HEIGHT, ARM4_WIDTH2);
    let instanceMatrix = mult(translate(0.0, 0.5 * -ARM4_HEIGHT, 0.0), s);
    let t = mult(modelViewMatrix, instanceMatrix);
    gl.uniformMatrix4fv(modelViewMatrixLoc, false, flatten(t));
    gl.drawArrays(gl.TRIANGLES, 0, NumVertices);
}

function render() {
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

    eye = vec3(radius * Math.sin(angle) * Math.cos(phi),
                radius * Math.sin(phi),
                 radius * Math.cos(angle) * Math.cos(phi));

    if (isOrtho) {
        projectionMatrix = ortho(left, right, bottom, ytop, near, far);
    } else {
        projectionMatrix = perspective(fovy, 1.0, near, far);
    }

    gl.uniformMatrix4fv(projectionLoc, false, flatten(projectionMatrix));

    modelViewMatrix = lookAt(eye, at, up);

    gl.uniform4fv(drawColorLoc, redColor);
    modelViewMatrix = mult(modelViewMatrix, translate(xOff, yOff, 0.0));
    modelViewMatrix = mult(modelViewMatrix, rotate(theta[arm1Theta], 0, 0, 1));
    arm1();

    gl.uniform4fv(drawColorLoc, greenColor);
    modelViewMatrix = mult(modelViewMatrix, translate(0.0, -ARM1_HEIGHT, 0.0));
    modelViewMatrix = mult(modelViewMatrix, rotate(theta[arm2Theta], 0, 0, 1));
    arm2();

    gl.uniform4fv(drawColorLoc, blueColor);
    modelViewMatrix = mult(modelViewMatrix, translate(0.0, -ARM2_HEIGHT, 0.0));
    modelViewMatrix = mult(modelViewMatrix, rotate(theta[arm3Theta], 0, 0, 1));
    arm3();

    gl.uniform4fv(drawColorLoc, yellowColor);
    modelViewMatrix = mult(modelViewMatrix, translate(0.0, -ARM3_HEIGHT / 2, 0.0));
    modelViewMatrix = mult(modelViewMatrix, scalem(arm4Scale, 1, 1));
    arm4();

    requestAnimFrame(render);
}