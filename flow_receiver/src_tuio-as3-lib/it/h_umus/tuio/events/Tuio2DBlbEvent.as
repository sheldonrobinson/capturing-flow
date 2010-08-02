package it.h_umus.tuio.events
{
	import flash.events.Event;
	
	import it.h_umus.tuio.Tuio2DBlb;
	
	/**
	 * 
	 * @author Ignacio Delgado
	 * @see http://code.google.com/p/tuio-as3-lib
	 * @see http://www.tuio.org
	 * @see http://mtg.upf.es/reactable/?software
	 * 
	 */
	public class Tuio2DBlbEvent extends Event
	{
		public static const ADD_TUIO_2D_BLB:String		= "it.h_umus.tuio.events.addTuio2DBlb";
		public static const UPDATE_TUIO_2D_BLB:String 	= "it.h_umus.tuio.events.updateTuio2DBlb";
		public static const REMOVE_TUIO_2D_BLB:String	= "it.h_umus.tuio.events.removeTuio2DBlb";
		
		public var data:Tuio2DBlb;
		
		public function Tuio2DBlbEvent(type:String, data:Tuio2DBlb)
		{
			super(type);
			this.data = data;
		}
		
		override public function clone():Event{
			return new Tuio2DBlbEvent(type, data);
		}
		
	}
}