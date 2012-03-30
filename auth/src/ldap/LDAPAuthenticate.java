package ldap;

import javax.naming.Context;
import javax.naming.NamingEnumeration;
import javax.naming.directory.Attributes;
import javax.naming.directory.InitialDirContext;
import javax.naming.directory.DirContext;
import javax.naming.directory.SearchControls;
import javax.naming.directory.SearchResult;
import javax.naming.NamingException;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Hashtable;

public class LDAPAuthenticate {
	private String authenticated;
	private Hashtable<Object, Object> env;
	private DirContext ldapContextNone;
	private SearchControls searchCtrl;
	private String url;
	private String o;
	private String ou;
	private String uid;
	private String cn;
	private boolean logout;
	
	public LDAPAuthenticate() {
		authenticated = "false";
		logout = false;
		url = "ldap://dssy.senecac.on.ca/";
		o = "sene.ca";
		//String security = "";
		/*
		try {
			//Using factory get an instance of document builder
			DocumentBuilder db = DocumentBuilderFactory.newInstance().newDocumentBuilder();
			//parse using builder to get DOM representation of the XML file
			//Document dom = db.parse("WEB-INF/config.xml");
			Document dom = db.parse(Thread.currentThread().getContextClassLoader().getResourceAsStream("../config.xml"));
			//get the root element
			Element docEle = dom.getDocumentElement();
			
			NodeList ldapConfig = docEle.getElementsByTagName("ldap").item(0).getChildNodes();
			for (int i=0; i<ldapConfig.getLength(); i++) {
				if (ldapConfig.item(i).getNodeName().equals("url")) {
					url = ldapConfig.item(i).getFirstChild().getNodeValue();
				//} else if (ldapConfig.item(i).getNodeName().equals("security-authentication")) {
				//	security = ldapConfig.item(i).getFirstChild().getNodeValue();
				} else if (ldapConfig.item(i).getNodeName().equals("o")) {
					o = ldapConfig.item(i).getFirstChild().getNodeValue();
				}
			}
		} catch (ParserConfigurationException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		} catch (SAXException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		*/
		env = new Hashtable<Object, Object>();
		env.put(Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.ldap.LdapCtxFactory");
		
		// specify where the ldap server is running
		env.put(Context.PROVIDER_URL, url);
		env.put(Context.SECURITY_AUTHENTICATION, "none");
		
		// Create the initial directory context
		try {
			ldapContextNone = new InitialDirContext(env);
		} catch (NamingException e) {

		}
		
		searchCtrl = new SearchControls();
		searchCtrl.setSearchScope(SearchControls.SUBTREE_SCOPE);
	}
	
	public boolean search(String user, String pass) {
		search(user);
		
		if (authenticated.equals("true") && user.equals(uid)) {
			try {
				env = new Hashtable<Object, Object>();
				env.put(Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.ldap.LdapCtxFactory");
				
				// specify where the ldap server is running
				env.put(Context.PROVIDER_URL, url);
				//env.put(Context.SECURITY_AUTHENTICATION, "none");
				env.put(Context.SECURITY_AUTHENTICATION, "simple");
				env.put(Context.SECURITY_PRINCIPAL, "uid="+uid+", ou="+ou+", o="+o);
				env.put(Context.SECURITY_CREDENTIALS, pass);
				
				// this command will throw an exception if the password is incorrect
				DirContext ldapContext = new InitialDirContext(env);
				
				NamingEnumeration<SearchResult> results = ldapContext.search("o="+o, "(&(uid="+user+"))", searchCtrl);
				
				if (!results.hasMore()) // search failed
					throw new Exception();
				
				SearchResult sr = results.next();
				Attributes at = sr.getAttributes();
				cn = at.get("cn").toString().split(": ")[1];
				
				authenticated = "true";
				return true;
			} catch (NamingException e) {
				//System.out.println("search for username on ldap failed.");
			} catch (Exception e) {
				
			}
		}
		authenticated = "failed";
		
		return false;
	}
	
	public boolean search(String user) {
		
		if (ldapContextNone!=null) { // if the initial context was created fine
			try {
				NamingEnumeration<SearchResult> results = ldapContextNone.search("o="+o, "(&(uid="+user+"))", searchCtrl);
				
				if (!results.hasMore()) // search failed
					throw new Exception();
				
				SearchResult sr = results.next();
				Attributes at = sr.getAttributes();
				
				ou = ((sr.getName().split(","))[1].split("="))[1];
				uid = at.get("uid").toString().split(": ")[1];
				
				authenticated = "true";
				return true;
			} catch (NamingException e) {
				//System.out.println("search for username on ldap failed.");
			} catch (Exception e) {
				
			}
		}
		
		authenticated = "failed";
		
		return false;
	}
	
	public String getUID() {
		return uid;
	}
	
	public String getCN() {
		return cn;
	}
	
	public String getAuthenticated() {
		return authenticated;
	}
	
	public void resetAuthenticated() {
		authenticated = "false";
	}
	
	public boolean isLogout() {
		return logout;
	}
	
	public void setLogout(boolean l) {
		logout = l;
	}
}
