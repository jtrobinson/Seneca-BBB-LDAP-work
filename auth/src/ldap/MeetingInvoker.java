package ldap;
// If redis packages are not working, make sure jedis-2.0.0.jar is included in the Build Path
import ldap.Meeting;
import ldap.MeetingApplication;
import java.util.ArrayList;
import java.util.Collections;

import org.apache.commons.lang.StringUtils;

import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;

public class MeetingInvoker {
	JedisPool redisPool;

	public ArrayList <Meeting> invokeAllMeetings(){
		// Create an ArrayList for lectures and one for ordinary meetings
		Jedis jedis = MeetingApplication.dbConnect();
		ArrayList <String> lectureList = new ArrayList <String> ();
		ArrayList <String> meetingList = new ArrayList <String> ();
		ArrayList <Meeting> allSortedMeetings = new ArrayList <Meeting> ();
		
		// Goes through all keys in Redis
		for (String eachKey : jedis.keys("*")){
			// Checks if the current key is a hash, and if it contains any meetings
			if (jedis.type(eachKey) == "hash" && jedis.hexists(eachKey, "meeting*")){
				// Goes through each meeting in the current hash
				for (int i = 1; i <= jedis.hlen(eachKey); i++){
					// Extracts the meeting data string from the current meeting
					String rawMeeting = jedis.hget(eachKey, "meeting"+i);
					// Adds the data string to either lectureList or meetingList depending on the presence of the PROF_SYMBOL
					if (rawMeeting.charAt(0) == Meeting.PROF_SYMBOL)
						lectureList.add(rawMeeting);
					else
						meetingList.add(rawMeeting);
				}
			}
		}
		// Sort the lecture and meeting lists alphabetically
		Collections.sort(lectureList);
		Collections.sort(meetingList);
		
		// Add the sorted "ordinary meetings" to the end of the sorted lecture list.
		for (int i = 0; i < meetingList.size(); i++){
			lectureList.add(meetingList.get(i));
		}
		
		// Convert all meetings to Meeting objects, ready to return them
		for (int i = 0; i < lectureList.size(); i++){
			allSortedMeetings.add(MeetingApplication.extractMeeting(lectureList.get(i)));
		}
		
		return allSortedMeetings;
	}
}
