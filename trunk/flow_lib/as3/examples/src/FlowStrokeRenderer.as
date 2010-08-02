package  
{
	import com.mikecreighton.flow.FlowPoint;

	import org.casalib.display.CasaShape;
	import org.casalib.process.Process;
	import org.casalib.time.EnterFrame;

	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.geom.Point;

	/**
	 * @author Mike Creighton
	 */
	public class FlowStrokeRenderer extends Process 
	{
		private var _buffer : BitmapData;
		private var _stroke : Vector.<FlowPoint>;
		private var _currPointIndex : int;
		private var _canvas : CasaShape;

		private var _lastMid : Point;
		private var _lastPerp : Point;
		private var _lastAmp : Number;		

		private var _maxVelocity : Number;
		private var _minVelocity : Number;

		public function FlowStrokeRenderer(bitmapBuffer : BitmapData, stroke : Vector.<FlowPoint>)
		{
			super();
			_buffer = bitmapBuffer;
			_stroke = stroke; // This is a reference to the data... never modify this Vector
			_currPointIndex = -1;
			_canvas = new CasaShape();
			
			// Loop through all the points in our stroke and determine our min and max velocities.
			_minVelocity = 0;
			_maxVelocity = 0; // Set a low value to compare against.
			for each (var p : FlowPoint in _stroke) 
			{
				// Determine this point's velocity length.
				var velP : Point = p.pos.add(p.vel);
				var dist : Number = Point.distance(velP, p.pos);
				if(dist > _maxVelocity)
					_maxVelocity = dist;
			}
		}

		override public function start() : void 
		{
			super.start();
			EnterFrame.getInstance().addEventListener(Event.ENTER_FRAME, _renderNextPoint, false, 0, true);
		}

		/**
		 * Derived from Penner's easing equations
		 */
		private static function _easeInQuad(t : Number, b : Number, c : Number, d : Number) : Number 
		{
			return c * (t /= d) * t + b;
		}

		private function _renderNextPoint(event : Event) : void 
		{
			_currPointIndex++;
			// Check to make sure we haven't exceeded our total points.
			if(_currPointIndex < _stroke.length)
			{
				const FILL_COLOR : int = 0xC43D65;
				const STROKE_COLOR : int = 0x8D9018;
				
				var currP : FlowPoint = _stroke[_currPointIndex];
				var lastP : FlowPoint = null;
				var currMid : Point;
				var currPerp : Point;
				var currAmp : Number;
				
				if(_currPointIndex > 0)
				{
					lastP = _stroke[_currPointIndex - 1];
				}
				var g : Graphics = _canvas.graphics;
			
				// Draw an ellipse at this point position.	
				g.clear();
				g.beginFill(FILL_COLOR, 0.2);
				g.drawEllipse(currP.x - 2.5, currP.y - 2.5, 5, 5);
				g.endFill();
				
				// Draw this to the buffer.
				_buffer.draw(_canvas, null, null, BlendMode.ADD, null, false);
				g.clear();
				
				
				if(lastP != null)
				{
					// First determine the "amplitude" of this point's velocity.
					var velP : Point = currP.pos.add(currP.vel);
					var dist : Number = Point.distance(velP, currP.pos);
					currAmp = 1 - dist / _maxVelocity; // This is inversed because the FASTER the velocity, the thinner we want our stroke.
					// But we want the value to be logarithmic
					currAmp = _easeInQuad(currAmp, 0, 1, 1);
					currAmp *= 30;
					
					// Figure out the perpendicular to the velocity vector.
					var velLength : Number = Math.sqrt(currP.xVel * currP.xVel + currP.yVel * currP.yVel);
					currPerp = new Point();
					if(velLength > 0)
					{
						currPerp.x = -(currP.yVel / velLength);
						currPerp.y = currP.xVel / velLength;
					}
					
					
					// See if this is the first quad we're drawing.
					if(_currPointIndex == 1)
					{
						// We're going ot do something special here.
						// Draw a triangle from the last point to our midpoint.
						currMid = Point.interpolate(lastP.pos, currP.pos, 0.5);
						
						/*
						 *      m1
						 *    /  |
						 * lP    |    cP
						 *    \  |
						 *      m2
						 * 
						 */

						var m1 : Point = new Point();
						var m2 : Point = new Point();
						
						m1.x = currMid.x - currPerp.x * currAmp; 
						m1.y = currMid.y - currPerp.y * currAmp;
						
						m2.x = currMid.x + currPerp.x * currAmp; 
						m2.y = currMid.y + currPerp.y * currAmp; 
						
						
						g.beginFill(STROKE_COLOR, 0.05);
						g.lineStyle(0, STROKE_COLOR, 0.5, true);
							
						g.moveTo(lastP.x, lastP.y);
						g.lineTo(m2.x, m2.y);
						// Lighter mid-segment.
						g.lineStyle(0, STROKE_COLOR, 0.1, true);
						g.lineTo(m1.x, m1.y);
						g.lineStyle(0, STROKE_COLOR, 0.5, true);
						g.lineTo(lastP.x, lastP.y);
						
						g.endFill();
						
						_lastMid = currMid.clone();
						_lastPerp = currPerp.clone();
						_lastAmp = currAmp;
					}
					else
					{
						// This time, we're going to draw between the last mid-point and the curr midpoint.
						
						/*
						 *       p1 ----------- p3
						 *       |              |
						 *     lastM     lP    currM     cP
						 *       |              |
						 *       p2 ----------- p4
						 * 
						 */

						currMid = Point.interpolate(lastP.pos, currP.pos, 0.5);
						var p1 : Point = new Point();
						var p2 : Point = new Point();
						var p3 : Point = new Point();
						var p4 : Point = new Point();
						
						p1.x = _lastMid.x - _lastPerp.x * _lastAmp;
						p1.y = _lastMid.y - _lastPerp.y * _lastAmp;
						
						p2.x = _lastMid.x + _lastPerp.x * _lastAmp;
						p2.y = _lastMid.y + _lastPerp.y * _lastAmp;
						
						p3.x = currMid.x - currPerp.x * currAmp;
						p3.y = currMid.y - currPerp.y * currAmp;
						
						p4.x = currMid.x + currPerp.x * currAmp;
						p4.y = currMid.y + currPerp.y * currAmp;
						
						g.beginFill(STROKE_COLOR, 0.05);
						g.lineStyle(0, STROKE_COLOR, 0.1, true);
						
						g.moveTo(p1.x, p1.y);
						g.lineTo(p2.x, p2.y);
						
						g.lineStyle(0, STROKE_COLOR, 0.5, true);
						g.lineTo(p4.x, p4.y);
						
						g.lineStyle(0, STROKE_COLOR, 0.1, true);
						g.lineTo(p3.x, p3.y);
						
						g.lineStyle(0, STROKE_COLOR, 0.5, true);
						g.lineTo(p1.x, p1.y);
						
						g.endFill();
						
						_lastMid = currMid.clone();
						_lastPerp = currPerp.clone();
						_lastAmp = currAmp;
						
						// Draw a final triangle if this is the last point.
						if(_currPointIndex == _stroke.length - 1)
						{
							/*
							 *      p3 
							 *       | \  
							 *       |  \
							 * lP    |   cP
							 *       | /
							 *      p4
							 * 
							 */

							g.beginFill(STROKE_COLOR, 0.05);
							g.lineStyle(0, STROKE_COLOR, 0.1, true);
							
							g.moveTo(p3.x, p3.y);
							g.lineTo(p4.x, p4.y);
							
							g.lineStyle(0, STROKE_COLOR, 0.5, true);
							g.lineTo(currP.x, currP.y);
							g.lineTo(p3.x, p3.y);
							
							g.endFill();
						}
					}
						
					// Draw this to the buffer.
					_buffer.draw(_canvas, null, null, BlendMode.ADD, null, false);
					g.clear();
				}
			}
			else
			{
				// We're done rendering.
				_complete();
			}
		}

		override protected function _complete() : void 
		{
			EnterFrame.getInstance().removeEventListener(Event.ENTER_FRAME, _renderNextPoint);
			super._complete();
		}

		override public function destroy() : void 
		{
			EnterFrame.getInstance().removeEventListener(Event.ENTER_FRAME, _renderNextPoint);
			
			_canvas.graphics.clear();
			_canvas.destroy();
			_canvas = null;
			
			_buffer = null;
			_stroke = null;
			
			super.destroy();
		}
	}
}
