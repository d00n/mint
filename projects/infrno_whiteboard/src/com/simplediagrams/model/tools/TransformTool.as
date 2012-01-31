package com.simplediagrams.model.tools
{
	import com.simplediagrams.events.TransformEvent;
	import com.simplediagrams.model.CopyUtil;
	import com.simplediagrams.model.DiagramModel;
	import com.simplediagrams.model.SDObjectModel;
	import com.simplediagrams.model.SelectionModel;
	import com.simplediagrams.model.TransformData;
	import com.simplediagrams.view.startup.RecentDiagramsItemRenderer;
	
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.PropertyChangeEvent;

	public class TransformTool extends ToolBase
	{
		public function TransformTool()
		{
			super();
		}
		
		public override function activateTool():void
		{
			selectedObjects = null;
		}
		
		public override function deactivateTool():void
		{
			selectedObjects = null;
		}
		
		private var _selectedObjects:IList;

		public function get selectedObjects():IList
		{
			return _selectedObjects;
		}

		public function set selectedObjects(value:IList):void
		{
			if(_selectedObjects)
				_selectedObjects.removeEventListener(CollectionEvent.COLLECTION_CHANGE, onSelectedCollectionChange);
			_selectedObjects = value;
			if(_selectedObjects)
			{
				_selectedObjects.addEventListener(CollectionEvent.COLLECTION_CHANGE, onSelectedCollectionChange);
				originalTransform = calculateTransform();
				currentTransform = originalTransform.clone();
			}
			else
			{
				originalTransform = null;
				currentTransform = null;
			}
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function onSelectedCollectionChange(event:CollectionEvent):void
		{
			if(internalChanges == false && event.kind == CollectionEventKind.UPDATE)
			{
				originalTransform = calculateTransform();
				currentTransform = originalTransform.clone();
			}
		}
		
		private var _scaleX:Number;
		
		
		public function get scaleX():Number
		{
			return _scaleX;
		}
		
		private var _scaleY:Number;
		
		public function get scaleY():Number
		{
			return _scaleY;
		}
		
		public function setScale(scaleX:Number, scaleY:Number):void
		{
			_scaleX = scaleX;
			_scaleY = scaleY;
			calculateDisplayTransform(currentTransform);
		}
		
		private var _displayTransform:TransformData;
		
		[Bindable("change")]
		public function get displayTransform():TransformData
		{
			return _displayTransform;
		}
		
		public function set displayTransform(value:TransformData):void
		{
			_displayTransform = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function calculateDisplayTransform(transformData:TransformData):void
		{
			if(transformData)
			{
				var scaledTransform:TransformData = transformData.clone();
				scaledTransform.scale(scaleX, scaleY);
				displayTransform = scaledTransform;
			}
			else
				displayTransform = null;
		}
		
		public var originalTransform:TransformData;
		
		private var _currentTransform:TransformData;		

		public function get currentTransform():TransformData
		{
			return _currentTransform;
		}

		public function set currentTransform(value:TransformData):void
		{
			_currentTransform = value;
			calculateDisplayTransform(currentTransform);
		}

		private var currentDragRole:uint = 0;		
		private var startDragPoint:Point;
		private var currentDragPoint:Point;
		private var resizeDirectionPoint:Point;
		private var backupObjectTransforms:Array;
		private var mouseDownRotation:Number;
		private var backUps:Array;
		private var maintainAspectRatio:Boolean = false;
		
		public override function onMouseDown(toolMouseInfo:ToolMouseInfo):void
		{
			maintainAspectRatio = toolMouseInfo.shiftKey;
			if(toolMouseInfo.target != null)
			{
				startDragPoint = new Point( toolMouseInfo.x,  toolMouseInfo.y);
				currentDragPoint = startDragPoint;
				
				if(toolMouseInfo.target is SDObjectModel)
					currentDragRole = HandleRoles.MOVE;
				else
					currentDragRole = uint(toolMouseInfo.target);
				if(HandleRoles.isRotate(currentDragRole))
					mouseDownRotation = originalTransform.rotation + toDegrees( getAngleInRadians(toolMouseInfo.x, toolMouseInfo.y) );        
				backupObjectTransforms = getBackupObjectTransforms();
				backUps = getBackupObjects();
			}
		}
		
		private var internalChanges:Boolean = false;
		
		public override function onMouseMove(toolMouseInfo:ToolMouseInfo):void
		{
			if(currentDragRole != 0)
			{
				currentDragPoint = new Point( toolMouseInfo.x,  toolMouseInfo.y);
				var translation:TransformData = new TransformData();
				
				if( HandleRoles.isMove( currentDragRole ) )
					applyMovement( toolMouseInfo.x, toolMouseInfo.y, translation );
				
				if( HandleRoles.isResizeLeft( currentDragRole ) )
					applyResizeLeft(toolMouseInfo.x, toolMouseInfo.y, translation);              
				
				if( HandleRoles.isResizeUp( currentDragRole) )
					applyResizeUp( toolMouseInfo.x, toolMouseInfo.y, translation);                
				
				if( HandleRoles.isResizeRight( currentDragRole ) )
					applyResizeRight( toolMouseInfo.x, toolMouseInfo.y, translation);             
				
				if( HandleRoles.isResizeDown( currentDragRole ) )
					applyResizeDown( toolMouseInfo.x, toolMouseInfo.y, translation);                      
				
				if( HandleRoles.isRotate( currentDragRole ) )
					applyRotate( toolMouseInfo.x, toolMouseInfo.y, translation );              
				
				internalChanges = true;
				applyTranslation( translation );   
				internalChanges = false;
			}
		}
		
		public override function onMouseUp(toolMouseInfo:ToolMouseInfo):void
		{
			if(currentDragRole != 0)
			{
				originalTransform = currentTransform.clone();
				var transformEvent:TransformEvent = new TransformEvent(TransformEvent.TRANSFORM);
				transformEvent.newTransforms = getBackupObjectTransforms();
				transformEvent.oldTransforms = backupObjectTransforms;
				transformEvent.backup = backUps;
				dispatcher.dispatchEvent(transformEvent);
				currentDragRole = 0;
			}
		}
		
		private function getBackupObjectTransforms():Array
		{
			var result:Array = [];
			for each(var sdModel:SDObjectModel in selectedObjects)
			{
				result.push(new TransformData(sdModel.x, sdModel.y, sdModel.width, sdModel.height, sdModel.rotation));
			}
			return result;
		}
		
		private function getBackupObjects():Array
		{
			var result:Array = [];
			for each(var sdModel:SDObjectModel in selectedObjects)
			{
				result.push(CopyUtil.clone(sdModel));
			}
			return result;
		}
		
		
		private function getDragTransformData(startDragPoint:Point, toolMouseInfo:ToolMouseInfo):TransformData
		{
			var top:Number;
			var left:Number;
			var right:Number;
			var bottom:Number;
			if(toolMouseInfo.y > startDragPoint.y)
			{
				top = startDragPoint.y;
				bottom = toolMouseInfo.y;
			} 
			else
			{
				top = toolMouseInfo.y;
				bottom = startDragPoint.y;
			}
			if(toolMouseInfo.x > startDragPoint.x)
			{
				left = startDragPoint.x;
				right = toolMouseInfo.x;
			}
			else
			{
				left = toolMouseInfo.x;
				right = startDragPoint.x;
			}
			return new TransformData(left, top, right - left, bottom - top);
		}
		
		public function calculateTransform():TransformData
		{
			var obj:SDObjectModel;
			var resultTransform:TransformData = new TransformData();			
			if(selectedObjects.length == 0 ) { return null; }
			if(selectedObjects.length == 1) 
			{
				obj = selectedObjects.getItemAt(0) as SDObjectModel;	
				return obj.getTransform();
			} 
			else 
				return calculateMultiGeometry();
			return null;
		}
		
		
		protected function calculateMultiGeometry():TransformData
		{
			var resultTransform:TransformData;
			var lx1: Number = Number.POSITIVE_INFINITY; // top left bounds
			var ly1: Number = Number.POSITIVE_INFINITY;
			var lx2: Number = Number.NEGATIVE_INFINITY; // bottom right bounds
			var ly2: Number = Number.NEGATIVE_INFINITY;
			
			var matrix:Matrix = new Matrix();
			var temp:Point = new Point();
			var temp2:Point = new Point();
			
			for each(var modelObject:SDObjectModel in selectedObjects) 
			{      
				var transform:TransformData = modelObject.getTransform();
				matrix.identity();
				matrix.rotate( toRadians(transform.rotation) );
				matrix.translate( transform.x, transform.y );
				
				
				temp.x=0; // Check top left
				temp.y=0;
				temp = matrix.transformPoint(temp);                             
				
				lx1 = Math.min(lx1, temp.x );
				ly1 = Math.min(ly1, temp.y );
				lx2 = Math.max(lx2, temp.x );
				ly2 = Math.max(ly2, temp.y );
				
				temp.x=0; // Check bottom left
				temp.y=transform.height;
				temp = matrix.transformPoint(temp);                             
				lx1 = Math.min(lx1, temp.x );
				ly1 = Math.min(ly1, temp.y );
				lx2 = Math.max(lx2, temp.x );
				ly2 = Math.max(ly2, temp.y );
				
				temp.x=transform.width; // Check top right
				temp.y=0;
				temp = matrix.transformPoint(temp);                             
				lx1 = Math.min(lx1, temp.x );
				ly1 = Math.min(ly1, temp.y );
				lx2 = Math.max(lx2, temp.x );
				ly2 = Math.max(ly2, temp.y );
				
				temp.x=transform.width; // Check top right
				temp.y=transform.height;
				temp = matrix.transformPoint(temp);                             
				lx1 = Math.min(lx1, temp.x );
				ly1 = Math.min(ly1, temp.y );
				lx2 = Math.max(lx2, temp.x );
				ly2 = Math.max(ly2, temp.y );
				
				
			}
			resultTransform = new TransformData(lx1, ly1, lx2 - lx1,  ly2 - ly1, 0);
			return resultTransform;
		}
		
		protected static function toRadians( degrees:Number ) :Number
		{
			return degrees * Math.PI / 180;
		}
		protected static function toDegrees( radians:Number ) :Number
		{
			return radians *  180 / Math.PI;
		}
		
		public function applyConstraint(original:TransformData, translation:TransformData, resizeHandleRole:uint):void
		{			
			if( ! HandleRoles.isResize( resizeHandleRole ) ) return;
			
			var originalProportion:Number = original.width / original.height;  // x/y
			var possiblePos1:Point = new Point( translation.width, translation.width / originalProportion );
			var possiblePos2:Point = new Point( translation.height * originalProportion, translation.height );
			var originalPoint:Point = new Point( translation.width, translation.height);
			var distance1:Number = Point.distance( possiblePos1, originalPoint );
			var distance2:Number = Point.distance( possiblePos2, originalPoint );
			
			var target:Point;
			
			if( !(HandleRoles.isResizeDown(resizeHandleRole) || HandleRoles.isResizeUp(resizeHandleRole)) )
			{
				// only resize left/right
				target =  possiblePos1 ;
			}
			else if( !(HandleRoles.isResizeLeft(resizeHandleRole) || HandleRoles.isResizeRight(resizeHandleRole)) )
			{
				// only resize up/down
				target = possiblePos2;
			}
			else
			{
				target = distance1 < distance2 ? possiblePos1 : possiblePos2;	
			}
			
			if(target)
			{
				translation.width = target.x;
				translation.height = target.y;
			}
		}
		
		protected function applyTranslation( translation:TransformData) : void
		{
			if(maintainAspectRatio)
				applyConstraint(originalTransform, translation, currentDragRole);
			applyTransformToData(translation, originalTransform);
			if(selectedObjects.length == 1 )                           
				applyTranslationForSingleObject(selectedObjects.getItemAt(0) as SDObjectModel, translation, backupObjectTransforms[0] , backUps[0]);                    
			else if( selectedObjects.length > 1 )
			{          
				var i:int = 0;
				for each ( var subObject:SDObjectModel in selectedObjects )
				{
					var subTranslation:TransformData = calculateTranslationFromMultiTranslation(subObject,  translation, backupObjectTransforms[i]);
					applyTranslationForSingleObject( subObject, subTranslation, backupObjectTransforms[i], backUps[i]);
					i++;
				}
			}
		}
		
		private var selectionMatrix:Matrix = new Matrix();
		private var objectMatrix:Matrix = new Matrix();
		private var relativeGeometry:Point = new Point();
		
		protected function calculateTranslationFromMultiTranslation(object:SDObjectModel, overallTranslation:TransformData, originalObjectTransform:TransformData):TransformData
		{
			var rv:TransformData = new TransformData();
			selectionMatrix.identity();
			selectionMatrix.rotate( toRadians( overallTranslation.rotation ));
			selectionMatrix.scale( (originalTransform.width + overallTranslation.width) / originalTransform.width,
				(originalTransform.height + overallTranslation.height) / originalTransform.height );
			selectionMatrix.translate( overallTranslation.x + originalTransform.x, overallTranslation.y + originalTransform.y);
			
			relativeGeometry.x = originalObjectTransform.x - originalTransform.x;
			relativeGeometry.y = originalObjectTransform.y - originalTransform.y;                      
			
			objectMatrix.identity();
			objectMatrix.rotate( toRadians( overallTranslation.rotation +  originalObjectTransform.rotation) );                       
			objectMatrix.translate(relativeGeometry.x, relativeGeometry.y);
			
			
			var translatedZeroPoint:Point = objectMatrix.transformPoint( new Point() );
			var translatedTopRightCorner:Point = objectMatrix.transformPoint( new Point(originalObjectTransform.width,0) );                   
			var translatedBottomLeftCorner:Point = objectMatrix.transformPoint( new Point(0,originalObjectTransform.height) );                        
			
			translatedZeroPoint = selectionMatrix.transformPoint( translatedZeroPoint );
			translatedTopRightCorner = selectionMatrix.transformPoint( translatedTopRightCorner );
			translatedBottomLeftCorner = selectionMatrix.transformPoint( translatedBottomLeftCorner );
			
			var targetWidth:Number = Point.distance( translatedZeroPoint, translatedTopRightCorner);
			var targetHeight:Number = Point.distance( translatedZeroPoint, translatedBottomLeftCorner ) ;
			
			rv.x = translatedZeroPoint.x - originalObjectTransform.x; 
			rv.y = translatedZeroPoint.y - originalObjectTransform.y;
			rv.width = targetWidth - originalObjectTransform.width;
			rv.height = targetHeight - originalObjectTransform.height;
			
			var targetAngle:Number = toDegrees(Math.atan2( translatedTopRightCorner.y - translatedZeroPoint.y, translatedTopRightCorner.x - translatedZeroPoint.x));
			
			rv.rotation = targetAngle - originalObjectTransform.rotation - overallTranslation.rotation;
			return rv;
		}
		
		protected function applyTranslationForSingleObject( current:SDObjectModel, translation:TransformData , originalTransform:TransformData, backup:SDObjectModel) : void
		{
			var totalTransform:TransformData = new TransformData();
			totalTransform.x = translation.x + originalTransform.x;
			totalTransform.y = translation.y + originalTransform.y;
			
			totalTransform.width = translation.width + originalTransform.width;
			totalTransform.height = translation.height + originalTransform.height;
			totalTransform.rotation = translation.rotation + originalTransform.rotation;
			
			current.applyTransform(totalTransform, originalTransform, backup);
		}
		
		protected function applyTransformToData(translation:TransformData , originalTransform:TransformData):void
		{
			currentTransform.x = translation.x + originalTransform.x;
			currentTransform.y = translation.y + originalTransform.y;
			
			currentTransform.width = translation.width + originalTransform.width;
			currentTransform.height = translation.height + originalTransform.height;
			currentTransform.rotation = translation.rotation + originalTransform.rotation;			
			calculateDisplayTransform(currentTransform);
		}
		
		
		protected function applyRotate(x:Number, y:Number, proposed:TransformData ) : void
		{
			var centerRotatedAmount:Number = toRadians(originalTransform.rotation) - toRadians(mouseDownRotation) + getAngleInRadians(x, y);
			
			var oldRotationMatrix:Matrix = new Matrix();
			oldRotationMatrix.rotate( toRadians( originalTransform.rotation) );
			var oldCenter:Point = oldRotationMatrix.transformPoint(new Point(originalTransform.width/2, originalTransform.height/2));
			
			var newRotationMatrix:Matrix = new Matrix();
			newRotationMatrix.translate(-oldCenter.x, -oldCenter.y);//-originalGeometry.width/2,-originalGeometry.height/2);                                    
			newRotationMatrix.rotate( centerRotatedAmount );
			newRotationMatrix.translate(oldCenter.x, oldCenter.y);                          
			var newOffset:Point = newRotationMatrix.transformPoint( new Point() );
			
			
			proposed.x += newOffset.x;
			proposed.y += newOffset.y;
			proposed.rotation = toDegrees(centerRotatedAmount);
		}    
		
		
		protected function getAngleInRadians(x:Number,y:Number):Number
		{
			var m:Matrix = new Matrix();
			var angle1:Number;
			m.identity();
			m.rotate( toRadians( originalTransform.rotation)  );
			var originalCenter:Point = m.transformPoint( new Point(originalTransform.width/2, originalTransform.height/2) );
			originalCenter.offset( originalTransform.x,  originalTransform.y );
			return Math.atan2(y - originalCenter.y, x - originalCenter.x) ;
		}
		
		protected function applyMovement(x:Number, y:Number, translation:TransformData ) : void
		{          
			var mouseDelta:Point = new Point( x - startDragPoint.x, y - startDragPoint.y );
			translation.x = mouseDelta.x;
			translation.y = mouseDelta.y;
		}
		
		protected function applyResizeRight(x:Number, y:Number, translation:TransformData) : void
		{
			var matrix:Matrix = new Matrix();
			matrix.rotate( toRadians( originalTransform.rotation ) );
			var invMatrix:Matrix = matrix.clone();
			invMatrix.invert();
			var localOriginalMousePoint:Point = invMatrix.transformPoint( startDragPoint );
			var localMousePoint:Point = invMatrix.transformPoint( new Point(x, y) );
			var resizeDistance:Number = localMousePoint.x - localOriginalMousePoint.x ;			
			translation.width +=  resizeDistance;						
			var translationp:Point = matrix.transformPoint( new Point() );
			translation.x +=  translationp.x;
			translation.y +=  translationp.y;
		}
		
		protected function applyResizeDown( x:Number, y:Number, translation:TransformData ) : void
		{
			var matrix:Matrix = new Matrix();
			matrix.rotate( toRadians( originalTransform.rotation ) );
			var invMatrix:Matrix = matrix.clone();
			invMatrix.invert();
			var localOriginalMousePoint:Point = invMatrix.transformPoint( startDragPoint );
			var localMousePoint:Point = invMatrix.transformPoint( new Point(x, y) );
			var resizeDistance:Number = localMousePoint.y - localOriginalMousePoint.y;
			translation.height +=  resizeDistance;
			
			var translationp:Point = matrix.transformPoint( new Point() );
			
			translation.x +=  translationp.x;
			translation.y +=  translationp.y;
		}
		
		protected function applyResizeLeft(x:Number, y:Number, translation:TransformData  ) : void
		{
			var matrix:Matrix = new Matrix();
			matrix.rotate( toRadians( originalTransform.rotation ) );
			var invMatrix:Matrix = matrix.clone();
			invMatrix.invert();
			var localOriginalMousePoint:Point = invMatrix.transformPoint( startDragPoint );
			var localMousePoint:Point = invMatrix.transformPoint( new Point(x, y) );			
			var resizeDistance:Number = localOriginalMousePoint.x - localMousePoint.x ;
			translation.width +=  resizeDistance;
			var translationp:Point = matrix.transformPoint( new Point(-translation.width,0) );
			translation.x +=  translationp.x;
			translation.y +=  translationp.y;
		}
		
		protected function applyResizeUp(x:Number, y:Number, translation:TransformData ) : void
		{
			var matrix:Matrix = new Matrix();
			matrix.rotate( toRadians( originalTransform.rotation ) );
			var invMatrix:Matrix = matrix.clone();
			invMatrix.invert();			
			
			var localOriginalMousePoint:Point = invMatrix.transformPoint( startDragPoint );
			var localMousePoint:Point = invMatrix.transformPoint( new Point(x, y) );
			var resizeDistance:Number = localOriginalMousePoint.y - localMousePoint.y ;
			translation.height +=  resizeDistance;
			var translationp:Point = matrix.transformPoint( new Point(0, -translation.height) );			
			translation.x += translationp.x;
			translation.y += translationp.y;
		}     
	}
}