package ldap;

public class LDAPTester {
	
	public void main(String [] args) {
		LDAPAuthenticate ldap = new LDAPAuthenticate();
		ldap.search("capilkey", "h)rse!@#");
	}
}
