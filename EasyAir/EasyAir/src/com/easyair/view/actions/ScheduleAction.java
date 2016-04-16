/**
 * 
 */
package com.easyair.view.actions;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

import org.apache.commons.lang3.StringUtils;
import org.apache.struts2.interceptor.SessionAware;

import com.easyair.controller.ScheduleManager;
import com.easyair.dto.ScheduleDto;
import com.easyair.model.beans.UserBean;
import com.easyair.utils.Constants;
import com.opensymphony.xwork2.ActionSupport;

/**
 * @author Ajay
 *
 */
public class ScheduleAction extends ActionSupport implements SessionAware {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	/** */
	public String source;
	/** */
	public String destination;
	/** Departure date of flight */
	private Date departureDate;
	/** Departure time of flight */
	private double departureTime;
	/** Arrival date of flight */
	private Date arrivalDate;
	/** Arrival time of flight */
	private double arrivalTime;
	/** Total trip hours */
	private double tripHours;
	/** trip type */
	private String tripType;
	/** List of all schedules */
	private List<ScheduleDto> schedules = new ArrayList<ScheduleDto>();
	/** */
	private Long selectedSchedule;
	/** */
	ScheduleManager mgr = new ScheduleManager();
	/** session map for user */
	private Map<String, Object> sessionMap;
	
	/**
	 * 
	 * @return
	 */
	public String init() {
		return "success";
	}
	
	/**
	 * 
	 * @return
	 */
	public String bookTicket() {
		sessionMap.put(Constants.BOOK_FORWARD, selectedSchedule);
		if (sessionMap.get(Constants.USER) == null) {
			return "login";
		} else {
			return "book";
		}
	}
	
	/**
	 * 
	 * @return
	 */
	public String updateSchedule() {
		ScheduleDto updateSchedule = null;
		for (ScheduleDto schedule : schedules) {
			if (schedule.getScheduleId().equals(this.selectedSchedule))
			{
				updateSchedule = schedule;
				break;
			}
		}
		String msg = mgr.updateSchedule(updateSchedule);
		if (StringUtils.equals("success", msg)) {
			addActionMessage(getText("schedule.update.success"));
		} else {
			addActionError(getText("schedule.update.error"));
		}
		return search();
	}
	
	/**
	 * 
	 * @return
	 */
	public String deleteSchedule() {
		ScheduleDto scheduleToDelete = null;
		for (ScheduleDto schedule : schedules) {
			if (schedule.getScheduleId().equals(this.selectedSchedule))
			{
				scheduleToDelete = schedule;
				break;
			}
		}
		Set<UserBean> users = mgr.deleteSchedule(scheduleToDelete);
		//sendEmail(users);
		
		addActionMessage(getText("schedule.delete.success"));
		return search();
	}
	
	/**
	 * 
	 * @param from
	 * @param to
	 * @param ticketNo
	 * @param departureDate
	 * @param seatNo
	 * @param pnr
	 */
	public String sendEmail(Set<UserBean> users) {
		Properties props = new Properties();
		props.put("mail.smtp.auth", "true");
		props.put("mail.smtp.starttls.enable", "true");
		props.put("mail.smtp.host", "smtp.gmail.com");
		props.put("mail.smtp.port", "587");

		Authenticator auth = new GMailAuthenticator(getText("email.username"), getText("email.password"));
		Session session = Session.getInstance(props, auth);
		String msgBody = "Dear Subscriber,";
		msgBody += "\n\n\tYour ticket has been cancelled by the Admin.";
		msgBody += "\n\n\t You can visit EasyAir for further information.";
		msgBody += "\n\n\nRegards," + "\nEasyAir Team.";

		try {
			Message msg = new MimeMessage(session);
			msg.setFrom(new InternetAddress("kauthaleajay40@gmail.com", "EasyAir"));
			for (UserBean user : users) {
				msg.addRecipient(Message.RecipientType.TO, new InternetAddress(user.getEmail()));
			}
			msg.setSubject("EasyAir Ticket Cancellation Alert!!!");
			msg.setText(msgBody);
			Transport.send(msg);

		} catch (Exception e) {
			e.printStackTrace();
		}
		return "success";
	}
	
	/**
	 * 
	 * @return
	 */
	public String addSchedule() {
		return "addNew";
	}
	
	/**
	 * 
	 */
	public void resetDateFormat() {
		SimpleDateFormat sdf = new SimpleDateFormat("MM-dd-yyyy");
		
		try {
			if (this.departureDate != null) {
				this.setDepartureDate(sdf.parse(sdf.format(this.departureDate)));
			}
			if (this.arrivalDate != null) {
				this.setArrivalDate(sdf.parse(sdf.format(this.arrivalDate)));
			}
		} catch (ParseException e) {
			e.printStackTrace();
		}
	}
	
	/**
	 * 
	 * @return
	 */
	public String search() {
		String source = this.source.substring(this.source.indexOf("-")+2);
		String destination = this.destination.substring(this.destination.indexOf("-")+2);
		this.schedules = mgr.getSchedules(source, destination, this.departureDate);
		resetDateFormat();
		return "success";
	}
	
	/**
	 * 
	 * @return
	 */
	public String getAllSchedules() {
		//this.schedules = mgr.getSchedules(this.source, this.destination);
		return "success";
	}
	
	/**
	 * 
	 * @return
	 */
	public String addNewSchedule() {
		return null;
	}
	
	/**
	 * @return the departureDate
	 */
	public Date getDepartureDate() {
		return departureDate;
	}
	/**
	 * @param departureDate the departureDate to set
	 */
	public void setDepartureDate(Date departureDate) {
		this.departureDate = departureDate;
	}
	/**
	 * @return the departureTime
	 */
	public double getDepartureTime() {
		return departureTime;
	}
	/**
	 * @param departureTime the departureTime to set
	 */
	public void setDepartureTime(double departureTime) {
		this.departureTime = departureTime;
	}
	/**
	 * @return the arrivalDate
	 */
	public Date getArrivalDate() {
		return arrivalDate;
	}
	/**
	 * @param arrivalDate the arrivalDate to set
	 */
	public void setArrivalDate(Date arrivalDate) {
		this.arrivalDate = arrivalDate;
	}
	/**
	 * @return the arrivalTime
	 */
	public double getArrivalTime() {
		return arrivalTime;
	}
	/**
	 * @param arrivalTime the arrivalTime to set
	 */
	public void setArrivalTime(double arrivalTime) {
		this.arrivalTime = arrivalTime;
	}
	/**
	 * @return the tripHours
	 */
	public double getTripHours() {
		return tripHours;
	}
	/**
	 * @param tripHours the tripHours to set
	 */
	public void setTripHours(double tripHours) {
		this.tripHours = tripHours;
	}

	/**
	 * @return the schedules
	 */
	public List<ScheduleDto> getSchedules() {
		return schedules;
	}

	/**
	 * @param schedules the schedules to set
	 */
	public void setSchedules(List<ScheduleDto> schedules) {
		this.schedules = schedules;
	}


	/**
	 * @return the source
	 */
	public String getSource() {
		return source;
	}


	/**
	 * @param source the source to set
	 */
	public void setSource(String source) {
		this.source = source;
	}


	/**
	 * @return the destination
	 */
	public String getDestination() {
		return destination;
	}


	/**
	 * @param destination the destination to set
	 */
	public void setDestination(String destination) {
		this.destination = destination;
	}


	/**
	 * @return the tripType
	 */
	public String getTripType() {
		return tripType;
	}


	/**
	 * @param tripType the tripType to set
	 */
	public void setTripType(String tripType) {
		this.tripType = tripType;
	}


	/**
	 * @return the selectedSchedule
	 */
	public Long getSelectedSchedule() {
		return selectedSchedule;
	}


	/**
	 * @param selectedSchedule the selectedSchedule to set
	 */
	public void setSelectedSchedule(Long selectedSchedule) {
		this.selectedSchedule = selectedSchedule;
	}
	
	@Override
	/**
	 * set session map
	 */
	public void setSession(Map sessionMap) {
		this.sessionMap = sessionMap;
	}
}
