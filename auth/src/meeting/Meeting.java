package meeting;

import java.util.ArrayList;




public class Meeting {
	String [] meeting;
	
	public boolean loadMeeting(String meetingID) {
		boolean found = false;
		MeetingApplication ma = new MeetingApplication();
		ma.loadAllMeetings();
		
		ArrayList <String[]> allMeetings = new ArrayList<String[]>();
		allMeetings.addAll(ma.getLectures());
		allMeetings.addAll(ma.getMeetings());
		ArrayList <String[]> lec = ma.getLectures();
		ArrayList <String[]> mee = ma.getMeetings();
		
		meeting = null;

		for (int i=0; i<lec.size() && !found; i++) {
			if (lec.get(i)[0].equals(meetingID)){
				meeting = lec.get(i);
				found = true;
			}
		}
		for (int i=0; i<mee.size() && !found; i++) {
			if (mee.get(i)[0].equals(meetingID)){
				meeting = mee.get(i);
				found = true;
			}
		}
		
		return found;
	}
	
	public boolean isFound() {
		return meeting!=null;
	}
	
	public String getMeetingID() {
		return meeting[0];
	}
	
	public String getViewPass() {
		return meeting[2];
	}
	
	public boolean isGuestsAllowed() {
		return meeting[3].equals("true");
	}
}
