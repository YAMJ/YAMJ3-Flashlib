
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