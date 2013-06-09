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
import dent.api.Server;
import dent.tools.UltraLoader;

import com.greensock.*;

class dent.ssbg {
	private static var ssMC:MovieClip=null;
	private static var imagedata:Array=null;
	private static var current:Number=0;
	private static var clip:String=null;
	private static var last:String=null;
	private static var first:Boolean=true;
	private static var killed:Boolean=false;
	private static var paused:Boolean=false;

	public static function init() {
		ssMC=Common.stage.createEmptyMovieClip("ssbg", Common.depths['SSBG']);

		delete imagedata;
		imagedata=null;

		trace("ssbg ready");
	}

	public static function kill() {
		trace("killing ssbg");
		killed=true;
		for(var p in ssMC) {
			if(typeof(ssMC[p])=="movieclip") {
				TweenMax.killTweensOf(ssMC[p]);
				ssMC[p].removeMovieClip();
			}
		}

		delete imagedata;
		imagedata=null;
		current=0;
		first=true;
		clip=null;
		last=null;
	}

	public static function pause() {
		trace("SSBG: Pausing");

		paused=true;
		var all=TweenMax.getTweensOf(ssMC[clip],ssMC[last]);
		for(var a in all) {
			all[a].pause();
		}
	}

	public static function resume() {
		trace("SSBG: resuming");

		paused=false;
		var all=TweenMax.getTweensOf(ssMC[clip],ssMC[last]);
		for(var a in all) {
			all[a].resume();
		}

	}

	public static function load(url) {
		trace("SSBG: "+url);
		//Server.retrieve(url, ssbg.loaded);
	}

	public static function loaded(success, data) {
		if(success) {
			killed=false;
			imagedata=data;
			trace(imagedata);
			paused=false;
			killed=false;
			ssbg.next();
		} else {
			trace("SSBG: failed to get data "+data);
			resume();
		}
	}

	public static function next() {
		if(killed) return;

		last=clip;
		var d=new Date();
		clip=d.getTime();
		UltraLoader.image(ssMC, imagedata[current], {name:clip,x:0,y:0,width:1280,height:720}, 1, ssbg.image_up);
		current++;
		if(current>=imagedata.length) current=0;
	}

	public static function image_up(success, data) {
		if(success) {
			if(first) {
				trace("SSBG: first, showing");
				ssMC[clip]._alpha=100;
				ssMC[clip]._visible=true;

				if(Common.runtime.animation==0) {
					trace("ssbg: animation disabled, done");
				} else {
					first=false;
					_global["setTimeout"](ssbg.tween_done, (Common.runtime.animation-1)*1000);
				}

				// pull out the bg clip (load was good)
				ssMC['background'].removeMovieClip();
			} else {
				trace("SSBG: tweening");
				ssMC[clip].swapDepths(ssMC[last]);
				TweenMax.to(ssMC[last], Common.runtime.animation, {autoAlpha:0,onComplete:ssbg.tween_done,paused:paused,delay:1});
			}
		} else {
			trace("SSBG: image failed to load");
			next();
		}
	}

	public static function remove() {
		for (var i in ssMC) {
			if(ssMC[i]._name!=clip) {
				ssMC[i].removeMovieClip();
			}
		}
	}

	public static function tween_done() {
		trace("SSBG: tween done");

		remove();
		next();
	}
}
