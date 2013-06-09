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
import mx.utils.Delegate;

// the base class for hardware player apis

class dent.api.Playerapi {

    // ****** SETTINGS

	// name
	private function name() {
		return("non-hardware or generic");
	}

	private function id() {
		return("generic flash");
	}

	// detect my hardware
	private function detect(callback) {
		callback(false);
	}

	// check hardware specific methods to pass server to flash
	private function find_server(callback) {
		callback(false);
	}

    // ****** CONNECTIONS
	public static function realtime_start(callback) {
		trace("HW: realtime monitoring not supported");
	}

	// ****** REMOTE

	private function remote(remotemap,remotemapname) {
		// there are no special keys by default
	}

	private function keyboard(remotemap,remotemapname) {
		trace("keyboard codes");

		// TODO: some of these are going to get in the way of keyboard support, remap

		// default mapping are keyboard debugging based

		// name to key mappings
		remotemapname['ENTER']=Key.ENTER;
		remotemapname['SELECT']=Key.ENTER;
		remotemapname['PAGEUP']=Key.PGUP;
		remotemapname['PAGEDOWN']=Key.PGDN;
		remotemapname['NUM0']=48;
		remotemapname['NUM1']=49;
		remotemapname['NUM2']=50;
		remotemapname['NUM3']=51;
		remotemapname['NUM4']=52;
		remotemapname['NUM5']=53;
		remotemapname['NUM6']=54;
		remotemapname['NUM7']=55;
		remotemapname['NUM8']=56;
		remotemapname['NUM9']=57;
		remotemapname['MENU']=187;  // =
		remotemapname['INFO']=188;  // ,
		remotemapname['EQUAL']=187;
		remotemapname['COMMA']=188;
		remotemapname['SEMICOLON']=186;
		remotemapname['BACK']=8;  		// backspace
		remotemapname['FORWARD']=220;  	// backslash
		remotemapname['HOME']=221;  	// ]

		// key to name.  (not a full reverse chart, just special case)
		remotemap[65]='PAGEUP';    // a=pageup for cs5.5 lack of softkeys with syabas profile
		remotemap[90]='PAGEDOWN';  // z=pagedown for cs5.5 lack of softkeys with syabas profile
	}

// *************** PLAY STUFF
	private function playlist() {
		// return: 'no': single play and can monitor
		//         'yes': need a full playlist
		//         'remote': need a url to get playlist from server

		return 'no';
	}

	private function youtube() {
		// return true if you can play youtube urls
		return false;
	}

	private function play_single(data) {
		// play a single file
		trace("play_single");
		return true;
	}

	private function play_playlist(data) {
		// play a playlist
		trace("play_playlist");
		return false;
	}
}