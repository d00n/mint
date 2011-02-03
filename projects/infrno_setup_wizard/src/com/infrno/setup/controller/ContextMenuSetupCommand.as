package com.infrno.setup.controller
{
    import com.infrno.setup.model.DataProxy;
    
    import flash.events.ContextMenuEvent;
    import flash.system.Capabilities;
    import flash.system.System;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    
    import org.robotlegs.mvcs.Command;
    
    public class ContextMenuSetupCommand extends Command
    {
		override public function execute() :void    
        {
        	var custom_menu:ContextMenu = new ContextMenu();
			custom_menu.hideBuiltInItems();
			
			var app_version:ContextMenuItem = new ContextMenuItem("Infrno Tester " + DataProxy.VERSION);
			app_version.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, copyToClipboard);

			custom_menu.customItems.push(app_version);
        	
			contextView.contextMenu = custom_menu;
        }
        
        private function copyToClipboard(event:ContextMenuEvent):void
        {
        	trace("setting content to the clipboard: "+ DataProxy.VERSION+" "+Capabilities.version+ (Capabilities.isDebugger?" -D":""));
        	System.setClipboard(DataProxy.VERSION+" "+Capabilities.version+ (Capabilities.isDebugger?" -D":"") );
        }
    }
}