package sampleSuite.tests
{
	import com.infrno.chat.controller.SetupPeerNetStreamCommand;
	import com.infrno.chat.model.DataProxy;
	import com.infrno.chat.model.DeviceProxy;
	import com.infrno.chat.model.events.VideoPresenceEvent;
	import com.infrno.chat.model.vo.UserInfoVO;
	import com.infrno.chat.services.MSService;
	import com.infrno.chat.services.NetStreamMS;
	import com.infrno.chat.services.NetStreamPeer;
	import com.infrno.chat.services.PeerService;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import flex.lang.reflect.Method;
	
	import mockolate.mock;
	import mockolate.nice;
	import mockolate.prepare;
	import mockolate.strict;
	import mockolate.stub;
	import mockolate.verify;
	
	import mx.rpc.AsyncToken;
	
	import org.flexunit.Assert;
	import org.flexunit.async.Async;
	
	public class SetupPeerNetStreamCommand_Test
	{
		private var serviceEventDispatcher:EventDispatcher = new EventDispatcher();	
		
		[Before(async, timeout=5000)]
		public function runBeforeEveryTest():void { 
			Async.proceedOnEvent(this,
				prepare(MSService,PeerService,NetStream,NetStreamPeer,NetStreamMS,UserInfoVO),
				Event.COMPLETE);		
		}   
		
		[After]
		public function tearDown():void
		{
			this.serviceEventDispatcher = null;
		}		
		
		[Test]  
		public function connectPeer():void { 
			trace("SetupPeerNetStreamCommand_Test.testCommand()");
			
			var infoObj:Object = new Object();
			infoObj.suid 				= 123456;
			infoObj.user_id 		= 'user_id';
			infoObj.user_name 	= 'user_name';
			var userInfoVO:UserInfoVO		= strict(UserInfoVO,"userInfoVO",[infoObj]);		
			
			var netConnection:NetConnection = new NetConnection(); 
			netConnection.connect(null); 				
			var netStreamPeer:NetStreamPeer = nice(NetStreamPeer, "netStreamPeer", [ netConnection ]); 
			var netStream:NetStream = nice(NetStream, "netStream", [ netConnection ]); 
			
			var dataProxy:DataProxy = new DataProxy();	
			dataProxy.use_peer_connection = true;
			dataProxy.peer_capable = true;
			userInfoVO.nearID 			= 'nearID';
			mock(userInfoVO).getter("netStream").returns(netStream);
			mock(userInfoVO).setter("netStream");
			
			var peerService:PeerService = strict(PeerService);
			mock(peerService).method("getNewNetStream").args(userInfoVO.nearID).returns(netStreamPeer);
			
			var vpEvent:VideoPresenceEvent = new VideoPresenceEvent(VideoPresenceEvent.SETUP_PEER_NETSTREAM);
			vpEvent.userInfoVO = userInfoVO;

			
			var setupPeerNetStreamCommand:SetupPeerNetStreamCommand = new SetupPeerNetStreamCommand();
			setupPeerNetStreamCommand.event = vpEvent;
			setupPeerNetStreamCommand.dataProxy = dataProxy;
			setupPeerNetStreamCommand.peerService = peerService;			
			setupPeerNetStreamCommand.eventDispatcher = serviceEventDispatcher;
						
		
			Assert.assertNotNull(setupPeerNetStreamCommand);
			setupPeerNetStreamCommand.execute();
			Assert.assertNotNull(setupPeerNetStreamCommand);
			verify(peerService);
			Assert.assertEquals(setupPeerNetStreamCommand.event.userInfoVO.netStream, netStream);

		}
	}
}