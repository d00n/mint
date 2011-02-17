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
			dataProxy.my_info = userInfoVO;
			
			_MSService = new MSService();		
//			_MSService.eventDispatcher = serviceEventDispatcher;
			_MSService.dataProxy = dataProxy;
			_MSService.deviceProxy = deviceProxy;

		}
		
		[After]
		public function tearDown():void
		{
			this.serviceEventDispatcher = null;
		}		
		
		
  	
		[Test]  
		public function initializeMSService():void { 
			Assert.assertNotNull(_MSService);
			Assert.assertNotNull(_MSService.nc);
			Assert.assertNull(_MSService.ns);
			
			_MSService.connect();
			Assert.assertNotNull(_MSService.ns);
			
//			var event:NetStatusEvent = new NetStatusEvent(NetStatusEvent.NET_STATUS);
//			event.info = new Object();
//			event.info.code = "NetConnection.Connect.Success";
//			
//			_MSService.netStatusHandler(event);
//			Assert.assertNotNull(_MSService.ns);

		}
	}
}