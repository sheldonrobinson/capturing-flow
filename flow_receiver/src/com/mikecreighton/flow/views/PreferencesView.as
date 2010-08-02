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
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.mikecreighton.flow.data.Config;

	import org.casalib.util.StageReference;
	import org.casalib.util.StringUtil;

	import flash.events.MouseEvent;

	/**
	 * Modal view for letting user change the Flow Storage URL and TUIO server host
	 * and port settings. Automatically updates the Config settings upon close.
	 * 
	 * @author Mike Creighton
	 */
	public class PreferencesView extends ModalWindow 
	{
		private static const H_MARGIN : int = 20; 
		private static const V_MARGIN : int = 20;

		private var _flowServerLabel : Label;
		private var _flowServerInput : InputText;
		private var _tuioHostLabel : Label;
		private var _tuioHostInput : InputText;
		private var _tuioPortLabel : Label;
		private var _tuioPortInput : InputText;

		public function PreferencesView()
		{
			super('Preferences');
			init();
		}

		override public function init() : void 
		{
			_windowWidth = StageReference.getStage().stageWidth - H_MARGIN * 2;
			_windowHeight = 210;
			
			_flowServerLabel = new Label(_window, H_MARGIN, V_MARGIN + 10, 'Flow Storage Server URL');
			_flowServerInput = new InputText(_window, _flowServerLabel.x, _flowServerLabel.y + 20, Config.getInstance().flowStorageURL);
			_flowServerInput.width = _windowWidth / 2 - H_MARGIN * 2;
			
			_tuioHostLabel = new Label(_window, H_MARGIN, _flowServerLabel.y + 60, 'TUIO FLOSC Server Host');
			_tuioHostInput = new InputText(_window, _tuioHostLabel.x, _tuioHostLabel.y + 20, Config.getInstance().server);
			_tuioHostInput.width = _flowServerInput.width;
			
			_tuioPortLabel = new Label(_window, _windowWidth / 2 + H_MARGIN, _tuioHostLabel.y, 'TUIO FLOSC Server Port');
			_tuioPortInput = new InputText(_window, _tuioPortLabel.x, _tuioHostInput.y, Config.getInstance().port.toString());
			_tuioPortInput.width = _flowServerInput.width;
			_tuioPortInput.restrict = '0123456789';
			
			super.init();
		}

		override protected function _onOkayClick(event : MouseEvent) : void
		{
			// This means we save any settings made.
			
			// Get the flow server URL, make sure it's got http:// in the front.
			var flowServerURL : String = _flowServerInput.text;
			flowServerURL = StringUtil.removeWhitespace(flowServerURL);
			if(flowServerURL.indexOf('http://') < 0)
			{
				flowServerURL = 'http://' + flowServerURL;
			}
			// Make sure there's a trailing slash at the end.
			if(flowServerURL.charAt(flowServerURL.length - 1) != '/')
			{
				flowServerURL += '/';
			}
			
			var tuioHost : String = StringUtil.removeWhitespace(_tuioHostInput.text);
			var tuioPort : int = parseInt(_tuioPortInput.text, 10);
			
			var c : Config = Config.getInstance();
			c.flowStorageURL = flowServerURL;
			c.server = tuioHost;
			c.port = tuioPort;
			c.updateUserSettingsFile();
			
			transitionOut();
		}

		override public function destroy() : void 
		{
			_window.removeChild(_flowServerLabel);
			_flowServerLabel = null;
			_window.removeChild(_flowServerInput);
			_flowServerInput = null;
			_window.removeChild(_tuioHostInput);
			_tuioHostInput = null;
			_window.removeChild(_tuioHostLabel);
			_tuioHostLabel = null;
			_window.removeChild(_tuioPortInput);
			_tuioPortInput = null;
			_window.removeChild(_tuioPortLabel);
			_tuioPortLabel = null;
			
			super.destroy();
		}
	}
}
