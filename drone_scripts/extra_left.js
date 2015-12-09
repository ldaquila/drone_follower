/**
 * Take off, go left, land.
 */
'use strict';

var Drone = require('../');
var temporal = require('temporal');
var d = new Drone(process.env.UUID);
console.log('Trying to connect to drone');
d.connect(function () {
  d.setup(function () {
    d.flatTrim();
    d.startPing();
    d.flatTrim();
    console.log('Connected to drone', d.name);

    temporal.queue([
      {
        delay: 5000,
        task: function () {
          console.log('Taking Off');
          d.takeOff();
          d.flatTrim();
        }
      },
      {
        delay: 4500,
        task: function () {
          console.log('Going left');
          d.tiltLeft({steps: 40, speed: 100});
        }
      },
      {
        delay: 5000,
        task: function () {
          console.log('Landing');
          d.land();
        }
      },
      {
        delay: 5000,
        task: function () {
          temporal.clear();
          process.exit(0);
        }
      }
    ]);
  });
});
