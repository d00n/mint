package com.simplediagrams.util
{
	
	import com.simplediagrams.model.ApplicationModel;
	
	import flash.events.IOErrorEvent;
//	import flash.filesystem.*;
	import flash.net.XMLSocket;
	import flash.utils.getQualifiedClassName;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.logging.LogEventLevel;
		
	
	public class Logger	
	{
								
		public static var enabled : Boolean = true;
		public static var myLogger : ILogger
		private static var socket : XMLSocket;
//		public static var logFile:File		
//		public static var logFileStream:FileStream
		public static var logToFile:Boolean = true;
		
		

		public static function debug(o:Object, target:Object=null):void
		{
			_send(LogEventLevel.DEBUG, o, target);
		}

		public static function info(o:Object, target:Object=null):void
		{
			_send(LogEventLevel.INFO, o, target);
		}
		
		public static function warn(o:Object, target:Object=null):void
		{
			_send(LogEventLevel.WARN, o, target);
		}
		
		public static function error(o:Object, target:Object=null):void
		{
			_send(LogEventLevel.ERROR, o, target);
		}

		public static function fatal(o:Object, target:Object=null):void
		{
			_send(LogEventLevel.FATAL, o, target);
		}
		
		public static function all(o:Object, target:Object=null):void
		{
			_send(LogEventLevel.ALL, o, target);
		}

		private static function onSocketError(err:IOErrorEvent):void
		{
				//do nothing.
		}
			
		private static function _send(lvl:Number, o:Object, target:Object):void
		{
			
			try
			{
								
				if (myLogger == null)
				{
					myLogger = Log.getLogger("com.simplediagrams") 
				}
											
				var type:String
				var targetName:String
				switch(lvl)
	            {
	            	case LogEventLevel.DEBUG:
						type = "DEBUG:"
	                	if (Log.isDebug()) 
						{
							targetName = getTargetClassName(target)
	                    	myLogger.debug(targetName + " : " + o.toString()) 
	                    }
	                    break;
					case LogEventLevel.INFO:
						type = "INFO:"
						if (Log.isInfo()) 
						{							
							targetName = getTargetClassName(target)
							myLogger.info(targetName + " : " +o.toString()); 
						}
						break;
					case LogEventLevel.WARN:
						type = "WARN:"
						if (Log.isWarn()) 
						{							
							targetName = getTargetClassName(target)
	                        myLogger.warn(targetName + " : " + o.toString());
	                    }
	                    break;
	                case LogEventLevel.ERROR:
						type = "ERROR:"
	                    if (Log.isError()) 
						{							
							targetName = getTargetClassName(target)
	                        myLogger.error(targetName + " : " + o.toString());
	                    }
	                    break;
	                case LogEventLevel.FATAL:
						type = "FATAL:"
	                    if (Log.isFatal()) 
						{
							targetName = getTargetClassName(target)
	                        myLogger.fatal(targetName + " : " + o.toString());
	                    }
	                    break;
					case LogEventLevel.ALL:
						type = "ALL:"
						targetName = getTargetClassName(target)
						myLogger.log(lvl, targetName + " : " +  o.toString());
						break;
	            }
			}
			catch(error:Error)
			{
				//hmm...
			}
           
            //log to file 
            try
            {
//				if (logFile==null)
//				{
//					var logFileDir:File = File.applicationStorageDirectory.resolvePath(ApplicationModel.logFileDir)
//	           		logFile = logFileDir.resolvePath(ApplicationModel.logFileName)
//	           		logFileStream = new FileStream()
//	   			}
//	   			
//	   			if (logToFile)
//	   			{					
//					logFileStream.open(logFile, FileMode.APPEND)
//	   				logFileStream.writeUTFBytes( File.lineEnding + type + o)
//	   				logFileStream.close()
//	   			}
            }
	   		catch(err:Error)
	   		{
	   			trace("couldn't delete log file! Error: " + err)
	   		}
			
//			if (logToFile && logFile) //&& lvl> LogEventLevel.DEBUG)
//			{					
//				if (logFileStream==null) logFileStream = new FileStream()
//				logFileStream.open(logFile, FileMode.APPEND)
//				logFileStream.writeUTFBytes( File.lineEnding + type + o)
//				logFileStream.close()
//			}
				
		}
	
		protected static function getTargetClassName(target:Object):String
		{
			if (target!=null)
			{
				var targetName:String = getQualifiedClassName(target).split("::")[1]
			}
			else
			{
				targetName=""
			}
			return targetName
		}
		

	}


}
