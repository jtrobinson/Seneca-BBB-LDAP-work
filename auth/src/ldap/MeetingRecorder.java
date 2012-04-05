// This class is on it's way to obsolescence

package ldap;

//If redis packages are not working, make sure jedis-2.0.0.jar is included in the Build Path
import ldap.Meeting;
import ldap.MeetingApplication;
import java.util.ArrayList;
import java.util.Collections;

import org.apache.commons.lang.StringUtils;

import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;

public class MeetingRecorder {

	private String compressMeeting(Meeting meeting){
		return MeetingApplication.compressMeeting(meeting);
	}
	
	public void saveMeeting(String presenterKey, Meeting meeting){
		Jedis jedis = MeetingApplication.dbConnect();
		Boolean newMeeting = true;
		String dataString = compressMeeting(meeting);
		// Checks for the existence of the presenterKey and that the key refers to a hash
		if (jedis.exists(presenterKey) && jedis.type(presenterKey) == "hash"){
			// Goes through all meetings associated with the presenterKey and compares the names
			for (int i = 1; i <= jedis.hlen(presenterKey); i++){
				Meeting oldMeeting = MeetingApplication.extractMeeting(jedis.hget(presenterKey, "meeting"+i));
				if (meeting.name == oldMeeting.name){
					newMeeting = false;
					jedis.hset(presenterKey, "meeting"+i, dataString);
				} // Compare new meeting to old meeting
			} // For loop
			if (newMeeting){
				jedis.hset(presenterKey, "meeting"+(jedis.hlen(presenterKey)+1), dataString);
			} // Save new meeting
		} // Presenter checking
	}
}
