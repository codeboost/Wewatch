Wewatch - watch youtube clips together
======================================

Description
-----------

Wewatch allows multiple people to watch youtube clips together.
Scroll, pause and play is synchronized between all connected clients.

Features:

- Synchronized youtube player
- Playlist editor: Search and add clips easily
- Bookmarks: Set 'bookmarks' in clips
- Chat

A production server is running at: [http://wewatch.me]()


License
-------

The source code is distributed under the MIT license.

Requirements
------------

The project is written in Coffee-Script (iced dialect) and uses Socket.io, Backbone.js and Skull.io libraries, among others.

This project requires iced coffee-script:

	npm install -g iced-coffee-script

Mongodb is used as database, make sure it's installed and running.
Configure the db in server/config.coffee (default is mongodb://localhost/wewatch)


Directory structure
-------------------

build
	Contains the compiled javascript files as well as the script to stitch and minify them

client
	Contains the client-side coffee script source code. Compiles to build/js

server
	The server source code

www
	Jade templates, vendor javascripts and the stylesheets


Installing
----------

	git clone git@github.com:codeboost/Wewatch.git
	npm install
	iced server

To start a 'debug' server, run:

	iced server debug


Compiling
---------

To compile the client sources to a minified javascript file:
	
	cd build
	iced compilejs

Configuration
-------------

You can edit the listen host/port and db parameters in server/config.coffee


Disclaimer
----------

This was done in my spare time and is mostly experimental. Good luck.
