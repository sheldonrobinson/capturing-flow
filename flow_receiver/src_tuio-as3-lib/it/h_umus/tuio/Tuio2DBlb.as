package it.h_umus.tuio
{
	/**
	 * 
	 * @author Ignacio Delgado
	 * @see http://code.google.com/p/tuio-as3-lib
	 * @see http://www.tuio.org
	 * @see http://mtg.upf.es/reactable/?software
	 * 
	 */
	public class Tuio2DBlb extends AbstractTuio
	{
		public var x:Number;
		public var y:Number;
		public var a:Number;
		public var w:Number;
		public var h:Number;
		public var f:Number;
		public var X:Number;
		public var Y:Number;
		public var A:Number;
		public var m:Number;
		public var r:Number;
		
		public function Tuio2DBlb(s:int, x:Number, y:Number, a:Number, w:Number, h:Number, f:Number, X:Number, Y:Number, A:Number, m:Number, r:Number)
		{
			//super(s);
			this.s = s;
			this.x = x;
			this.y = y;
			this.a = a;
			this.w = w;
			this.h = h;
			this.f = f;
			this.X = X;
			this.Y = Y;
			this.A = A;
			this.m = m;
			this.r = r;
		}
		
		public function update(x:Number, y:Number, a:Number, w:Number, h:Number, f:Number, X:Number, Y:Number, A:Number, m:Number, r:Number):void{
			this.x = x;
			this.y = y;
			this.a = a;
			this.w = w;
			this.h = h;
			this.f = f;
			this.X = X;
			this.Y = Y;
			this.A = A;
			this.m = m;
			this.r = r;
		}
		
	}
}