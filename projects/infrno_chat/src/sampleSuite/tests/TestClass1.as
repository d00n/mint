package sampleSuite.tests
{
	import com.infrno.chat.model.DataProxy;
	import com.infrno.chat.model.DeviceProxy;
	import com.infrno.chat.model.vo.UserInfoVO;
	import com.infrno.chat.services.MSService;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	
	import mockolate.mock;
	import mockolate.prepare;
	import mockolate.strict;
	
	import mx.rpc.AsyncToken;
	
	import org.flexunit.Assert;
	import org.flexunit.async.Async;

	public class TestClass1
	{
		private var _MSService:MSService;	
		private var serviceEventDispatcher:EventDispatcher = new EventDispatcher();
		
		
		[Before(async, timeout=5000)]
		public function runBeforeEveryTest():void { 
			Async.proceedOnEvent(this,
				prepare(DeviceProxy),
				Event.COMPLETE);		
		}   
		
		[Before(order=2)]
		public function setup():void {
			var infoObj:Object = new Object();
			infoObj.suid = 'suid';
			infoObj.user_id = 'user_id';
			infoObj.user_name = 'user_name';
			
			serviceEventDispatcher = new EventDispatcher();
			
			var userInfoVO:UserInfoVO = new UserInfoVO(infoObj);			
			var deviceProxy:DeviceProxy = strict(DeviceProxy);
			var dataProxy:DataProxy = new DataProxy();			
			dataProxy.local_userInfoVO = userInfoVO;
			
			trace("TestClass1.setup() 1");
			_MSService = new MSService();		
			trace("TestClass1.setup() 2");
			_MSService.eventDispatcher = serviceEventDispatcher;
			trace("TestClass1.setup() 3");
			_MSService.dataProxy = dataProxy;
			trace("TestClass1.setup() 4");
//			_MSService.deviceProxy = deviceProxy;
			trace("TestClass1.setup() 5");

		}
		
		[After]
		public function tearDown():void
		{
			this.serviceEventDispatcher = null;
		}		
		
		[Test]  
		public function updatePublishStreamTest():void { 
//			trace("TestClass1.updatePublishStreamTest()");
//			
//			Assert.assertNotNull(_MSService.netStream);
//			
//			_MSService.dataProxy.pubishing_audio = false;
//			_MSService.dataProxy.pubishing_video = false;
//			
//			trace("TestClass1.updatePublishStreamTest() before calling _MSService.updatePublishStream() ");
//			_MSService.updatePublishStream();
//			trace("TestClass1.updatePublishStreamTest() after calling _MSService.updatePublishStream() ");
			
			// This fails because NetStatusEvent.NET_STATUS has not been caught yet
			// Should we sign up for that event?
			//			Assert.assertNotNull(_MSService.ns);
			
			//			var event:NetStatusEvent = new NetStatusEvent(NetStatusEvent.NET_STATUS);
			//			event.info = new Object();
			//			event.info.code = "NetConnection.Connect.Success";
			//			
			//			_MSService.netStatusHandler(event);
			//			Assert.assertNotNull(_MSService.ns);
		}
		
  	
		[Test]  
		public function initializeMSService():void { 
			trace("TestClass1.initializeMSService()");

			Assert.assertNotNull(_MSService);
			Assert.assertNotNull(_MSService.netConnection);
			Assert.assertNull(_MSService.netStream);
			
			trace("TestClass1.initializeMSService() before calling _MSService.connect() ");
			_MSService.connect();
			trace("TestClass1.initializeMSService() after calling _MSService.connect() ");
			
			// This fails because NetStatusEvent.NET_STATUS has not been caught yet
			// Should we sign up for that event?
//			Assert.assertNotNull(_MSService.ns);
			
//			var event:NetStatusEvent = new NetStatusEvent(NetStatusEvent.NET_STATUS);
//			event.info = new Object();
//			event.info.code = "NetConnection.Connect.Success";
//			
//			_MSService.netStatusHandler(event);
//			Assert.assertNotNull(_MSService.ns);
		}
	}
}