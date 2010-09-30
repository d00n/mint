package com.simplediagrams.model
{
		
    import com.simplediagrams.events.RemoteSharedObjectEvent;
    import com.simplediagrams.model.mementos.ITransformMemento;
    import com.simplediagrams.model.mementos.SDImageMemento;
    import com.simplediagrams.model.mementos.SDObjectMemento;
    import com.simplediagrams.util.Logger;
    import com.simplediagrams.view.SDComponents.ISDComponent;
    import com.simplediagrams.view.SDComponents.SDImage;
    
    import flash.utils.ByteArray;
	import flash.net.URLRequest;
	import flash.display.Loader;
	import flash.events.ProgressEvent;


	[Bindable]
	[Table(name="images")]
	public class SDImageModel extends SDObjectModel
	{
		
		public static const STYLE_NONE:String = "none"
		public static const STYLE_PHOTO:String = "photoStyle"
		
		private var _imageData:ByteArray
		private var _styleName:String = STYLE_NONE;
		
		[Transient]
		public var origWidth:int
		[Transient]
		public var origHeight:int
		
		private var _startState:SDImageMemento
		
		private var _imageURL:String;
		
		public function SDImageModel()
		{
			super();
			this.width = 200
			this.height = 200
		}
	
		public override function createSDComponent():ISDComponent
		{
			var component:SDImage = new SDImage()
			component.objectModel = this
			this.sdComponent = component
			Logger.debug("component: " + component)
			return component
		}
		
		public function get imageData():ByteArray
		{
			return _imageData;
		}
				
		public function set imageData(v:ByteArray):void
		{
			_imageData = v;
		}
		
		public function get imageURL():String{
			return _imageURL;			
		}
		
		public function set imageURL(value:String):void{
			_imageURL = value;
		}
		
		private function loadProgress(event:ProgressEvent):void
		{   
			// TODO loading bar in the image frame for extra credit
			var percentLoaded:Number = Math.round((event.bytesLoaded/event.bytesTotal) * 100);
			trace("Loading: "+percentLoaded+"%");
		}
		
		public function loadComplete(event:Event):void
		{
			trace("Complete");
			// TODO: ....and where's Johnny?
			//			addChild(loader);
		}

		
		public function get styleName():String
		{
			return _styleName;
		}

		public function set styleName(v:String):void
		{
			_styleName = v;
		}
		
		override public function getMemento():SDObjectMemento
		{
			var memento:SDImageMemento = new SDImageMemento()
			captureBasePropertiesInMemento(memento)
			
			//now record SDSymbolModel's specific properties into memento
			//...todo
			var mem:SDImageMemento = SDImageMemento(memento)
			mem.imageData = imageData
			mem.styleName = styleName 
			mem.origHeight = origHeight
			mem.origWidth = origWidth 
			
			return mem 
		}
		
		
		override public function setMemento(memento:SDObjectMemento):void
		{
							
			//set base properties from memento
			this.setBasePropertiesFromMemento(memento)
			
			//now set SDSymbolModel specific properties from memento
			var mem:SDImageMemento = SDImageMemento(memento)
			imageData = mem.imageData
			styleName = mem.styleName
			origHeight = mem.origHeight
			origWidth = mem.origWidth
				
		}
		
		
		
	
	}
}