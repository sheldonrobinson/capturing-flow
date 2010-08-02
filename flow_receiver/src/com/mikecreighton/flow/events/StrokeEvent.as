/**
 * 
 * Copyright (c) 2010, Michael Creighton
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without 
 * modification, are permitted provided that the following conditions are met:
 * 
 *     * Redistributions of source code must retain the above copyright notice,
 *       this list of conditions and the following disclaimer.
 * 
 *     * Redistributions in binary form must reproduce the above copyright 
 *       notice, this list of conditions and the following disclaimer in the 
 *       documentation and/or other materials provided with the distribution.
 * 
 *     * Neither the name of the organization nor the names of its
 * 	  contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 * 
 */
package com.mikecreighton.flow.events 
{
	import com.mikecreighton.flow.data.StrokePoint;

	import flash.events.Event;

	/**
	 * @author Mike Creighton
	 */
	public class StrokeEvent extends Event 
	{
		public static const ADD : String = 'add';
		public static const MOVE : String = 'move';
		public static const REMOVE : String = 'remove';
		
		private var _point : StrokePoint;
		
		public function StrokeEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
		
		public function set strokePoint(p : StrokePoint) : void
		{
			_point = p.clone();
		}
		
		public function get strokePoint() : StrokePoint
		{
			return _point.clone();
		}

		override public function clone() : Event 
		{
			var e : StrokeEvent = new StrokeEvent(type, bubbles, cancelable);
			e.strokePoint = this.strokePoint;
			return e;
		}
	}
}
