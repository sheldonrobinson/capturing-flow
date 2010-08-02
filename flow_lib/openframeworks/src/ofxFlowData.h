/*
 *  FlowData.h
 *
 *  Created by Michael Creighton on 7/30/10.
 */

#pragma once

#include <vector>
#include <string>
#include "ofMain.h"
#include "ofxXmlSettings.h"
#include "ofxVectorMath.h"
#include "ofxFlowPoint.h"

class ofxFlowData {
	
public:
	ofxFlowData()
	{
		init();
	}
	
	ofxFlowData(const std::string &dataSource)
	{
		this->dataSource = dataSource;
		init();
	}
	
	~ofxFlowData();
	
	void load();
	std::vector<ofxFlowPoint>* const getStroke(int strokeIndex) const;
	void setRemapRect(float left, float top, float right, float bottom);
	bool isReady() const;
	int getNumStrokes() const;
	
	std::string dataSource;
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
	std::vector<std::vector<ofxFlowPoint>*> mStrokes;
	
};