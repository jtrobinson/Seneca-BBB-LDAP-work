package ldap;

/* Add these lines to create.jsp right at the top:
<jsp:useBean id="meetingApplication" class="ldap.MeetingApplication" scope="session"/>
<%@ include file="meeting_api.jsp"%>
 */

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.apache.commons.lang.StringUtils;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;

public class MeetingApplication {
	
	private final static char PROF_SYMBOL = '#';
	private final static char EMP_SYMBOL = '&';
	private final static char STUDENT_SYMBOL = '$';
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
		
		lectures = new ArrayList<String[]>();
		meetings = new ArrayList<String[]>();
		
		// Populate the instance variables lectures and meetings with all the available lectures and general meetings, respectively
		for (int i = 0; i < lectureList.size(); i++){
			lectures.add(decompress(lectureList.get(i)));
		}
		for (int i = 0; i < meetingList.size(); i++){
			meetings.add(decompress(meetingList.get(i)));
		}
	}
	
	/*
	 * This function receives user ID and returns formatted recording string for the recordings.jsp
	 */
	public String getRecordingString(String userId){
	   String  s = " "; // temporary recording string
	  
	  
		  loadMeetingsByUser(userId);
		  
		  ArrayList<String[]> lectures = getLectures();
		  ArrayList<String[]> meetings = getMeetings();
	   
		  //getting meeting id which is 0 elementof the array
		   for (String[] lecture : lectures){
			   s+= lecture[0]+",";
		   }
		   
		   for (String[] meeting : meetings){
			   s+=meeting[0]+",";
			   
		   }
		   
		   
		   // getting rid of last comma
		   String recordingString = s.substring(0, s.length()-1 );
		   
		   System.out.println("here we are recording string!");
	   
	   return recordingString;
	}
	
	public void loadMeetingsByUser(String presenterKey){
		// Create an ArrayList for lectures and one for ordinary meetings
		Jedis jedis = dbConnect();
		ArrayList <String> lectureList = new ArrayList <String> ();
		ArrayList <String> meetingList = new ArrayList <String> ();
		System.out.println("presenterKey: " + presenterKey);

		// Checks if the current key is a hash, and if it contains any meetings
		if (jedis.type(presenterKey).equals("hash")){
			System.out.println("inside");
			// Goes through each meeting in the current hash
			for (int i = 1; i <= jedis.hlen(presenterKey); i++){
				// Extracts the meeting data string from the current meeting
				String rawMeeting = jedis.hget(presenterKey, "meeting"+i);
				System.out.println("rawMeeting : " + rawMeeting);
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
		
		lectures = new ArrayList<String[]>();
		meetings = new ArrayList<String[]>();
		
		// Populate the instance variables lectures and meetings with all the available lectures and general meetings, respectively
		for (int i = 0; i < lectureList.size(); i++){
			lectures.add(decompress(lectureList.get(i)));
		}
		for (int i = 0; i < meetingList.size(); i++){
			meetings.add(decompress(meetingList.get(i)));
		}
	}

	// Gets a list of available courses for lecture creation from the config.xml
	public ArrayList<String> processCourseList(){
		ArrayList <String> courses = new ArrayList <String> ();
		try{
			//Using factory get an instance of document builder
			DocumentBuilder db = DocumentBuilderFactory.newInstance().newDocumentBuilder();
			//parse using builder to get DOM representation of the XML file
			Document dom = db.parse(Thread.currentThread().getContextClassLoader().getResourceAsStream("config.xml"));
			//get the root element
			Element docEle = dom.getDocumentElement();
			
			NodeList courseList = docEle.getElementsByTagName("courseList").item(0).getChildNodes();
			for (int i=0; i<courseList.getLength(); i++) {
				if (courseList.item(i).getNodeName().equals("course")) {
					courses.add(courseList.item(i).getFirstChild().getNodeValue());
				} 
			}
		}
		catch (Exception e) {
			e.printStackTrace();
		}
		return courses;
	}
	
	public String getUserMeetingsXML(String uid) {
		System.out.println("uid: " + uid);
		
		String newXMLdoc = "<meetings>";
		
		loadMeetingsByUser(uid);	
		
		System.out.println("lect: "+ lectures.size());
		System.out.println("meet: "+ meetings.size());
		
		newXMLdoc += convertMeetingList(getLectures(), "Lecture");
		newXMLdoc += convertMeetingList(getMeetings(), "Meeting");

		newXMLdoc += "</meetings>";
		System.out.println("num meetings : " + meetings.size());
		
		System.out.println(newXMLdoc);
		
		return newXMLdoc;
	}
	
	private String convertMeetingList(ArrayList<String[]> meetings, String type) {
		String convMeetings = "";
		
		/*	Each meeting follows the format
			course-uid
			modpass
			viewpass
			guests allowed
			recorded
			date
		 */
		for (String[] meet : meetings) {
			
			// not implemented yet
			//String [] parts = meet[0].split("-");
			
			convMeetings += "<meeting>";
			
			convMeetings += "<meetingID>" + meet[0] + "</meetingID>";
			convMeetings += "<type>" + type + "</type>";
			convMeetings += "<name>" + meet[0] + "</name>";
			convMeetings += "<modPass>" + meet[1] + "</modPass>";
			convMeetings += "<viewPass>" + meet[2] + "</viewPass>";
			convMeetings += "<guests>" + meet[3] + "</guests>";
			convMeetings += "<recorded>" + meet[4] + "</recorded>";
			convMeetings += "<date>" + meet[5] + "</date>";
			
			convMeetings += "</meeting>";
		}
		
		return convMeetings;
	}
}
