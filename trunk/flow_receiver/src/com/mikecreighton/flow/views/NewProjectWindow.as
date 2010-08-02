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
	import com.mikecreighton.flow.services.NewProjectService;

	import org.casalib.events.ProcessEvent;
	import org.casalib.util.StageReference;
	import org.casalib.util.StringUtil;

	import flash.events.MouseEvent;

	/**
	 * @author Mike Creighton
	 */
	public class NewProjectWindow extends ModalWindow 
	{
		private static const H_MARGIN : int = 20;

		private var _projectNameLabel : Label;
		private var _projectNameInput : InputText;
		private var _newProjectService : NewProjectService;
		private var _newProjectId : int;

		public function NewProjectWindow()
		{
			super('Create New Project');
			init();
		}

		override public function init() : void 
		{
			_newProjectId = -1;
			
			_windowWidth = StageReference.getStage().stageWidth - H_MARGIN * 2;
			_windowHeight = 160;
			
			_projectNameLabel = new Label(_window, 20, 40, 'Project Name');
			_projectNameInput = new InputText(_window, 20, 70);
			_projectNameInput.width = _windowWidth - H_MARGIN * 2;
			_projectNameInput.enabled = false;
			
			super.init();
		}

		override public function activate() : void 
		{
			super.activate();
			_projectNameInput.enabled = true;
			StageReference.getStage().focus = _projectNameInput.textField;
		}

		override public function deactivate() : void 
		{
			super.deactivate();			
			_projectNameInput.enabled = false;
		}

		override protected function _onOkayClick(event : MouseEvent) : void 
		{
			// Make sure we've actually got something in there.
			var whitespaceRemoved : String = StringUtil.removeWhitespace(_projectNameInput.text);
			if(whitespaceRemoved != '')
			{
				var projectName : String = _projectNameInput.text;
				if(_newProjectService != null)
				{
					_newProjectService.destroy();
					_newProjectService = null;
				}
				
				_newProjectService = new NewProjectService(projectName);
				_newProjectService.addEventListener(ProcessEvent.COMPLETE, _onNewProjectComplete, false, 0, true);
				_newProjectService.start();
				
				deactivate();
			}
		}

		private function _onNewProjectComplete(event : ProcessEvent) : void 
		{
			_newProjectId = _newProjectService.project.id;
			
			if(_newProjectService != null)
			{
				_newProjectService.destroy();
				_newProjectService = null;
			}
			// Now transition out.
			transitionOut();
		}

		public function get newProjectId() : int
		{
			return _newProjectId;
		}

		override public function destroy() : void 
		{
			deactivate();
			
			if(_newProjectService != null)
			{
				_newProjectService.destroy();
				_newProjectService = null;
			}
			
			_window.removeChild(_projectNameLabel);
			_window.removeChild(_projectNameInput);
			_projectNameLabel = null;
			_projectNameInput = null;
			
			super.destroy();
		}
	}
}
