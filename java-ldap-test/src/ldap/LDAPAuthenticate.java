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
	private String username;
	private boolean authenticated;
	private Hashtable<Object, Object> env;
	private DirContext ldapContext;
	private SearchControls searchCtrl; 
	private String o;
	private String title;
	private String ou;
	
	public LDAPAuthenticate() {
		String url = "";
		String security = "";
		
		try {
			//Using factory get an instance of document builder
			DocumentBuilder db = DocumentBuilderFactory.newInstance().newDocumentBuilder();
			//parse using builder to get DOM representation of the XML file
			//Document dom = db.parse("WEB-INF/config.xml");
			Document dom = db.parse(Thread.currentThread().getContextClassLoader().getResourceAsStream("config.xml"));
			//get the root element
			Element docEle = dom.getDocumentElement();
			
			NodeList ldapConfig = docEle.getElementsByTagName("ldap").item(0).getChildNodes();
			for (int i=0; i<ldapConfig.getLength(); i++) {
				if (ldapConfig.item(i).getNodeName().equals("url")) {
					url = ldapConfig.item(i).getFirstChild().getNodeValue();
				} else if (ldapConfig.item(i).getNodeName().equals("security-authentication")) {
					security = ldapConfig.item(i).getFirstChild().getNodeValue();
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

		

		
		env = new Hashtable<Object, Object>();
		env.put(Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.ldap.LdapCtxFactory");
		
		// specify where the ldap server is running
		env.put(Context.PROVIDER_URL, url);
		env.put(Context.SECURITY_AUTHENTICATION, security);
		
		// Create the initial directory context
		try {
			ldapContext = new InitialDirContext(env);
		} catch (NamingException e) {
			System.out.println("LDAP server not found");
		}
		
		searchCtrl = new SearchControls();
		searchCtrl.setSearchScope(SearchControls.SUBTREE_SCOPE);
		
		username = "";
		authenticated = false;
	}
	
	public boolean search(String u) {
		username = u;
		u = "(&(uid="+u+"))"; // format the username
		username = o;
		try {
			NamingEnumeration<SearchResult> results = ldapContext.search("o="+o, u, searchCtrl);
			
			if (!results.hasMore()) // search failed
				throw new Exception();
			
			SearchResult sr = results.next();
			
			Attributes at = sr.getAttributes();
			
			ou = ((sr.getName().split(","))[1].split("="))[1]; // grab the ou (either Student or Employee)
			
			if (ou.equals("Employee"))
				title = (String) at.get("title").get(0);
			else
				title = ou;
				
			
			/*NamingEnumeration<String> ids = at.getIDs(); // outputs all the possible attribute names
			while (ids.hasMore()) {
				System.out.println(ids.next());
			}*/
			
			authenticated = true;
			return true;
		} catch (NamingException e) {
			//System.out.println("search for username on ldap failed.");
		} catch (Exception e) {
			
		}
		
		authenticated = false;
		
		return false;
	}
	
	public String getUserName() {
		return username;
	}
	
	public boolean getAuthenticated() {
		return authenticated;
	}
	
	public String getTitle() {
		return title;
	}
}
