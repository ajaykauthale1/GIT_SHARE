/**
 * 
 */
package com.easyair.view.actions;

import java.util.Date;
import java.util.Map;
import java.util.Properties;

import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

import org.apache.struts2.interceptor.SessionAware;

import com.easyair.controller.PaymentManager;
import com.easyair.controller.ScheduleManager;
import com.easyair.model.beans.PaymentDataBean;
import com.easyair.model.beans.ScheduleDataBean;
import com.easyair.model.beans.TicketDataBean;
import com.easyair.model.beans.UserBean;
import com.easyair.utils.Constants;
import com.opensymphony.xwork2.ActionSupport;

/**
 * @author Ajay
 *
 */
public class PaymentAction extends ActionSupport implements SessionAware {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	/** session map for user */
	private Map<String, Object> sessionMap;
	/** */
	private UserBean user = null;
	/** */
	private PaymentDataBean payment = null;
	/** */
	private PaymentManager paymentManager = null;
	/** */
	private ScheduleDataBean schedule = null;
	/** */
	private ScheduleManager mgr = null;
	/** */
	private TicketDataBean ticket = null;

	/**
	 * 
	 */
	public PaymentAction() {
		payment = new PaymentDataBean();
		paymentManager = new PaymentManager();
		mgr = new ScheduleManager();
	}

	@Override
	/**
	 * set session map
	 */
	public void setSession(Map sessionMap) {
		this.sessionMap = sessionMap;
	}

	public String init() {
		user = (UserBean) sessionMap.get(Constants.USER);
		setPayment(paymentManager.getPaymentInfo(user.getUserId()));
		return "success";
	}

	public String purchase() {
		user = (UserBean) sessionMap.get(Constants.USER);
		payment.setUser(user);
		paymentManager.storePaymentInfo(payment);
		Long scheduleId = (Long) sessionMap.get(Constants.BOOK_FORWARD);
		schedule = mgr.getSchedule(scheduleId);
		ticket = paymentManager.getTicket(user.getUserId(), scheduleId);
		sendEmail(user, schedule.getFlight().getSource(), schedule.getFlight().getDestination(),
				ticket.getTicketNumber(), schedule.getDepartureDate(), ticket.getSeatNo(), ticket.getPnrNumber());
		sessionMap.remove(Constants.BOOK_FORWARD);

		return "print_ticket";
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
	public String sendEmail(UserBean user, String from, String to, String ticketNo, Date departureDate, String seatNo,
			String pnr) {
		Properties props = new Properties();
		props.put("mail.smtp.auth", "true");
		props.put("mail.smtp.starttls.enable", "true");
		props.put("mail.smtp.host", "smtp.gmail.com");
		props.put("mail.smtp.port", "587");

		Authenticator auth = new GMailAuthenticator(getText("email.username"), getText("email.password"));
		Session session = Session.getInstance(props, auth);
		String msgBody = "Dear " + user.getFirstname() + ",";
		msgBody += "\n\n\tTicket Number: " + ticketNo;
		msgBody += "\n\tFrom: " + from + " To: " + to;
		msgBody += "\n\tDeparture Date: " + departureDate;
		msgBody += "\n\tSeat No: " + seatNo + " PNR: " + pnr;
		msgBody += "\n\tHAPPY JOURNY.";
		msgBody += "\n\n\t You can visit EasyAir for further information.";
		msgBody += "\n\n\nRegards," + "\nEasyAir Team.";

		try {
			Message msg = new MimeMessage(session);
			msg.setFrom(new InternetAddress("kauthaleajay40@gmail.com", "EasyAir"));
			msg.addRecipients(Message.RecipientType.TO, InternetAddress.parse(user.getEmail()));
			msg.setSubject("EasyAir Ticket Details: Form " + from + " to " + to);
			msg.setText(msgBody);
			Transport.send(msg);

		} catch (Exception e) {
			e.printStackTrace();
		}
		return "success";
	}

	/**
	 * @return the user
	 */
	public UserBean getUser() {
		return user;
	}

	/**
	 * @param user
	 *            the user to set
	 */
	public void setUser(UserBean user) {
		this.user = user;
	}

	/**
	 * @return the payment
	 */
	public PaymentDataBean getPayment() {
		return payment;
	}

	/**
	 * @param payment
	 *            the payment to set
	 */
	public void setPayment(PaymentDataBean payment) {
		this.payment = payment;
	}

	/**
	 * @return the paymentManager
	 */
	public PaymentManager getPaymentManager() {
		return paymentManager;
	}

	/**
	 * @param paymentManager
	 *            the paymentManager to set
	 */
	public void setPaymentManager(PaymentManager paymentManager) {
		this.paymentManager = paymentManager;
	}

	/**
	 * @return the schedule
	 */
	public ScheduleDataBean getSchedule() {
		return schedule;
	}

	/**
	 * @param schedule
	 *            the schedule to set
	 */
	public void setSchedule(ScheduleDataBean schedule) {
		this.schedule = schedule;
	}

	/**
	 * @return the mgr
	 */
	public ScheduleManager getMgr() {
		return mgr;
	}

	/**
	 * @param mgr
	 *            the mgr to set
	 */
	public void setMgr(ScheduleManager mgr) {
		this.mgr = mgr;
	}

	/**
	 * @return the serialversionuid
	 */
	public static long getSerialversionuid() {
		return serialVersionUID;
	}

	/**
	 * @return the ticket
	 */
	public TicketDataBean getTicket() {
		return ticket;
	}

	/**
	 * @param ticket
	 *            the ticket to set
	 */
	public void setTicket(TicketDataBean ticket) {
		this.ticket = ticket;
	}
}
