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
	private char NAME_DELIMITER = '-';
	
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
	
	// SAVING TO REDIS
	public void saveMeeting(String presenterKey, String meetingName, String modPass, String viewPass, Boolean allowGuests, Boolean recordable){
		Jedis jedis = dbConnect();
		Boolean newMeeting = true;
		String dataString = compressMeeting(meetingName, modPass, viewPass, allowGuests, recordable);
		// Checks for the existence of the presenterKey and that the key refers to a hash
		//if (jedis.exists(presenterKey) && jedis.type(presenterKey) == "hash"){
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
		//} // Presenter checking		
	}

	// -- SAVING

	// DELETING A MEETING
	public void deleteMeeting(String presenterKey, String meetingName){
		Jedis jedis = dbConnect();
		try {
			// Find the number of meetings for this presenter
			Integer numMeetings = jedis.hlen(presenterKey).intValue();
			Integer target = 0;
			int position = 1;
			Boolean found = false;
			while (!found || position <= numMeetings){
				// Find the meeting that matches that name				
				if (extractName(presenterKey, "meeting"+position, jedis) == meetingName){
					// Save which "position" that meeting is at (meeting1, meeting2....)
					target = position;
				}
				position++;
			}
			if (target > 0){
				// If meeting position == number of meetings, just flat-out delete it
				if (target == numMeetings){
					jedis.hdel(presenterKey, "meeting"+numMeetings);
				}
				// Else, copy meeting(n+1) into meeting(n) until meeting(n+1) doesn't exist, and then delete meeting(n+1)
				else{
					for (position = target; position < numMeetings; position++){
						String nextMeeting = jedis.hget(presenterKey, "meeting"+(position+1));
						jedis.hset(presenterKey, "meeting"+position, nextMeeting);
					}
					jedis.hdel(presenterKey, "meeting"+numMeetings);
				}
			}
		}
		catch (Exception e){
			e.printStackTrace();
		}
	}
	// -- DELETING
%>