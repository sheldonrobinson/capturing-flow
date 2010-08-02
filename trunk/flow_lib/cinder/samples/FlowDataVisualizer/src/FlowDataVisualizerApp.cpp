#include "cinder/app/AppBasic.h"
#include "Resources.h"
#include "cinder/Utilities.h"
#include "cinder/gl/gl.h"
#include "FlowData.h"

using namespace ci;
using namespace ci::app;
using namespace std;
using namespace flow;

// ====================================================================
class FlowDataVisualizer : public AppBasic {
public:
	void	prepareSettings( Settings * settings );
	void	resize( int width, int height );
	void	setup();
	void	update();
	void	draw();
	void	keyUp( KeyEvent event );
	
	void	prepareCurrentStroke();
	inline float easeInQuad(float t, float b, float c, float d) { return c * (t /= d) * t + b; }
	
	
	FlowData flowData;
	
	int currStrokeIndex;  // Holds the current stroke index we're rendering
	
	bool isCurrStrokeDoneRendering; // Determines whether or not we're done rendering our current stroke
	
	vector<FlowPoint> * currStroke; // Holds a reference to our current stroke of FlowPoints.
	
	int currPointIndex; // Keeps track of the current point index we're dealing with on this frame render.
	
	float minVelocity; // Gives us a min point velocity to determine the stroke width.
	
	float maxVelocity; // Gives us a max point velocity to determine the stroke width.
	
	Vec2f lastMid; // Holds the last mid-point between two FlowPoints in our draw loop
	
	Vec2f lastPerp; // Holds the last perpendicular point from that midpoint.
	
	float lastAmp; // Holds the last amplitude calculation based on a point's velocity.
};
// ====================================================================

void FlowDataVisualizer::prepareSettings( Settings * settings )
{
	settings->setWindowSize(1024, 768);
	settings->setFrameRate(60.f);
}

// ====================================================================

void FlowDataVisualizer::resize( int width, int height )
{
	
}

// ====================================================================

void FlowDataVisualizer::setup()
{
	// Clear our stage.
	float c = 17.f / 255.f;
	gl::clear( Colorf( c, c, c ) );
	gl::enableAlphaBlending();
	
	flowData.dataSource = loadResource(RES_EXAMPLE_GML);
	flowData.ignoreRedundantPositions = true;
	flowData.minNumberOfPointsInStroke = 0;
	flowData.setRemapRect(0.f, 0.f, getWindowWidth(), getWindowHeight());
	flowData.load();
	
	currStrokeIndex = 0;
	minVelocity = 0.f;
	
	if(flowData.isReady())
		prepareCurrentStroke();
}

// ====================================================================

void FlowDataVisualizer::prepareCurrentStroke()
{
	minVelocity = 0;
	maxVelocity = 0;
	currStroke = flowData.getStroke(currStrokeIndex);
	
	// Determine the max velocity in our data set.
	for(vector<FlowPoint>::iterator it = currStroke->begin(); it < currStroke->end(); it++)
	{
		FlowPoint p = *it;
		Vec2f pos(p.pos);
		Vec2f vel(p.vel);
		Vec2f velP = pos + vel;
		float velDist = velP.distance(pos);
		if(velDist > maxVelocity)
			maxVelocity = velDist;
	}
	
	currPointIndex = -1; // We're starting this stroke fresh, so we need to reset the index.
	isCurrStrokeDoneRendering = false;
	
	console() << "\nCurrent stroke index being rendered: " << currStrokeIndex << endl;
}

// ====================================================================

void FlowDataVisualizer::keyUp( KeyEvent event )
{
	if(flowData.isReady())
	{
		if(event.getCode() == KeyEvent::KEY_UP)
		{
			// Go to the prev stroke.
			currStrokeIndex--;
			if(currStrokeIndex < 0) {
				currStrokeIndex = flowData.getNumStrokes() - 1;
			}
			prepareCurrentStroke();
			
		}
		else if (event.getCode() == KeyEvent::KEY_DOWN)
		{
			// Go to the next stroke.
			currStrokeIndex++;
			if(currStrokeIndex > flowData.getNumStrokes() - 1) {
				currStrokeIndex = 0;
			}
			prepareCurrentStroke();
		}
	}
}

// ====================================================================

void FlowDataVisualizer::update()
{
	
}

// ====================================================================

void FlowDataVisualizer::draw()
{
	if(currPointIndex == -1)
	{
		// First time through, so clear our stage.
		float c = 17.f / 255.f;
		gl::clear( Colorf( c, c, c ) );
	}
	
	if(!isCurrStrokeDoneRendering && flowData.isReady())
	{
        currPointIndex++;
        if(currPointIndex < currStroke->size()) {
            
			ColorAf FILL_COLOR( 196.f / 255.f, 61.f / 255.f, 101.f / 255.f, 1.f );
            ColorAf STROKE_COLOR( 141.f / 255.f, 144.f / 255.f, 24.f / 255.f, 1.f );
            
            FlowPoint * currP = &(currStroke->at(currPointIndex));
            FlowPoint * lastP = NULL;
            Vec2f currMid;
            Vec2f currPerp;
            float currAmp;
            
            if(currPointIndex > 0)
                lastP = &(currStroke->at(currPointIndex - 1));
            
            // First draw an ellipse at this point's position.			
			glColor4f( FILL_COLOR.r, FILL_COLOR.g, FILL_COLOR.b, 51.f / 255.f );
			gl::drawSolidCircle( currP->pos, 2.5 );
			
            // Now let's draw something with dimension.
            if(lastP != NULL) {
                // First determine the "amplitude" of this point's velocity.
				Vec2f velP = currP->pos + currP->vel;
				float velDist = velP.distance(currP->pos);
				currAmp = 1.f - velDist / maxVelocity; // This is inversed because the FASTER the velocity, the thinner we want our stroke.
				// But we want the value to be logarithmic
                currAmp = easeInQuad(currAmp, 0, 1.f, 1.f);
				currAmp *= 30; // This tells us how wide the stroke will be from a given midpoint.
				
				// Figure out the perpendicular to the velocity vector.				
				float velLength = sqrt( currP->getXVel() * currP->getXVel() + currP->getYVel() * currP->getYVel() );
				if(velLength > 0) {
					currPerp.x = -(currP->getYVel() / velLength);
					currPerp.y = currP->getXVel() / velLength;
				}
				
                // See if this is the first quad we're drawing (rather, a triangle).
                if(currPointIndex == 1) {
					currMid = lastP->pos.lerp(0.5f, currP->pos);
                    
                    Vec2f m1;
                    Vec2f m2;
                    m1.x = currMid.x - currPerp.x * currAmp;
                    m1.y = currMid.y - currPerp.y * currAmp;
                    m2.x = currMid.x + currPerp.x * currAmp;
                    m2.y = currMid.y + currPerp.y * currAmp;
                    
                    // Draw the fill
					glColor4f( STROKE_COLOR.r, STROKE_COLOR.g, STROKE_COLOR.b, 0.05f );
					glBegin(GL_TRIANGLES);
					{
						gl::vertex(lastP->pos);
						gl::vertex(m2);
						gl::vertex(m1);
					}
					glEnd();
                    
                    // Draw the lines
					glColor4f( STROKE_COLOR.r, STROKE_COLOR.g, STROKE_COLOR.b, 0.5f );
					glBegin(GL_LINES);
					{
						gl::vertex(lastP->pos);
						gl::vertex(m2);
					}
					glEnd();
					glColor4f( STROKE_COLOR.r, STROKE_COLOR.g, STROKE_COLOR.b, 0.1f );
					glBegin(GL_LINES);
					{
						gl::vertex(m2);
						gl::vertex(m1);
					}
					glEnd();
					glColor4f( STROKE_COLOR.r, STROKE_COLOR.g, STROKE_COLOR.b, 0.5f );
					glBegin(GL_LINES);
					{
						gl::vertex(m1);
						gl::vertex(lastP->pos);
					}
					glEnd();
                } 
				else
				{
                    currMid = lastP->pos.lerp(0.5f, currP->pos);
                    Vec2f p1;
                    Vec2f p2;
                    Vec2f p3;
                    Vec2f p4;
                    
                    p1.x = lastMid.x - lastPerp.x * lastAmp;
                    p1.y = lastMid.y - lastPerp.y * lastAmp;
					
                    p2.x = lastMid.x + lastPerp.x * lastAmp;
                    p2.y = lastMid.y + lastPerp.y * lastAmp;
					
                    p3.x = currMid.x - currPerp.x * currAmp;
                    p3.y = currMid.y - currPerp.y * currAmp;
					
                    p4.x = currMid.x + currPerp.x * currAmp;
                    p4.y = currMid.y + currPerp.y * currAmp;
                    
                    // Draw the fill.
					glColor4f( STROKE_COLOR.r, STROKE_COLOR.g, STROKE_COLOR.b, 0.05f );
					glBegin(GL_QUADS);
					{
						gl::vertex(p1);
						gl::vertex(p2);
						gl::vertex(p4);
						gl::vertex(p3);
					}
					glEnd();
                    
                    // Draw the lines.					
					glColor4f( STROKE_COLOR.r, STROKE_COLOR.g, STROKE_COLOR.b, 0.1f );
					glBegin(GL_LINES);
					{
						gl::vertex(p1);
						gl::vertex(p2);
					}
					glEnd();
					glColor4f( STROKE_COLOR.r, STROKE_COLOR.g, STROKE_COLOR.b, 0.5f );
					glBegin(GL_LINES);
					{
						gl::vertex(p2);
						gl::vertex(p4);
					}
					glEnd();
					glColor4f( STROKE_COLOR.r, STROKE_COLOR.g, STROKE_COLOR.b, 0.1f );
					glBegin(GL_LINES);
					{
						gl::vertex(p4);
						gl::vertex(p3);
					}
					glEnd();
					glColor4f( STROKE_COLOR.r, STROKE_COLOR.g, STROKE_COLOR.b, 0.5f );
					glBegin(GL_LINES);
					{
						gl::vertex(p3);
						gl::vertex(p1);
					}
					glEnd();
					
					
                    // Draw a final triangle if this is the last point.
                    if(currPointIndex == currStroke->size() - 1) {
                        
                        // Draw the fill.
						glColor4f( STROKE_COLOR.r, STROKE_COLOR.g, STROKE_COLOR.b, 0.05f );
						glBegin(GL_TRIANGLES);
						{
							gl::vertex(p3);
							gl::vertex(p4);
							gl::vertex(currP->pos);
						}
						glEnd();
						
						
						// Draw the lines
						glColor4f( STROKE_COLOR.r, STROKE_COLOR.g, STROKE_COLOR.b, 0.1f );
						glBegin(GL_LINES);
						{
							gl::vertex(p3);
							gl::vertex(p4);
						}
						glEnd();
						glColor4f( STROKE_COLOR.r, STROKE_COLOR.g, STROKE_COLOR.b, 0.5f );
						glBegin(GL_LINES);
						{
							gl::vertex(p4);
							gl::vertex(currP->pos);
							gl::vertex(currP->pos);
							gl::vertex(p3);
						}
						glEnd();
                    }
                }
				
                lastMid.set(currMid);
                lastPerp.set(currPerp);
                lastAmp = currAmp;
            }
			
        } else {
            // We're done with this stroke.
            isCurrStrokeDoneRendering = true;            
            cout << "Stroke index " << currStrokeIndex << " is done renderering!\n";
        }
	}
}

// This line tells Cinder to actually create the application
CINDER_APP_BASIC( FlowDataVisualizer, RendererGl )

