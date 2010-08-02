import com.mikecreighton.flow.*;

// ===================================================================================================
// Begin all property variables
// ---------------------------------------------------------------------------------------------------

FlowData data;

boolean isFlowDataReady; // Keeps track of whether or not we ran into any errors when loading our data.

int currStrokeIndex; // Holds the current stroke index we're rendering

boolean isCurrStrokeDoneRendering; // Determines whether or not we're done rendering our current stroke

ArrayList<FlowPoint> currStroke; // Holds a reference to our current stroke of FlowPoints.

int currPointIndex; // Keeps track of the current point index we're dealing with on this frame render.

float minVelocity = 0; // Gives us a min point velocity to determine the stroke width.

float maxVelocity; // Gives us a max point velocity to determine the stroke width.

PVector lastMid; // Holds the last mid-point between two FlowPoints in our draw loop

PVector lastPerp; // Holds the last perpendicular point from that midpoint.

float lastAmp; // Holds the last amplitude calculation based on a point's velocity.


// ===================================================================================================
// setup()
// ---------------------------------------------------------------------------------------------------

void setup() {
    size(1024, 768);
    smooth();
    noStroke();
    noFill();
    background(0x111111); // Clear the stage.
    
    isFlowDataReady = false;
    currStrokeIndex = 0;
    
    data = new FlowData(this, "example.gml");
    data.setRemapRect(0, 0, width, height);
    data.ignoreRedundantPositions = true;
    data.minNumberOfPointsInStroke = 0;
    
    try {
        isFlowDataReady = data.load();
    } catch (FileNotFoundException e) {
        println("The file doesn't exist.");
    } catch (IOException e) {
        println("There was an error reading the file.");
    }
    
    prepareCurrentStroke();
}


// ===================================================================================================
// prepareCurrentStroke()
// 
// Determines the max velocity value among all points within the current stroke
// so that we can derive a relative max width for the stroke at slow velocities.
// ---------------------------------------------------------------------------------------------------

void prepareCurrentStroke() {
    if(isFlowDataReady) {
        minVelocity = 0;
        maxVelocity = 0;
        currStroke = data.getStroke(currStrokeIndex);
        
        // Determine the max velocity in our data set.
        for(Object o : currStroke) {
            PVector pos = ((FlowPoint) o).getPosition();
            PVector vel = ((FlowPoint) o).getVelocity();
            PVector velP = PVector.add(pos, vel);
            float velDist = PVector.dist(velP, pos);
            if(velDist > maxVelocity)
                maxVelocity = velDist;
        }
        
        currPointIndex = -1; // We're starting this stroke fresh, so we need to reset the index.
        isCurrStrokeDoneRendering = false;
        
        background(0x111111); // Clear the stage.
        
        println("\nCurrent stroke index being rendered: " + currStrokeIndex);
    }
}


// ===================================================================================================
// draw()
// 
// Draw loop that renders our current stroke one segment every frame.
// ---------------------------------------------------------------------------------------------------

void draw() {
    
    // Verify that we've got data, and that we're not done rendering our stroke!
    if(isFlowDataReady && !isCurrStrokeDoneRendering) {
        
        currPointIndex++;
        if(currPointIndex < currStroke.size()) {
            
            final int FILL_COLOR = 0xFFC43D65;
            final int STROKE_COLOR = 0xFF8D9018;
            
            FlowPoint currP = currStroke.get(currPointIndex);
            FlowPoint lastP = null;
            PVector currMid;
            PVector currPerp;
            float currAmp;
            
            if(currPointIndex > 0)
                lastP = currStroke.get(currPointIndex - 1);
            
            // First draw an ellipse at this point's position.
            fill(FILL_COLOR, 51);
            ellipse(currP.getX(), currP.getY(), 5, 5);
            noFill();
            
            // Now let's draw something with dimension.
            if(lastP != null) {
                // First determine the "amplitude" of this point's velocity.
		PVector velP = PVector.add(currP.getPosition(), currP.getVelocity());
		float velDist = velP.dist(currP.getPosition());
		currAmp = 1.f - velDist / maxVelocity; // This is inversed because the FASTER the velocity, the thinner we want our stroke.
		// But we want the value to be logarithmic
                currAmp = easeInQuad(currAmp, 0, 1.f, 1.f);
		currAmp *= 30; // This tells us how wide the stroke will be from a given midpoint.
		
		// Figure out the perpendicular to the velocity vector.
		float velLength = sqrt(sq(currP.getXVel()) + sq(currP.getYVel()));
		currPerp = new PVector();
		if(velLength > 0) {
		    currPerp.x = -(currP.getYVel() / velLength);
		    currPerp.y = currP.getXVel() / velLength;
		}
		
                // See if this is the first quad we're drawing (rather, a triangle).
                if(currPointIndex == 1) {
                    currMid = interpolateBetweenPoints(lastP.getPosition(), currP.getPosition(), 0.5f);
                    
                    PVector m1 = new PVector();
                    PVector m2 = new PVector();
                    m1.x = currMid.x - currPerp.x * currAmp;
                    m1.y = currMid.y - currPerp.y * currAmp;
                    m2.x = currMid.x + currPerp.x * currAmp;
                    m2.y = currMid.y + currPerp.y * currAmp;
                    
                    // Draw the fill
                    fill(STROKE_COLOR, 0.05 * 255);
                    beginShape(TRIANGLES);
                    vertex(lastP.getX(), lastP.getY());
                    vertex(m2.x, m2.y);
                    vertex(m1.x, m1.y);
                    endShape();
                    noFill();
                    
                    // Draw the lines
                    stroke(STROKE_COLOR, 128);
                    line(lastP.getX(), lastP.getY(), m2.x, m2.y);
                    stroke(STROKE_COLOR, 25);
                    line(m2.x, m2.y, m1.x, m1.y);
                    stroke(STROKE_COLOR, 128);
                    line(m1.x, m1.y, lastP.getX(), lastP.getY());
                    noStroke();
                    
                } else {
                    currMid = interpolateBetweenPoints(lastP.getPosition(), currP.getPosition(), 0.5f);
                    PVector p1 = new PVector();
                    PVector p2 = new PVector();
                    PVector p3 = new PVector();
                    PVector p4 = new PVector();
                    
                    p1.x = lastMid.x - lastPerp.x * lastAmp;
                    p1.y = lastMid.y - lastPerp.y * lastAmp;

                    p2.x = lastMid.x + lastPerp.x * lastAmp;
                    p2.y = lastMid.y + lastPerp.y * lastAmp;
		
                    p3.x = currMid.x - currPerp.x * currAmp;
                    p3.y = currMid.y - currPerp.y * currAmp;

                    p4.x = currMid.x + currPerp.x * currAmp;
                    p4.y = currMid.y + currPerp.y * currAmp;
                    
                    // Draw the fill.
                    fill(STROKE_COLOR, 0.05 * 255);
                    beginShape(QUADS);
                    vertex(p1.x, p1.y);
                    vertex(p2.x, p2.y);
                    vertex(p4.x, p4.y);
                    vertex(p3.x, p3.y);
                    endShape();
                    noFill();
                    
                    // Draw the lines.
                    stroke(STROKE_COLOR, 25);
                    line(p1.x, p1.y, p2.x, p2.y);
                    stroke(STROKE_COLOR, 128);
                    line(p2.x, p2.y, p4.x, p4.y);
                    stroke(STROKE_COLOR, 25);
                    line(p4.x, p4.y, p3.x, p3.y);
                    stroke(STROKE_COLOR, 128);
                    line(p3.x, p3.y, p1.x, p1.y);
                    noStroke();
                    
                    // Draw a final triangle if this is the last point.
                    if(currPointIndex == currStroke.size() - 1) {
                        
                        // Draw the fill.
                        fill(STROKE_COLOR, 0.05 * 255);
                        beginShape(TRIANGLES);
                        vertex(p3.x, p3.y);
                        vertex(p4.x, p4.y);
                        vertex(currP.getX(), currP.getY());
                        endShape();
                        noFill();
                        
                        // Now the lines.
                        stroke(STROKE_COLOR, 25);
                        line(p3.x, p3.y, p4.x, p4.y);
                        stroke(STROKE_COLOR, 128);
                        line(p4.x, p4.y, currP.getX(), currP.getY());
                        line(currP.getX(), currP.getY(), p3.x, p3.y);
                        noStroke();
                        
                    }
                }
                
                lastMid = new PVector();
                lastMid.set(currMid);
                lastPerp = new PVector();
                lastPerp.set(currPerp);
                lastAmp = currAmp;
            }
        } else {
            // We're done with this stroke.
            isCurrStrokeDoneRendering = true;            
            println("Stroke index " + currStrokeIndex + " is done renderering!");
        }
        
    }
    
}


// ===================================================================================================
// keyPressed()
// 
// Callback for handling UP and DOWN arrow key events, so we can move to prev and next strokes.
// ---------------------------------------------------------------------------------------------------

void keyPressed() {
   if(keyCode == UP) {
       
       // Go to the prev stroke.
       currStrokeIndex--;
       if(currStrokeIndex < 0) {
           currStrokeIndex = data.getNumStrokes() - 1;
       }
       prepareCurrentStroke();
       
   } else if(keyCode == DOWN) {
       
       // Go to the next stroke.
       currStrokeIndex++;
       if(currStrokeIndex > data.getNumStrokes() - 1) {
           currStrokeIndex = 0;
       }
       prepareCurrentStroke();
       
   }
}

// ===================================================================================================
// easeInQuad()
// 
// Robert Penner's easeInQuad easing equation.
// ---------------------------------------------------------------------------------------------------

float easeInQuad(float t, float b, float c, float d) {
    return c * (t /= d) * t + b;
}


// ===================================================================================================
// interpolateBetweenPoints()
// 
// Performs a linear interpolation between two points.
// ---------------------------------------------------------------------------------------------------

PVector interpolateBetweenPoints(PVector pt1, PVector pt2, float amount) {
    if(amount > 1)
        amount = 1.f;
    if(amount < 0)
        amount = 0.f;
    PVector ptInt = new PVector();
    ptInt.x = lerp(pt1.x, pt2.x, amount);
    ptInt.y = lerp(pt1.y, pt2.y, amount);
    return ptInt;
}
