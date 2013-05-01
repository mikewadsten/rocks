Rocks In Space
===============

What is this?
-

This is a simple "clone" of the arcade game Asteroids, created by Mike Wadsten to use as part
of a final project for CSCI 4511W at the University of Minnesota. There is no "player" - the
spaceship moves around of its own will.

How do I run it?
-

In order to start a local instance of the game, you'll need [NodeJS](http://nodejs.org) and
npm. Once you have the source code, run

    $ npm install

from the root directory - all necessary NPM packages should automatically install. You may
need to do `npm install -g grunt-cli` -- I seem to have forgotten about this one.

Once all these dependencies have been installed, run

    $ grunt

This will compile all of the CoffeeScript files to JavaScript, minify that JavaScript as well
as the HTML and CSS necessary for the site, and copy these files to the public/ directory.

Finally execute

    $ sudo node server.js

to launch the Node app and serve up the game.

But is it live somewhere already?
-

Yes... yes it is. [Live demo here](http://vm.mikewadsten.com).

What is there left to do?
-

1. Implement depth-limited breadth-first search and A* algorithms.
1. Add functionality to report game results back to server. (See Environment.jsonify)
1. Be awesome...?
