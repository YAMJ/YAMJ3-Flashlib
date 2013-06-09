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

import dent.Core;
import dent.ssbg;
import dent.tools.Util;
import dent.tools.UltraLoader;
import com.greensock.*;
import com.greensock.plugins.*;

class dent.Common {
    // system
	public static var stage:MovieClip=null;		// our root clip
	public static var runtime:Object=null;		// runtime vars
	public static var settings:Object=null;		// live settings
	public static var playerapi=null;			// the hardware api in use
	public static var depths:Object=null;		// depth list
	public static var ready:Boolean=false;
	public static var core:Core=null;

    // reset.
	public static function reset() {
		delete Common.runtime;
		delete Common.depths;
		Common.runtime=null;
		Common.depths=null;
		Common.settings=null;
		Common.stage=null;
		Common.ready=false;

		core.cleanup();
		UltraLoader.cleanup();
		// api is not reset
	}

	// setup enviromental variables
	public static function enviroment(parentMC:MovieClip) {
		trace("Setting up enviroment");

		trace(".. resetting globals");
		Common.reset();
		Common.ready=false;
		Common.runtime=new Object();
		Common.runtime.settings=new Object();
		Common.runtime.server=new Object();
		Common.settings=new Object();
		Common.runtime.halt=false;
		Common.runtime.skipplayer=false;
		Common.stage=parentMC;
		Common.depths=new Object;
		Common.depths={SSBG: 4, SCREEN0:5, SCREEN1:6, PLAYER:10, MENU: 11, DIM: 15, POPUP:16, VIDEOMASK:17, PRELOADER: 18, ERROR:20, CONNECTDIM:30, SERVER:31}

		// paths
		var ttemp=parentMC._url;
		Common.runtime.swfpath=ttemp;
		Common.runtime.runpath=ttemp.substring(0, parentMC._url.lastIndexOf("/"));
		Common.runtime.version="R0003";

		// defaults
		Common.update_settings();

		// see it
		trace(Common.runtime);

		// greensock
		TweenPlugin.activate([AutoAlphaPlugin]);

		// other
		UltraLoader.init();
		ssbg.init();
	}

	public static function update_settings() {
		trace("updating user settings");

		Common.runtime.timelayout=Common.fix_setting("clock", "12");
		Common.runtime.datelayout=Common.fix_setting("date", "MM-DD-YYYY");
		switch(Common.fix_setting("animation","medium")) {
			case 'off':
				Common.runtime.animation=0;
				break;
			case 'slow':
				Common.runtime.animation=3;
				break;
			case 'medium':
				Common.runtime.animation=2;
				break;
			default: // fast
				Common.runtime.animation=1;
				break;
		}
		trace("animation speed: "+Common.runtime.animation);
	}

	private static function fix_setting(name, def) {
		if(Util.blank(Common.runtime.settings['user']['user'][name]) || Common.runtime.settings['user']['user'][name]=='SYSTEM') {
			if(!Util.blank(Common.runtime.settings['system'][name])) return Common.runtime.settings['system'][name];
			return def;
		} else {
			return Common.runtime.settings['user']['user'][name];
		}
	}
}
