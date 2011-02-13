package com.infrno.chat.controller
{
	import com.infrno.chat.model.DataProxy;
	import com.infrno.chat.model.events.PeerEvent;
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
		public var dataProxy		:DataProxy;
		
		[Inject]
		public var msService		:MSService;
		
		override public function execute() :void    
		{
			//        	trace(DataProxy.VERSION);
			
			var custom_menu:ContextMenu = new ContextMenu();
			custom_menu.hideBuiltInItems();
			
			var app_version:ContextMenuItem = new ContextMenuItem("Infrno Chat " + DataProxy.VERSION);
			app_version.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, copyToClipboard);
			custom_menu.customItems.push(app_version);
			
			var conn_status:ContextMenuItem = new ContextMenuItem("peer connected: "+dataProxy.use_peer_connection,true);
			custom_menu.customItems.push(conn_status);
			
			var wowza_switch:ContextMenuItem = new ContextMenuItem("turn on wowza stream");
			wowza_switch.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, switchToWowza);
			custom_menu.customItems.push(wowza_switch);
			
			var peer_status:ContextMenuItem = new ContextMenuItem("turn on peer stream");
			peer_status.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, switchToPeer);
			custom_menu.customItems.push(peer_status);
			
			var report_stats:ContextMenuItem = new ContextMenuItem("report user stats");
			report_stats.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, reportStats);
			custom_menu.customItems.push(report_stats);
			
			contextView.contextMenu = custom_menu;
		}
		
		private function copyToClipboard(event:ContextMenuEvent):void
		{
			trace("setting content to the clipboard: "+ DataProxy.VERSION+" "+Capabilities.version+ (Capabilities.isDebugger?" -D":""));
			System.setClipboard(DataProxy.VERSION+" "+Capabilities.version+ (Capabilities.isDebugger?" -D":"") );
		}
		
		private function switchToPeer(e:ContextMenuEvent):void
		{
			dispatch(new PeerEvent(PeerEvent.PEER_NETCONNECTION_CONNECTED));
		}
		
		private function reportStats(e:ContextMenuEvent):void
		{
			msService.getUserStats();
		}
		
		private function switchToWowza(e:ContextMenuEvent):void
		{
			dispatch(new PeerEvent(PeerEvent.PEER_NETCONNECTION_DISCONNECTED));
		}
	}
}