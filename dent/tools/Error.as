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

class dent.tools.Errror {
	public static function xml(errorcode) {
		switch(errorcode) {
			case 0:
				return("file not found");
			case -2:
				return("bad CDATA");
			case -3:
				return("broken xml node");
			case -5:
				return("broken comment");
			case -6:
				return("malformed xml");
			case -7:
				return("out of memory");
			case -8:
				return("bad attribute");
			case -9:
				return("missing end tag");
			case -10:
				return("missing start tag");
			case 10000:
			case 10001:
				return("bug, please report");
			default:
				return("unknown flash error "+errorcode);
		}
	}
}