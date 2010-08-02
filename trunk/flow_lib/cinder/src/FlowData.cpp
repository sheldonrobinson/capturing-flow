/*
 *  FlowData.cpp
 *
 *  Created by Michael Creighton on 7/30/10.
 */

#include "FlowData.h"

namespace flow {

FlowData::~FlowData()
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

void FlowData::load()
{
	if(!mReady)
	{
		Timer timer(true);
		
		XmlDocument * pointsDoc = new XmlDocument(dataSource);
		XmlElement rootNode = pointsDoc->rootNode();
		
		if(rootNode.hasChildren())
		{
			XmlElement tagNode = rootNode.findChild("tag");
			XmlElement drawingNode = tagNode.findChild("drawing");
			
			// Now get all the drawingNode's children.. and only worry about the stroke nodes.
			if(drawingNode.hasChildren())
			{
				std::vector<XmlElement> strokeNodes = drawingNode.children();
				
				// std::vector<XmlElement> strokeNodes = rootNode.xpath("//tag/drawing//stroke");
				
				if(strokeNodes.size() > 0)
				{
					int totalPoints = 0;
					
					// Now declare some variables to reuse in our loop.
					FlowPoint lastPt(Vec2f::zero(), Vec2f::zero(), -1.f);
					
					for(std::vector<XmlElement>::iterator it = strokeNodes.begin(); it < strokeNodes.end(); it++)
					{
						XmlElement strokeNode = *it;
						
						if(strokeNode.name() == "stroke")
						{
							// Get all the point nodes.
							std::vector<XmlElement> pointNodes = strokeNode.children();
							
							// Create a new stroke 
							std::vector<FlowPoint> * stroke = new std::vector<FlowPoint>;
							
							for(std::vector<XmlElement>::iterator it2 = pointNodes.begin(); it2 < pointNodes.end(); it2++)
							{
								XmlElement ptNode = *it2;
								if(ptNode.name() == "pt")
								{
									std::string xVal = ptNode.findChild("x").value();
									// float x = fromString( xVal );
									float x = boost::lexical_cast<float>( xVal );
									
									std::string yVal = ptNode.findChild("y").value();
									// float y = fromString( yVal );
									float y = boost::lexical_cast<float>( yVal );
									
									std::string timeVal = ptNode.findChild("time").value();
									// float time = fromString( timeVal );
									float time = boost::lexical_cast<float>( timeVal );
									
									x = mRemapMinX + (mRemapMaxX - mRemapMinX) * x;
									y = mRemapMinY + (mRemapMaxY - mRemapMinY) * y;
									Vec2f pos(x, y);
									Vec2f vel;
									if(lastPt.time > -1)
									{
										vel.x = pos.x - lastPt.getX();
										vel.y = pos.y - lastPt.getY();
									}
									FlowPoint pt(pos, vel, time);
									
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
										lastPt = FlowPoint(pt.pos, pt.vel, pt.time);
									}
								}
							}
							
							// Now see if our stroke is long enough.
							if(stroke->size() > minNumberOfPointsInStroke)
							{
								mStrokes.push_back(stroke);
							}
						}
					}
					
					// We're done.
					timer.stop();
					
					
					std::cout << "FlowData :: GML file parsing complete. Elapsed seconds: " << toString( timer.getSeconds() ) << std::endl;
					std::cout << "FlowData :: Total number of points: " << totalPoints << std::endl;
					std::cout << "FlowData :: Number of strokes: " << mStrokes.size() << std::endl;
					
					if(mStrokes.size() > 0)
						mReady = true;
				}
			}
		}
	}
}

// ==================================================================================

std::vector<FlowPoint>* const FlowData::getStroke(int strokeIndex) const
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

void FlowData::setRemapRect(float left, float top, float right, float bottom)
{
	mRemapMinX = left;
	mRemapMaxX = right;
	mRemapMinY = top;
	mRemapMaxY = bottom;
}

// ==================================================================================

bool FlowData::isReady() const
{
	return mReady;
}

// ==================================================================================

int FlowData::getNumStrokes() const
{
	return mStrokes.size();
}

} // end flow namespace