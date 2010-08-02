#include "testApp.h"

//--------------------------------------------------------------
void testApp::setup()
{
	// Clear the stage.
	ofSetBackgroundAuto(false);
	ofBackground( 17, 17, 17 );
	ofSetFrameRate(60);
	ofEnableAlphaBlending();
	
	// Turn on openGL hinting.
	glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
	glEnable(GL_LINE_SMOOTH);
	
	
	flowData.dataSource = ofToDataPath( "example.gml", true );
	flowData.ignoreRedundantPositions = true;
	flowData.minNumberOfPointsInStroke = 250;
	flowData.setRemapRect(0.f, 0.f, ofGetWidth(), ofGetHeight());
	flowData.load();
	
	currStrokeIndex = 0;
	minVelocity = 0.f;
	
	if(flowData.isReady())
		prepareCurrentStroke();
}

//--------------------------------------------------------------

void testApp::prepareCurrentStroke()
{
	minVelocity = 0;
	maxVelocity = 0;
	currStroke = flowData.getStroke(currStrokeIndex);
	
	// Determine the max velocity in our data set.
	for(vector<ofxFlowPoint>::iterator it = currStroke->begin(); it < currStroke->end(); it++)
	{
		ofxFlowPoint p = *it;
		ofxVec2f pos(p.pos);
		ofxVec2f vel(p.vel);
		ofxVec2f velP = pos + vel;
		float velDist = velP.distance(pos);
		if(velDist > maxVelocity)
			maxVelocity = velDist;
	}
	
	currPointIndex = -1; // We're starting this stroke fresh, so we need to reset the index.
	isCurrStrokeDoneRendering = false;
	
	std::cout << "\nCurrent stroke index being rendered: " << currStrokeIndex << std::endl;
}


//--------------------------------------------------------------
void testApp::update(){

}

//--------------------------------------------------------------
void testApp::draw(){
	
	
	if(currPointIndex == -1)
	{
		// First time through, so clear our stage.
		ofBackground(17, 17, 17);
	}
	
	if(!isCurrStrokeDoneRendering && flowData.isReady())
	{
        currPointIndex++;
        if(currPointIndex < currStroke->size()) {
            
			ofColor FILL_COLOR;
			FILL_COLOR.r = 196;
			FILL_COLOR.g = 61;
			FILL_COLOR.b = 101;
			FILL_COLOR.a = 255;
			
			ofColor STROKE_COLOR;
			STROKE_COLOR.r = 141;
			STROKE_COLOR.g = 144;
			STROKE_COLOR.b = 24;
			STROKE_COLOR.a = 255;
            
            ofxFlowPoint * currP = &(currStroke->at(currPointIndex));
            ofxFlowPoint * lastP = NULL;
            ofxVec2f currMid;
            ofxVec2f currPerp;
            float currAmp;
            
            if(currPointIndex > 0)
                lastP = &(currStroke->at(currPointIndex - 1));
            
            // First draw an ellipse at this point's position.
			ofSetColor( FILL_COLOR.r, FILL_COLOR.g, FILL_COLOR.b, 51 );
			ofCircle( currP->getX(), currP->getY(), 2.5f );
						
            // Now let's draw something with dimension.
            if(lastP != NULL) {
                // First determine the "amplitude" of this point's velocity.
				ofxVec2f velP = currP->pos + currP->vel;
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
					currMid = lastP->pos.getInterpolated(currP->pos, 0.5f);
                    
                    ofxVec2f m1;
                    ofxVec2f m2;
                    m1.x = currMid.x - currPerp.x * currAmp;
                    m1.y = currMid.y - currPerp.y * currAmp;
                    m2.x = currMid.x + currPerp.x * currAmp;
                    m2.y = currMid.y + currPerp.y * currAmp;
                    
                    // Draw the fill
					ofSetColor( STROKE_COLOR.r, STROKE_COLOR.g, STROKE_COLOR.b, 12 );
					glBegin(GL_TRIANGLES);
					{
						glVertex2f(lastP->getX(), lastP->getY());
						glVertex2f(m2.x, m2.y);
						glVertex2f(m1.x, m1.y);
					}
					glEnd();
                    
                    // Draw the lines
					ofSetColor( STROKE_COLOR.r, STROKE_COLOR.g, STROKE_COLOR.b, 128 );
					glBegin(GL_LINES);
					{
						glVertex2f(lastP->getX(), lastP->getY());
						glVertex2f(m2.x, m2.y);
					}
					glEnd();
					ofSetColor( STROKE_COLOR.r, STROKE_COLOR.g, STROKE_COLOR.b, 25 );
					glBegin(GL_LINES);
					{
						glVertex2f(m2.x, m2.y);
						glVertex2f(m1.x, m1.y);
					}
					glEnd();
					ofSetColor( STROKE_COLOR.r, STROKE_COLOR.g, STROKE_COLOR.b, 128 );
					glBegin(GL_LINES);
					{
						glVertex2f(m1.x, m1.y);
						glVertex2f(lastP->getX(), lastP->getY());
					}
					glEnd();
                } 
				else
				{
                    currMid = lastP->pos.getInterpolated(currP->pos, 0.5f);
                    ofxVec2f p1;
                    ofxVec2f p2;
                    ofxVec2f p3;
                    ofxVec2f p4;
                    
                    p1.x = lastMid.x - lastPerp.x * lastAmp;
                    p1.y = lastMid.y - lastPerp.y * lastAmp;
					
                    p2.x = lastMid.x + lastPerp.x * lastAmp;
                    p2.y = lastMid.y + lastPerp.y * lastAmp;
					
                    p3.x = currMid.x - currPerp.x * currAmp;
                    p3.y = currMid.y - currPerp.y * currAmp;
					
                    p4.x = currMid.x + currPerp.x * currAmp;
                    p4.y = currMid.y + currPerp.y * currAmp;
                    
                    // Draw the fill.
					ofSetColor( STROKE_COLOR.r, STROKE_COLOR.g, STROKE_COLOR.b, 12 );
					glBegin(GL_QUADS);
					{
						glVertex2f(p1.x, p1.y);
						glVertex2f(p2.x, p2.y);
						glVertex2f(p4.x, p4.y);
						glVertex2f(p3.x, p3.y);
					}
					glEnd();
                    
                    // Draw the lines.					
					ofSetColor( STROKE_COLOR.r, STROKE_COLOR.g, STROKE_COLOR.b, 25 );
					glBegin(GL_LINES);
					{
						glVertex2f(p1.x, p1.y);
						glVertex2f(p2.x, p2.y);
					}
					glEnd();
					ofSetColor( STROKE_COLOR.r, STROKE_COLOR.g, STROKE_COLOR.b, 128 );
					glBegin(GL_LINES);
					{
						glVertex2f(p2.x, p2.y);
						glVertex2f(p4.x, p4.y);
					}
					glEnd();
					ofSetColor( STROKE_COLOR.r, STROKE_COLOR.g, STROKE_COLOR.b, 25 );
					glBegin(GL_LINES);
					{
						glVertex2f(p4.x, p4.y);
						glVertex2f(p3.x, p3.y);
					}
					glEnd();
					ofSetColor( STROKE_COLOR.r, STROKE_COLOR.g, STROKE_COLOR.b, 128 );
					glBegin(GL_LINES);
					{
						glVertex2f(p3.x, p3.y);
						glVertex2f(p1.x, p1.y);
					}
					glEnd();
					
					
                    // Draw a final triangle if this is the last point.
                    if(currPointIndex == currStroke->size() - 1) {
                        
                        // Draw the fill.
						ofSetColor( STROKE_COLOR.r, STROKE_COLOR.g, STROKE_COLOR.b, 12 );
						glBegin(GL_TRIANGLES);
						{
							glVertex2f(p3.x, p3.y);
							glVertex2f(p4.x, p4.y);
							glVertex2f(currP->getX(), currP->getY());
						}
						glEnd();
						
						
						// Draw the lines
						ofSetColor( STROKE_COLOR.r, STROKE_COLOR.g, STROKE_COLOR.b, 25 );
						glBegin(GL_LINES);
						{
							glVertex2f(p3.x, p3.y);
							glVertex2f(p4.x, p4.y);
						}
						glEnd();
						ofSetColor( STROKE_COLOR.r, STROKE_COLOR.g, STROKE_COLOR.b, 128 );
						glBegin(GL_LINES);
						{
							glVertex2f(p4.x, p4.y);
							glVertex2f(currP->getX(), currP->getY());
							glVertex2f(currP->getX(), currP->getY());
							glVertex2f(p3.x, p3.y);
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

//--------------------------------------------------------------
void testApp::keyPressed(int key){

}

//--------------------------------------------------------------
void testApp::keyReleased(int key){
	
	if(flowData.isReady())
	{
		if(key == OF_KEY_UP)
		{
			// Go to the prev stroke.
			currStrokeIndex--;
			if(currStrokeIndex < 0) {
				currStrokeIndex = flowData.getNumStrokes() - 1;
			}
			prepareCurrentStroke();
			
		}
		else if (key == OF_KEY_DOWN)
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

//--------------------------------------------------------------
void testApp::mouseMoved(int x, int y ){

}

//--------------------------------------------------------------
void testApp::mouseDragged(int x, int y, int button){

}

//--------------------------------------------------------------
void testApp::mousePressed(int x, int y, int button){

}

//--------------------------------------------------------------
void testApp::mouseReleased(int x, int y, int button){

}

//--------------------------------------------------------------
void testApp::windowResized(int w, int h){

}

