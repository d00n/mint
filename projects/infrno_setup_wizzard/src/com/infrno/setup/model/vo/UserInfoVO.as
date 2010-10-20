package com.infrno.setup.model.vo
{
	public class UserInfoVO
	{
		public var user_name				:String;
		public var user_id					:String;
		
		public function UserInfoVO(infoObj:Object=null)
		{
			user_id = infoObj.user_id;
			user_name = infoObj.user_name;
		}
		
	}
}