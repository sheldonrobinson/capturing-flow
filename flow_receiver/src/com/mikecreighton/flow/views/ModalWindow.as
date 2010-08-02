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
	import com.bit101.components.PushButton;
	import com.bit101.components.Window;
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.mikecreighton.framework.display.BaseTransitioningSprite;
	import com.mikecreighton.util.DrawUtil;

	import org.casalib.display.CasaShape;
	import org.casalib.util.StageReference;

	import flash.events.MouseEvent;

	/**
	 * @author Mike Creighton
	 */
	public class ModalWindow extends BaseTransitioningSprite 
	{
		protected static const DEFAULT_WIDTH : int = 300;
		protected static const DEFAULT_HEIGHT : int = 300;

		protected var _overlay : CasaShape;
		protected var _window : Window;
		protected var _windowWidth : int;
		protected var _windowHeight : int;
		protected var _okayButton : PushButton;
		protected var _cancelButton : PushButton;

		public function ModalWindow(windowTitle : String = '')
		{
			super();
			
			_overlay = new CasaShape();
			DrawUtil.drawRect(_overlay.graphics, 0, 0, StageReference.getStage().stageWidth, StageReference.getStage().stageHeight, 0x000000, 0.5);
			addChild(_overlay);
			 
			_window = new Window(this, 0, 0, windowTitle);
			_windowWidth = DEFAULT_WIDTH;
			_windowHeight = DEFAULT_HEIGHT;
			_window.draggable = false;
			
			_okayButton = new PushButton(_window, 0, 0, 'Okay');
			_cancelButton = new PushButton(_window, 0, 0, 'Cancel');
		}

		override public function init() : void 
		{
			super.init();
			
			_overlay.alpha = 0;
			_window.alpha = 0;
			_overlay.visible = false;
			_window.visible = false;
			
			if(_okayButton)
				_okayButton.enabled = false;
			if(_cancelButton)
				_cancelButton.enabled = false;
			
			_updateLayout();
		}

		protected function _updateLayout() : void
		{
			_window.setSize(_windowWidth, _windowHeight);
			_window.x = Math.floor((StageReference.getStage().stageWidth - _windowWidth) / 2);
			_window.y = Math.floor((StageReference.getStage().stageHeight - _windowHeight) / 2);
			if(_okayButton && _cancelButton)
			{
				_okayButton.x = _windowWidth - (_okayButton.width + 20);
				_okayButton.y = _windowHeight - (_okayButton.height + 20);
				_cancelButton.x = _okayButton.x - (_cancelButton.width + 10);
				_cancelButton.y = _okayButton.y;
			}
		}

		override public function activate() : void 
		{
			super.activate();
			if(_okayButton)
			{
				_okayButton.enabled = true;
				_okayButton.addEventListener(MouseEvent.CLICK, _onOkayClick);
			}
			if(_cancelButton)
			{
				_cancelButton.enabled = true;
				_cancelButton.addEventListener(MouseEvent.CLICK, _onCancelClick);
			}
		}

		override public function deactivate() : void 
		{
			super.deactivate();
			if(_okayButton)
			{
				_okayButton.enabled = false;
				_okayButton.removeEventListener(MouseEvent.CLICK, _onOkayClick);
			}
			if(_cancelButton)
			{
				_cancelButton.enabled = false;
				_cancelButton.removeEventListener(MouseEvent.CLICK, _onCancelClick);
			}
		}

		override public function transitionIn() : void 
		{
			super.transitionIn();
			TweenMax.to(_overlay, 0.3, {autoAlpha: 1, ease: Quad.easeOut});
			TweenMax.to(_window, 0.15, {autoAlpha: 1, ease: Quad.easeOut, delay: 0.15, onComplete: _completeTransitionIn});
		}

		override protected function _completeTransitionIn() : void 
		{
			super._completeTransitionIn();
			activate();
		}

		override public function transitionOut() : void 
		{
			deactivate();
			
			super.transitionOut();
			TweenMax.to(_window, 0.3, {autoAlpha: 0, ease: Quad.easeOut});
			TweenMax.to(_overlay, 0.3, {autoAlpha: 0, ease: Quad.easeOut, delay: 0.15, onComplete: _completeTransitionOut});
		}

		protected function _onOkayClick(event : MouseEvent) : void
		{
		}

		protected function _onCancelClick(event : MouseEvent) : void
		{
			transitionOut();
		}

		protected function _destroyOkayAndCancelButtons() : void
		{
			if(_okayButton)
			{
				_window.removeChild(_okayButton);
				_okayButton.removeEventListener(MouseEvent.CLICK, _onOkayClick);
				_okayButton = null;
			}
			if(_cancelButton)
			{
				_window.removeChild(_cancelButton);
				_cancelButton.removeEventListener(MouseEvent.CLICK, _onCancelClick);
				_cancelButton = null;
			}			
		}

		override public function destroy() : void 
		{			
			TweenMax.killTweensOf(_overlay);
			TweenMax.killTweensOf(_window);
			
			_destroyOkayAndCancelButtons();
			
			removeChild(_window);
			_window = null;
			_overlay.destroy();
			_overlay = null;
			
			super.destroy();
		}
	}
}
