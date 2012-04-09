<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Collections"%>
<%@page import="java.util.Date"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="org.apache.commons.lang.StringUtils"%>
<%@page import="redis.clients.jedis.*" language="java" %>

<%!
	private char PROF_SYMBOL = '#';
	private char EMP_SYMBOL = '&';
	private char STUDENT_SYMBOL = '$';
	private char DELIMITER = '~';
	
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


	// COMPRESSION AND EXTRACTION
	// --------------------------
	
	public String compressMeeting(String meetingName, String modPass, String viewPass, String allowGuests, String recordable){
		return compressMeeting(meetingName, modPass, viewPass, Boolean.parseBoolean(allowGuests), Boolean.parseBoolean(recordable));
	}
			
	public String compressMeeting(String meetingName, String modPass, String viewPass, Boolean allowGuests, Boolean recordable){
		StringBuilder sb = new StringBuilder();
		
		// Meeting Name
		sb.append(meetingName);
		sb.append(DELIMITER);
		
		// Moderator Password
		sb.append(modPass);
		sb.append(DELIMITER);
		
		// Viewer Password
		sb.append(viewPass);
		sb.append(DELIMITER);
		
		// Guests Allowed (True/False)
		sb.append(allowGuests.toString());
		sb.append(DELIMITER);
		
		// Recordable (True/False)
		sb.append(recordable.toString());
		sb.append(DELIMITER);
		
		// Date Last Edited
		sb.append(new java.util.Date());
		
		String dataString = sb.toString();
		return dataString;
	}
	
	public String[] decompress(String rawData){
		String components[] = StringUtils.split(rawData, DELIMITER);
		return components;
	}
	
	public String extractName(String presenterKey, String fieldKey, Jedis jedis){
		String components[] = decompress(jedis.hget(presenterKey, fieldKey));
		return components[0];
	}
	
	// -- COMPRESSION, EXTRACTION
	
	
	public void saveMeeting(String presenterKey, String meetingName, String modPass, String viewPass, Boolean allowGuests, Boolean recordable){
		Jedis jedis = dbConnect();
		Boolean newMeeting = true;
		String dataString = compressMeeting(meetingName, modPass, viewPass, allowGuests, recordable);
		// Checks for the existence of the presenterKey and that the key refers to a hash
		if (jedis.exists(presenterKey) && jedis.type(presenterKey) == "hash"){
			// Goes through all meetings associated with the presenterKey and compares the names
			for (int i = 1; i <= jedis.hlen(presenterKey); i++){
				//Meeting oldMeeting = MeetingApplication.extractMeeting(jedis.hget(presenterKey, "meeting"+i));
				String oldName = extractName(presenterKey, "meeting"+i, jedis);
				if (meetingName == oldName){
					newMeeting = false;
					jedis.hset(presenterKey, "meeting"+i, dataString);
				} // Compare new meeting to old meeting
			} // For loop
			if (newMeeting){
				jedis.hset(presenterKey, "meeting"+(jedis.hlen(presenterKey)+1), dataString);
			} // Save new meeting
		} // Presenter checking		
	}

	/* // This method may be obsolete with it's inclusion in MeetingApplication.java
	public ArrayList <String[]> loadAllMeetings(){
		// Create an ArrayList for lectures and one for ordinary meetings
		Jedis jedis = dbConnect();
		ArrayList <String> lectureList = new ArrayList <String> ();
		ArrayList <String> meetingList = new ArrayList <String> ();
		ArrayList <String[]> allSortedMeetings = new ArrayList <String[]> ();
		
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
		
		// Add the sorted "ordinary meetings" to the end of the sorted lecture list.
		for (int i = 0; i < meetingList.size(); i++){
			lectureList.add(meetingList.get(i));
		}
		
		// Convert all meetings to Meeting objects, ready to return them
		for (int i = 0; i < lectureList.size(); i++){
			allSortedMeetings.add(decompress(lectureList.get(i)));
		}
		
		return allSortedMeetings;
	}
	*/
%>