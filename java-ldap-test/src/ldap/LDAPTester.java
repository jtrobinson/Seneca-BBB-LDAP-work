package ldap;

import java.util.Scanner;

public class LDAPTester {
	
	public static void main(String [] args) {
		LDAPAuthenticate ldap = new LDAPAuthenticate();
		
		Scanner kbdIn = new Scanner(System.in);
		System.out.print("Enter username: ");
		String username = kbdIn.nextLine();
		while (!username.equals("exit")) {
			ldap.search(username);
			
			if (ldap.getAuthenticated())
				System.out.println(ldap.getTitle());
			else
				System.out.println("Username not found");
			
			System.out.print("Enter username: ");
			username = kbdIn.nextLine();
		};
	}
}
