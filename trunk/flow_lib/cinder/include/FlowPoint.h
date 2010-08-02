/*
 *  FlowPoint.h
 *
 *  Created by Michael Creighton on 7/30/10.
 */

#pragma once

#include "cinder/Vector.h"

using namespace ci;

namespace flow {

class FlowPoint {
public:
	FlowPoint() { }
	
	FlowPoint(Vec2f position, Vec2f velocity, float time)
		: pos(position), vel(velocity), time(time) { }
	
	Vec2f pos;
	Vec2f vel;
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

} // end flow namepsace