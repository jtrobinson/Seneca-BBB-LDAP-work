package org.apache.commons.lang;

import javax.naming.Context;
import javax.naming.NamingEnumeration;
import javax.naming.directory.InitialDirContext;
import javax.naming.directory.DirContext;
import javax.naming.directory.SearchControls;
import javax.naming.directory.SearchResult;
import javax.naming.NamingException;

import java.util.ArrayList;
import java.util.Hashtable;
import java.util.Scanner;

public class LDAPTest {
	public static void main(String[] args) {
			Hashtable env = new Hashtable();

			Boolean keyboard = false;
			Boolean verbose = true;
			String username;
			String password;
			
			if (keyboard){
				Scanner kbdIn = new Scanner(System.in);
				System.out.print("Enter username: ");
				username = kbdIn.nextLine();
				System.out.print("Enter password: ");
				password = kbdIn.nextLine();
			}
			else {
				username = "justin.robinson";
				password = "lord__fl4gg";
			}
			String principalString = "uid=" + username;
			
			
			env.put(Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.ldap.LdapCtxFactory");
			
			// specify where the ldap server is running
			env.put(Context.PROVIDER_URL, "ldap://dssy.senecac.on.ca/");
			//env.put(Context.SECURITY_AUTHENTICATION, "none");
			
			env.put(Context.SECURITY_AUTHENTICATION, "simple");
			env.put(Context.SECURITY_PRINCIPAL, principalString);
			env.put(Context.SECURITY_CREDENTIALS, password);
			
			System.out.println("Survived all env.puts.");
			try {
				System.out.println("Entering try block.");
				
				// Create the initial directory context
				DirContext ctx = new InitialDirContext(env);
				System.out.println("Survived creating ctx");
				
				SearchControls ctrl = new SearchControls();
				System.out.println("Survived creating ctrl");
				
				ctrl.setSearchScope(SearchControls.SUBTREE_SCOPE);
				System.out.println("Survived ctrl.setSearchScope");
				
	            String filter = "(&(uid="+username+"))";
	            NamingEnumeration enume = ctx.search("o=sene.ca", filter, ctrl);
	            System.out.println("Survived creating enume");
	            	            	
	            if (verbose){
	            	printSearchEnumeration(enume);
	            }
	            else{
	            	SearchResult sr = (SearchResult)enume.next();
	            	StringUtils util = new StringUtils();
	            
	            	String result = sr.getAttributes().toString();
	            	String [] info = util.split(sr.getName(), "=");	            
	            	String status = info[info.length-1];
	             
	            	System.out.println(status);

	            
	            	if (status.compareTo("Employee") == 0){
	            		String [] elements = util.split(result, "{,}");
	            		String givenName = null;
	            		String title = null;
	            		String office = null;
	            		for (String s : elements){
	            			s = s.trim();
	            			if (s.startsWith("cn"))
	            				givenName = s.substring(7);
	            			else if (s.startsWith("title"))
	            				title = s.substring(13);
	            			else if (s.startsWith("l"))
	            				office = s.substring(5);	            		
	            		}
	            		System.out.println(givenName);
	            		System.out.println(title);
	            		System.out.println(office);
	            	}            
	            }
	            
				// Close the context
				ctx.close();
				System.out.println("I am Dave!Yognaught");
			} 
			//catch (NamingException e) {
			catch (Exception e) {
				System.err.println(e.toString());
			}
			
	  }//End of main		
		
	public static void printSearchEnumeration(NamingEnumeration en) {
		try {
			while (en.hasMore()){
				SearchResult sr = (SearchResult)en.next();
				System.out.println(">>>" + sr.getName());
				System.out.println("----------");
				System.out.println(sr.getAttributes());
				System.out.println("----------");
			}
		} 
		catch (NamingException e) {
			System.err.println("WRONG");
			e.printStackTrace();
		}
	}
	
}//End of LDAPTest Class