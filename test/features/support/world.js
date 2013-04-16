// features/support/world.js

var zombie = require('zombie');
var World = function World(callback) {
  this.browser = new zombie.Browser(); // this.browser will be available in step definitions

  this.visit = function(path, callback) {
    console.log('Visiting http://localhost:' + process.env.PORT + path);
    this.browser.visit('http://localhost:' + process.env.PORT + path, callback);
  };

  callback(); // tell Cucumber we're finished and to use 'this' as the world instance
};
exports.World = World;
