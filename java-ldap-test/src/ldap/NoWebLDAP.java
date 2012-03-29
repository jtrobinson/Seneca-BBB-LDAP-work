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

public class NoWebLDAP {
	private String username;
	private boolean authenticated;
	private Hashtable<Object, Object> env;
	private DirContext ldapContext;
	private SearchControls searchCtrl; 
	private String o = "sene.ca";
	private String title;
	private String ou;
	
	public NoWebLDAP() {
		String url = "ldap://dssy.senecac.on.ca/";
		String security = "simple";
		
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
		*/
		

		
		env = new Hashtable<Object, Object>();
		env.put(Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.ldap.LdapCtxFactory");
		
		// specify where the ldap server is running
		env.put(Context.PROVIDER_URL, url);
		//env.put(Context.SECURITY_AUTHENTICATION, "none");
		env.put(Context.SECURITY_AUTHENTICATION, "simple");
		env.put(Context.SECURITY_PRINCIPAL, "uid=capilkey, ou=Student, o="+o);
		env.put(Context.SECURITY_CREDENTIALS, passwordgoeshere);
		// Create the initial directory context
		try {
			ldapContext = new InitialDirContext(env);
		} catch (NamingException e) {
			System.out.println("LDAP server not found");
			e.printStackTrace();
		}
		
		searchCtrl = new SearchControls();
		searchCtrl.setSearchScope(SearchControls.SUBTREE_SCOPE);
		
		username = "";
		authenticated = false;
	}
	
	public boolean search(String u) {
		username = u;
		//u = "(&(objectClass=person))"; // format the username
		String filter = "(&(uid=capilkey))";
		try {
			NamingEnumeration<SearchResult> results = ldapContext.search("o="+o, filter, searchCtrl);

			if (!results.hasMore()) // search failed
				throw new Exception();
			
			
			while(results.hasMore()) {
				SearchResult sr = results.next();
				Attributes at = sr.getAttributes();
				System.out.println(sr.getName());
				NamingEnumeration<String> ids = at.getIDs(); // outputs all the possible attribute names
				while (ids.hasMore()) {
					String id = ids.next();
					System.out.println(at.get(id));
				}
				System.out.println("**************************");
			}
			//ou = ((sr.getName().split(","))[1].split("="))[1]; // grab the ou (either Student or Employee)
			
			/*if (ou.equals("Employee"))
				title = (String) at.get("title").get(0);
			else
				title = ou;*/
				
			
			
			
			authenticated = true;
			return true;
		} catch (NamingException e) {
			System.out.println("search for username on ldap failed.");
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
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
