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
import dent.Player;
import dent.api.RemoteControl;
import dent.History;
import mx.utils.Delegate;

class dent.Core {
	private var callback:Function=null;
	private var fn:Object = null;

	// screen vars
	private var screen:Array=null;
	private var active_screen:Number=null;
	private var clip_name:Array=null;

	// remote
	private var remote:Boolean=false;
	private var remote_screen:Boolean=false;

// ************** init
	public function Core(callback) {
		trace('core init called');
		this.callback=callback;

		this.cleanup();

		// init
		this.fn = {core_remote:Delegate.create(this, this.core_remote),
				   screen_signal:Delegate.create(this, this.screen_signal)
				  };

		// setup our friends
		RemoteControl.add_core(this.fn.core_remote);
		Player.init();

		this.screen=new Array;
		this.screen[0]=new Object;
		this.screen[1]=new Object;

		this.clip_name=new Array;
		this.clip_name[0]="SCREEN0";
		this.clip_name[1]="SCREEN1";

		// we're ready
		this.take_control();
	}

	// designed for first run call once only
	private function take_control() {
		// launch
		this.screen_change(History.current());

		// get the splash off
		this.callback("core");
	}

	public function reconnect_reload() {
		Dialog.preload('Reloading');

		this.take_control();
		Dialog.server_clear();
	}

// ************** screen
	private function screen_url(where) {
		trace("screen going to "+where);

		var history:Object=History.next(where);
		if(history!=null) {
			this.screen_change(history);
		} else {
			this.remote_screen=true;
			trace(".. skipped: we're at that location already");
		}
	}

	private function screen_change(history) {
		if(history==null) {
			this.remote_screen=true;
			trace("history change skipped");
			return;
		}

		trace("history change to "+history.url);

		// launch the screen
		this.active_screen=this.other_screen();
		// FIX ME
		//this.screen[this.active_screen].run=new Screen(this.fn.screen_signal, Common.stage, this.clip_name[this.active_screen], Common.depths[this.clip_name[this.active_screen]], history);
	}

	private function other_screen() {
		if(this.active_screen==null) this.active_screen=1;

		return Math.abs(1-this.active_screen);
	}

	// cleanup the opposite screen
	private function screen_swap() {
		this.screen_close(this.other_screen());
	}

	private function screen_close(which) {
		trace("closing down screen "+which);

		this.screen[which].run.cleanup();
	}

	private function screen_signal(status, data) {
		trace("screen_signal "+this.active_screen+" "+status+" : "+data);

		switch(status) {
			case 'exit':      // dbmain passthrough
			case 'relaunch':
			case 'fatal':
				this.remote=false;
				this.callback(status, data);
				break;
			case 'ready':
				this.remote=true;          // core remote
				this.remote_screen=true;   // send to screen
				Dialog.preload_clear();    // remove the preloader if any
				this.screen_swap();		   // close old screen
				break;
			case 'back':
			case 'forward':
			case 'home':
				// change by history
				this.remote_screen=false;
				this.save_state();
				this.screen_change(History.move(status));
				break;
			case 'change':
				this.remote_screen=false;
				this.save_state();
				this.screen_url(status);
				break;
			case 'error':
				this.show_error(data);
				break;
			case 'popup':
				Dialog.popup(data);
				break;
			default:
				trace("skipping unknown status "+status);
		}
	}

	private function save_state() {
		trace("saving state");
		var s:Object=this.screen[this.active_screen].run.alert("state");
		History.add_state(s);
	}

// ************** remote
	public function core_remote(keyhit, keyname) {
		if(this.remote) {
			trace("core remote "+keyhit);

			// todo: globals

			// screen
			if(this.remote_screen && this.screen[this.active_screen].run.remote(keyhit, keyname) == true) return true;

			// core
			switch(keyname) {
				case 'BACK':
				case 'FORWARD':
				case 'HOME':
					this.remote_screen=false;
					this.save_state();
					this.screen_change(History.move(keyname));
					return true;
				default:
					break;
			}
		}

		// didn't use the button
		return false;
	}

// ************** error
	private function show_error(message) {
		Dialog.preload_clear();

		if(History.len()<=1) {
			trace("error on first screen, switching to fatal");
			this.callback('fatal', message);
		} else {
			Dialog.error(message);
		}
	}

// ************** Cleanup

	public function cleanup() {
		trace('core cleanup called');

		this.remote=false;
		this.remote_screen=false;

		delete this.screen;
		this.screen=null;
		this.active_screen=null;

		delete this.clip_name;
		this.clip_name=null;
	}
}
