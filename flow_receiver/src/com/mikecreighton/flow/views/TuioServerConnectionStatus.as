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
	import com.bit101.components.IndicatorLight;
	import com.bit101.components.Panel;
	import com.greensock.TweenMax;
	import com.greensock.easing.Expo;
	import com.mikecreighton.flow.tuio.TuioManager;
	import com.mikecreighton.framework.display.BaseTransitioningSprite;

	import org.casalib.util.StageReference;

	import flash.events.Event;

	/**
	 * @author Mike Creighton
	 */
	public class TuioServerConnectionStatus extends BaseTransitioningSprite 
	{
		public static const HEIGHT : int = 20;

		private static const COLOR_CONNECTED : int = 0x63B20F;
		private static const COLOR_DISCONNECTED : int = 0xC52D33;
		private static const LABEL_CONNECTED : String = 'TUIO Server Connected';
		private static const LABEL_DISCONNECTED : String = 'TUIO Server Not Connected';

		private var _panel : Panel;
		private var _light : IndicatorLight;

		public function TuioServerConnectionStatus()
		{
			super();
			init();
		}

		override public function init() : void 
		{
			super.init();
			
			_panel = new Panel(this, 0, 0);
			_panel.setSize(StageReference.getStage().stageWidth, HEIGHT);
			// _panel.color = 0xFF00FF;

			_light = new IndicatorLight(_panel, 10, 5, COLOR_DISCONNECTED, LABEL_DISCONNECTED);
			_light.isLit = true;
			
			TuioManager.getInstance().addEventListener(Event.CONNECT, _onServerConnected, false, 0, true);
			TuioManager.getInstance().addEventListener(Event.CLOSE, _onServerDisconnect, false, 0, true);
			
			if(TuioManager.getInstance().connected)
			{
				_onServerConnected(null);
			}
			
			y = StageReference.getStage().stageHeight;
		}

		override public function transitionIn() : void 
		{
			super.transitionIn();
			
			TweenMax.to(this, 0.6, {y: StageReference.getStage().stageHeight - HEIGHT, roundProps: ['y'], ease: Expo.easeOut, onComplete: _completeTransitionIn});
		}

		override protected function _completeTransitionIn() : void 
		{
			super._completeTransitionIn();
			// y = Math.floor(StageReference.getStage().stageHeight - HEIGHT);
		}

		private function _onServerDisconnect(event : Event) : void 
		{
			_light.label = LABEL_DISCONNECTED;
			_light.color = COLOR_DISCONNECTED;
		}

		private function _onServerConnected(event : Event) : void 
		{
			_light.label = LABEL_CONNECTED;
			_light.color = COLOR_CONNECTED;
		}

		override public function destroy() : void 
		{
			_panel.removeChild(_light);
			_light = null;
			removeChild(_panel);
			_panel = null;
			
			TuioManager.getInstance().removeEventListener(Event.CONNECT, _onServerConnected);
			TuioManager.getInstance().removeEventListener(Event.CLOSE, _onServerDisconnect);
			
			super.destroy();
		}
	}
}
