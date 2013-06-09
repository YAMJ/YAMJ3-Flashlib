// This file is part of YAMJ3-Flashlib.

// YAMJ3-Flashlib is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// YAMJ3-Flashlib is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with YAMJ3-Flashlib.  If not, see <http://www.gnu.org/licenses/>.

import dent.Common;

class dent.api.SharedObj {
	public static var saveObject:SharedObject = null;
	public static var soCallback:Function=null;

	public static function onSharedObjectLoad(so:SharedObject) {
		trace("SO: after load called");
		SharedObj.saveObject=so;

		if (so.getSize() != 0) {	             // check that the shared object exists and contains data
			if (so.data.state != undefined) {   // check that the data actually exists
				if(so.data.state.sessionid != undefined && so.data.state.dentserver != undefined && so.data.state.serverhost != undefined && so.data.state.serverport != undefined) {
					Common.runtime.server['session']=so.data.state.sessionid;
					Common.runtime.server['dent']=so.data.state.dentserver;
					Common.runtime.server['serverhost']=so.data.state.serverhost;
					Common.runtime.server['serverport']=so.data.state.serverport;

					trace("SO: session: "+Common.runtime.server['session']);
					trace("SO: dentedboxes server: "+Common.runtime.server['serverhost']);
					trace("SO: dentedboxes port: "+Common.runtime.server['serverport']);
					trace("SO: dentedboxes clientapi: "+Common.runtime.server['dent']);
				} else {
					trace("SO: state rejected, not complete");
				}

				// reset the saved state
				SharedObj.clear();
				SharedObj.soCallback(true);
			} else {
				trace("SO:  data state undefined");
			}
		} else {
			trace("SO: no data");
		}

		SharedObj.soCallback(false);
	}

	public static function load(callback:Function) {
		trace("SO: load called");

		SharedObj.soCallback=callback;

		if(SharedObj.saveObject==null) {
			// init the save object
			SharedObject.addListener("dentedboxes", SharedObj.onSharedObjectLoad);
		}

		SharedObject.getLocal("dentedboxes");
	}

	public static function save() {
		trace("SO: save called");

		if(SharedObj.saveObject==null) {
			trace("SO:  not inited, can't save");
			return;
		}

		if(Common.runtime.server['session']==null) {
			trace("SO: no sessionid, no reason to save state");
			return;
		}

		// save
		SharedObj.saveObject.data.state=new Object();

		SharedObj.saveObject.data.state.sessionid=Common.runtime.server['session'];
		SharedObj.saveObject.data.state.serverhost=Common.runtime.server['serverhost'];
		SharedObj.saveObject.data.state.serverport=Common.runtime.server['serverport'];
		SharedObj.saveObject.data.state.dentserverCommon.runtime.server['dent'];

		SharedObj.saveObject.flush();
		trace("SO state save finished");
	}

	public static function clear() {
		trace("SO: clear called");

		if(SharedObj.saveObject==null) {
			trace("SO: not inited, can't clear");
			return;
		}

		SharedObj.saveObject.clear();
		SharedObj.saveObject.flush();
		trace("SO: state cleared");
	}
}
