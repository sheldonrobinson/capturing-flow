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
	import com.bit101.components.List;
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.mikecreighton.flow.data.LastProjectSelected;
	import com.mikecreighton.flow.data.ProjectData;
	import com.mikecreighton.flow.events.ProjectWindowEvent;
	import com.mikecreighton.flow.services.ExportGMLCommand;
	import com.mikecreighton.flow.services.GetProjectsService;
	import com.mikecreighton.framework.display.BaseTransitioningSprite;
	import com.mikecreighton.framework.events.TransitionEvent;
	import com.mikecreighton.util.DrawUtil;

	import org.casalib.display.CasaShape;
	import org.casalib.events.ProcessEvent;
	import org.casalib.util.StageReference;

	import flash.events.Event;
	import flash.events.MouseEvent;

	[Event(name="openProject", type="com.mikecreighton.flow.events.ProjectWindowEvent")]

	/**
	 * @author Mike Creighton
	 */
	public class HomeView extends BaseTransitioningSprite 
	{		
		private static const TOP_MARGIN : int = 20;
		private static const HORZ_MARGIN : int = 10;
		private static var SW : int;
		private static var SH : int;

		private var _ground : CasaShape;

		private var _createPanel : Panel;
		private var _createButton : PushButton;
		private var _preferencesButton : PushButton;
		private var _prefsWindow : PreferencesView;

		private var _projectsPanel : Panel;
		private var _projectsPanelLabel : Label;
		private var _projectsList : List;
		private var _deleteProjectButton : PushButton;
		private var _exportGMLButton : PushButton;
		private var _openProjectButton : PushButton;

		private var _projects : Vector.<ProjectData>;
		private var _getProjectsService : GetProjectsService;
		private var _newProjectWindow : NewProjectWindow;
		private var _deleteProjectWindow : ConfirmDeleteWindow;

		private var _exportGMLCommand : ExportGMLCommand;
		private var _savingWindow : SavingGMLWindow;

		private var _newProjectId : int;

		public function HomeView()
		{
			super();
			init();
		}

		override public function init() : void 
		{
			super.init();
			
			_newProjectId = -1;
			
			SW = StageReference.getStage().stageWidth;
			SH = StageReference.getStage().stageHeight;
			
			_ground = new CasaShape();
			DrawUtil.drawRect(_ground.graphics, 0, 0, SW, SH, 0xCCCCCC);
			addChild(_ground);
			
			
			_createPanel = new Panel(this, HORZ_MARGIN, TOP_MARGIN);
			_createPanel.setSize(SW - HORZ_MARGIN * 2, 40);
			
			_createButton = new PushButton(_createPanel, 10, 10, 'Create New Project');
			_createButton.enabled = false;
			
			_preferencesButton = new PushButton(_createPanel, _createButton.width + 20, 10, 'Preferences');
			_preferencesButton.enabled = false;
			
			_projectsPanel = new Panel(this, HORZ_MARGIN, TOP_MARGIN + 40 + 20);
			_projectsPanel.setSize(SW - HORZ_MARGIN * 2, 460);
			
			_projectsPanelLabel = new Label(_projectsPanel, 10, 10, 'Existing Projects');
			
			_projectsList = new List(_projectsPanel, 10, 40);
			_projectsList.setSize(SW - HORZ_MARGIN * 4, 370);
			_projectsList.enabled = false;
			
			const BUT_Y : int = 425;
			_openProjectButton = new PushButton(_projectsPanel, 10, BUT_Y, 'Open Project');
			_exportGMLButton = new PushButton(_projectsPanel, 120, BUT_Y, 'Export GML');
			_deleteProjectButton = new PushButton(_projectsPanel, 230, BUT_Y, 'Delete Project');
			_deleteProjectButton.width = _exportGMLButton.width = _openProjectButton.width = 100;
			_deleteProjectButton.enabled = _exportGMLButton.enabled = _openProjectButton.enabled = false;
			// _deleteProjectButton.alpha = _exportGMLButton.alpha = _openProjectButton.alpha = .25;
			
			// Make the delete button red.
			TweenMax.to(_deleteProjectButton, 0, {colorMatrixFilter: {colorize: 0xC52D33, amount: .6}});
			
			visible = false;
			alpha = 0;
		}

		
		override public function transitionIn() : void 
		{
			super.transitionIn();
			TweenMax.to(this, 0.6, {autoAlpha: 1, ease: Quad.easeOut, onComplete: _completeTransitionIn});
		}

		override public function activate() : void 
		{
			super.activate();
			
			_createButton.enabled = true;
			_createButton.addEventListener(MouseEvent.CLICK, _onCreateClick, false, 0, true);
			
			_preferencesButton.enabled = true;
			_preferencesButton.addEventListener(MouseEvent.CLICK, _onPreferencesClick, false, 0, true);
			
			_projectsList.enabled = true;
			_projectsList.addEventListener(Event.SELECT, _onItemSelected, false, 0, true);
			
			_deleteProjectButton.enabled = _exportGMLButton.enabled = _openProjectButton.enabled = true;
			_deleteProjectButton.addEventListener(MouseEvent.CLICK, _onDeleteProjectClick, false, 0, true);
			_exportGMLButton.addEventListener(MouseEvent.CLICK, _onExportGMLClick, false, 0, true);
			_openProjectButton.addEventListener(MouseEvent.CLICK, _onOpenProjectClick, false, 0, true);
			
			if(_projects == null)
			{
				_updateProjectsList();
			}
			else
			{
				// Begin the routine for maintaining the last selected project in the projects list.

				if(LastProjectSelected.id != -1)
				{
					if(_projectsList.items.length > 0)
					{
						var selectedProject : ProjectData;
						var items : Array = _projectsList.items;
						for each (var pd : ProjectData in items) 
						{
							if(pd.id == LastProjectSelected.id)
							{
								selectedProject = pd;
								break;
							}
						}
						if(selectedProject != null)
						{
							_projectsList.selectedItem = selectedProject;
						}
						else
						{
							_projectsList.selectedIndex = 0;
							LastProjectSelected.id = (_projectsList.selectedItem as ProjectData).id;
						}
					}
				}
				else
				{
					if(_projectsList.items.length > 0)
					{
						_projectsList.selectedIndex = 0;
						LastProjectSelected.id = (_projectsList.selectedItem as ProjectData).id;
					}
				}
			}
		}

		private function _onItemSelected(event : Event) : void 
		{
			LastProjectSelected.id = (_projectsList.selectedItem as ProjectData).id;
		}

		private function _onCreateClick(event : MouseEvent) : void 
		{
			deactivate();
			_newProjectWindow = new NewProjectWindow();
			addChild(_newProjectWindow);
			_newProjectWindow.addEventListener(TransitionEvent.TRANSITION_OUT_COMPLETE, _onNewProjectWindowClosed);
			_newProjectWindow.transitionIn();
		}

		private function _onPreferencesClick(event : MouseEvent) : void 
		{
			deactivate();
			
			_prefsWindow = new PreferencesView();
		
			_prefsWindow.addEventListener(TransitionEvent.TRANSITION_IN_COMPLETE, _onPreferencesReady);
			_prefsWindow.addEventListener(TransitionEvent.TRANSITION_OUT_COMPLETE, _onPreferencesClosed);
			addChild(_prefsWindow);
			_prefsWindow.transitionIn();
		}

		private function _onPreferencesReady(event : TransitionEvent) : void 
		{
			_prefsWindow.activate();
		}

		private function _onPreferencesClosed(event : TransitionEvent) : void 
		{
			_prefsWindow.destroy();
			_prefsWindow = null;
			
			activate();
		}

		private function _onNewProjectWindowClosed(event : TransitionEvent) : void 
		{
			_newProjectId = _newProjectWindow.newProjectId;
			
			_newProjectWindow.destroy();
			_newProjectWindow = null;
			// Refresh our projects.
			_updateProjectsList();
		}

		private function _onOpenProjectClick(event : MouseEvent) : void 
		{
			// Get the project
			var projectData : ProjectData = _projectsList.selectedItem as ProjectData;
			var e : ProjectWindowEvent = new ProjectWindowEvent(ProjectWindowEvent.OPEN_PROJECT, true);
			e.projectData = projectData;
			dispatchEvent(e);
		}

		private function _onExportGMLClick(event : MouseEvent) : void 
		{
			deactivate();
			
			_savingWindow = new SavingGMLWindow();
			addChild(_savingWindow);
			_savingWindow.addEventListener(TransitionEvent.TRANSITION_IN_COMPLETE, _onSavingWindowTransitionInComplete, false, 0, true);
			_savingWindow.transitionIn();
		}

		private function _onSavingWindowTransitionInComplete(event : TransitionEvent) : void 
		{
			var projectData : ProjectData = _projectsList.selectedItem as ProjectData;
			_exportGMLCommand = new ExportGMLCommand(projectData);
			_exportGMLCommand.addEventListener(ProcessEvent.COMPLETE, _onExportGMLComplete, false, 0, true);
			_exportGMLCommand.start();
		}

		private function _onExportGMLComplete(event : ProcessEvent) : void 
		{
			_exportGMLCommand.destroy();
			_exportGMLCommand = null;
			
			_savingWindow.addEventListener(TransitionEvent.TRANSITION_OUT_COMPLETE, _onSavingWindowTransitionOutComplete, false, 0, true);
			_savingWindow.transitionOut();
		}		

		private function _onSavingWindowTransitionOutComplete(event : TransitionEvent) : void 
		{
			_savingWindow.destroy();
			_savingWindow = null;
			
			activate();
		}

		private function _onDeleteProjectClick(event : MouseEvent) : void 
		{
			if(_deleteProjectWindow != null)
			{
				_deleteProjectWindow.destroy();
				_deleteProjectWindow = null;
			}
			
			deactivate();
			
			var projectData : ProjectData = _projectsList.selectedItem as ProjectData;
			_deleteProjectWindow = new ConfirmDeleteWindow(projectData.id, projectData.name);
			_deleteProjectWindow.addEventListener(TransitionEvent.TRANSITION_OUT_COMPLETE, _onDeleteWindowClosed, false, 0, true);
			addChild(_deleteProjectWindow);
			_deleteProjectWindow.transitionIn();
		}

		private function _onDeleteWindowClosed(event : TransitionEvent) : void 
		{
			var updateList : Boolean = _deleteProjectWindow.deletedProjectSuccessfully == true;
			_deleteProjectWindow.destroy();
			_deleteProjectWindow = null;
			
			_updateProjectsList();
		}

		private function _updateProjectsList() : void
		{
			deactivate();
			if(_getProjectsService != null)
			{
				_getProjectsService.destroy();
				_getProjectsService = null;
			}
			_getProjectsService = new GetProjectsService();
			_getProjectsService.addEventListener(ProcessEvent.COMPLETE, _onProjectsServiceComplete);
			_getProjectsService.start();
		}

		private function _onProjectsServiceComplete(event : ProcessEvent) : void 
		{
			_projects = _getProjectsService.projects;
			_getProjectsService.destroy();
			_getProjectsService = null;
			
			var selectedIndex : int = 0;
			 
			var projects : Array = [];
			var index : int = -1;
			for each (var p : ProjectData in _projects) 
			{
				index++;
				projects.push(p);
				if(_newProjectId != -1)
				{
					if(p.id == _newProjectId)
					{
						selectedIndex = index;
						_newProjectId = -1;
					}
				}
			}
			
			_projectsList.items = projects;
			_projectsList.selectedIndex = selectedIndex;
			_projectsList.draw();
			
			activate();
		}

		override public function deactivate() : void 
		{
			super.deactivate();
			_createButton.enabled = false;
			_createButton.removeEventListener(MouseEvent.CLICK, _onCreateClick);
			
			_deleteProjectButton.enabled = false;
			_exportGMLButton.enabled = false;
			_openProjectButton.enabled = false;
			
			_deleteProjectButton.removeEventListener(MouseEvent.CLICK, _onDeleteProjectClick);
			_exportGMLButton.removeEventListener(MouseEvent.CLICK, _onExportGMLClick);
			_openProjectButton.removeEventListener(MouseEvent.CLICK, _onOpenProjectClick);
			
			_preferencesButton.enabled = false;
			_preferencesButton.removeEventListener(MouseEvent.CLICK, _onPreferencesClick);
			
			_projectsList.enabled = false;
			_projectsList.removeEventListener(Event.SELECT, _onItemSelected);
		}

		override public function destroy() : void 
		{
			deactivate();
			TweenMax.killTweensOf(this);
			
			// Get rid of the create panel + buttons
			_createPanel.removeChild(_createButton);
			_createButton = null;
			_createPanel.removeChild(_preferencesButton);
			_preferencesButton = null;
			
			if(_prefsWindow != null)
			{
				_prefsWindow.destroy();
				_prefsWindow = null;
			}
			
			removeChild(_createPanel);
			_createPanel = null;
			
			_projectsPanel.removeChild(_projectsPanelLabel);
			_projectsPanelLabel = null;
			_projectsPanel.removeChild(_projectsList);
			_projectsList = null;
			_projectsPanel.removeChild(_openProjectButton);
			_openProjectButton = null;
			_projectsPanel.removeChild(_exportGMLButton);
			_exportGMLButton = null;
			_projectsPanel.removeChild(_deleteProjectButton);
			TweenMax.killTweensOf(_deleteProjectButton);
			_deleteProjectButton = null;
			
			removeChild(_projectsPanel);
			_projectsPanel = null;
			
			_projects = null;
			
			if(_getProjectsService != null)
			{
				_getProjectsService.destroy();
				_getProjectsService = null;
			}
			
			if(_newProjectWindow != null)
			{
				_newProjectWindow.destroy();
				_newProjectWindow = null;
			}
			
			if(_deleteProjectWindow != null)
			{
				_deleteProjectWindow.destroy();
				_deleteProjectWindow = null;
			}
			
			if(_exportGMLCommand != null)
			{
				_exportGMLCommand.destroy();
				_exportGMLCommand = null;
			}
			
			_ground.destroy();
			_ground = null;
			
			super.destroy();
		}
	}
}
