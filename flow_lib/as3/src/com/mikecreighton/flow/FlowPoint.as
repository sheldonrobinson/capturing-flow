package com.mikecreighton.flow 
{
	import flash.geom.Point;

	/**
	 * @author Mike Creighton
	 */
	public class FlowPoint 
	{
		private var _pos : Point;
		private var _time : Number;
		private var _vel : Point;

		public function FlowPoint(position : Point, velocity : Point = null, time : Number = 0) 
		{
			_pos = position.clone();
			if(velocity != null)
			{
				_vel = velocity.clone();
			}
			else
			{
				_vel = new Point();
			}
			_time = time;
		}
		
		public function get pos() : Point
		{
			return _pos.clone();
		}
		
		public function get x() : Number
		{
			return _pos.x;
		}
		
		public function get y() : Number
		{
			return _pos.y;
		}

		public function set pos(pos : Point) : void
		{
			_pos = pos.clone();
		}
		
		public function get vel() : Point
		{
			return _vel.clone();
		}
		
		public function set vel(vel : Point) : void
		{
			_vel = vel.clone();
		}
		
		public function get xVel() : Number
		{
			return _vel.x;
		}
		
		public function get yVel() : Number
		{
			return _vel.y;
		}
		
		public function get time() : Number
		{
			return _time;
		}
		
		public function set time(time : Number) : void
		{
			_time = time;
		}
		
		public function destroy() : void
		{
			_pos = null;
			_vel = null;
		}
	}
}
