<jsp:useBean id="meetingApplication" class="meeting.MeetingApplication" scope="session"/>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="org.w3c.dom.*, javax.xml.parsers.*" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">

<%!
  public boolean isTextNode(Node n){
  return n.getNodeName().equals("#text");
  }
%>

 <script type="text/javascript">

 // this small function allows to change Drop down list of lecture to textbox  (for Professors )
function onCheck()
  {
  // this code is to trigger oncheck isLecture Event 
   var isCheckedLecture = document.getElementById("check").checked;
  if( isCheckedLecture  == true)
 	  isCheckedLecture = "true";
   else 
      isCheckedLecture = "false";	 
    
    window.location.replace("create.jsp?isLecture="+isCheckedLecture);
    
<%   String check = (String) request.getParameter("isLecture"); 
     String isLecture = "true";
     session.setAttribute( "isChecked", check );
     session.setAttribute("isLecture", isLecture);
    
%>
}	
 
</script>
 
 
<title>Create Meeting</title>
</head>
<body>
<%@ include file="meeting_api.jsp"%>
<%@ include file="auth_header.jsp"%>

<%
if (ldap.getAccessLevel() < 10) {
	response.sendRedirect("login.jsp");	
}
%>
   <form action="createAction.jsp" method="post" name="form">
   <table align='center' width='465'>
      <tr><td colspan='2'><h3> Create Session</h3></td></tr>
      
   <% String checked = ""; 
     if(session.getAttribute( "isChecked") != null){
      checked =  (String) session.getAttribute( "isChecked");
      }else checked = "false";
      
      if(ldap.getAccessLevel() >= 30){
      // if you are logged in as prof you have checkbox which allows you to  create a lecture
         out.println("<tr height='30'><td> Create a Lecture ?</td> <td><input type='checkbox' id='check' name='check' onClick='onCheck()'");
                if (checked.equals("true"))  out.println("checked = 'checked'");
                out.println("><td></tr>");
      }
      
       if( ldap.getAccessLevel() >= 30 && checked.equals("true") ){
             // if you are professor and you checked is Lecture you see drop down list of lectures
        		out.println("<tr height='30'><td align='center'>");
                out.println(" <span style='color:red'>*</span><select name='courses'>");
                
                ArrayList <String> courseList = meetingApplication.processCourseList();
                
                
                for (String courseName : meetingApplication.processCourseList()){
                
                  if(courseName.equals(session.getAttribute("meetingName"))){
                  out.println("<option selected='selected'>" + courseName + "</option>");
                  }else{
                	out.println("<option>" + courseName + "</option>");	
                  }
                }
                

                out.println("</select></td>");
                if(session.getAttribute("section") == null){
                 out.print("<td>Section <input type='text' size='5' maxlength='5' name='section' />");
                }else{
                 out.print("<td>Section <input type='text' size='5' maxlength='5' name='section'");
                 out.print("value = '"+session.getAttribute("section") +"'");
                 out.print("/>");
                 }
                 out.print("</td></tr>");
                
       }else{
         // else user sees a textbox with name of the lecture
         out.print("<tr> <td>Name of Meeting:  <span style='color:red'>*</span></td><td>   <input type='text' id='meetingName' ");
         if(session.getAttribute("meetingName") != null)
           out.print("value = '"+session.getAttribute("meetingName")+"' "); 
            out.print("name='meetingName' size='30'/></td> </tr>");
           
       }
   
%>
 
     </tr><tr>
     <td>Moderator Password <span style='color:red'>*</span></td><td>   <input type="text" id="mPwd" name="mPwd"
                        <% if(session.getAttribute( "mPwd" ) != null) out.print("value = '"+session.getAttribute("mPwd")+"'"); %>/></td>
 
     </tr>
     <tr >
     <td>Confirm Mod. Password  <span style='color:red'>*</span></td><td>   <input type="text" id="mPwdre"  name="mPwdre" 
      					<% if(session.getAttribute( "mPwdre" ) != null) out.print("value = '"+session.getAttribute("mPwdre")+"'"); %>/></td>
     </tr>
     <tr >
     <td>Viewer Password  <span style='color:red'>*</span></td><td>      <input type="text" id="vPwd" name="vPwd"  
     				<% if(session.getAttribute( "vPwd" ) != null) out.print("value = '"+session.getAttribute("vPwd")+"'"); %>/></td>
     </tr>
     <tr>
     <td>Confirm View. Password  <span style='color:red'>*</span></td><td>   <input type="text" id="vPwdre" name="vPwdre"  
     					<% if(session.getAttribute( "vPwdre" ) != null) out.print("value = '"+session.getAttribute("vPwdre")+"'"); %>/></td>
     </tr>
    
<% 
   String guestsChecked = (String) session.getAttribute("allowGuests");
   String lectures = (String) session.getAttribute("lectures");
   
       // if user is authenticated as employee allowing them two options: invite non-ldap authenticated people
       // allow to record their meetings
      if(ldap.getAccessLevel() >= 20){
        out.println("<tr height='60'>");
       if(session.getAttribute("allowGuests")  != null && guestsChecked.equals("on")){
        out.println(" <td colspan='2'> Allow Guests ? <input type='checkbox' id='allowGuests' name='allowGuests' checked='yes'/> ");
        }else{
         out.println(" <td colspan='2'> Allow Guests ? <input type='checkbox' id='allowGuests' name='allowGuests'/> ");
         }
        if(session.getAttribute("lectures")  != null && lectures.equals("on")){
        out.println(" Recordable ? <input type='checkbox' id='Recordable' name='Recordable' checked='yes'/></td> ");
        }else{
          out.println(" Recordable ? <input type='checkbox' id='Recordable' name='Recordable' /></td> ");
        }
        out.println("</tr>");
       }
%>
       
        
         

     <tr>
        <td><input type='submit' value='Create'/></td>
     </tr>
     <tr>
        <td colspan="2">
           <%
          
           
           
           if( session.getAttribute( "fail" )!= null){
            String fail = (String) session.getAttribute( "fail" );
            session.removeAttribute("fail");
           if(fail.equals("1")){
           out.print("<div style='color:red' align='center'> Please fill all the  Required Fields!</div>");
           }else if(fail.equals("2")){
           out.print("<div style='color:red' align='center'> Presenter's password and Confirmation must match!</div>");
           }else if(fail.equals("3")){
           out.print("<div style='color:red' align='center'> Viewer's password and Confirmation must match!</div>");
           } else if(fail.equals("4")){
              out.print("<div style='color:red' align='center'> Your meeting name or section contains forbidden character (not allowed: $&`~-#)</div>");
           }else if(fail.equals("5")){
           out.print("<div style='color:red' align='center'> Presenter and Moderator passwords cannot be the same!</div>");
           }
           }
           
          	session.setAttribute("mPwd", null);
			session.setAttribute("mPwdre", null);
			session.setAttribute("vPwd", null);
			session.setAttribute("vPwdre", null);
			session.setAttribute("meetingName", null);
			session.setAttribute("section", null);
			session.setAttribute("allowGuests", null);
			session.setAttribute("lectures", null);
	
           %>
        </td>
     </tr>
     <tr>
         <td> <span style='color:red'>*</span> - Required Field</td>
     </tr>
     </table>
    </form>
</body>


</html>