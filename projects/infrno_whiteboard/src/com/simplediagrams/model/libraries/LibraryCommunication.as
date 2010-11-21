package com.simplediagrams.model.libraries
{
	
	import com.simplediagrams.model.SDObjectModel;
	import com.simplediagrams.model.SDSymbolModel;
	import com.simplediagrams.util.Logger;
	
	import mx.collections.ArrayCollection;
	
	import com.simplediagrams.shapelibrary.communication.*
	import com.simplediagrams.model.libraries.AbstractLibrary;

	import com.simplediagrams.model.libraries.ILibrary;

	[Bindable]
	public class LibraryCommunication extends AbstractLibrary implements ILibrary
	{
		
				
		Dialog;
		Emission;
		ExclamationMark;
		Lightbulb;
		Monologue;
		Monologue2;
		QuestionMark;
		ThoughtBubble;
		ThoughtBubble2;
		Sign;
		Pencil;
		Phone; 			
		Cell; 					
		Email; 		
		Mail;
		Fax; 	
		Bullhorn;
		Stop;
		Cloud;
		HappyFace;
		SadFace;
		//more by Kat
		Phone2;
		Mobile;
		MobileWithHI;
		ChatBox;
		Memo;
		Postcard;
		GlobeWithMail;
		Teacher;
		Radio;
		DoubleSquareSpeechBubbles;
		SquareSpeechBubble;
		SquareSpeechBubble2;
		RoundSpeechBubble;
		RoundSpeechBubble2;
		SpeechBox3D;
		SpeechBox3D2;
		Facebook;
		Twitter;
		LinkedIn;
		
		
		
		
				
		public function LibraryCommunication()
		{ 
			libraryName ="com.simplediagrams.shapelibrary.communication"
			displayName = "Communication"
			super()
		}
		
		override public function initShapes():void
		{
			addLibraryItem( new SDSymbolModel("Dialog"))
			addLibraryItem( new SDSymbolModel("DoubleSquareSpeechBubbles"))
			addLibraryItem( new SDSymbolModel("Monologue2"))
			addLibraryItem( new SDSymbolModel("Monologue"))
			addLibraryItem( new SDSymbolModel("SquareSpeechBubble")) 
			addLibraryItem( new SDSymbolModel("SquareSpeechBubble2"))  
			addLibraryItem( new SDSymbolModel("RoundSpeechBubble")) 
			addLibraryItem( new SDSymbolModel("RoundSpeechBubble2")) 
			addLibraryItem( new SDSymbolModel("ThoughtBubble2"))
			addLibraryItem( new SDSymbolModel("ThoughtBubble"))
			addLibraryItem( new SDSymbolModel("SpeechBox3D")) 
			addLibraryItem( new SDSymbolModel("SpeechBox3D2")) 
			addLibraryItem( new SDSymbolModel("Emission"))
			addLibraryItem( new SDSymbolModel("Lightbulb"))
			addLibraryItem( new SDSymbolModel("Cloud"))
			addLibraryItem( new SDSymbolModel("ExclamationMark", 30))
			addLibraryItem( new SDSymbolModel("QuestionMark", 30))
			addLibraryItem( new SDSymbolModel("Sign"))
			addLibraryItem( new SDSymbolModel("Pencil", 20))
			addLibraryItem( new SDSymbolModel("Fax")) 		
			addLibraryItem( new SDSymbolModel("Email")) 	
			addLibraryItem( new SDSymbolModel("Phone")) 	
			addLibraryItem( new SDSymbolModel("Phone2")) 
			addLibraryItem( new SDSymbolModel("Mobile")) 
			addLibraryItem( new SDSymbolModel("MobileWithHI")) 
			addLibraryItem( new SDSymbolModel("Cell", 30))
			addLibraryItem( new SDSymbolModel("Mail", 50,40)) 
			addLibraryItem( new SDSymbolModel("ChatBox")) 
			addLibraryItem( new SDSymbolModel("Bullhorn")) 
			addLibraryItem( new SDSymbolModel("Stop")) 
			addLibraryItem( new SDSymbolModel("HappyFace")) 
			addLibraryItem( new SDSymbolModel("SadFace")) 			
			addLibraryItem( new SDSymbolModel("Memo")) 
			addLibraryItem( new SDSymbolModel("Postcard")) 
			addLibraryItem( new SDSymbolModel("GlobeWithMail")) 
			addLibraryItem( new SDSymbolModel("Teacher")) 
			addLibraryItem( new SDSymbolModel("Facebook")) 
			addLibraryItem( new SDSymbolModel("Twitter")) 
			addLibraryItem( new SDSymbolModel("LinkedIn")) 
			 
			
		}
		
		
		

		
	}
}