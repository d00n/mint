package com.adobe.example.packaging
{
	import com.simplediagrams.util.Logger;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
//	import flash.filesystem.File;
//	import flash.filesystem.FileMode;
//	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	import flash.utils.Endian;
	
	public class Unpackager extends EventDispatcher
	{
		private var m_ucfParseState:uint = AT_START;
		//private var identifier:String;
		private var source:URLStream;
		
		// data about the file/Central Dir entry currently being read
		
		private var _generalPurposeBitFlags : uint;
		private var _compressionMethod : uint;
		private var _extraFieldLength : uint;
		private var _compressedSize : uint;
		private var _uncompressedSize : uint;
		private var _filenameLength : uint;
		private var _data : ByteArray;
		private var _path : String;
		private var _currentLFH : ByteArray;
		private var isDirectory:Boolean;		
		private var m_fileCount:uint = 0;
		
		// Used to maintain a tree of directories seen.
		private var _root : Object = new Object();
		
//		private var m_dir:File;
		///private var m_validator:UCFSignature = new UCFSignature();
		///private var m_enableSignatureValidation = true;
		//private var m_isComplete:Boolean = false;
		
		protected static const AT_START       : uint = 0;
		protected static const AT_HEADER      : uint = 1;
		protected static const AT_FILENAME    : uint = 2;
		protected static const AT_EXTRA_FIELD : uint = 3;
		protected static const AT_DATA        : uint = 4;
		protected static const AT_END         : uint = 5;
		protected static const AT_ERROR       : uint = 6;
		protected static const AT_COMPLETE    : uint = 12;
		protected static const AT_ABORTED     : uint = 13;
		
//		public function unpack( url:URLRequest, destination:File ):void
//		{
//			Logger.debug("unpacking destination: " + destination.nativePath, this)
//			m_dir = destination;
//			source = new URLStream();
//			source.addEventListener(ProgressEvent.PROGRESS, parse);
//			source.addEventListener(Event.COMPLETE, onLoadComplete);            
//			source.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);            
//			source.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
//			source.load( url );
//		}
		
		private function parse( event:ProgressEvent ):void 
		{
			Logger.debug("parsing()...", this)
			// The underlying progress from the byte stream is the best estimate
			// we've got of work accomplished and remaining.
			
			try 
			{
				const HEADER_SIZE_BYTES : uint = 30;
				const ZIP_LFH_MAGIC : uint = 0x04034b50;
				
				//const CDHEADER_SIZE_BYTES : uint = 46;
				const ZIP_CDH_MAGIC : uint = 0x02014b50;
				
				//const ZIP_CDSIG_MAGIC : uint = 0x06054b50;
				
				// When a data event is received we must process as much data as possible because it's possible
				// that this is the only or last data event we'll receive. However, we don't have to read every last
				// byte: if the stream stops in, say, the middle of a header, we can reasonably expect to receive
				// another data event. This would only not happen if the data stream is malformed; in that case
				// we'll know that when we get the complete event.
				
				while( true ) 
				{
					switch( m_ucfParseState ) 
					{
						case AT_START:
						case AT_HEADER:
							if( source.bytesAvailable < HEADER_SIZE_BYTES ) return;
							
							_currentLFH = new ByteArray();
							_currentLFH.endian = Endian.LITTLE_ENDIAN;						
							
							// Read the magic identifier first to determine where we are. 
							source.readBytes(_currentLFH, 0, 4);
							
							var magic : uint = _currentLFH.readUnsignedInt();
							if( ZIP_LFH_MAGIC != magic ) {
								if( m_ucfParseState == AT_START ) throw new Error( "not an AIR file" );
								
								// Everything after the local file header we skip for now.								
								if (ZIP_CDH_MAGIC == magic) 
								{
									m_ucfParseState = AT_END;
									dispatchEvent( new Event( Event.COMPLETE )); 
									return;
									break;
								}							
								m_ucfParseState = AT_END;
								return;
							}
							
							source.readBytes(_currentLFH, _currentLFH.length, HEADER_SIZE_BYTES - 4);											
							
							// TODO: Check "version need to extract" field
							var versionNeededToExtract : uint = _currentLFH.readUnsignedShort();
							
							// If bit 3 is set, some header values are in the data
							// descriptor following the file instead of in the file.
							_generalPurposeBitFlags = _currentLFH.readUnsignedShort();
							if(( _generalPurposeBitFlags & 0xFFF9 ) != 0 ) throw new Error( "file uses unsupported encryption or streaming features" );
							
							_compressionMethod = _currentLFH.readUnsignedShort();
							var lastModTime : uint = _currentLFH.readUnsignedShort();
							var lastModDate : uint = _currentLFH.readUnsignedShort();
							
							var crc32 : uint = _currentLFH.readUnsignedInt();													
							_compressedSize = _currentLFH.readUnsignedInt();
							_uncompressedSize = _currentLFH.readUnsignedInt();
							_filenameLength = _currentLFH.readUnsignedShort();
							_extraFieldLength = _currentLFH.readUnsignedShort();
							
							if( _filenameLength == 0 ) throw new Error( "one of the files has an empty (zero-length) name" );
							
							// Fall through
							m_ucfParseState = AT_FILENAME;
							
						case AT_FILENAME:
							
							if( source.bytesAvailable < _filenameLength ) return;
							
							source.readBytes(_currentLFH, _currentLFH.length, _filenameLength);
							
							var filename : ByteArray = new ByteArray();
							_currentLFH.readBytes( filename, 0, _filenameLength );
							
							_path = filename.toString();
							
							// Now that we have a file name, check some error conditions.
							// First, make sure files are in a specific order
							
							if( m_fileCount == 0 && _path != "mimetype" )
								throw new Error( "mimetype must be the first file" );
							
							var DATA_DESCRIPTOR_FLAG : uint = 0x80;
							if( _generalPurposeBitFlags & DATA_DESCRIPTOR_FLAG ) throw new Error( "file " + _path + " uses a data descriptor field" );
							
							var COMPRESSION_NONE : uint = 0;
							var COMPRESSION_DEFLATE : uint = 8;
							if( _compressionMethod != COMPRESSION_DEFLATE && _compressionMethod != COMPRESSION_NONE ) 
							{
								throw new Error( "file " + _path + " uses an illegal compression method " + _compressionMethod );
							}
							
							// A directory is defined to be an entry with a name ending in /. Once we
							// know that, however, we strip of the the last / before doing a split.
							
							isDirectory = ( _path.charAt( _path.length - 1 ) == "/" );
							if( isDirectory ) {
								_path = _path.slice( 0, _path.length - 1 );
							}
							
							var elements : Array = _path.split( "/" );
							if( elements.length == 0 ) throw new Error( "it contains a file with an empty name" );
							
							elements.filter( function( item : *, index : int, array : Array ):Boolean {
								if( item == "." ) throw new Error( "filename " + _path + " contains a component of '.'" );
								if( item == ".." ) throw new Error( "filename " + _path + " contains a component of '..'" );
								if( item == "" ) throw new Error( "filename " + _path + " contains an empty component" );
								return true;
							});				
							
							// The name looks valid. Now figure out the list of parent directories for this file, if any.
							// Then notify the listener of any new directories in this path.
							
							var numParentDirs : int = ( isDirectory ? elements.length : elements.length - 1 );
							var parent : Object = _root;
							var currentPath : Array = new Array();
							
							for( var i : uint = 0; i < numParentDirs; i++ ) {
								var element : String = elements[i];
								currentPath.push( element );
								
								if( parent[element] == null ) {
									parent[element] = new Object();
								}
								
								parent = parent[element];
							}
							
							// Fall through, as before
							m_ucfParseState = AT_EXTRA_FIELD;
							
						case AT_EXTRA_FIELD:
							
							if( source.bytesAvailable < _extraFieldLength ) return;
							
							if( _extraFieldLength > 0 ) {
								
								// The extra field is discarded, but we still need to hash it. 							
								source.readBytes(_currentLFH, _currentLFH.length, _extraFieldLength);															
							}
							
							// Fall through, as before
							m_ucfParseState = AT_DATA;
							
						case AT_DATA:
							var sizeToRead : uint = ( _compressionMethod == 8 ? _compressedSize : _uncompressedSize );
							if( source.bytesAvailable < sizeToRead ) return;
							
							// Note that directory events are dispatched in the AT_FILENAME state, above.
							
							if( isDirectory ) {
								if( _uncompressedSize != 0 ) throw new Error( "directory entry " + _path + " has associated data" );
								
								if( m_dir ) {
									m_dir.resolvePath( _path ).createDirectory();
								}
								
							} else {
								_data = new ByteArray();
								if( sizeToRead > 0 ) {
									source.readBytes( _data, 0, sizeToRead );
									if( _compressionMethod == 8 ) _data.uncompress(CompressionAlgorithm.DEFLATE);
								}
								
								if( m_dir ) {
									_data.position = 0;
//									var fs:FileStream = new FileStream();
//									fs.open( m_dir.resolvePath( _path ), FileMode.WRITE );
//									fs.writeBytes( _data );
//									fs.close();
								}
								
								
							}
							
							// Back to the beginning
							m_fileCount++;
							m_ucfParseState = AT_HEADER;
							break;
						
						case AT_END:
							// We've passed all of the files but are still receiving data events. Ignore them.
							dispatchEvent( new Event( Event.COMPLETE ));
							return;
							
						case AT_ABORTED:
							// Ignore everything until the read completes
							return;
							
						case AT_ERROR:
							// Something has already gone wrong, but we might receive more progress events
							// while waiting for the end. Ignore them.
							return;
					}
				}
			} catch( e:Error ) {
				dispatchError( e );
			}
		}
		
		protected function onLoadComplete(event:Event):void
		{
			Logger.debug("onUnpackComplete() ", this) 
		}
		
		protected function ioErrorHandler(event:IOErrorEvent):void 
		{
			Logger.error("ioErrorHandler: " + event, this);
		}
		
		protected function securityErrorHandler(event:SecurityErrorEvent):void 
		{
			Logger.error("securityErrorHandler: " + event, this);
		}

		
		protected function dispatchError( error:Error ):void 
		{
			Logger.error("dispatchError: error: " + error.errorID + " " + error.message, this)
			m_ucfParseState = AT_ERROR;
			dispatchEvent( new ErrorEvent(ErrorEvent.ERROR, false, false, error.message, error.errorID));
		}
	}
}