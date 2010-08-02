package com.mikecreighton.flow;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;

import processing.core.PApplet;
import processing.core.PVector;
import processing.xml.XMLElement;

public class FlowData {

	PApplet parent;
	
	public boolean ignoreRedundantPositions;
	public int minNumberOfPointsInStroke;
	
	private String dataSource;
	private float remapMinX;
	private float remapMaxX;
	private float remapMinY;
	private float remapMaxY;
	private ArrayList<ArrayList<FlowPoint>> strokes;

	public final static String VERSION = "##version##";
	
	/**
	 * Constructor.
	 * 
	 * @param theParent 
	 * 				Reference to your main Processing Applet 
	 * @param dataSource 
	 * 				Path to the GML file, relative to your sketch's data folder.
	 */
	public FlowData(PApplet theParent, String dataSource) {
		this.parent = theParent;
		this.parent.registerDispose(this);

		minNumberOfPointsInStroke = 0;
		setRemapMaxX(1);
		setRemapMaxY(1);
		setRemapMinX(0);
		setRemapMinY(0);
		ignoreRedundantPositions = false;
		setDataSource(dataSource);
	}
	
	/**
	 * Loads the GML file and parses the data.
	 * 
	 * @return
	 * @throws FileNotFoundException
	 * @throws IOException
	 */
	public boolean load() throws FileNotFoundException, IOException {

		int startTime = parent.millis();
		
		// Read in the XML data file.
		XMLElement gml = new XMLElement(parent, dataSource);
		XMLElement[] strokeNodes = gml.getChildren("tag/drawing/stroke");

		// Declare some variables that we'll use in the loop.
		ArrayList<FlowPoint> stroke = null;
		PVector pos = null;
		PVector vel = null;
		FlowPoint pt = null;
		FlowPoint lastPt = null;
		int totalPoints = 0;
		
//		PApplet.println("Number of stroke nodes: " + strokeNodes.length);
		
		strokes = new ArrayList<ArrayList<FlowPoint>>();
		
		for (int i = 0; i < strokeNodes.length; i++) {
			XMLElement strokeNode = strokeNodes[i];

			// Create an array list to hold our flowpoints for this stroke.
			stroke = new ArrayList<FlowPoint>();
			lastPt = null;

			XMLElement[] pointNodes = strokeNode.getChildren("pt");
			
//			PApplet.println("Number of points in stroke: " + pointNodes.length);
			
			for (int j = 0; j < pointNodes.length; j++) {
				XMLElement pointNode = pointNodes[j];
				float x = PApplet.parseFloat(pointNode.getChild("x")
						.getContent());
				float y = PApplet.parseFloat(pointNode.getChild("y")
						.getContent());
				float time = PApplet.parseFloat(pointNode.getChild("time")
						.getContent());
				// Remap the positions.
				x = PApplet.map(x, 0.f, 1.f, getRemapMinX(), getRemapMaxX());
				y = PApplet.map(y, 0.f, 1.f, getRemapMinY(), getRemapMaxY());
				pos = new PVector(x, y);
				// Calc the velocity.
				vel = new PVector();
				if (lastPt != null) {
					vel.x = pos.x - lastPt.getX();
					vel.y = pos.y - lastPt.getY();
				}
				pt = new FlowPoint(pos, vel, time);

				// Figure out if we want to add this point to our stroke.
				boolean shouldAddPoint = false;
				if (ignoreRedundantPositions == true) {
					// Validate whether this point is the same as the last point
					if (lastPt != null) {
						if (pt.getX() != lastPt.getX()
								&& pt.getY() != lastPt.getY()) {
							shouldAddPoint = true;
						}
					} else {
						shouldAddPoint = true;
					}
				} else {
					shouldAddPoint = true;
				}
				if (shouldAddPoint) {
					totalPoints++;
					stroke.add(pt);
					lastPt = pt;
					pt = null;
				}
			}
			
			// Now see if our stroke is long enough.
			if(stroke.size() > minNumberOfPointsInStroke)
				strokes.add(stroke);
		}

		int parseTime = parent.millis() - startTime;

		PApplet.println("FlowData :: GML file parsing complete. Elapsed milliseconds: " + parseTime);
		PApplet.println("FlowData :: Total number of points: " + totalPoints);
		PApplet.println("FlowData :: Number of strokes: " + strokes.size());
		
		return true;
	}
	
	/**
	 * @return The number of strokes in the data set.
	 */
	public int getNumStrokes() {
		return strokes.size();
	}
	
	/**
	 * Gets a stroke's worth of data. If the strokeIndex is invalid,
	 * then null is returned.
	 * 
	 * @param strokeIndex Index of the stroke to return.
	 * 
	 * @return An ArrayList of FlowPoint instances in chronological order.
	 */
	public ArrayList<FlowPoint> getStroke(int strokeIndex)	{
		if(strokeIndex < strokes.size() && strokeIndex >= 0)
		{
			ArrayList<FlowPoint> points = strokes.get(strokeIndex);
			return points;
		}
		return null;
	}

	public void dispose() {
		strokes = null;
	}

	/**
	 * return the version of the library.
	 * 
	 * @return String
	 */
	public static String version() {
		return VERSION;
	}

	/**
	 * @param dataSource
	 *            Path to the GML file, relative to your sketch's data folder.
	 */
	public void setDataSource(String dataSource) {
		this.dataSource = dataSource;
	}

	/**
	 * @return Path to the GML file, relative to your sketch's data folder.
	 */
	public String getDataSource() {
		return dataSource;
	}
	
	/**
	 * Sets the remap rectangle for all points as they're parsed during the load process.
	 * The points' x and y values should originate as float values from 0 to 1. This
	 * can let you remap those values to your screen space as they're parsed. 
	 * 
	 * @param left
	 * @param top
	 * @param right
	 * @param bottom
	 */
	public void setRemapRect(float left, float top, float right, float bottom) {
		setRemapMinX(left);
		setRemapMaxX(right);
		setRemapMinY(top);
		setRemapMaxY(bottom);
	}

	/**
	 * @param remapMinX
	 *            The minimum remap X (left) of the remap rectangle
	 */
	public void setRemapMinX(float remapMinX) {
		this.remapMinX = remapMinX;
	}

	/**
	 * @return The minimum remap X (left) of the remap rectangle
	 */
	public float getRemapMinX() {
		return remapMinX;
	}

	/**
	 * @param remapMaxX
	 *            The maximum remap X (right) of the remap rectangle
	 */
	public void setRemapMaxX(float remapMaxX) {
		this.remapMaxX = remapMaxX;
	}

	/**
	 * @return The maximum remap X (right) of the remap rectangle
	 */
	public float getRemapMaxX() {
		return remapMaxX;
	}

	/**
	 * @param remapMinY
	 *            The minimum remap Y (top) of the remap rectangle
	 */
	public void setRemapMinY(float remapMinY) {
		this.remapMinY = remapMinY;
	}

	/**
	 * @return The minimum remap Y (top) of the remap rectangle
	 */
	public float getRemapMinY() {
		return remapMinY;
	}

	/**
	 * @param remapMaxY
	 *            The maximum remap Y (bottom) of the remap rectangle
	 */
	public void setRemapMaxY(float remapMaxY) {
		this.remapMaxY = remapMaxY;
	}

	/**
	 * @return The maximum remap Y (bottom) of the remap rectangle
	 */
	public float getRemapMaxY() {
		return remapMaxY;
	}
}
