
/*
* Based on cade by Soph-Ware Associates, Inc.
*
* Copyright (C) 2007-2008 Soph-Ware Associates, Inc. 
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/


package com.simplediagrams.model
{
	import com.simplediagrams.commands.IUndoRedoCommand;
	import com.simplediagrams.util.Logger;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	public class UndoRedoManager extends EventDispatcher
	{
		
		public static const MAX_UNDOS:Number = 100
		
		private var _stack:ArrayCollection = new ArrayCollection()
				
		// should only be used by associated getter/setter 
		private var _stackIndex:Number = -1;

		
		public function UndoRedoManager()
		{
		}
		
		/**
		 * Returns true if an undoable event is present on the stack
		 */

		[Bindable("indexChanged")]
		public function get canUndo():Boolean
		{
			return stackIndex > 0
		}
		
		/**
		 * True if a redo operation can be performed
		 */
		[Bindable("indexChanged")]
		public function get canRedo():Boolean
		{
			// note, if all undo events have been undone, then stackIndex
			// will be -1 but stack.length will be greater than zero.  
			return stackIndex < _stack.length 
		}
		
		public function clear():void
		{
			_stack = new ArrayCollection()
			stackIndex = -1
			dispatchEvent(new Event("countChanged"))
		}
		
		[Bindable("countChanged")]
		public function get count():Number
		{
			return _stack.length
		}
		
		/**
		 * Returns the index of the current command.
		 *
		 * <p>
		 * The current command is the command that will be executed on the
		 * next call to redo().  If no commands are on the stack, then -1 will
		 * be returned.  The current command is not always the top-most
		 * command on the stack as other commands may have been undone.
		 * </p>
		 *
		 * <p>
		 * The index is a zero based index that should be between zero and
		 * count - 1, inclusive.  An index of -1 implies that no entries are
		 * available on the undo stack.
		 * </p>
		 */
		[Bindable("indexChanged")]
		public function get index():uint
		{
			return stackIndex
		}
		
		/**
		 * Pushes <code>cmd</code> onto the UndoStack and executes the command.
		 *  
		 * <p>
		 * All commands after the command at index() will be deleted.
		 * </p>
		 * 
		 * @param cmd The command being pushed onto the stack
		 */
		public function push(cmd:IUndoRedoCommand):void
		{
			//If there are redo's on the stack after the current index, wipe them out
			if (canRedo)
			{
				removeCommands(stackIndex++, _stack.length)
			}
			
			//If there are more than a set amount, remove first and then change index
			if (_stack.length>MAX_UNDOS)
			{
				_stack.removeItemAt(0)
				stackIndex = _stack.length - 1
			}
			
			//don't execute command since it will already have been executed in the normal course of the program
			addUndoRedoCommand(cmd)
			
		}
		
		public function undo():void
		{
			if (stackIndex==-1)
			{
				Logger.error("undo() can't undo because stackIndex = -1",this)
				return
			}
			
			if (!canUndo) 
			{ 
				Logger.debug("can't undo.",this); 
				return;
			}
			stackIndex--
			_stack[stackIndex].undo()
		}
		
		public function redo():void
		{
			if (!canRedo) 
			{ 
				Logger.debug("can't redo.",this)
				return
			}
			if (stackIndex>=0)
			{
				_stack[stackIndex].redo()
				stackIndex++
			}
		}
		
		public function set index(ix:uint):void
		{
			if (!isValidIndex(ix)) return
				
			if (ix<stackIndex)
			{
				do
				{
					undo()
				}
				while (ix<stackIndex && stackIndex>0)
				
			}
			else if (ix>stackIndex)
			{
				var i:uint = count
				do
				{
					redo()
				}
				while (ix>stackIndex)
			}
		}
		
					
		
		/**
		 * Returns true if the index is valid
		 *
		 * @param ix a non-negative index number
		 */
		protected function isValidIndex(ix:Number):Boolean
		{
			if (ix >=0 && ix < count)
				return true;
			return false;
		}
		
		/**
		 * Adds an undo command to the top of the stack and dispatches an
		 * appropriate event.
		 *
		 * @param cmd The undo command to add to the stack
		 */
		protected function addUndoRedoCommand(cmd:IUndoRedoCommand):void
		{
			_stack.addItem(cmd);
			stackIndex = _stack.length
			dispatchEvent( new Event("countChanged") );
		}
		
		
		/**
		 * Removes the items between the first index (inclusive) and the last
		 * index (exclusive).
		 *
		 * <p>
		 * It is assumed that stackIndex is already set to something
		 * lower than the entries being removed, thus it is safe to perform
		 * this operation.  It will normally be used after a series of undo
		 * events have been performed and then a new undo event is pushed onto
		 * the stack, thus removing all the entries that are currently after
		 * the current stackIndex
		 * </p>
		 *
		 * @param start The starting index, included in removal
		 * @param end The ending index, excluded from removal
		 */
		protected function removeCommands(start:Number, end:Number):void
		{
			if (end <= start || start < 0)
				return;
			
			var ix:Number = end - 1;
			while (ix >= start) 
			{
				_stack.removeItemAt(ix--);
			}
		}
		
		/**
		 * Returns the current stack index.
		 *
		 * <p>
		 * The whole purpose of having stackIndex getters and setters is to
		 * allow the indexChanged event to be dispatched so that the getters
		 * for canUndo, canRedo, undoText, and redoText will be updated
		 * appropriately.
		 * </p>
		 */
		protected function get stackIndex():Number
		{
			return _stackIndex;
		}
		
		/**
		 * Updates the current stack index.
		 *
		 * <p>
		 * Updates the current stack index and dispatches the indexChanged
		 * event.
		 * </p>
		 */
		protected function set stackIndex(ix:Number):void
		{
			_stackIndex = ix;
			dispatchEvent(new Event("indexChanged"));
		}
		
				
		protected function traceStack():void
		{
			Logger.debug("STACK INDEX: " + this.stackIndex, this)
			for (var i:uint=0;i<_stack.length;i++)
			{
				if (i==stackIndex)
				{
					Logger.debug("## " + i + ") " + IUndoRedoCommand(_stack[stackIndex]).toString(), this)
				}
				else 
				{					
					Logger.debug(i + ") " + IUndoRedoCommand(_stack[i]).toString(), this)
				}	
			}
		}
			
		
		
	}
}