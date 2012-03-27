<HTML> 
<HEAD><TITLE>Welcome</TITLE></HEAD>  
<BODY>
<br><br>
<%
if(session.getAttribute("theName")!=null && session.getAttribute("theName")!="")
{
String user = session.getAttribute("theName").toString();
%>
<h2>Welcome <b><%= user%></b> Where have you been man ? Take a sit! </h2>
<a href="logout.jsp"><b>Logout</b></a>

<%
}else{
    response.sendRedirect("../login.jsp");	
}

%>
<%
 response.setHeader("Cache-Control", "no-cache"); //Forces caches to obtain a new copy of the page from the origin server  
            response.setHeader("Cache-Control", "no-store"); //Directs caches not to store the page under any circumstance  
            response.setDateHeader("Expires", 0); //Causes the proxy cache to see the page as "stale"  
            response.setHeader("Pragma", "no-cache"); //HTTP 1.0 backward compatibility  
%>
</body>
<html>
