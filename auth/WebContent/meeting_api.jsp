<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Collections"%>
<%@page import="java.util.Date"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="org.apache.commons.lang.StringUtils"%>
<%@page import="redis.clients.jedis.*" language="java" %>
<%@ include file="bbb_api.jsp"%>

<%!
	private final static char PROF_SYMBOL = '#';
	private final static char USERID_HEADER = '$';
	private final static char DELIMITER = '~';
	private final static char NAME_DELIMITER = '^';
	
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
		
		// Meeting Name (Field [0])
		sb.append(meetingName);
		sb.append(DELIMITER);
		
		// Moderator Password (Field [1])
		sb.append(modPass);
		sb.append(DELIMITER);
		
		// Viewer Password (Field [2])
		sb.append(viewPass);
		sb.append(DELIMITER);
		
		// Guests Allowed (True/False) (Field [3])
		sb.append(allowGuests.toString());
		sb.append(DELIMITER);
		
		// Recordable (True/False) (Field [4])
		sb.append(recordable.toString());
		sb.append(DELIMITER);
		
		// Date Last Edited (Field [5])
		SimpleDateFormat df = new SimpleDateFormat("yyyy/MM/dd aa HH:mm");
		Date date = new java.util.Date();
		sb.append(df.format(date));
		
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
		presenterKey = USERID_HEADER + presenterKey;
		Jedis jedis = dbConnect();
		Boolean newMeeting = true;
		String dataString = compressMeeting(meetingName, modPass, viewPass, allowGuests, recordable);
		// Goes through all meetings associated with the presenterKey and compares the names
		for (int i = 1; i <= jedis.hlen(presenterKey); i++){
			//Meeting oldMeeting = MeetingApplication.extractMeeting(jedis.hget(presenterKey, "meeting"+i));
			String oldName = extractName(presenterKey, "meeting"+i, jedis);
			if (meetingName.compareTo(oldName) == 0){
				newMeeting = false;
				jedis.hset(presenterKey, "meeting"+i, dataString);
			} // Compare new meeting to old meeting
		} // For loop
		if (newMeeting){
			jedis.hset(presenterKey, "meeting"+(jedis.hlen(presenterKey)+1), dataString);
		} // Save new meeting		
	}

	// -- SAVING

	// DELETING A MEETING
	public String deleteMeeting(String presenterKey, String meetingName){
		presenterKey = USERID_HEADER + presenterKey;
		Jedis jedis = dbConnect();
		//System.out.println("Survived initializing Jedis");
		try {
			// Find the number of meetings for this presenter
			Integer numMeetings = jedis.hlen(presenterKey).intValue();
			Integer target = 0;
			int position = 1;
			Boolean found = false;
			//System.out.println("About to enter while loop");
			while (!found && position <= numMeetings){
				//System.out.println("Checking meeting"+position);
				// Find the meeting that matches that name
				//System.out.println("DEBUG: extraction is: " + extractName(presenterKey, "meeting"+position, jedis));
				//System.out.println("DEBUG: meetingName is: " + meetingName);
				if (meetingName.compareTo(extractName(presenterKey, "meeting"+position, jedis)) == 0){
					// Save which "position" that meeting is at (meeting1, meeting2....)
					//System.out.println("DEBUG: Found!");
					target = position;
					found = true;
				}
				position++;
			}
			//System.out.println("Out of while loop");
			if (target > 0){
				// If meeting position == number of meetings, just flat-out delete it
				if (target == numMeetings){
					//System.out.println("Deleting only/last existing meeting");
					jedis.hdel(presenterKey, "meeting"+numMeetings);
				}
				// Else, copy meeting(n+1) into meeting(n) until meeting(n+1) doesn't exist, and then delete meeting(n+1)
				else{
					//System.out.println("Deleting a meeting in the middle");
					for (position = target; position < numMeetings; position++){
						String nextMeeting = jedis.hget(presenterKey, "meeting"+(position+1));
						jedis.hset(presenterKey, "meeting"+position, nextMeeting);
					}
					jedis.hdel(presenterKey, "meeting"+numMeetings);
				}
			}
			else {
				//System.out.println("Meeting with name " + meetingName + " not found!");
			}
		}
		catch (Exception e){
			e.printStackTrace();
		}
		//System.out.println("Exiting deleteMeeting");
		
		return "<response><returncode>SUCCESS</returncode><deleted>true</deleted></response>";
	}
	// -- DELETING
	
	// This method accepts an ArrayList of decompressed meetings (works for both meetings and lectures) and returns
	// an ArrayList of those meetings/lectures which are currently running.
	public ArrayList <String[]> runningList(ArrayList <String[]> meetings){
		ArrayList <String[]> openMeetings = new ArrayList <String[]> ();
		for (int i = 0; i < meetings.size(); i ++){
			String meetingID = StringUtils.removeStart(meetings.get(i)[0], String.valueOf(PROF_SYMBOL));
			//System.out.println(meetingID + ": " + isMeetingRunning(meetingID));
			if (isMeetingRunning(meetingID).equals("true")){
				openMeetings.add(meetings.get(i));
			}
		}
		return openMeetings;
	}
%>