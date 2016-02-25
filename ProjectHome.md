<a href='http://www.flickr.com/photos/mikecreighton/4850776261/'><img src='http://farm5.static.flickr.com/4073/4850776261_4390918155_z.jpg' /></a>

<font color='#2B2A29'>The Flow Suite is a set of modular tools used for the capturing, storing, and exporting of single-point motion data.</font>

<font color='#2B2A29'>The process begins with data generation. This can be any application that sends out <a href='http://www.tuio.org/'>TUIO</a> <code>2dcur</code> messages. For my own purposes, I created a fork of <a href='http://nuigroup.com/'>NUI Group</a>'s <a href='http://ccv.nuigroup.com/'>Community Core Vision</a> (CCV for short) application which adds HSV-tracking capabilities. <i>The CCV HSV Tracker project can be found here:</i> <a href='http://ccv-hsv-tracker.googlecode.com'>http://ccv-hsv-tracker.googlecode.com</a>. Using this application, all that you'll need to track motion data is a distinct color swatch, a camera, and a computer.</font>

<font color='#2B2A29'>Next we receive and store this motion data. <b>Flow Receiver</b> is an <a href='http://www.adobe.com/products/air/'>Adobe AIR 2.0</a> application that connects to a TUIO server for data acquisition<sup>1</sup>. <b>Flow Storage</b> is a web application that stores the data received by <b>Flow Receiver</b> in a MySQL database. <b>Flow Storage</b> can exist on a local or remote web server.</font>

<font color='#2B2A29'>Either of these applications can then be used to output the captured data to a <a href='http://graffitianalysis.com/gml/'>GML</a> (Gaffiti Markup Language) file for maximum data portability.</font>

<font color='#2B2A29'>Finally, a set of libraries called <b>Flow Lib</b> have been created for <a href='http://www.adobe.com/products/flashplayer/'>Adobe Flash Player 10 ActionScript 3.0</a>, <a href='http://processing.org'>Processing</a>, <a href='http://openframeworks.cc'>openFrameworks</a>, and <a href='http://libcinder.org'>Cinder</a> for loading, parsing, and manipulating your motion-captured data.</font>

<sup>1</sup> <font color='#888888'>At this time, while native UDP connectivity is possible in AIR 2.0, it has not been implemented in Flow Receiver. You will need to use a proxy server like <a href='http://www.benchun.net/flosc/'>flosc</a> or the built-in flosc-like behavior in CCV.</font>

# Huge Thanks #

I want to express a personal thank you to all the contributors of the following open source libraries and frameworks, because without your hard work and commitment to sharing, I would not have been able to develop this project.

(In no particular order)

  * [Processing](http://processing.org)
  * [Cinder](http://libcinder.org)
  * [openFrameworks](http://openframeworks.cc)
  * [Community Core Vision](http://ccv.nuigroup.com/)
  * [CodeIgniter](http://www.codeigniter.com)
  * [CASA Lib](http://casalib.org/)
  * [Graffiti Analysis](http://graffitianalysis.com/)
  * [tuio-as3-lib](http://code.google.com/p/tuio-as3-lib/)
  * [GreenSock Tweening Platform](http://www.greensock.com/v11beta/)
  * [Wiimote Whiteboard](http://sourceforge.net/projects/wiiwhiteboard/)
  * [Adobe Flex SDK](http://opensource.adobe.com/wiki/display/flexsdk/Flex+SDK)
  * [FirePHP](http://code.google.com/p/firephp/)
  * [Minimal Comps](http://www.minimalcomps.com/)
  * [XAMPP](http://www.apachefriends.org/en/xampp.html)