<%

 if(request.getParameter( "username" ) != null && request.getParameter( "password" ) != null){
	 String name = request.getParameter( "username" );
 	 String paswd = request.getParameter( "password" ) ;
   
    if (name.equalsIgnoreCase("root") && paswd.equalsIgnoreCase("root"))
        {
	   
 	    session.setAttribute( "theName",  name);
            response.sendRedirect("loggedIn/welcome.jsp");

        }
    else
        {
            response.sendRedirect("login.jsp?fail=1001a99847aa");	
        }
}else if(session.getAttribute("theName") != "root")
{
    response.sendRedirect("login.jsp");	
}

%>
