package ldap;

import ldap.Meeting;
import ldap.MeetingRecorder;
import ldap.MeetingInvoker;
import java.util.ArrayList;

import org.apache.commons.lang.StringUtils;

import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;

public class MeetingApplication {
	public static Jedis dbConnect(){
		String serverIP = "127.0.0.1";
		JedisPool redisPool = new JedisPool(serverIP, 6379);
		try{
			return redisPool.getResource();
		}
		catch (Exception e){
			System.err.print("Error in MeetingApplication.dbConnect():");
			System.err.println(e.toString());
		}
		System.err.println("Returning NULL from dbConnect()");
		return null;
	}
	
	public void saveMeeting(String presenterKey, Meeting meeting){
		MeetingRecorder mr = new MeetingRecorder();
		mr.saveMeeting(presenterKey, meeting);
	}
	
	public void loadAllMeetings(){
		MeetingInvoker mi = new MeetingInvoker();
		mi.invokeAllMeetings();
	}
	
	// CONVERSION METHODS
	// ------------------
	
	// Converts a Meeting object to a Redis-friendly data string
	public static String compressMeeting(Meeting meeting){
		StringBuilder sb = new StringBuilder();
		if (meeting.lecture)
			sb.append(Meeting.PROF_SYMBOL);
		sb.append(meeting.name);
		sb.append(Meeting.DELIMITER);
		
		sb.append(meeting.modPass);
		sb.append(Meeting.DELIMITER);
		
		sb.append(meeting.viewPass);
		sb.append(Meeting.DELIMITER);
		
		sb.append(meeting.allowGuests.toString());
		sb.append(Meeting.DELIMITER);
		
		sb.append(meeting.recordable.toString());
		
		String dataString = sb.toString();
		return dataString;
	}
	
	// Converts a data string from Redis to a Meeting object
	public static Meeting extractMeeting(String rawMeeting)
	{
		String components[] = StringUtils.split(rawMeeting, Meeting.DELIMITER);
		Meeting meeting = new Meeting(components);
		return meeting;
	}
}
