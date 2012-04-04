package ldap;

import java.util.ArrayList;
import org.apache.commons.lang.StringUtils;

public class Meeting 
{
	protected static char PROF_SYMBOL = '#';
	protected static char EMP_SYMBOL = '&';
	protected static char STUDENT_SYMBOL = '$';
	protected static char DELIMITER = '~';
	
	public String name;
	public String modPass;
	public String viewPass;
	public Boolean lecture;
	public Boolean allowGuests;
	public Boolean recordable;
	
	public Meeting (String components[]) 
	{
		name = components[0];
		modPass = components[1];
		viewPass = components[2];
		allowGuests = Boolean.parseBoolean(components[3]);
		recordable = Boolean.parseBoolean(components[4]);
		if (name.charAt(0) == PROF_SYMBOL)
			lecture = true;
		else 
			lecture = false;
		name = StringUtils.removeStart(name, String.valueOf(PROF_SYMBOL));
	}
	
	public Meeting (ArrayList otherMeeting) 
	{
		name = otherMeeting.get(0).toString();
		modPass = otherMeeting.get(1).toString();
		viewPass = otherMeeting.get(2).toString();
		lecture = (Boolean)otherMeeting.get(3);
		allowGuests = (Boolean)otherMeeting.get(4);
		recordable = (Boolean)otherMeeting.get(5);
	}
}
