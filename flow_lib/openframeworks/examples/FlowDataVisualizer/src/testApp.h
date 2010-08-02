#ifndef _TEST_APP
#define _TEST_APP


#include "ofMain.h"
#include "ofxFlowData.h"
#include "ofxFlowPoint.h"
#include <vector>

class testApp : public ofBaseApp
{

public:
	void setup();
	void update();
	void draw();

	void keyPressed  (int key);
	void keyReleased(int key);
	void mouseMoved(int x, int y );
	void mouseDragged(int x, int y, int button);
	void mousePressed(int x, int y, int button);
	void mouseReleased(int x, int y, int button);
	void windowResized(int w, int h);
		
	void	prepareCurrentStroke();
	inline float easeInQuad(float t, float b, float c, float d) { return c * (t /= d) * t + b; }

	ofxFlowData flowData;
	
	int currStrokeIndex;  // Holds the current stroke index we're rendering
	
	bool isCurrStrokeDoneRendering; // Determines whether or not we're done rendering our current stroke
	
	vector<ofxFlowPoint> * currStroke; // Holds a reference to our current stroke of FlowPoints.
	
	int currPointIndex; // Keeps track of the current point index we're dealing with on this frame render.
	
	float minVelocity; // Gives us a min point velocity to determine the stroke width.
	
	float maxVelocity; // Gives us a max point velocity to determine the stroke width.
	
	ofxVec2f lastMid; // Holds the last mid-point between two FlowPoints in our draw loop
	
	ofxVec2f lastPerp; // Holds the last perpendicular point from that midpoint.
	
	float lastAmp; // Holds the last amplitude calculation based on a point's velocity.

};

#endif
