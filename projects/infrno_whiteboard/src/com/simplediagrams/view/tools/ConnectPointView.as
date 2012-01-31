package com.simplediagrams.view.tools
{
	import com.simplediagrams.model.tools.ConnectorPoint;
	
	import flash.display.Graphics;
	
	import spark.core.SpriteVisualElement;
	
	public class ConnectPointView extends SpriteVisualElement
	{
		
		private var _connectionPoint:ConnectorPoint;

		public function get connectionPoint():ConnectorPoint
		{
			return _connectionPoint;
		}

		public function set connectionPoint(value:ConnectorPoint):void
		{
			_connectionPoint = value;
			redraw();
		}

		
		public function ConnectPointView()
		{
			super();
			redraw();
		}
		
		
		public function redraw() : void
		{
			var g:Graphics = this.graphics
			g.clear();
			if(_connectionPoint)
			{
				x = _connectionPoint.x;
				y = _connectionPoint.y;
				
				//bigger white x
				
				g.lineStyle(4, 0xFFFFFF, .5	)
				g.moveTo(-5, - 5);
				g.lineTo(5, 5);
				g.moveTo(-5, 5);
				g.lineTo(5, -5);
				
				//blue x
				g.lineStyle(2, 0x0000ff);
				g.moveTo(-4, - 4);
				g.lineTo(4, 4);
				g.moveTo(-4, 4);
				g.lineTo(4, -4);
				
				
				
				if(_connectionPoint.isClose)
				{
					g.lineStyle(2, 0xff0000);
					g.drawRect(-5, -5, 10, 10);
				}
			}
		}
	}
}