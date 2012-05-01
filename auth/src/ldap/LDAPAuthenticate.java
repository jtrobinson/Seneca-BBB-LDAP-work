package ldap;

import javax.naming.Context;
import javax.naming.NamingEnumeration;
import javax.naming.directory.Attribute;
import javax.naming.directory.Attributes;
import javax.naming.directory.InitialDirContext;
import javax.naming.directory.DirContext;
import javax.naming.directory.SearchControls;
import javax.naming.directory.SearchResult;
import javax.naming.NamingException;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.apache.commons.lang.StringUtils;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Hashtable;

public class LDAPAuthenticate {
	private String authenticated;
	private Hashtable<Object, Object> env;
	private DirContext ldapContextNone;
	private SearchControls searchCtrl;
	private String url;
	private String o;
	
	private String positionField;
	private String userIDField;
	private String givenNameField;
	private String titleField;
	
	private String position;
	private String userID;
	private String givenName;
	private String title;
	
	private String positionList[];
	private String titleList[];
	
	private Date lastAccess;
	private Integer timeoutTime;
	private String placeholder;
	private Integer accessLevel;
	private HashMap accessMap;
	
	private boolean logout;
	
	public LDAPAuthenticate() {
		authenticated = "false";
		logout = false;
		
		try {
			//Using factory get an instance of document builder
			DocumentBuilder db = DocumentBuilderFactory.newInstance().newDocumentBuilder();
			//parse using builder to get DOM representation of the XML file

			Document dom = db.parse(Thread.currentThread().getContextClassLoader().getResourceAsStream("config.xml"));
			//get the root element
			Element docEle = dom.getDocumentElement();
			
			NodeList miscConfig = docEle.getElementsByTagName("system").item(0).getChildNodes();
			for (int i=0; i<miscConfig.getLength(); i++) {
				if (miscConfig.item(i).getNodeName().equals("timeout")) {
					timeoutTime = Integer.decode(miscConfig.item(i).getFirstChild().getNodeValue());
				} else if (miscConfig.item(i).getNodeName().equals("placeholder")) {
					placeholder = miscConfig.item(i).getFirstChild().getNodeValue();
				}
			}
			
			NodeList ldapConfig = docEle.getElementsByTagName("ldap").item(0).getChildNodes();
			for (int i=0; i<ldapConfig.getLength(); i++) {
				if (ldapConfig.item(i).getNodeName().equals("url")) {
					url = ldapConfig.item(i).getFirstChild().getNodeValue();
				} else if (ldapConfig.item(i).getNodeName().equals("o")) {
					o = ldapConfig.item(i).getFirstChild().getNodeValue();
				}
			}
			
			// Now that LDAP connection elements have been pulled from the config, extract the fields we'll be looking in
			NodeList ldapFields = docEle.getElementsByTagName("ldapfields").item(0).getChildNodes();
			for (int i = 0; i < ldapFields.getLength(); i++) {
				Node fieldNode = ldapFields.item(i);
				if (fieldNode.getNodeName().equals("user_id")) {
					userIDField = fieldNode.getFirstChild().getNodeValue();
				} else if (fieldNode.getNodeName().equals("user_fullname")) {
					givenNameField = fieldNode.getFirstChild().getNodeValue();
				} else if (fieldNode.getNodeName().equals("user_position")) {
					positionField = fieldNode.getFirstChild().getNodeValue();
				} else if (fieldNode.getNodeName().equals("user_title")) {
					titleField = fieldNode.getFirstChild().getNodeValue();
				} 
			}
			
			// Generate a HashMap to chart access levels
			NodeList accessList = docEle.getElementsByTagName("access_levels").item(0).getChildNodes();
			// Outer for loop will only fire once, with only one <access_levels> tag
			for (int i = 0; i < accessList.getLength(); i++) {
				Node accessNode = accessList.item(i);
				if (accessNode.getNodeName().equals("level")){
					// Logic begins for processing <level> blocks
					NodeList levelInfo = accessNode.getChildNodes();
					System.out.println(levelInfo.getLength());
					// Inner for loop will fire for each <level> block
					for (int j = 0; j < levelInfo.getLength(); j++){
						Node levelNode = levelInfo.item(j);
						Integer levelN = Integer.decode(levelNode.getFirstChild().getNodeValue());
						String roleN = null;
						String titleN = null;
						// Logic begins for processing <position> blocks
						NodeList posList = levelNode.getChildNodes();
						for (int k = 0; k < posList.getLength(); k ++){
							Node posNode = posList.item(k);
							if (posNode.getNodeName().equals("position")) {
								// A level node can have many position nodes
								// Each position node will have one role_name node
								// Each position node can have many title nodes
								// The combination of role_name and title determine whether the user exists at that access level
							}
						}
					}
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
		
		if (authenticated.equals("true") && user.equals(userID)) {
			try {
				env = new Hashtable<Object, Object>();
				env.put(Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.ldap.LdapCtxFactory");
				
				// specify where the ldap server is running
				env.put(Context.PROVIDER_URL, url);
				env.put(Context.SECURITY_AUTHENTICATION, "simple");
				String userIDString = userIDField + "=" + userID;
				String positionString = positionField + "=" + position;
				env.put(Context.SECURITY_PRINCIPAL, userIDString + ", " + positionString + ", o="+o);
				env.put(Context.SECURITY_CREDENTIALS, pass);
				
				// this command will throw an exception if the password is incorrect
				DirContext ldapContext = new InitialDirContext(env);
				
				NamingEnumeration<SearchResult> results = ldapContext.search("o=" + o, "(&(" + userIDField + "=" + user + "))", searchCtrl);
				
				if (!results.hasMore()) // search failed
					throw new Exception();
				
				SearchResult sr = results.next();
				Attributes at = sr.getAttributes();
				givenName = at.get(givenNameField).toString().split(": ")[1];
				
				title = at.get(titleField).toString().split(": ")[1];
				
				//prints out all possible attributes
			//	for(NamingEnumeration i = at.getAll(); i.hasMore(); ) {
			//		System.out.println((Attribute) i.next());
			//	}
				
				authenticated = "true";
				calculateAccessLevel();
				return true;
			} catch (NamingException e) {} 
			  catch (Exception e) {}
		}
		authenticated = "failed";
		
		return false;
	}
	
	public boolean search(String user) {
		
		if (ldapContextNone!=null) { // if the initial context was created fine
			try {
				NamingEnumeration<SearchResult> results = ldapContextNone.search("o="+o, "(&(" + userIDField + "="+user+"))", searchCtrl);
				
				if (!results.hasMore()) // search failed
					throw new Exception();
				
				SearchResult sr = results.next();
				Attributes at = sr.getAttributes();
				
				position = ((sr.getName().split(","))[1].split("="))[1];
				userID = at.get(userIDField).toString().split(": ")[1];
				
				authenticated = "true";
				return true;
			} catch (NamingException e) {} 
			  catch (Exception e) {}
		}
		
		authenticated = "failed";
		
		return false;
	}
	
	private void calculateAccessLevel(){
		//Integer calc;
		//accessLevel = calc;
	}
	
	// Methods for getting the user's details as fetched by LDAP
	public String getUserID() {
		// getUID()
		return userID;
	}
	public String getGivenName() {
		//getCN()
		return givenName;
	}
	public String getTitle() {
		if (title.equals("")){
			title = placeholder;
		}
		return title;
	}
	public String getPosition() {
		//getOU()
		return position;
	}
	public int getAccessLevel(){
		return accessLevel;
	}
	// ----
	// Methods for other pages to get the fields to check within LDAP for details; for example, one organization stores the user ID under "uid" while another uses "ou"
	public String getUserIDField() {
		return userIDField;
	}
	public String getGivenNameField() {
		return givenNameField;
	}
	public String getTitleField() {
		return titleField;
	}
	public String getPositionField() {
		return positionField;
	}
	public String getPlaceholder() {
		return placeholder;
	}
	// ----
	// Methods for returning the lists of valid positions and titles which can use the system
	// Temporarily deactivated
	/*
	public String [] getTitleList() {
		return titleList;
	}
	public String [] getPositionList() {
		return positionList;
	}
	*/
	// ----
	public String getAuthenticated() {
		Date now = new Date();
		if (lastAccess != null) {
			if ((now.getTime() - lastAccess.getTime())/1000.0/60 > timeoutTime) {
				lastAccess = null;
				authenticated = "timeout";
			} else {
				lastAccess = now;
			}
		}
		return authenticated;
	}
	
	public void resetAuthenticated() {
		authenticated = "false";
	}
	
	public boolean isLogout() {
		return logout;
	}
	
	public void setLogout(boolean l) {
		if (true) reset();
		logout = l;
	}
	
	private void reset() {
		position = userID = givenName = title = null;
	}
}
