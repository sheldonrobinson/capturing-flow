The Flow Suite is a set of modular tools used for the capturing, storing, and exporting of single-point motion data.

The process begins with data generation. This can be any application that sends out [TUIO 2dcur messages](http://www.tuio.org). For my own purposes, I created a fork of [NUI Group's Community Core Vision,CCV,](http://ccv.nuigroup.com) application which adds HSV-tracking capabilities. The CCV HSV Tracker project can be found here: [http://ccv-hsv-tracker.googlecode.com](http://ccv-hsv-tracker.googlecode.com). Using this application, all that you'll need to track motion data is a distinct color swatch, a camera, and a computer.

Next we receive and store this motion data. Flow Receiver is an [Adobe AIR 2.0](http://www.adobe.com/products/air/) application that connects to a TUIO server for data acquisition1. Flow Storage is a web application that stores the data received by Flow Receiver in a MySQL database. Flow Storage can exist on a local or remote web server.

Either of these applications can then be used to output the captured data to a [Gaffiti Markup Language, GML,](http://graffitianalysis.com/gml/) file for maximum data portability.

Finally, a set of libraries called Flow Lib have been created for [Adobe Flash Player 10](http://www.adobe.com/products/flashplayer/) ActionScript 3.0, [Processing](http://processing.org), [openFrameworks](http://openframeworks.cc), and [Cinder](http://libcinder.org) for loading, parsing, and manipulating your motion-captured data.

1 At this time, while native UDP connectivity is possible in AIR 2.0, it has not been implemented in Flow Receiver. You will need to use a proxy server like [flosc](http://www.benchun.net/flosc/) or the built-in flosc-like behavior in CCV.
