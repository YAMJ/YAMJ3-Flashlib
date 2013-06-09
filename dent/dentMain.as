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
import dent.Core;
import dent.Background;
import dent.api.Server;
import dent.api.SharedObj;
import dent.api.Hardware;
import dent.api.RemoteControl;
import mx.utils.Delegate;

class dent.dentMain {
	private var fn:Object = null;

	private var parentMC:MovieClip = null;
	private var mainMC:MovieClip = null;

	public function cleanup():Void {
		Common.reset();

		delete this.fn;
		this.fn=null;

		this.parentMC = null;
		this.mainMC.removeMovieClip();
		this.mainMC = null;
	}

	public function create(parentMC:MovieClip):Void {
		// setup
		this.cleanup();

		this.fn = {foundSERVER:Delegate.create(this, this.foundSERVER),
				   apiREADY:Delegate.create(this, this.apiREADY),
				   server_up:Delegate.create(this, this.server_up),
				   dentREADY:Delegate.create(this, this.dentREADY),
				   afterstate:Delegate.create(this, this.afterstate),
				   afterstatenoserver:Delegate.create(this, this.afterstatenoserver),
				   exit:Delegate.create(this, this.exit)
				  };

		this.parentMC = parentMC;

		trace("YAMJ3 FLASHLIB READY");

		// start it up
		this.startDENT();
	}

	private function startDENT() {
		// reset the system
		Common.enviroment(this.parentMC);

		Dialog.splash('Starting');

		// find the dent we use
		Server.find(this.fn.foundSERVER);
	}

	private function foundSERVER(success) {
		if(success) {
			SharedObj.load(this.fn.afterstate);
		} else {
			SharedObj.load(this.fn.afterstatenoserver);
		}
	}

	private function afterstate(success) {
		Hardware.setupapi(this.fn.apiREADY);
	}

	private function afterstatenoserver(success) {
		if(success) {
			Hardware.setupapi(this.fn.apiREADY);
		} else {
			trace(".. halted, no server");
			Dialog.fatal('I do not know the YAMJ server to connect to');
		}
	}

	private function apiREADY(success) {
		trace(".. player api: "+Common.playerapi.name());

		RemoteControl.init();

		// connect to db
		Server.first_connect(this.fn.server_up);
	}

	private function server_up(success) {
		if(success) {
			Server.first_socket(this.fn.dentREADY);
		} else {
			Dialog.fatal('unable to communicate with server');
		}
	}

	private function dentREADY(success) {
		if(success) {
			Dialog.update_splash("READY");

			RemoteControl.start_remote();
			Common.core=new Core(this.fn.exit);
		} else {
			Dialog.fatal('unable to communicate with server');
		}
	}

	private function exit(status, message) {
		trace("main exit called: "+status+" "+message);

		switch(status) {
			case 'core':	 // core in control, clear splash
				Common.ready=true;
				Dialog.close_splash();
				Background.init();
				break;
			case 'exit':
				// TODO
				break;
			case 'relaunch':
				// TODO
				break;
			case 'reset':
				// TODO
				break;
			case 'fatal':
				RemoteControl.stop_remote();
				Dialog.fatal(message);
				break;
			default:
				trace("dbmain: ignored unknown exit status "+status);
		}
	}
}