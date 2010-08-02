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

	import org.casalib.events.LoadEvent;
	import org.casalib.load.DataLoad;

	/**
	 * @author Mike Creighton
	 */
	public class GetProjectsService extends BaseService 
	{

		private var _projects : Vector.<ProjectData>;

		public function GetProjectsService() 
		{
			super();
			
			_projects = new Vector.<ProjectData>();
			
			_serviceURL = Config.getInstance().flowStorageURL + 'projects/get_projects/';
			_dataLoad = new DataLoad(_serviceURL);
			_dataLoad.addEventListener(LoadEvent.COMPLETE, _onDataLoadComplete, false, 0, true);
		}

		override public function start() : void 
		{
			super.start();
			_dataLoad.start();
		}

		private function _onDataLoadComplete(event : LoadEvent) : void 
		{
			_dataLoad.removeEventListeners();
			var resultXML : XML = _dataLoad.dataAsXml;
			
			_parseResultCode(resultXML);
			
			// Parse it.
			if(resultCode == 0) 
			{
				var p : ProjectData;
				for each (var projectXML : XML in resultXML..project) 
				{
					p = new ProjectData();
					p.id = parseInt(projectXML.@id.toString(), 10);
					p.num_points = parseInt(projectXML.@num_points.toString(), 10);
					p.name = projectXML.toString();
					_projects.push(p);
				}
			}
			
			_projects.sort(_doProjectsCompare);
			
			_complete();
		}

		private function _doProjectsCompare(x : ProjectData, y : ProjectData) : Number
		{
			if(x.name < y.name)
			{
				return -1;
			}
			else if (x.name > y.name)
			{
				return 1;
			}
			else
			{
				return 0;
			}
		}

		public function get projects() : Vector.<ProjectData> 
		{
			return _projects.slice();
		}

		override public function destroy() : void 
		{
			while(_projects.length > 0) 
			{
				_projects.pop();
			}
			_projects = null;
			_dataLoad.destroy();
			_dataLoad = null;
			super.destroy();
		}
	}
}
