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
	import com.mikecreighton.flow.events.ProjectWindowEvent;
	import com.mikecreighton.framework.events.TransitionEvent;
	import com.mikecreighton.framework.display.BaseTransitioningSprite;

	import org.casalib.display.CasaSprite;

	/**
	 * @author Mike Creighton
	 */
	public class MainView extends BaseTransitioningSprite 
	{
		private var _connectionIndicator : TuioServerConnectionStatus;

		private var _holder : CasaSprite; // Main holder for all views.
		private var _home : HomeView;
		private var _project : ProjectView;

		public function MainView()
		{
			super();
			init();
		}

		override public function init() : void 
		{
			_holder = new CasaSprite();
			addChild(_holder);
			
			_home = new HomeView();
			_holder.addChild(_home);
			
			_connectionIndicator = new TuioServerConnectionStatus();
			addChild(_connectionIndicator);
		}

		override public function transitionIn() : void 
		{
			super.transitionIn();
			
			_home.addEventListener(TransitionEvent.TRANSITION_IN_COMPLETE, _onHomeTransitionInComplete, false, 0, true);
			_home.transitionIn();
			_connectionIndicator.transitionIn();
		}

		private function _onHomeTransitionInComplete(event : TransitionEvent) : void
		{
			_home.removeEventListener(TransitionEvent.TRANSITION_IN_COMPLETE, _onHomeTransitionInComplete);
			activate();
		}

		override public function activate() : void 
		{
			super.activate();
			
			if(_home)
			{
				_home.activate();
				_home.addEventListener(ProjectWindowEvent.OPEN_PROJECT, _onProjectViewOpenRequest, false, 0, true);
			}
			if(_project)
			{
				_project.activate();
				_project.addEventListener(ProjectWindowEvent.CLOSE_PROJECT, _onProjectViewCloseRequest, false, 0, true);
			}
		}

		private function _onProjectViewOpenRequest(event : ProjectWindowEvent) : void 
		{
			// Deactivate everything.
			deactivate();
			// Create a new project view.
			_project = new ProjectView(event.projectData);
			_holder.addChild(_project);
			_project.addEventListener(TransitionEvent.TRANSITION_IN_COMPLETE, _onProjectViewTransitionInComplete, false, 0, true);
			_project.transitionIn();
		}		

		private function _onProjectViewTransitionInComplete(event : TransitionEvent) : void 
		{
			// Now that it's covering up the Home view, let's destroy the home view and activate everything.
			_project.removeEventListener(TransitionEvent.TRANSITION_IN_COMPLETE, _onProjectViewTransitionInComplete);
			_home.destroy();
			_home = null;
			activate();			
		}

		private function _onProjectViewCloseRequest(event : ProjectWindowEvent) : void 
		{
			deactivate();
			
			// Let's go back home.
			_home = new HomeView();
			_home.visible = true;
			_home.alpha = 1;
			
			_holder.addChild(_home);
			_holder.addChild(_project); // Keep the project on top.
			_project.addEventListener(TransitionEvent.TRANSITION_OUT_COMPLETE, _onProjectViewTransitionOutComplete, false, 0, true);
			_project.transitionOut();
		}

		private function _onProjectViewTransitionOutComplete(event : TransitionEvent) : void 
		{
			// Now that it's covering up the Home view, let's destroy the home view and activate everything.
			_project.removeEventListener(TransitionEvent.TRANSITION_OUT_COMPLETE, _onProjectViewTransitionOutComplete);
			_project.destroy();
			_project = null;
			activate();			
		}

		override public function deactivate() : void 
		{
			super.deactivate();
			
			if(_home)
			{
				_home.deactivate();
				_home.removeEventListener(ProjectWindowEvent.OPEN_PROJECT, _onProjectViewOpenRequest);
			}
			if(_project)
			{
				_project.deactivate();
				_project.removeEventListener(ProjectWindowEvent.CLOSE_PROJECT, _onProjectViewCloseRequest);
			}
		}
	}
}
