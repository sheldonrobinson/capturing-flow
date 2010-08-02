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
package  
{
	import com.greensock.OverwriteManager;
	import com.mikecreighton.flow.data.Config;
	import com.mikecreighton.flow.tuio.TuioManager;
	import com.mikecreighton.flow.views.MainView;
	import com.mikecreighton.flow.views.PreferencesView;
	import com.mikecreighton.framework.events.TransitionEvent;

	import org.casalib.time.Interval;
	import org.casalib.util.StageReference;

	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;

	/**
	 * @author Mike Creighton
	 */
	public class FlowReceiverApp extends Sprite
	{
		public static const APP_WIDTH : int = 400;
		public static const APP_HEIGHT : int = 600;

		private var _config : Config;
		private var _windowChecker : Interval;
		private var _initializeDelay : Interval;
		private var _initPreferences : PreferencesView;
		private var _mainView : MainView;

		public function FlowReceiverApp()
		{
			addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
			if(stage != null) _onAddedToStage(null);
		}

		/**
		 * Sets up some initial stage preferences, initializes our Logger,
		 * and creates a checker to make sure our window is the right size.
		 */
		private function _onAddedToStage(event : Event) : void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
			
			StageReference.setStage(stage);
			var s : Stage = StageReference.getStage();
			s.align = StageAlign.TOP_LEFT;
			s.scaleMode = StageScaleMode.NO_SCALE;
			
			OverwriteManager.init();
			
			_initializeDelay = Interval.setTimeout(_initialize, 500);
			
			// Now we want to show the window, but only if it has sized itself correctly.			
			if(s.nativeWindow.width != APP_WIDTH && s.nativeWindow.height != APP_HEIGHT)
			{
				_windowChecker = Interval.setInterval(_checkForWindow, 50);
				_windowChecker.start();
			}
			else
			{
				_initializeDelay.start();
			}
		}

		private function _checkForWindow() : void
		{
			var s : Stage = StageReference.getStage();
			if(s.nativeWindow.width == APP_WIDTH && s.nativeWindow.height == APP_HEIGHT)
			{
				_windowChecker.destroy();
				_windowChecker = null;
				_initializeDelay.start();
			}
		}

		/**
		 * Kicks off the program.
		 */
		private function _initialize() : void
		{
			_initializeDelay.destroy();
			_initializeDelay = null;
			
			StageReference.getStage().nativeWindow.visible = true;
			
			// Check to see if the configuration file exists.
			var showPreferencesFirst : Boolean = !Config.configFileExists; 
			if( !Config.configFileExists )
			{
				// Create the default configuration file and show the Preferences window.
				Config.createDefaultConfigFile();
			}
			
			// Load up user configuration.
			_config = Config.getInstance();
			
			// Now, if we need to show preferences, we need to do that first, then we
			// can proceed with all the connection stuff.
			// Otherwise, we'll do the default startup.
			if( showPreferencesFirst )
			{
				_initPreferences = new PreferencesView();
				_initPreferences.addEventListener(TransitionEvent.TRANSITION_IN_COMPLETE, _onPreferencesReady);
				_initPreferences.addEventListener(TransitionEvent.TRANSITION_OUT_COMPLETE, _onPreferencesClosed);
				addChild(_initPreferences);
				_initPreferences.transitionIn();
			}
			else
			{
				_createDefaultViews();
			}
		}

		private function _onPreferencesReady(event : TransitionEvent) : void 
		{
			_initPreferences.activate();
		}

		private function _onPreferencesClosed(event : TransitionEvent) : void 
		{
			_initPreferences.destroy();
			_initPreferences = null;
			
			_createDefaultViews();
		}

		private function _createDefaultViews() : void
		{
			TuioManager.getInstance().connectToServer();
			
			_mainView = new MainView();
			addChild(_mainView);
			_mainView.transitionIn();
		}
	}
}
