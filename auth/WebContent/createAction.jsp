<jsp:useBean id="ldap" class="ldap.LDAPAuthenticate" scope="session"/>
<jsp:useBean id="meetingApplication" class="ldap.MeetingApplication" scope="session"/>
<%@ include file="meeting_api.jsp"%>

<%
	if(!ldap.getAuthenticated().equals("true")) {
	    response.sendRedirect("login.jsp");	
	}

	String mPwd = request.getParameter( "mPwd" );
	String mPwdre = request.getParameter( "mPwdre" );
	String vPwd = request.getParameter( "vPwd" );
	String vPwdre = request.getParameter( "vPwdre" );
	String check = request.getParameter("check");
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


   out.print("<br > <b>course</b> selected is: " + meetingName+"<br ><b>Allow guests?</b> "+allowGuests+ "<br ><b>Recordable:</b>  " + recordable +"<br > <b>Section</b> is " +section + "</br>" );
	// checking no fields to be empty
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
	}
	else{
 		out.println(" Valid! Saving to Redis!");
		// Here goes code when everything is VALID
		
  		StringBuilder sb = new StringBuilder();
  		// If the meeting is actually a lecture, build the name as "#COURSENAME-SECTION-PRESENTERNAME"
  		// If the meeting is NOT a lecture, build the name as "#MEETINGNAME-PRESENTERNAME"
  		if (lecture){
  			sb.append(PROF_SYMBOL);
  			sb.append(meetingName);
  			sb.append(NAME_DELIMITER);
  			sb.append(section);
  		}
  		else{
  			sb.append(meetingName);
  		}
  		sb.append(NAME_DELIMITER);
  		sb.append(ldap.getCN());
  		
  		meetingName = sb.toString();
  		
  		String dataString = compressMeeting(meetingName, mPwd, vPwd, allowGuests, recordable);
		out.println("DEBUG: Data string is: " + dataString);
		
  		saveMeeting(ldap.getUID(), meetingName, mPwd, vPwd, allowGuests, recordable);
  	}

%>