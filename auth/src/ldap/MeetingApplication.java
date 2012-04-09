package ldap;

/* Add these lines to create.jsp right at the top:
<jsp:useBean id="meetingApplication" class="ldap.MeetingApplication" scope="session"/>
<%@ include file="meeting_api.jsp"%>
 */

import java.util.ArrayList;
import java.util.Collections;

import org.apache.commons.lang.StringUtils;

import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;

public class MeetingApplication {
	
	private char PROF_SYMBOL = '#';
	private char EMP_SYMBOL = '&';
	private char STUDENT_SYMBOL = '$';
	private char DELIMITER = '~';
	
	ArrayList <String[]> lectures;
	ArrayList <String[]> meetings;
	
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
	
	public String[] decompress(String rawData){
		String components[] = StringUtils.split(rawData, DELIMITER);
		return components;
	}
	
	public ArrayList <String[]> getLectures(){
		return lectures;
	}
	
	public ArrayList <String[]> getMeetings(){
		return meetings;
	}
	
	public void loadAllMeetings(){
		// Create an ArrayList for lectures and one for ordinary meetings
		Jedis jedis = dbConnect();
		ArrayList <String> lectureList = new ArrayList <String> ();
		ArrayList <String> meetingList = new ArrayList <String> ();
		
		// Goes through all keys in Redis
		for (String eachKey : jedis.keys("*")){
			// Checks if the current key is a hash, and if it contains any meetings
			if (jedis.type(eachKey) == "hash" && jedis.hexists(eachKey, "meeting*")){
				// Goes through each meeting in the current hash
				for (int i = 1; i <= jedis.hlen(eachKey); i++){
					// Extracts the meeting data string from the current meeting
					String rawMeeting = jedis.hget(eachKey, "meeting"+i);
					// Adds the data string to either lectureList or meetingList depending on the presence of the PROF_SYMBOL
					if (rawMeeting.charAt(0) == PROF_SYMBOL)
						lectureList.add(rawMeeting);
					else
						meetingList.add(rawMeeting);
				}
			}
		}
		// Sort the lecture and meeting lists alphabetically
		Collections.sort(lectureList);
		Collections.sort(meetingList);
		
		// Populate the instance variables lectures and meetings with all the available lectures and general meetings, respectively
		for (int i = 0; i < lectureList.size(); i++){
			lectures.add(decompress(lectureList.get(i)));
		}
		for (int i = 0; i < meetingList.size(); i++){
			meetings.add(decompress(meetingList.get(i)));
		}
	}
	
	public void loadMeetingsByUser(String presenterKey){
		// Create an ArrayList for lectures and one for ordinary meetings
		Jedis jedis = dbConnect();
		ArrayList <String> lectureList = new ArrayList <String> ();
		ArrayList <String> meetingList = new ArrayList <String> ();
		

		// Checks if the current key is a hash, and if it contains any meetings
		if (jedis.type(presenterKey) == "hash" && jedis.hexists(presenterKey, "meeting*")){
			// Goes through each meeting in the current hash
			for (int i = 1; i <= jedis.hlen(presenterKey); i++){
				// Extracts the meeting data string from the current meeting
				String rawMeeting = jedis.hget(presenterKey, "meeting"+i);
				// Adds the data string to either lectureList or meetingList depending on the presence of the PROF_SYMBOL
				if (rawMeeting.charAt(0) == PROF_SYMBOL)
					lectureList.add(rawMeeting);
				else
					meetingList.add(rawMeeting);
			}
		}
		
		// Sort the lecture and meeting lists alphabetically
		Collections.sort(lectureList);
		Collections.sort(meetingList);
		
		// Populate the instance variables lectures and meetings with all the available lectures and general meetings, respectively
		for (int i = 0; i < lectureList.size(); i++){
			lectures.add(decompress(lectureList.get(i)));
		}
		for (int i = 0; i < meetingList.size(); i++){
			meetings.add(decompress(meetingList.get(i)));
		}
	}
}
