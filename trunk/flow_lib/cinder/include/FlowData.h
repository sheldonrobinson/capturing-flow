/*
 *  FlowData.h
 *
 *  Created by Michael Creighton on 7/30/10.
 */

#pragma once

#include <vector>
#include <string>
#include "cinder/Cinder.h"
#include "cinder/Utilities.h"
#include "cinder/Vector.h"
#include "cinder/DataSource.h"
#include "cinder/Timer.h"
#include "cinder/Xml.h"
#include "FlowPoint.h"

using namespace ci;

namespace flow {

class FlowData {
	
public:
	FlowData()
	{
		init();
	}
	
	FlowData(DataSourceRef dataSource)
	{
		this->dataSource = dataSource;
		init();
	}
	
	~FlowData();
	
	void load();
	std::vector<FlowPoint>* const getStroke(int strokeIndex) const;
	void setRemapRect(float left, float top, float right, float bottom);
	bool isReady() const;
	int getNumStrokes() const;
	
	DataSourceRef dataSource;
	int minNumberOfPointsInStroke;
	bool ignoreRedundantPositions;
	
private:
	void init()
	{
		mRemapMinX = 0.f;
		mRemapMaxX = 1.f;
		mRemapMinY = 0.f;
		mRemapMaxY = 1.f;
		ignoreRedundantPositions = false;
		minNumberOfPointsInStroke = 0;
		mReady = false;
	}
	bool mReady;
	float mRemapMinX;
	float mRemapMinY;
	float mRemapMaxX;
	float mRemapMaxY;
	std::vector<std::vector<FlowPoint>*> mStrokes;
	
};

} // end flow namespace