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
package com.mikecreighton.flow.services 
{
	import com.mikecreighton.flow.data.Config;
	import com.mikecreighton.flow.data.ProjectData;

	import org.casalib.process.Process;
	import org.casalib.util.StringUtil;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.net.URLStream;

	/**
	 * @author Mike Creighton
	 */
	public class ExportGMLCommand extends Process 
	{
		private var _fileSaver : File;
		private var _projectData : ProjectData;
		private var _fileStream : FileStream;
		private var _gmlStream : URLStream;
		
		public function ExportGMLCommand(projectData : ProjectData)
		{
			_projectData = projectData;
		}

		override public function start() : void 
		{
			super.start();
			
			var filename : String = _projectData.name;
			filename = StringUtil.replace(filename, ' ', '_');
			filename += '.gml';
			_fileSaver = File.documentsDirectory.resolvePath(filename);
			try {
				_fileSaver.addEventListener(Event.SELECT, _onFileSelected, false, 0, true);
				_fileSaver.addEventListener(Event.CANCEL, _onFileCanceled, false, 0, true);
				_fileSaver.browseForSave("Save As...");
			}
			catch (e : Error)
			{
				trace("ExportGMLCommand :: browseForSave failed: " + e.message);
				_complete();
			}
		}

		private function _onFileCanceled(event : Event) : void {
			trace("ExportGMLCommand :: _onFileCanceled()");
			_complete();
		}

		private function _onFileSelected(event : Event) : void {
			// Now we need to go ahead and retrieve the GML from the server...
			var url : String = Config.getInstance().flowStorageURL + "points/get_points/" + _projectData.id;
			var request : URLRequest = new URLRequest(url);
			_gmlStream = new URLStream();
			_gmlStream.addEventListener(ProgressEvent.PROGRESS, _onDownloadProgress, false, 0, true);
			_gmlStream.addEventListener(IOErrorEvent.IO_ERROR, _onDownloadError, false, 0, true);
			_gmlStream.addEventListener(Event.COMPLETE, _onDownloadComplete, false, 0, true);
			
			// Delete the existing file if it exists.
			if(_fileSaver.exists)
			{
				_fileSaver.deleteFile();
			}
			
			// Open up our file stream
			_fileStream = new FileStream();
			_fileStream.open(_fileSaver, FileMode.APPEND);
			
			_gmlStream.load(request);
		}

		private function _onDownloadError(event : IOErrorEvent) : void 
		{
			_complete();
		}

		private function _onDownloadProgress(event : ProgressEvent) : void 
		{
			try {
				var streamUTFBytes : String = _gmlStream.readUTFBytes(_gmlStream.bytesAvailable);
				_fileStream.writeUTFBytes(streamUTFBytes);
			}
			catch ( error : Error )
			{
				_complete();
			}
		}

		private function _onDownloadComplete(event : Event) : void 
		{
			try {
				var streamUTFBytes : String = _gmlStream.readUTFBytes(_gmlStream.bytesAvailable);
				_fileStream.writeUTFBytes(streamUTFBytes);
			}
			catch ( error : Error )
			{
			}
			_complete();
		}

		override public function destroy() : void 
		{
			if(_fileStream != null)
			{
				_fileStream.close();
				_fileStream = null;
			}
			
			if(_gmlStream != null)
			{
				_gmlStream.close();
				_gmlStream.removeEventListener(ProgressEvent.PROGRESS, _onDownloadProgress);
				_gmlStream.removeEventListener(IOErrorEvent.IO_ERROR, _onDownloadError);
				_gmlStream.removeEventListener(Event.COMPLETE, _onDownloadComplete);
				_gmlStream = null;
			}
			
			if(_fileSaver != null)
			{
				_fileSaver.removeEventListener(Event.SELECT, _onFileSelected);
				_fileSaver.removeEventListener(Event.CANCEL, _onFileCanceled);
				_fileSaver = null;
			}
			
			_projectData = null;
			
			super.destroy();
		}
	}
}
