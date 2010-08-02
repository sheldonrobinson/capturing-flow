/*
 *  ofxFlowData.cpp
 *
 *  Created by Michael Creighton on 7/30/10.
 */

#include "ofxFlowData.h"

ofxFlowData::~ofxFlowData()
{
	if(mReady)
	{
		// Empty the strokes vector.
		if(mStrokes.size() > 0)
		{
			for (int i = 0; i < mStrokes.size(); i++) {
				delete mStrokes.at(i);
			}
			mStrokes.empty();
		}
	}
}

// ==================================================================================

void ofxFlowData::load()
{
	if(!mReady)
	{
		float startTime = ofGetElapsedTimef();
		
		ofxXmlSettings * pointsDoc = new ofxXmlSettings;
		pointsDoc->loadFile( dataSource.c_str() );
		pointsDoc->pushTag("GML");
		
		if( pointsDoc->tagExists("tag") == true )
		{
			pointsDoc->pushTag("tag"); // Go into the <tag> node
			pointsDoc->pushTag("drawing"); // Go into the <drawing> node
			
			// Now get all the drawingNode's children.. and only worry about the stroke nodes.
			if(pointsDoc->tagExists("stroke") == true)
			{
				// Now lets get the strokes.
				int numStrokeNodes = pointsDoc->getNumTags("stroke");
				
				if(numStrokeNodes > 0)
				{
					int totalPoints = 0;
					
					// Now declare some variables to reuse in our loop.
					ofxFlowPoint lastPt(ofxVec2f(), ofxVec2f(), -1.f);
					
					// Now we need to go into a push pop tag loop. Weird way to traverse XML.
					for (int i = 0; i < numStrokeNodes; i++)
					{
						// Push into the first stroke node.
						pointsDoc->pushTag("stroke", i);
						
						// Create a new stroke 
						std::vector<ofxFlowPoint> * stroke = new std::vector<ofxFlowPoint>;
						
						// Now loop thru the point nodes.
						int numPointNodes = pointsDoc->getNumTags("pt");
						
						for(int j = 0; j < numPointNodes; j++)
						{
							pointsDoc->pushTag("pt", j);
							
							// Now get into the x, y, and z values.
							double x = pointsDoc->getValue("x", 0.f);
							double y = pointsDoc->getValue("y", 0.f);
							double time = pointsDoc->getValue("time", 0.f);
							
							x = mRemapMinX + (mRemapMaxX - mRemapMinX) * x;
							y = mRemapMinY + (mRemapMaxY - mRemapMinY) * y;
							ofxVec2f pos(x, y);
							ofxVec2f vel;
							if(lastPt.time > -1)
							{
								vel.x = pos.x - lastPt.getX();
								vel.y = pos.y - lastPt.getY();
							}
							ofxFlowPoint pt(pos, vel, time);
							
							bool shouldAddPoint = false;
							if(ignoreRedundantPositions == true)
							{
								if(lastPt.time > -1)
								{
									if(pt.getX() != lastPt.getX() && pt.getY() != lastPt.getY())
									{
										shouldAddPoint = true;
									}  
								}
								else
								{
									shouldAddPoint = true;
								}
							}
							else
							{
								shouldAddPoint = true;
							}
							
							if(shouldAddPoint)
							{
								totalPoints++;
								stroke->push_back(pt);
								lastPt = ofxFlowPoint(pt.pos, pt.vel, pt.time);
							}
							
							pointsDoc->popTag(); // Get out of this point node.
						}
						
						// Now see if our stroke is long enough.
						if(stroke->size() > minNumberOfPointsInStroke)
						{
							mStrokes.push_back(stroke);
						}
						
						// Get out of this <stroke> node.
						pointsDoc->popTag();
					}
					
					// We're done.
					float endTime = ofGetElapsedTimef();
					float dur = endTime - startTime;
					
					
					std::cout << "ofxFlowData :: GML file parsing complete. Elapsed seconds: " << ofToString(dur) << std::endl;
					std::cout << "ofxFlowData :: Total number of points: " << totalPoints << std::endl;
					std::cout << "ofxFlowData :: Number of strokes: " << mStrokes.size() << std::endl;
					
					if(mStrokes.size() > 0)
						mReady = true;
				}
			}
		}
	}
}

// ==================================================================================

std::vector<ofxFlowPoint>* const ofxFlowData::getStroke(int strokeIndex) const
{
	// Make sure this index is valid.
	if(mReady)
	{
		if(mStrokes.size() > 0)
		{
			if(strokeIndex < mStrokes.size() && strokeIndex >= 0)
			{
				return mStrokes.at( strokeIndex );
			}
			return NULL;
		}
		return NULL;
	}
	return NULL;
}

// ==================================================================================

void ofxFlowData::setRemapRect(float left, float top, float right, float bottom)
{
	mRemapMinX = left;
	mRemapMaxX = right;
	mRemapMinY = top;
	mRemapMaxY = bottom;
}

// ==================================================================================

bool ofxFlowData::isReady() const
{
	return mReady;
}

// ==================================================================================

int ofxFlowData::getNumStrokes() const
{
	return mStrokes.size();
}