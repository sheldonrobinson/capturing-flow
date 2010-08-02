package com.mikecreighton.flow 
{
	import org.casalib.util.NumberUtil;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import org.casalib.events.LoadEvent;
	import org.casalib.events.RemovableEventDispatcher;
	import org.casalib.load.DataLoad;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Point;

	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	
	[Event(name="securityError", type="flash.events.SecurityErrorEvent")]
	
	[Event(name="complete", type="flash.events.Event")]

	/**
	 * @author Mike Creighton
	 */
	public class FlowData extends RemovableEventDispatcher 
	{
		private var _startedGMLLoad : Boolean;
		private var _gmlLoad : DataLoad;
		private var _strokes : Vector.<Vector.<FlowPoint>>;
		private var _minNumberOfPointsInStroke : int;
		private var _remapPointsToRect : Boolean;
		private var _remapRect : Rectangle;
		private var _ignoreRedundantPositions : Boolean;
		
		/**
		 * @param dataSource String representing the path to a Flow GML data file
		 * @param minNumberOfPointsInStroke [optional] Minimum number of points required for a stroke to be stored in strokes data set. Defaults to 0. 
		 * @param remapRect [optional] Rectangle specifying the new coordinate space for remapping the source GML point data
		 * @param ignoreRedundantPositions [optional] Instructs the parser to ignore sequentially-same point data. Set to true to get better velocity data.
		 */
		public function FlowData(dataSource : String, minNumberOfPointsInStroke : int = 0, remapRect : Rectangle = null, ignoreRedundantPositions : Boolean = false)
		{
			super();
			_startedGMLLoad = false;
			_ignoreRedundantPositions = ignoreRedundantPositions;
			_minNumberOfPointsInStroke = minNumberOfPointsInStroke;
			_remapPointsToRect = remapRect != null;
			_remapRect = remapRect.clone();
			_gmlLoad = new DataLoad(dataSource);
			_gmlLoad.addEventListener(LoadEvent.PROGRESS, _onGMLLoadProgress, false, 0, true);
			_gmlLoad.addEventListener(LoadEvent.COMPLETE, _onGMLLoadComplete, false, 0, true);
			_gmlLoad.addEventListener(IOErrorEvent.IO_ERROR, _onGMLLoadError, false, 0, true);
			_gmlLoad.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _onGMLSecurityError, false, 0, true);
		}
		
		public function load() : void
		{
			if(!_startedGMLLoad)
			{
				_startedGMLLoad = true;
				_gmlLoad.start();
			}
		}

		private function _onGMLLoadError(event : IOErrorEvent) : void 
		{
			dispatchEvent(event);
		}

		private function _onGMLSecurityError(event : SecurityErrorEvent) : void 
		{
			dispatchEvent(event);
		}

		private function _onGMLLoadProgress(event : LoadEvent) : void 
		{
		}

		private function _onGMLLoadComplete(event : LoadEvent) : void 
		{
			trace("FlowData :: GML file load complete.");
			
			_strokes = new Vector.<Vector.<FlowPoint>>();
			
			var parseStartTime : Number = getTimer();
			
			// Need to parse through the GML.
			var gmlXML : XML = _gmlLoad.dataAsXml;
			var stroke : Vector.<FlowPoint>;
			var pt : FlowPoint;
			var lastPt : FlowPoint;
			var pos : Point;
			var vel : Point;
			var time : Number;
			var totalPoints : int = 0;
			for each (var strokeNode : XML in gmlXML..stroke) {
				// Create a new stroke.
				stroke = new Vector.<FlowPoint>();
				lastPt = null;
				for each (var ptNode : XML in strokeNode.pt) {
					pos = new Point();
					pos.x = parseFloat(ptNode.x.toString());
					pos.y = parseFloat(ptNode.y.toString());
					if(_remapPointsToRect)
					{
						pos.x = NumberUtil.map(pos.x, 0, 1, _remapRect.left, _remapRect.right);
						pos.y = NumberUtil.map(pos.y, 0, 1, _remapRect.top, _remapRect.bottom);
					}
					
					time = parseFloat(ptNode.time.toString());
					// Calc the velocity.
					vel = new Point();
					if(lastPt != null)
					{
						vel.x = pos.x - lastPt.x;
						vel.y = pos.y - lastPt.y;
					}
					pt = new FlowPoint(pos, vel, time);
					var shouldAddPoint : Boolean = false;
					if(_ignoreRedundantPositions == true)
					{
						// Validate whether this point is the same as the last point
						if(lastPt != null)
						{
							if(pt.x != lastPt.x && pt.y != lastPt.y)
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
						stroke.push(pt);
						lastPt = pt;
					}
				}
				if(stroke.length >= _minNumberOfPointsInStroke)
					_strokes.push(stroke);
			}
			
			var parseTime : Number = getTimer() - parseStartTime;
			
			trace("FlowData :: GML file parsing complete. Elapsed milliseconds: " + parseTime);
			trace("FlowData :: Total number of points: " + totalPoints);
			trace("FlowData :: Number of strokes: " + numStrokes);
			
			dispatchEvent(new Event(Event.COMPLETE, true));
		}
		
		/**
		 * @return The number of strokes in the data set.
		 */
		public function get numStrokes() : int
		{
			return _strokes.length;
		}
		
		/**
		 * Gets a stroke's worth of data. If the strokeIndex is invalid,
		 * then null is returned.
		 * 
		 * @param strokeIndex Index of the stroke to return.
		 * 
		 * @return A Vector of FlowPoint instances in chronological order.
		 */
		public function getStroke(strokeIndex : uint) : Vector.<FlowPoint>
		{
			if(strokeIndex < _strokes.length && strokeIndex >= 0)
			{
				return _strokes[strokeIndex].slice();
			}
			else
			{
				return null;
			}
		}

		override public function destroy() : void 
		{
			super.destroy();
		}
	}
}
