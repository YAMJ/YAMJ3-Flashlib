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
import dent.Dialog;
import dent.tools.Data;
import dent.api.Hardware;
import dent.api.RemoteControl;
import dent.api.Socket;
import dent.api.Server;
import mx.xpath.XPathAPI;

class dent.api.Control {
// **************** Connect
	public static function start_socket(cb) {
		// "realtime" hardware monitoring
		Common.playerapi.realtime_start(Control.fromHardware);

		cb(true);
	}

// **************** Communicate

	public static function fromHardware(command) {
		trace("HW SOCKET:");
		trace(command);

		// switch(d) {
			// default:
				// trace("unknown hw socket command: "+d);
		// }
	}

// **************** Control

// TODO: LOTS OF STUFF

}
