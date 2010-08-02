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
package com.mikecreighton.flow.views 
{
	import com.mikecreighton.flow.data.StrokePoint;
	import com.mikecreighton.flow.events.StrokeEvent;
	import com.mikecreighton.flow.tuio.TuioManager;
	import com.mikecreighton.framework.display.BaseTransitioningSprite;
	import com.mikecreighton.util.DrawUtil;

	import org.casalib.display.CasaSprite;

	import flash.geom.Rectangle;

	/**
	 * @author Mike Creighton
	 */
	public class PointsVisualizer extends BaseTransitioningSprite 
	{

		private static const VERT_MARGIN : int = 20;
		private static const HORZ_MARGIN : int = 20;

		private var _areaWidth : Number;
		private var _areaHeight : Number;
		private var _debugArea : CasaSprite;
		private var _debugHolder : CasaSprite;
		private var _debugMask : CasaSprite;
		private var _debugRect : Rectangle;
		private var _points : Vector.<PointIndicator>;

		public function PointsVisualizer( areaWidth : Number, areaHeight : Number) 
		{
			super();
			
			_areaWidth = areaWidth;
			_areaHeight = areaHeight;
			
			init();
		}

		override public function init() : void 
		{
			super.init();
			
			_debugRect = new Rectangle(HORZ_MARGIN, VERT_MARGIN, _areaWidth - HORZ_MARGIN * 2, _areaHeight - VERT_MARGIN * 2);
			_debugArea = new CasaSprite();
			DrawUtil.drawRect(_debugArea.graphics, _debugRect.x, _debugRect.y, _debugRect.width, _debugRect.height, 0x020202, 1);
			
			DrawUtil.drawRect(_debugArea.graphics, _debugRect.x - 1, _debugRect.y - 1, _debugRect.width + 2, 1, 0x1C1C1C, 1);
			DrawUtil.drawRect(_debugArea.graphics, _debugRect.x - 1, _debugRect.bottom, _debugRect.width + 2, 1, 0x1C1C1C, 1);
			
			DrawUtil.drawRect(_debugArea.graphics, _debugRect.x - 1, _debugRect.y, 1, _debugRect.height, 0x1C1C1C, 1);
			DrawUtil.drawRect(_debugArea.graphics, _debugRect.right, _debugRect.y, 1, _debugRect.height, 0x1C1C1C, 1);
			addChild(_debugArea);
			
			_debugHolder = new CasaSprite();
			_debugHolder.x = _debugRect.x;
			_debugHolder.y = _debugRect.y;
			addChild(_debugHolder);
			
			_debugMask = new CasaSprite();
			_debugMask.x = _debugRect.x;
			_debugMask.y = _debugRect.y;
			DrawUtil.drawRect(_debugMask.graphics, 0, 0, _debugRect.width, _debugRect.height, 0xFFFFFF, 1);
			addChild(_debugMask);
			
			_debugHolder.mask = _debugMask;
			
			_points = new Vector.<PointIndicator>();
			
			TuioManager.getInstance().addEventListener(StrokeEvent.ADD, _onPointMoved, false, 0, true);
			TuioManager.getInstance().addEventListener(StrokeEvent.MOVE, _onPointMoved, false, 0, true);
			TuioManager.getInstance().addEventListener(StrokeEvent.REMOVE, _onPointRemoved, false, 0, true);
		}

		private function _onPointMoved(event : StrokeEvent) : void 
		{
			// Verify this point doesn't exist yet.
			var found : Boolean = false;
			var p : PointIndicator;
			var sp : StrokePoint = event.strokePoint;
			for each (p in _points) 
			{
				if(p.id == sp.id) 
				{
					found = true;
					break;
				}
			}
			
			if(!found) 
			{
				p = new PointIndicator();
				p.id = sp.id;
				_debugHolder.addChild(p);
				_points.push(p);
			}
			
			p.x = sp.x * _debugRect.width;
			p.y = sp.y * _debugRect.height;
			p.updateLabel(sp.x, sp.y);
		}

		private function _onPointRemoved(event : StrokeEvent) : void 
		{
			var found : Boolean = false;
			var p : PointIndicator;
			var sp : StrokePoint = event.strokePoint;
			for each (p in _points) 
			{
				if(p.id == sp.id) 
				{
					found = true;
					break;
				}
			}
			if(found) 
			{
				_points.splice(_points.indexOf(p), 1);
				p.destroy();
			}
		}

		override public function destroy() : void 
		{
			TuioManager.getInstance().removeEventListener(StrokeEvent.ADD, _onPointMoved);
			TuioManager.getInstance().removeEventListener(StrokeEvent.MOVE, _onPointMoved);
			TuioManager.getInstance().removeEventListener(StrokeEvent.REMOVE, _onPointRemoved);
			
			while(_points.length > 0)
			{
				var p : PointIndicator = _points.pop() as PointIndicator;
				p.destroy();
			}
			_points = null;
			_debugRect = null;
			
			_debugHolder.mask = null;
			_debugHolder.destroy();
			_debugHolder = null;
			
			_debugMask.destroy();
			_debugMask = null;
			
			_debugArea.destroy();
			_debugArea = null;
			
			super.destroy();
		}
	}
}

import org.casalib.display.CasaShape;
import org.casalib.util.NumberUtil;

import com.mikecreighton.text.BaseTextField;

import org.casalib.display.CasaSprite;

class PointIndicator extends CasaSprite 
{

	public var id : int;
	private var _circ : CasaShape;
	private var _pos : BaseTextField;

	public function PointIndicator() 
	{
		super();
		_circ = new CasaShape();
		addChild(_circ);
		_circ.graphics.lineStyle(1, 0xc3c32a, 0.6);
		_circ.graphics.beginFill(0xc3c32a, 0.3);
		_circ.graphics.drawCircle(0, 0, 20);
		_circ.graphics.endFill();
		
		_circ.graphics.lineStyle();
		_circ.graphics.beginFill(0xc3c32a, 1);
		_circ.graphics.drawCircle(0, 0, 2);
		_circ.graphics.endFill();
		
		_pos = new BaseTextField();
		_pos.embedFonts = false;
		_pos.font = 'Courier New';
		_pos.fontSize = 8;
		_pos.textColor = 0xCCCCCC;
		_pos.background = true;
		_pos.backgroundColor = 0x000000;
		_pos.border = true;
		_pos.borderColor = 0x777777;
		_pos.text = '0, 0';
		_pos.y -= 22;
		_pos.x = 24;
		addChild(_pos);
	}

	public function updateLabel(xPos : Number, yPos : Number) : void
	{
		_pos.text = NumberUtil.roundDecimalToPlace(xPos, 3) + ', ' + NumberUtil.roundDecimalToPlace(yPos, 3);
	}

	override public function destroy() : void 
	{
		_pos.destroy();
		_pos = null;
		_circ.destroy();
		_circ.graphics.clear();
		_circ = null;
		super.destroy();
	}
}


