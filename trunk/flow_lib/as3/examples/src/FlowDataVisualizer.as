package  
{
	import com.mikecreighton.flow.FlowData;

	import org.casalib.display.CasaBitmap;
	import org.casalib.display.CasaTextField;
	import org.casalib.events.ProcessEvent;
	import org.casalib.ui.Key;
	import org.casalib.util.StageReference;

	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;

	/**
	 * @author Mike Creighton
	 */
	public class FlowDataVisualizer extends Sprite 
	{
		private var _flowData : FlowData;
		
		private var _strokeRenderDisplay : CasaBitmap;
		private var _strokeRenderBuffer : BitmapData;
		private var _strokeRenderer : FlowStrokeRenderer;
		private var _currStrokeDisplay : CasaTextField;
		private var _currStrokeIndex : int;
		
		public function FlowDataVisualizer()
		{
			addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage, false, 0, true);
		}

		private function _onAddedToStage(event : Event) : void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
			StageReference.setStage(stage);
			var s : Stage = StageReference.getStage();
			s.align = StageAlign.TOP_LEFT;
			s.scaleMode = StageScaleMode.NO_SCALE;
			
			_currStrokeIndex = 0;
			
			// Create a rectangle representing a new coordinate space for remapping the source Flow GML point data. 
			var remapRect : Rectangle = new Rectangle(0, 0, s.stageWidth, s.stageHeight);
			_flowData = new FlowData('example.gml', 0, remapRect, true);
			_flowData.addEventListener(Event.COMPLETE, _onFlowDataLoadComplete, false, 0, true);
			_flowData.load();
		}

		private function _onFlowDataLoadComplete(event : Event) : void 
		{
			_flowData.removeEventListener(Event.COMPLETE, _onFlowDataLoadComplete);
			
			// Create a dark-filled bitmap for rendering a stroke's data.
			_strokeRenderBuffer = new BitmapData(StageReference.getStage().stageWidth, StageReference.getStage().stageHeight, true, 0xFF111111);
			_strokeRenderDisplay = new CasaBitmap(_strokeRenderBuffer, PixelSnapping.ALWAYS, false);
			addChild(_strokeRenderDisplay);
			
			// Create an instructions display.
			var fmt : TextFormat = new TextFormat('_sans', 10, 0xAAAAAA);
			var instructions : CasaTextField = new CasaTextField();
			instructions.embedFonts = false;
			instructions.height = 16;
			instructions.wordWrap = false;
			instructions.multiline = false;
			instructions.autoSize = TextFieldAutoSize.LEFT;
			instructions.antiAliasType = AntiAliasType.ADVANCED;
			instructions.defaultTextFormat = fmt;
			instructions.x = 10;
			instructions.y = 10;
			instructions.text = "Use UP and DOWN arrow keys to change current stroke.";
			addChild(instructions);			
			
			// Create a textfield for indicating what stroke we're showing.
			_currStrokeDisplay = new CasaTextField();
			_currStrokeDisplay.embedFonts = false;
			_currStrokeDisplay.height = 16;
			_currStrokeDisplay.wordWrap = false;
			_currStrokeDisplay.multiline = false;
			_currStrokeDisplay.autoSize = TextFieldAutoSize.LEFT;
			_currStrokeDisplay.antiAliasType = AntiAliasType.ADVANCED;
			_currStrokeDisplay.defaultTextFormat = fmt;
			_currStrokeDisplay.x = 10;
			_currStrokeDisplay.y = 30;
			addChild(_currStrokeDisplay);
			
			// Add a keyboard listener for moving back and forth between strokes.
			Key.getInstance().addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown, false, 0, true);
			
			_updateCurrentStrokeDisplay();
			_drawCurrentStroke();
		}

		private function _onKeyDown(event : KeyboardEvent) : void 
		{
			// Check to see if it's the up or down arrow key.
			var update : Boolean = false;
			if(event.keyCode == Keyboard.UP)
			{
				_currStrokeIndex--;
				if(_currStrokeIndex < 0)
					_currStrokeIndex = _flowData.numStrokes - 1;
				update = true;
			}
			else if (event.keyCode == Keyboard.DOWN)
			{
				_currStrokeIndex++;
				if(_currStrokeIndex >= _flowData.numStrokes)
					_currStrokeIndex = 0;
				update = true;
			}
			
			if(update)
			{
				_updateCurrentStrokeDisplay();
				_drawCurrentStroke();
			}
		}
		
		private function _updateCurrentStrokeDisplay() : void 
		{
			_currStrokeDisplay.textColor = 0xAAAAAA;
			_currStrokeDisplay.text = 'Current stroke index: ' + _currStrokeIndex;
		}

		private function _drawCurrentStroke() : void
		{
			// Clear the buffer.
			_strokeRenderBuffer.fillRect(_strokeRenderBuffer.rect, 0xFF111111);
			
			if(_strokeRenderer != null)
			{
				_strokeRenderer.destroy();
				_strokeRenderer = null;
			}
			
			_strokeRenderer = new FlowStrokeRenderer(_strokeRenderBuffer, _flowData.getStroke(_currStrokeIndex));
			_strokeRenderer.addEventListener(ProcessEvent.COMPLETE, _onStrokeRendererDrawingComplete, false, 0, true);
			_strokeRenderer.start();
		}

		private function _onStrokeRendererDrawingComplete(event : ProcessEvent) : void 
		{
			_currStrokeDisplay.appendText(' (Render Complete!)');
			_currStrokeDisplay.textColor = 0xC43D65;
		}
	}
}
