/**
 * 
 */
package com.easyair.view.actions;

import java.util.Map;

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
		return "print_ticket";
	}
	
	/**
	 * @return the user
	 */
	public UserBean getUser() {
		return user;
	}

	/**
	 * @param user the user to set
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
	 * @param payment the payment to set
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
	 * @param paymentManager the paymentManager to set
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
	 * @param schedule the schedule to set
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
	 * @param mgr the mgr to set
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
	 * @param ticket the ticket to set
	 */
	public void setTicket(TicketDataBean ticket) {
		this.ticket = ticket;
	}
}
