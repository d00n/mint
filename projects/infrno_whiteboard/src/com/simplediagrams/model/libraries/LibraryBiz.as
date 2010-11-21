package com.simplediagrams.model.libraries
{
	
	import com.simplediagrams.model.SDObjectModel;
	import com.simplediagrams.model.SDSymbolModel;
	import com.simplediagrams.util.Logger;
	
	import mx.collections.ArrayCollection;
	
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import com.simplediagrams.shapelibrary.biz.*
	
	import com.simplediagrams.model.libraries.AbstractLibrary;

	import com.simplediagrams.model.libraries.ILibrary;

	[Bindable]
	public class LibraryBiz extends AbstractLibrary implements ILibrary
	{
						
		Building;
		Cash;				
		Check; 			
		Clock; 				
		Computer; 				
		Crown;				
		Database; 		
		Form; 	
		Interaction; 	
		Pain; 
		PeopleInvolved;
		Team; 
		Man; 
		ManCustomer; 	
		Woman; 
		WomanCustomer; 
		//from Kat
		Checklist;
		Briefcase;
		Document;
		Calendar;
		Building2;
		Binders;
		CoinEuro;
		CoinDollar;
		CoinPound;
		CoinBlank;
		IDCard;
		//BusinessWoman;
		//BusinessMan
				
		public function LibraryBiz()
		{
			libraryName ="com.simplediagrams.shapelibrary.biz"
			displayName = "Biz"
			super()	
		}
		
		override public function initShapes():void
		{
			
			addLibraryItem( new SDSymbolModel("Man",25))
			addLibraryItem( new SDSymbolModel("ManCustomer", 25, 55))
			addLibraryItem( new SDSymbolModel("Woman", 25))
			addLibraryItem( new SDSymbolModel("WomanCustomer", 25, 55))
			addLibraryItem( new SDSymbolModel("Crown"))
			addLibraryItem( new SDSymbolModel("Team", 80))
			addLibraryItem( new SDSymbolModel("PeopleInvolved", 90))
			addLibraryItem( new SDSymbolModel("Interaction"))
			addLibraryItem( new SDSymbolModel("Building", 40))
			addLibraryItem( new SDSymbolModel("Building2")) 
			addLibraryItem( new SDSymbolModel("Cash", 60))
			addLibraryItem( new SDSymbolModel("Check", 50, 40))
			addLibraryItem( new SDSymbolModel("Clock"))
			addLibraryItem( new SDSymbolModel("Computer"))
			addLibraryItem( new SDSymbolModel("Database", 40)) 
			addLibraryItem( new SDSymbolModel("Form", 40)) 
			addLibraryItem( new SDSymbolModel("Pain")) 
			addLibraryItem( new SDSymbolModel("Checklist")) 
			addLibraryItem( new SDSymbolModel("Briefcase")) 
			addLibraryItem( new SDSymbolModel("Document")) 
			addLibraryItem( new SDSymbolModel("Binders")) 
			addLibraryItem( new SDSymbolModel("CoinEuro")) 
			addLibraryItem( new SDSymbolModel("CoinDollar")) 
			addLibraryItem( new SDSymbolModel("CoinPound")) 
			addLibraryItem( new SDSymbolModel("CoinBlank")) 
			addLibraryItem( new SDSymbolModel("IDCard")) 
			//addLibraryItem( new SDSymbolModel("BusinessWoman")) 
			//addLibraryItem( new SDSymbolModel("BusinessMan")) 
				
			
			
		
		}
		
	
		
		

		
	}
}