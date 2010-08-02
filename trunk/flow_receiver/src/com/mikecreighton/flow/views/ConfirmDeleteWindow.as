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
	import com.bit101.components.Label;
	import com.mikecreighton.flow.services.DeleteProjectService;

	import org.casalib.events.ProcessEvent;
	import org.casalib.util.StageReference;

	import flash.events.MouseEvent;

	/**
	 * @author Mike Creighton
	 */
	public class ConfirmDeleteWindow extends ModalWindow 
	{
		private var _message : Label;
		private var _message2 : Label;
		private var _message3 : Label;
		private var _projectId : int;
		private var _projectName : String;
		private var _deleteService : DeleteProjectService;
		private var _deletedProjectSuccessfully : Boolean;

		public function ConfirmDeleteWindow(projectId : int, projectName : String)
		{
			super('Confirm Project Deletion');
			_projectId = projectId;
			_projectName = projectName;
			_deletedProjectSuccessfully = false;
			init();
		}

		override public function init() : void 
		{
			_windowWidth = StageReference.getStage().stageWidth - 40;
			_windowHeight = 200;
			
			_message = new Label(_window, 20, 40, 'Are you sure you want to delete this project?');
			_message2 = new Label(_window, 20, 70, '   "' + _projectName + '"');
			_message3 = new Label(_window, 20, 100, 'There is no undo.');
			_message.width = StageReference.getStage().stageWidth - 80;
			_message2.width = StageReference.getStage().stageWidth - 80;
			_message3.width = StageReference.getStage().stageWidth - 80;
			
			_okayButton.label = 'Yes, delete it.';
			
			super.init();
		}

		override protected function _onOkayClick(event : MouseEvent) : void 
		{
			deactivate();
			
			if(_deleteService != null)
			{
				_deleteService.destroy();
				_deleteService = null;
			}
			_deleteService = new DeleteProjectService(_projectId);
			_deleteService.addEventListener(ProcessEvent.COMPLETE, _onProjectDeleted, false, 0, true);
			_deleteService.start();
		}

		private function _onProjectDeleted(event : ProcessEvent) : void 
		{
			_deletedProjectSuccessfully = _deleteService.resultCode == 0;
			if(_deleteService != null)
			{
				_deleteService.destroy();
				_deleteService = null;
			}
			transitionOut();
		}

		public function get deletedProjectSuccessfully() : Boolean
		{
			return _deletedProjectSuccessfully;
		}

		override public function destroy() : void 
		{
			deactivate();
			
			if(_deleteService != null)
			{
				_deleteService.destroy();
				_deleteService = null;
			}
			
			_window.removeChild(_message);
			_window.removeChild(_message2);
			_window.removeChild(_message3);
			_message = null;
			_message2 = null;
			_message3 = null;
			
			super.destroy();
		}
	}
}
