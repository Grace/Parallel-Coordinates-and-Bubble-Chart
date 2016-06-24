d3js_design_contest
===================

4122 Assignment - D3 Design Contest

![screenshot](https://raw.github.com/Glchriste/d3js_design_contest/master/Visualization/sample.png)

## Authors:
Grace Christenbery

## Pre-reqs:

*  [Node.js](http://nodejs.org/dist/v0.10.20/node-v0.10.20.tar.gz)
*  Node.js csv module, run `npm install csv` in the command line to install it

OR

* [Python](http://www.python.org/download/)

## Instructions

* `git clone` the repository
* `cd` into root directory, and run `npm install`
* in the command line, run `node server.js`
* optionally, use `supervisor server.js`

server will be running on localhost:3000

Make sure to point your browser to `localhost:3000/Visualization/index.html` to view the project!

OR

* `git clone` the repository
* `cd` into root directory
* in the command line, run `python -m HTTPSimpleServer 8888 &` or `python -m http.server 8888 &` for Python 3+
* Point your browser to `http://localhost:8888`
* Use the browser's file explorer to open the root directory to launch the visualization

### Notes:

CSV files are in data/, to see it in the browser, for example
go to `localhost:3000/Visualization/data/a1-cereals.csv`

Open Visualization/index.html to view our hard work!

If running Node.js server:
`http://localhost:3000/Visualization/index.html`

If running Python server:
`http://localhost:8888/...path where you unzipped the folder.../Visualization/index.html`

With a server properly running via the instructions above, index.html will work out of the box.

### Todo:

* Project complete! View coffee/vis.coffee for visualization code.

### Links:

Our code repository can be found here: https://github.com/treehau5/d3js_design_contest
