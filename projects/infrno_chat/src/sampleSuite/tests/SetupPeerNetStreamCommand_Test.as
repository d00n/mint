package sampleSuite.tests
{
	import com.infrno.chat.controller.SetupPeerNetStreamCommand;
	import com.infrno.chat.model.DataProxy;
	import com.infrno.chat.model.DeviceProxy;
	import com.infrno.chat.model.events.VideoPresenceEvent;
	import com.infrno.chat.model.vo.UserInfoVO;
	import com.infrno.chat.services.MSService;
	import com.infrno.chat.services.PeerService;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.net.NetStream;
	
	import mockolate.mock;
	import mockolate.nice;
	import mockolate.prepare;
	import mockolate.strict;
	import mockolate.stub;
	
	import mx.rpc.AsyncToken;
	
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	
	public class SetupPeerNetStreamCommand_Test
	{
		private var serviceEventDispatcher:EventDispatcher = new EventDispatcher();	
		private var setupPeerNetStreamCommand:SetupPeerNetStreamCommand;
		
		[Before(async, timeout=5000)]
		public function runBeforeEveryTest():void { 
			Async.proceedOnEvent(this,
				prepare(MSService,PeerService,NetStream),
				Event.COMPLETE);		
		}   
		
		[Before(order=2)]
		public function setup():void {
			var infoObj:Object = new Object();
			infoObj.suid 				= 'suid';
			infoObj.user_id 		= 'user_id';
			infoObj.user_name 	= 'user_name';
			infoObj.nearID 			= 'nearID';
			var userInfoVO:UserInfoVO = new UserInfoVO(infoObj);			
			
			var vpEvent:VideoPresenceEvent = new VideoPresenceEvent(VideoPresenceEvent.SETUP_PEER_NETSTREAM);
			vpEvent.userInfoVO = userInfoVO;
			
			serviceEventDispatcher = new EventDispatcher();
			
			var dataProxy:DataProxy = new DataProxy();	
			var peerService:PeerService = strict(PeerService);
			var msService:MSService = nice(MSService);
			var netStream:NetStream = nice(NetStream);
			
//			mock(peerService).method("getNewNetStream").args('nearID').returns(netStream);
//			mock(msService).method("getNewNetStream").returns(netStream);
			
			setupPeerNetStreamCommand = new SetupPeerNetStreamCommand();
			setupPeerNetStreamCommand.event = vpEvent;
			setupPeerNetStreamCommand.dataProxy = dataProxy;
			setupPeerNetStreamCommand.msService = msService;
			setupPeerNetStreamCommand.peerService = peerService;			
		}
		
		[After]
		public function tearDown():void
		{
			this.serviceEventDispatcher = null;
		}		
		
		[Test]  
		public function testCommand():void { 
			trace("SetupPeerNetStreamCommand_Test.testCommand()");
			
			Assert.assertNotNull(setupPeerNetStreamCommand);
//			setupPeerNetStreamCommand.execute();
//			Assert.assertNotNull(setupPeerNetStreamCommand);

		}
	}
}