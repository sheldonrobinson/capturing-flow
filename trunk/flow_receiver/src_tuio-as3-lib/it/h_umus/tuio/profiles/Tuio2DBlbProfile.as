package it.h_umus.tuio.profiles
{
	import it.h_umus.osc.OSCMessage;
	import it.h_umus.tuio.AbstractTuio;
	import it.h_umus.tuio.Tuio2DBlb;
	import it.h_umus.tuio.events.Tuio2DBlbEvent;
	
	
	/**
	 * 
	 * @author Ignacio Delgado
	 * @see http://code.google.com/p/tuio-as3-lib
	 * @see http://www.tuio.org
	 * @see http://mtg.upf.es/reactable/?software
	 * 
	 */
	public class Tuio2DBlbProfile extends AbstractProfile
	{
		public function Tuio2DBlbProfile()
		{
			super();
		}
		
		override public function get profileName():String
		{
			return "/tuio/2Dblb";
		}
		
		protected override function dispatchRemove(tuio:AbstractTuio):void
		{
			_dispatcher.dispatchEvent(new Tuio2DBlbEvent(Tuio2DBlbEvent.REMOVE_TUIO_2D_BLB, tuio as Tuio2DBlb));
		}
		
		protected override function processSet(message:OSCMessage) : void
		{
			var s:int = message.getArgumentValue(1) as int;
			var x:Number = message.getArgumentValue(2) as Number;
			var y:Number = message.getArgumentValue(3) as Number;
			var a:Number = message.getArgumentValue(4) as Number;
			var w:Number = message.getArgumentValue(5) as Number;
			var h:Number = message.getArgumentValue(6) as Number;
			var f:Number = message.getArgumentValue(7) as Number;
			var X:Number = message.getArgumentValue(8) as Number;
			var Y:Number = message.getArgumentValue(9) as Number;
			var A:Number = message.getArgumentValue(10) as Number;
			var m:Number = message.getArgumentValue(11) as Number;
			var r:Number = message.getArgumentValue(12) as Number;
						
			var tuio2Dblb:Tuio2DBlb = (_objectsList[s] == null) ?  new Tuio2DBlb(s, x, y, a, w, h, f, X, Y, A, m, r) : _objectsList[s] as Tuio2DBlb;
						
			if(_objectsList[s] == null)
			{
				_objectsList[s] = tuio2Dblb;
				_dispatcher.dispatchEvent(new Tuio2DBlbEvent(Tuio2DBlbEvent.ADD_TUIO_2D_BLB, tuio2Dblb));
				_dispatcher.dispatchEvent(new Tuio2DBlbEvent(Tuio2DBlbEvent.UPDATE_TUIO_2D_BLB, tuio2Dblb));	
			}
			else
			{
				tuio2Dblb.update(x, y, a, w, h, f, X, Y, A, m, r);
				_dispatcher.dispatchEvent(new Tuio2DBlbEvent(Tuio2DBlbEvent.UPDATE_TUIO_2D_BLB, tuio2Dblb));
				_objectsList[s] = tuio2Dblb;
			}
		}
	}
}