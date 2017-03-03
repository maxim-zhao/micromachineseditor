Micro Machines Editor
===================

Editor for the Master System version of Micro Machines, based on disassembly of the original Z80 code, implemented in C#.

![Imgur](http://i.imgur.com/3y9WZBk.png)

Status
----

The editor itself is on hold. I got bored with it. Feel free to continue it!

I have instead been working on a disassembly of the game, under the Analysis section.

What is done/remains to be done
-----

- [x] Decompressor for the (presumably) bespoke compression scheme 
- [x] Locating data for, and rendering images of, tiles 
- [x] Locating data for, and rendering images of, metatiles and associated metadata (e.g. walls, material types) 
- [x] Locating data for, and rendering images of, tracks and associated metadata 
- [x] UI for selecting metatiles and editing a track in memory, with a few options for rendering metadata over the graphics 
- [ ] Figuring out some of the game data bits which are still mysterious to me 
- [ ] Discovery of anything I've missed for the game to work (e.g. CPU AI, how pool table holes work) 
- [ ] Data compression. I always find compressors hard to do because it rapidly gets hard to do something optimal when the number of possibilities goes up. I suspect a dumb compressor can match the original. Or maybe swap it out for an existing one like aPLib?
- [ ] Data (re-)insertion into the ROM, possibly with expansion 
- [ ] Level order editing, for both 1- and 2-player modes 
- [ ] Level metadata editing (car parameters, names) 
- [ ] Metatile editing 
- [ ] Tile editing 
- [ ] Upgrading from 3bpp to 4bpp graphics (as an enhancement to the game) 
- [x] Hacking all the known cheats to check for any more 

Not all of this is necessary for a first release - just being able to edit tracks in-place would be the majority of the usefulness.

The disassembly
----

This is a work in progress, based on an Emulicious disassembly and an awful lot of manual work on top. The editor has been slightly abused to act as a tool for exploring and exporting data from the game.
