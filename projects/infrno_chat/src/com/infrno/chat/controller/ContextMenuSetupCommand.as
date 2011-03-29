package com.infrno.chat.controller
{
	import com.infrno.chat.model.DataProxy;
	import com.infrno.chat.model.events.PeerEvent;
	import com.infrno.chat.model.events.StatsEvent;
	import com.infrno.chat.model.events.VideoPresenceEvent;
	import com.infrno.chat.services.MSService;
	
	import flash.events.ContextMenuEvent;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import org.robotlegs.mvcs.Command;
	
	public class ContextMenuSetupCommand extends Command
	{
		[Inject]
		public var dataProxy:DataProxy;
		
		[Inject]
		public var msService:MSService;
		
		override public function execute() :void    
		{
			trace("ContextMenuSetupCommand.execute() DataProxy.VERSION:"+DataProxy.VERSION);
			
			var custom_menu:ContextMenu = new ContextMenu();
			custom_menu.hideBuiltInItems();
			
			var app_version:ContextMenuItem = new ContextMenuItem("Infrno " + DataProxy.VERSION);
			app_version.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, copyToClipboard);
			custom_menu.customItems.push(app_version);
			
			var conn_status:ContextMenuItem;
			if (dataProxy.use_peer_connection)
				conn_status = new ContextMenuItem("Current connection: p2p",true);
			else
				conn_status = new ContextMenuItem("Current connection: server",true);
			
			custom_menu.customItems.push(conn_status);
			
			var wowza_switch:ContextMenuItem = new ContextMenuItem("Turn on server connection");
			wowza_switch.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, switchToWowza);
			custom_menu.customItems.push(wowza_switch);
			
			var peer_status:ContextMenuItem = new ContextMenuItem("Turn on p2p connection");
			peer_status.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, switchToPeer);
			custom_menu.customItems.push(peer_status);	
			
			var showNetworkGraphs_cmi:ContextMenuItem = new ContextMenuItem("Show network graphs");
			showNetworkGraphs_cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, showNetworkGraphs);
			custom_menu.customItems.push(showNetworkGraphs_cmi);
			
			var hideNetworkGraphs_cmi:ContextMenuItem = new ContextMenuItem("Hide network graphs");
			hideNetworkGraphs_cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, hideNetworkGraphs);
			custom_menu.customItems.push(hideNetworkGraphs_cmi);
			
			if (dataProxy.enable_network_god_mode) {
				var showNetworkGM_cmi:ContextMenuItem = new ContextMenuItem("Show network god mode");
				showNetworkGM_cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, showNetworkGodMode);
				custom_menu.customItems.push(showNetworkGM_cmi);
				
				var hideNetworkGM_cmi:ContextMenuItem = new ContextMenuItem("Hide network god mode");
				hideNetworkGM_cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, hideNetworkGodMode);
				custom_menu.customItems.push(hideNetworkGM_cmi);
			}
						
			contextView.contextMenu = custom_menu;
		}
		
		private function copyToClipboard(event:ContextMenuEvent):void
		{
			trace("ContextMenuSetupCommand.copyToClipboard() "+ DataProxy.VERSION+" "+Capabilities.version+ (Capabilities.isDebugger?" -D":""));
			System.setClipboard(DataProxy.VERSION+" "+Capabilities.version+ (Capabilities.isDebugger?" -D":"") );
		}
		
		private function showNetworkGraphs(e:ContextMenuEvent):void
		{
			dispatch(new VideoPresenceEvent(VideoPresenceEvent.SHOW_NETWORK_GRAPHS));
		}
		
		private function hideNetworkGraphs(e:ContextMenuEvent):void
		{
			dispatch(new VideoPresenceEvent(VideoPresenceEvent.HIDE_NETWORK_GRAPHS));
		}		
		
		private function showNetworkGodMode(e:ContextMenuEvent):void
		{
			dispatch(new StatsEvent(StatsEvent.SHOW_NETWORK_GOD_MODE));
		}
		
		private function hideNetworkGodMode(e:ContextMenuEvent):void
		{
			dispatch(new StatsEvent(StatsEvent.HIDE_NETWORK_GOD_MODE));
		}
		
		// TODO: That event, if correct, needs a better name, like PEER_NETCONNECTION_CONNECT
		// This is looking suspect. PeerService also throws this when handling NetConnection.Connect.Success,
		// which implies the connection just succeeded. We are not in a position to say that here.
		private function switchToPeer(e:ContextMenuEvent):void
		{
			dispatch(new PeerEvent(PeerEvent.PEER_NETCONNECTION_CONNECTED));
		}
				
		private function switchToWowza(e:ContextMenuEvent):void
		{
			dispatch(new PeerEvent(PeerEvent.PEER_NETCONNECTION_DISCONNECTED));
		}
	}
}