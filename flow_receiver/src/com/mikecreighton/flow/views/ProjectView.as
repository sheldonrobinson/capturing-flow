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
	import com.bit101.components.Label;
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	import com.greensock.TweenMax;
	import com.greensock.easing.Expo;
	import com.mikecreighton.flow.data.PointData;
	import com.mikecreighton.flow.data.ProjectData;
	import com.mikecreighton.flow.data.StrokePoint;
	import com.mikecreighton.flow.events.ProjectWindowEvent;
	import com.mikecreighton.flow.events.StrokeEvent;
	import com.mikecreighton.flow.services.AddPointsService;
	import com.mikecreighton.flow.tuio.TuioManager;
	import com.mikecreighton.framework.display.BaseTransitioningSprite;
	import com.mikecreighton.util.DrawUtil;

	import org.casalib.display.CasaShape;
	import org.casalib.events.ProcessEvent;
	import org.casalib.time.EnterFrame;
	import org.casalib.util.StageReference;

	import flash.events.Event;
	import flash.events.MouseEvent;

	[Event(name="closeProject", type="com.mikecreighton.flow.events.ProjectWindowEvent")]

	/**
	 * @author Mike Creighton
	 */
	public class ProjectView extends BaseTransitioningSprite 
	{
		private static const TOP_MARGIN : int = 20;
		private static const HORZ_MARGIN : int = 10;
		private static var SW : int;
		private static var SH : int;

		private var _ground : CasaShape;
		private var _actionsPanel : Panel;
		private var _projectData : ProjectData;
		private var _projectName : Label;
		private var _recordButton : PushButton;
		private var _stopButton : PushButton;
		private var _recordingIndicator : IndicatorLight;
		private var _recording : Boolean;
		private var _closeButton : PushButton;
		private var _pointsPanel : Panel;
		private var _pointsVisualizer : PointsVisualizer;
		private var _services : Vector.<AddPointsService>;
		private var _points : Vector.<PointData>;

		public function ProjectView( projectData : ProjectData )
		{
			super();
			
			_projectData = projectData.clone();
			_recording = false;
			_services = new Vector.<AddPointsService>();
			
			SW = StageReference.getStage().stageWidth;
			SH = StageReference.getStage().stageHeight;
			
			init();
		}

		override public function init() : void 
		{
			super.init();
			
			_ground = new CasaShape();
			DrawUtil.drawRect(_ground.graphics, 0, 0, SW, SH, 0xCCCCCC);
			addChild(_ground);
			
			_actionsPanel = new Panel(this, HORZ_MARGIN, TOP_MARGIN);
			_actionsPanel.setSize(SW - HORZ_MARGIN * 2, 70);
			
			const BW : int = 100;
			const BY : int = 35;
			
			_projectName = new Label(_actionsPanel, 10, 10, _projectData.name);
			_recordButton = new PushButton(_actionsPanel, 10, BY, "Start Recording");
			_recordButton.width = BW;
			_recordButton.enabled = false;
			_stopButton = new PushButton(_actionsPanel, 10, BY, "Stop Recording");
			_stopButton.width = BW;
			_stopButton.enabled = false;
			_stopButton.visible = false;
			_closeButton = new PushButton(_actionsPanel, _actionsPanel.width - (BW + 10), BY, "Close Project");
			_closeButton.width = BW;
			_closeButton.enabled = false;
			_recordingIndicator = new IndicatorLight(_actionsPanel, BW + 20, BY + 4, 0xC52D33, "Recording");
			_recordingIndicator.flash(0);
			
			_pointsPanel = new Panel(this, HORZ_MARGIN, _actionsPanel.y + _actionsPanel.height + TOP_MARGIN);
			_pointsPanel.setSize(_actionsPanel.width, SH - (_actionsPanel.height + TOP_MARGIN * 4));
			
			_pointsVisualizer = new PointsVisualizer(_pointsPanel.width, _pointsPanel.height);
			_pointsPanel.addChild(_pointsVisualizer);
			
			y = -SH;
		}

		override public function transitionIn() : void 
		{
			super.transitionIn();
			TweenMax.to(this, 0.6, {y: 0, roundProps: ['y'], ease: Expo.easeInOut, onComplete: _completeTransitionIn});
		}

		override public function activate() : void 
		{
			super.activate();
			if(_recording)
			{
				_stopButton.enabled = true;
				_stopButton.addEventListener(MouseEvent.CLICK, _onStopRecordingClick, false, 0, true);
			}
			else
			{
				_recordButton.enabled = true;
				_recordButton.addEventListener(MouseEvent.CLICK, _onStartRecordingClick, false, 0, true);
			}
			_closeButton.enabled = true;
			_closeButton.addEventListener(MouseEvent.CLICK, _onCloseClick, false, 0, true);
		}

		private function _onStartRecordingClick(event : MouseEvent) : void 
		{
			_recording = true;
			_points = new Vector.<PointData>();
			
			// EnterFrame.getInstance().addEventListener(Event.ENTER_FRAME, _watchIncomingPoints, false, 0, true);
			
			TuioManager.getInstance().addEventListener(StrokeEvent.ADD, _onTuioPoint, false, 0, true);
			TuioManager.getInstance().addEventListener(StrokeEvent.MOVE, _onTuioPoint, false, 0, true);
			TuioManager.getInstance().addEventListener(StrokeEvent.REMOVE, _onTuioPointRemove, false, 0, true);
			
			// Hide the start button, show the record button.
			_recordButton.enabled = false;
			_recordButton.visible = false;
			_recordButton.removeEventListener(MouseEvent.CLICK, _onStartRecordingClick);
			_stopButton.enabled = true;
			_stopButton.visible = true;
			_stopButton.addEventListener(MouseEvent.CLICK, _onStopRecordingClick, false, 0, true);
			
			_recordingIndicator.flash(500);
		}

		private function _onStopRecordingClick(event : MouseEvent) : void 
		{
			_recording = false;
			
			// Hide the start button, show the record button.
			_recordButton.enabled = true;
			_recordButton.visible = true;
			_recordButton.addEventListener(MouseEvent.CLICK, _onStartRecordingClick, false, 0, true);
			_stopButton.enabled = false;
			_stopButton.visible = false;
			_stopButton.removeEventListener(MouseEvent.CLICK, _onStopRecordingClick);
			
			_recordingIndicator.flash(0);
			
			// EnterFrame.getInstance().removeEventListener(Event.ENTER_FRAME, _watchIncomingPoints);
			
			TuioManager.getInstance().removeEventListener(StrokeEvent.ADD, _onTuioPoint);
			TuioManager.getInstance().removeEventListener(StrokeEvent.MOVE, _onTuioPoint);
			TuioManager.getInstance().removeEventListener(StrokeEvent.REMOVE, _onTuioPointRemove);
			// Let's just push off a request.
			_sendPointsPackage();
		}

		/**
		 * This is the callback for receiving new point data.
		 */
		private function _onTuioPoint(event : StrokeEvent) : void 
		{
			var date : Date = new Date();
			var ms : Number = date.getTime();
			var sp : StrokePoint = event.strokePoint;
			var p : PointData = new PointData();
			p.time = ms;
			p.x = sp.x;
			p.y = sp.y;
			p.id = sp.id;
			_points.push(p);
			
			if(_points.length > 100) 
			{
				_sendPointsPackage();
			}
		}

		/**
		 * This is the callback for removing points (setting position to -1,-1) in points array.
		 */
		private function _onTuioPointRemove(event : StrokeEvent) : void 
		{
			var p : PointData;
			var sp : StrokePoint = event.strokePoint;
			var date : Date = new Date();
			var ms : Number = date.getTime();
			
			p = new PointData();
			p.time = ms;
			p.x = -1;
			p.y = -1;
			p.id = sp.id;
			_points.push(p);
			
			if(_points.length > 100) 
			{
				_sendPointsPackage();
			}
		}

		/**
		 * This is the polling method for storing the points on each frame read.
		 */
		/*
		private function _watchIncomingPoints(event : Event) : void 
		{
			var tuio : TuioManager = TuioManager.getInstance();
			if(tuio.currentStrokePoint != null)
			{
				var date : Date = new Date();
				var ms : Number = date.getTime();
				var sp : StrokePoint = tuio.currentStrokePoint;
				var p : PointData = new PointData();
				p.time = ms;
				p.x = sp.x;
				p.y = sp.y;
				p.id = sp.id;
				_points.push(p);
			}
			
			if(_points.length > 100) 
			{
				_sendPointsPackage();
			}
		}
		*/
		
		private function _sendPointsPackage() : void 
		{
			if(_points != null)
			{
				if(_points.length > 0)
				{
					trace("ProjectView :: _sendPointsPackage() sending " + _points.length + " points.");
					var s : AddPointsService = new AddPointsService(_projectData.id, _points.slice());
					while(_points.length > 0)
					{
						_points.pop();
					}
					_points = null;
					_points = new Vector.<PointData>();
			
					s.addEventListener(ProcessEvent.COMPLETE, _onAddPointsComplete, false, 0, true);
					_services.push(s);
					s.start();
				}
			}
		}

		private function _onAddPointsComplete(event : ProcessEvent) : void 
		{
			trace("ProjectView :: add points has completed.");
			// When we're done, we need to kill this service.
			var sender : AddPointsService = AddPointsService(event.currentTarget);
			var senderIndex : Number = _services.indexOf(sender);
			if(senderIndex > -1)
			{
				_services.splice(senderIndex, 1);
			}
			sender.destroy();
		}

		private function _onCloseClick(event : MouseEvent) : void 
		{
			dispatchEvent(new ProjectWindowEvent(ProjectWindowEvent.CLOSE_PROJECT, true));
		}

		override public function deactivate() : void 
		{
			super.deactivate();
			
			_stopButton.enabled = false;
			_stopButton.removeEventListener(MouseEvent.CLICK, _onStopRecordingClick);
			_recordButton.enabled = false;
			_recordButton.removeEventListener(MouseEvent.CLICK, _onStartRecordingClick);
			_closeButton.enabled = false;
			_closeButton.removeEventListener(MouseEvent.CLICK, _onCloseClick);
			
			if(_recording)
				_recordingIndicator.flash(0);
			_recordingIndicator.isLit = false;
		}

		override public function transitionOut() : void 
		{
			super.transitionOut();
			// Start a checker to make sure we're done sending all our points.
			_sendPointsPackage();
			
			if(_services.length > 0) 
			{
				EnterFrame.getInstance().addEventListener(Event.ENTER_FRAME, _checkIfServicesDone, false, 0, true);
			} 
			else 
			{
				_animatePaneOut();
			}
		}

		private function _checkIfServicesDone(event : Event) : void 
		{
			if(_services.length == 0) 
			{
				EnterFrame.getInstance().removeEventListener(Event.ENTER_FRAME, _checkIfServicesDone);
				_animatePaneOut();
			}
		}

		private function _animatePaneOut() : void
		{
			TweenMax.to(this, 0.6, {y: -SH, roundProps: ['y'], ease: Expo.easeInOut, onComplete: _completeTransitionOut});
		}

		override public function destroy() : void 
		{
			deactivate();
			
			TweenMax.killTweensOf(this);
			
			EnterFrame.getInstance().removeEventListener(Event.ENTER_FRAME, _checkIfServicesDone);
			TuioManager.getInstance().removeEventListener(StrokeEvent.ADD, _onTuioPoint);
			TuioManager.getInstance().removeEventListener(StrokeEvent.MOVE, _onTuioPoint);
			TuioManager.getInstance().removeEventListener(StrokeEvent.REMOVE, _onTuioPointRemove);
			
			_actionsPanel.removeChild(_projectName);
			_projectName = null;
			_actionsPanel.removeChild(_closeButton);
			_closeButton = null;
			_actionsPanel.removeChild(_stopButton);
			_stopButton = null;
			_actionsPanel.removeChild(_recordButton);
			_recordButton = null;
			_recordingIndicator.flash(0);
			_recordingIndicator.isLit = false;
			_actionsPanel.removeChild(_recordingIndicator);
			_recordingIndicator = null;
			
			removeChild(_actionsPanel);
			_actionsPanel = null;
			
			_pointsVisualizer.destroy();
			_pointsVisualizer = null;
			
			removeChild(_pointsPanel);
			_pointsPanel = null;
			
			_ground.destroy();
			_ground = null;
			
			super.destroy();
		}
	}
}
