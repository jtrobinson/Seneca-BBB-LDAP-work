<%@page import="org.apache.commons.lang.StringUtils"%>
<jsp:useBean id="ldap" class="ldap.LDAPAuthenticate" scope="session"/>
<jsp:useBean id="meetingApplication" class="meeting.MeetingApplication" scope="session"/>
<%@ include file="meeting_api.jsp"%>

<%
	if(!ldap.getAuthenticated().equals("true")) {
	    response.sendRedirect("login.jsp");	
	}
 
	if(ldap.getAccessLevel() < 10) {
    	response.sendRedirect("login.jsp");	
	}
   // getting parameters
	String mPwd = request.getParameter( "mPwd" );
	String mPwdre = request.getParameter( "mPwdre" );
	String vPwd = request.getParameter( "vPwd" );
	String vPwdre = request.getParameter( "vPwdre" );
	String check = request.getParameter("check");
    String guests = request.getParameter("allowGuests");
    String lectures = request.getParameter("Recordable");
   
	String meetingName = "";
	
	
	
	
	if(check == null)
		meetingName = request.getParameter( "meetingName" );
	 else
	    meetingName = request.getParameter("courses");
	 

 

	String allowGuestsTemp = request.getParameter("allowGuests");
	
	// This is done for better parsing when sending to Jedis
	boolean allowGuests = false;
     if(allowGuestsTemp  != null){
       allowGuests = true;
     }
	//this is done for better parsing when sending to Jedis
	String recordableTemp = request.getParameter("Recordable");
	boolean recordable = false;
      if(recordableTemp != null){
      
         recordable = true;
      }
   
    boolean lecture = false;
      if(check != null){
      	lecture = true;
      }
    String section = request.getParameter("section");
   
  
    // saving them to session to repopulate them if validation went wrong
	
	session.setAttribute("mPwd", mPwd);
	session.setAttribute("mPwdre", mPwdre);
	session.setAttribute("vPwd", vPwd);
	session.setAttribute("vPwdre", vPwdre);
	session.setAttribute("meetingName", meetingName);
	session.setAttribute("section", section);
	session.setAttribute("allowGuests", guests);
	session.setAttribute("lectures", lectures);
	

	
  
	// checking no fields to be empty
	if(mPwd  == null || mPwdre == null || vPwd == null || vPwdre == null || meetingName == null){
	response.sendRedirect("create.jsp");
	}
	 out.print("<br > <b>course</b> selected is: " + meetingName+"<br ><b>Allow guests?</b> "+allowGuests+ "<br ><b>Recordable:</b>  " + recordable +"<br > <b>Section</b> is " +section + "</br>" );
	
	if(mPwd.length()  == 0 || mPwdre.length() == 0 || vPwd.length() == 0 || vPwdre.length() == 0 || meetingName.length() == 0 ){
		session.setAttribute( "fail", "1" );
	  if(check == null )
  		response.sendRedirect("create.jsp");
  	    else
  	        response.sendRedirect("create.jsp?isLecture=true");
	}
	else if(mPwd.equals(mPwdre) == false){ // checking for passwords to match
		session.setAttribute( "fail", "2" );
  		if(check == null )
  		response.sendRedirect("create.jsp");
  	    else
  	        response.sendRedirect("create.jsp?isLecture=true");
	}
	else if(vPwd.equals(vPwdre) == false){ // checking for viewer passwords to match
  		session.setAttribute( "fail", "2" );
  		if(check == null )
  		response.sendRedirect("create.jsp");
  	    else
  	        response.sendRedirect("create.jsp?isLecture=true");
  	        //making sure there is no invalid characters in both section and meeting Name
	}else if( StringUtils.indexOfAny(meetingName, "~") != -1 || StringUtils.indexOfAny(section, "~") != -1 || StringUtils.indexOfAny(meetingName, "$") != -1 ||  StringUtils.indexOfAny(section, "$") != -1
	           || StringUtils.indexOfAny(meetingName, "`") != -1 || StringUtils.indexOfAny(section, "`") != -1 || StringUtils.indexOfAny(meetingName, "&") != -1 ||  StringUtils.indexOfAny(section, "&") != -1
	           || StringUtils.indexOfAny(meetingName, "-") != -1 || StringUtils.indexOfAny(section, "-") != -1 || StringUtils.indexOfAny(meetingName, "#") != -1)
	{
	           session.setAttribute( "fail", "4" );
  		if(check == null )
  		response.sendRedirect("create.jsp");
	}else if(mPwd.equals(vPwd) == true){
	   session.setAttribute( "fail", "5" );
  		if(check == null )
  		response.sendRedirect("create.jsp");
	}
	else{
 		out.print(" Valid! Saving to Redis! <br >");
		// Here goes code when everything is VALID
		
		//we don't need session attirubtes any more so removing them:

	session.setAttribute("mPwd", null);
	session.setAttribute("mPwdre", null);
	session.setAttribute("vPwd", null);
	session.setAttribute("vPwdre", null);
	session.setAttribute("meetingName", null);
	session.setAttribute("section", null);
	session.setAttribute("allowGuests", null);
	session.setAttribute("lectures", null);
	
		
  		StringBuilder sb = new StringBuilder();
  		// If the meeting is actually a lecture, build the name as "#COURSENAME-SECTION-PRESENTERNAME"
  		// If the meeting is NOT a lecture, build the name as "#MEETINGNAME-PRESENTERNAME"
  		if (lecture){
  			sb.append(PROF_SYMBOL);
  			sb.append(meetingName);
  			sb.append("-");
  			sb.append(section);
  		}
  		else{
  			sb.append(meetingName);
  		}
  		sb.append(NAME_DELIMITER);
  		sb.append(ldap.getGivenName());
  		
  		meetingName = sb.toString();
  		
  		String dataString = compressMeeting(meetingName, mPwd, vPwd, allowGuests, recordable);
	//	out.print("DEBUG: Data string is: " + dataString + "<br >");
		
  		saveMeeting(ldap.getUserID(), meetingName, mPwd, vPwd, allowGuests, recordable);
  		
  		//out.print("DEBUG: Deleting entry 'a' <br >");
  		//deleteMeeting(ldap.getUserID(), "a");
  		response.sendRedirect("meetings.jsp");
  		// EAC150
  	}

%>