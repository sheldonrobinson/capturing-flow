package it.h_umus.tuio
{
	import it.h_umus.tuio.profiles.Tuio2DObjProfile;
	
	/**
	 * @eventType it.h_umus.tuio.events.Tuio2DObjEvent.ADD_TUIO_2D_OBJ
	 **/
	[Event(name="addTuio2DObj", type="it.h_umus.tuio.events.Tuio2DObjEvent")]
	
	/**
	 * @eventType it.h_umus.tuio.events.Tuio2DObjEvent.UPDATE_TUIO_2D_OBJ
	 **/
	[Event(name="updateTuio2DObj", type="it.h_umus.tuio.events.Tuio2DObjEvent")]
	
	/**
	 * @eventType it.h_umus.tuio.events.Tuio2DObjEvent.REMOVE_TUIO_2D_OBJ
	 **/
	[Event(name="removeTuio2DObj", type="it.h_umus.tuio.events.Tuio2DObjEvent")]
	
	/**
	 * 
	 * @author Ignacio Delgado
	 * @see http://code.google.com/p/tuio-as3-lib
	 * @see http://mtg.upf.es/reactable/?software
	 * 
	 */
	public class Tuio2DObjClient extends TuioClient
	{
		private var _tuio2DObjProfile:Tuio2DObjProfile;
		
		public function Tuio2DObjClient(host:String="localhost", port:uint=3000)
		{
			super(host, port);
			_tuio2DObjProfile = new Tuio2DObjProfile();
			addProfile(_tuio2DObjProfile);
		}
		
	}
}