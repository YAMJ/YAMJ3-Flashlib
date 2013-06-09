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
import dent.api.Playerapi;
import dent.api.SharedObj;
import mx.utils.Delegate;
import ExtCommand;

class dent.api.players.Dune extends Playerapi {

    // ****** SETTINGS

	// name
	private function name() {
		return("dune hardware");
	}

	private function id() {
		return("dune");
	}

	private function remote(remotemap,remotemapname) {
		trace("dune remote keys");

		remotemap[Key.SHIFT]='ENTER';   // select button reverse map

		remotemapname['RED']=16777247;
		remotemapname['GREEN']=16777248;
		remotemapname['YELLOW']=16777249;
		remotemapname['BLUE']=16777250;
		remotemapname['BACK']=16777238;	// return key
		remotemapname['MENU']=16777234;	// popup menu
		remotemapname['INFO']=16777235;
		remotemapname['PAGEUP']=16777220;
		remotemapname['PAGEDOWN']=16777221;
		remotemapname['SEARCH']=268436490;
		remotemapname['SETUP']=16777244;
		remotemapname['FILEMODE']=0x10000405;
		remotemapname['TITLE']=0x10000406;
		remotemapname['REPEAT']=16777241;
		remotemapname['ANGLE']=16777236;
		remotemapname['SLOW']=16777228;
		remotemapname['TIMESEEK']=0x1000040A;
		remotemapname['ZOOM']=16777233;
		remotemapname['TVMODE']=16777232;
		remotemapname['SOURCE']=0x1000040E;
		remotemapname['EJECT']=0x1000040F;
		remotemapname['MUTE']=16777219;
		remotemapname['PLAY']=16777223;
		remotemapname['PAUSE']=16777224;
		remotemapname['STOP']=0x01000009;
		remotemapname['FASTFORWARD']=16777226;
		remotemapname['FAST_FORWARD']=16777226;
		remotemapname['REWIND']=16777227;
		remotemapname['SKIPFORWARD']=16777230;
		remotemapname['SKIPBACK']=16777231;
		remotemapname['AUDIO']=16777239;
		remotemapname['SUBTITLE']=16777240;
		remotemapname['EQUAL']=187;
		remotemapname['COMMA']=188;
		remotemapname['SEMICOLON']=186;
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
		remotemapname['ENTER']=Key.ENTER;
		remotemapname['SELECT']=Key.ENTER;
		remotemapname['PAGEUP']=Key.PGUP;
		remotemapname['PAGEDOWN']=Key.PGDN;
	}

	// detect my hardware
	private function detect(callback) {
		trace("checking for dune hardware");

		if(ExtCommand.getSerialNumber()) {
			Dialog.update_splash("Dune Player");
			callback(true);
		} else {
			trace("not dune hardware");
			callback(false);
		}
	}

// ************************ PLAY STUFF
	private function playlist() {
		return 'remote';   // dunes exit flash to play, we need a server url for playlist
	}

	private function play_single(data) {
		trace("dune play");

		this.prepare_exit();

		// external play command goes here
		return true;
	}

	private function play_playlist(data) {
		trace("dune playlist");

		this.prepare_exit();

		// external playlist command goes here
		return true;
	}

	private function prepare_exit() {
		// resume so
		SharedObj.save();

		// TODO: history save
	}
}
