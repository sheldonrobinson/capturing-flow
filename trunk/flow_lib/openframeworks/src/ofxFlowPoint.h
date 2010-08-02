/*
 *  ofxFlowPoint.h
 *
 *  Created by Michael Creighton on 7/31/10.
 */

#pragma once

#include "ofxVectorMath.h"

class ofxFlowPoint {
	
public:
	ofxFlowPoint() { }
	
	ofxFlowPoint(ofxVec2f position, ofxVec2f velocity, float time)
		: pos(position), vel(velocity), time(time) { }
	
	ofxVec2f pos;
	ofxVec2f vel;
	float time;
	
	float getX() const
	{
		return pos.x;
	}
	
	float getY() const
	{
		return pos.y;
	}
	
	float getXVel() const
	{
		return vel.x;
	}
	
	float getYVel() const
	{
		return vel.y;
	}
	
};