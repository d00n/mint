package com.infrno.chat.view.components
{
	import spark.components.ToggleButton;
	import spark.primitives.BitmapImage;
	
	[Style(name="icon", type="Class")]
	[Style(name="selectedIcon", type="Class")]
	public class ImageToggleButton extends ToggleButton
	{
		
		[SkinPart(required="true")]
		public var iconImage:BitmapImage;
		
		[SkinPart(required="true")]
		public var selectedIconImage:BitmapImage
		
		public function ImageToggleButton( )
		{
			super( );
		}
		
		override protected function partAdded( partName:String, instance:Object ) : void
		{
			super.partAdded( partName, instance );
			
			if ( partName == "iconImage" ) 
			{
				setIconStyle( "icon", instance );
				return;
			}
			
			if( partName == "selectedIconImage" ) 
			{
				setIconStyle( "selectedIcon", instance );	
			}
			
		}
		
		private function setIconStyle( iconStyleName:String, instance:Object ) : void
		{
			var iconClass:Class = Class( getStyle( iconStyleName ) );
			if ( iconClass == null )
			{
				instance = null;
				return
			}
			
			BitmapImage( instance ).source = new iconClass( );
			
		}
	}
}