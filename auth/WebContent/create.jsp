<jsp:useBean id="meetingApplication" class="ldap.MeetingApplication" scope="session"/>
<%@ include file="meeting_api.jsp"%>

<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
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
<%@ include file="auth_header.jsp"%>
<div align ="center">
   <h1> Create Session:</h1>
   <form action="createAction.jsp" method="post" name="form">
   <br />
   <table>
   
  
    

   <% String checked = ""; 
     if(session.getAttribute( "isChecked") != null){
      checked =  (String) session.getAttribute( "isChecked");
      }else checked = "false";

      String  title = ldap.getTitle(); // this needed to find is employee is professor
      String position = ldap.getOU();  // this needed to diffirintiate students from employees (all employees)
     
       
      if(title == null){
      title = "Student";
      }
      
      if(position == null){
      position = "Guest";
      }
      
      if(title.equals("Support Staff")){
      // if you are logged in as prof you have checkbox which allows you to  create a lecture
         out.println("<tr height='30'><td colspan='2'> Create a Lecture ? <input type='checkbox' id='check' name='check' onClick='onCheck()'");
                if (checked.equals("true"))  out.println("checked = 'checked'");
                out.println("><td></tr>");
      }
      
       if( title.equals("Support Staff") && checked.equals("true") ){
             // if you are professor and you checked is Lecture you see drop down list of lectures
        		out.println("<tr height='30'><td align='center'>");
                out.println(" <span style='color:red'>*</span><select name='courses'>");
                
                meetingApplication.foo();
                
                //meetingApplication.processCourseList();
                //ArrayList <String> courseList = meetingApplication.processCourseList();
                
                /*
                for (String courseName : meetingApplication.processCourseList()){
                	out.println("<option>" + courseName + "</option>");	
                }
                */

                out.println("</select></td>");
                out.println("<td>Section <input type='text' size='5' maxlength='5' name='section' /></td></tr>");
       }else{
         // else user sees a textbox with name of the lecture
         out.println("<tr height='30'> <td height='50'>Name of Meeting:  <span style='color:red'>*</span></td><td>   <input type='text' id='meetingName' name='meetingName' size='60'/></td> </tr>");
       }
   
%>
 
     </tr><tr>
     <td>Moderator Password <span style='color:red'>*</span></td><td>   <input type="text" id="mPwd" name="mPwd" /></td>
     </tr>
     <tr >
     <td>Confirm Mod. Password  <span style='color:red'>*</span></td><td>   <input type="text" id="mPwdre"  name="mPwdre"/></td>
     </tr>
     <tr >
     <td>Viewer Password  <span style='color:red'>*</span></td><td>      <input type="text" id="vPwd" name="vPwd"/></td>
     </tr>
     <tr>
     <td>Confirm View. Password  <span style='color:red'>*</span></td><td>   <input type="text" id="vPwdre" name="vPwdre" /></td>
     </tr>
    
<% 
       // if user is authenticated as employee allowing them two options: invite non-ldap authenticated people
       // allow to record their meetings
      if(position.equals("Employee")){
        out.println("<tr height='60'>");
        out.println(" <td colspan='2'> Allow Guests ? <input type='checkbox' id='allowGuests' name='allowGuests'/> ");
        out.println(" Recordable ? <input type='checkbox' id='Recordable' name='Recordable'/></td> ");
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
           }
           }
          
           %>
        </td>
     </tr>
     <tr>
         <td> <span style='color:red'>*</span> - Required Field</td>
     </tr>
    </form>
    </div>
</body>


</html>