<jsp:useBean id="ldap" class="ldap.LDAPAuthenticate" scope="session"/>

<HTML> 
<HEAD><TITLE>Welcome</TITLE></HEAD>  
<BODY>
<div align='right'><a href="logout.jsp"><b>Logout</b></a></div>
<%@ include file="seneca_header.jsp"%>
<br><br>
<%
if(!ldap.getAuthenticated().equals("true")) {
    response.sendRedirect("../login.jsp");	
}

%>
<%@ include file="bbb_api.jsp"%>

<% 
String user = ldap.getCN();
//
// We're going to define some sample courses (meetings) below.  This API exampe shows how you can create a login page for a course. 
// The password below are not available to users as they are compiled on the server.
//

HashMap<String, HashMap> allMeetings = new HashMap<String, HashMap>();
HashMap<String, String> meeting;

// String welcome = "<br>Welcome to %%CONFNAME%%!<br><br>For help see our <a href=\"event:http://www.bigbluebutton.org/content/videos\"><u>tutorial videos</u></a>.<br><br>To join the voice bridge for this meeting:<br>  (1) click the headset icon in the upper-left, or<br>  (2) dial xxx-xxx-xxxx (toll free:1-xxx-xxx-xxxx) and enter conference ID: %%CONFNUM%%.<br><br>";

String welcome = "<br>Welcome to <b>%%CONFNAME%%</b>!<br><br>This is a Test Web Conferencing Session prepared for Seneca College.<br><br>To join the audio bridge click the headset icon (upper-left hand corner). <b>You can mute yourself in the Listeners window.</b>";

//Seneca Courses
//

meeting = new HashMap<String, String>();


allMeetings.put( "INT422: ASP.NET programming", meeting );	// The title that will appear in the drop-down menu
	

allMeetings.put( "OOP344: Object Oriented Programming II", meeting );	// The title that will appear in the drop-down menu


allMeetings.put( "JAC444: Java Programming", meeting );	// The title that will appear in the drop-down menu


	meeting.put("welcomeMsg", 	welcome);			// The welcome mesage
	meeting.put("moderatorPW", 	"cdot1042tel");			// The password for moderator
	meeting.put("viewerPW", 	"student123");			// The password for viewer
	meeting.put("voiceBridge", 	"72013");			// The extension number for the voice bridge (use if connected to phone system)

meeting = null;

Iterator<String> meetingIterator = new TreeSet<String>(allMeetings.keySet()).iterator();

if (request.getParameterMap().isEmpty()) {
		//
		// Assume we want to join a course
		//
	%> 



<br/>
<br/>
<div align='center'>
<br/>
<br/>
<h2 align="center">Join a Lecture (password required)</h2>

<p style='font-size:23px'>Welcome <b><span style='color:green;'><%= user%></b> <p>
</div>
<FORM NAME="form1" METHOD="GET">
<table cellpadding="5" cellspacing="5" style="width: 400px; " align="center">
	<tbody>
		<tr>
			<td>
				&nbsp;</td>
			<td style="text-align: right; ">
				</td>
			<td style="width: 5px; ">
				&nbsp;</td>
			<td style="text-align: left ">
				</td>
		</tr>
		
	
		
		<tr>
			<td>
				&nbsp;</td>
			<td style="text-align: right; ">
				Course:</td>
			<td>
				&nbsp;
			</td>
			<td style="text-align: left ">
			<select name="meetingID">
			<%
				String key;
				while (meetingIterator.hasNext()) {
					key = meetingIterator.next(); 
					out.println("<option value=\"" + key + "\">" + key + "</option>");
				}
			%>
			</select>
				
			</td>
		</tr>
		<tr>
			<td>
				&nbsp;</td>
			<td style="text-align: right; ">
				Password:</td>
			<td>
				&nbsp;</td>
			<td>
				<input type="password" required name="password" /></td>
		</tr>
		<tr>
			<td>
				&nbsp;</td>
			<td>
				&nbsp;</td>
			<td>
				&nbsp;</td>
			<td>
				<input type="submit" value="Join" /></td>
		</tr>	
	</tbody>
</table>
<INPUT TYPE=hidden NAME=action VALUE="create">
</FORM>

<h5 align="center">To login please use password: <b>student123</b> </h3>


</ul>


<%
	} else if (request.getParameter("action").equals("create")) {
		//
		// Got an action=create
		//

		String username = user;
		String meetingID = request.getParameter("meetingID");
		String password = request.getParameter("password");
		
		meeting = allMeetings.get( meetingID );
		
		String welcomeMsg = meeting.get( "welcomeMsg" );
		String logoutURL = meeting.get( "logoutURL" );
		
		Integer voiceBridge = Integer.parseInt( meeting.get( "voiceBridge" ).trim() );

		String viewerPW = meeting.get( "viewerPW" );
		String moderatorPW = meeting.get( "moderatorPW" );
		
		Map<String,String> metadata=new HashMap<String,String>();
		
		metadata.put("email", request.getParameter("username"));
		metadata.put("title", request.getParameter("meetingID"));

	

		//
		// Check if we have a valid password
		//
		 String joinURL;
		if ( ! password.equals(viewerPW) && ! password.equals(moderatorPW) ) {
%>

Invalid Password, please <a href="javascript:history.go(-1)">try again</a>.

<%
			return;
		}else if(password.equals(moderatorPW)){
			 joinURL = getJoinURL(username, meetingID, "true", welcomeMsg, metadata, null);	
		}else{
                          joinURL =  getJoinURLViewer(username,meetingID);
		}
		
		//
		// Looks good, let's create the meeting
		//
		
		
		//String meeting_ID = createMeeting( meetingID, welcomeMsg, moderatorPW, viewerPW, voiceBridge, logoutURL );
		
		//
		// Check if we have an error.
		//
		if (joinURL.startsWith("http://")) {
%>
<script language="javascript" type="text/javascript">
  window.location.href="<%=joinURL%>";
</script>
<%
		}else{
%>
Error: getJoinURL() failed
<p /><%=joinURL%> <%
		}
	}
%> 
<br />




<%
 response.setHeader("Cache-Control", "no-cache"); //Forces caches to obtain a new copy of the page from the origin server  
            response.setHeader("Cache-Control", "no-store"); //Directs caches not to store the page under any circumstance  
            response.setDateHeader("Expires", 0); //Causes the proxy cache to see the page as "stale"  
            response.setHeader("Pragma", "no-cache"); //HTTP 1.0 backward compatibility  
%>
</body>
<html>
