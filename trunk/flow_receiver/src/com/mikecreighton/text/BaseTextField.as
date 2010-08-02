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
package com.mikecreighton.text 
{
	import org.casalib.display.CasaTextField;

	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * @author Mike Creighton
	 */
	public class BaseTextField extends CasaTextField 
	{

		public function BaseTextField() 
		{
			super();
			
			_isDestroyed = false;
			
			autoSize = TextFieldAutoSize.LEFT;
			embedFonts = true;
			wordWrap = false;
			multiline = false;
			selectable = false;
			mouseEnabled = false;
		}

		public function set font(fontName : String) : void 
		{
			var fmt : TextFormat = getTextFormat();
			fmt.font = fontName;
			_applyFormat(fmt);
		}

		public function get font() : String 
		{
			var fmt : TextFormat = getTextFormat();
			return fmt.font;
		}

		public function get align() : String 
		{
			var fmt : TextFormat = getTextFormat();
			return fmt.align;
		}

		public function set align(alignType : String) : void 
		{
			var fmt : TextFormat = getTextFormat();
			fmt.align = alignType;
			_applyFormat(fmt);
		}

		public function get fontSize() : Number 
		{
			var fmt : TextFormat = getTextFormat();
			return Number(fmt.size);
		}

		public function set fontSize(size : Number) : void 
		{
			var fmt : TextFormat = getTextFormat();
			fmt.size = size;
			_applyFormat(fmt);
		}

		public function get color() : int 
		{
			var fmt : TextFormat = getTextFormat();
			return int(fmt.color);
		}

		public function set color(v : int) : void 
		{
			var fmt : TextFormat = getTextFormat();
			fmt.color = v;
			_applyFormat(fmt);
		}

		public function get letterSpacing() : Number 
		{
			var fmt : TextFormat = getTextFormat();
			return Number(fmt.letterSpacing);
		}

		public function set letterSpacing(v : Number) : void 
		{
			var fmt : TextFormat = getTextFormat();
			fmt.letterSpacing = v;
			_applyFormat(fmt);
		}

		private function _applyFormat(fmt : TextFormat) : void 
		{
			defaultTextFormat = fmt;
			setTextFormat(fmt);
		}
	}
}
