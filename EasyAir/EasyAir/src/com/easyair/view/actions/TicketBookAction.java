/**
 * 
 */
package com.easyair.view.actions;

import java.util.Map;

import org.apache.struts2.interceptor.SessionAware;

import com.easyair.controller.PaymentManager;
import com.easyair.controller.ScheduleManager;
import com.easyair.model.beans.ScheduleDataBean;
import com.easyair.model.beans.TicketDataBean;
import com.easyair.model.beans.UserBean;
import com.easyair.utils.Constants;
import com.opensymphony.xwork2.ActionSupport;

/**
 * @author Ajay
 *
 */
public class TicketBookAction extends ActionSupport implements SessionAware {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	/** session map for user */
	private Map<String, Object> sessionMap;
	/** List of all schedules */
	private ScheduleDataBean schedule;
	/** */
	ScheduleManager mgr = new ScheduleManager();
	/** */
	PaymentManager paymentManager = new PaymentManager();
	
	@Override
	/**
	 * set session map
	 */
	public void setSession(Map sessionMap) {
		this.sessionMap = sessionMap;
	}
	
	/**
	 * 
	 * @return
	 */
	public String init() {
		Long scheduleId = (Long) sessionMap.get(Constants.BOOK_FORWARD);
		if (scheduleId == null) {
			addActionError(getText("error.book"));
			return "error";
		} 
		schedule = mgr.getSchedule(scheduleId); 
		return "success";
	}

	/**
	 * 
	 * @return
	 */
	public String confirm() {
		Long scheduleId = (Long) sessionMap.get(Constants.BOOK_FORWARD);
		schedule = mgr.getSchedule(scheduleId); 
		// store ticket info
		TicketDataBean ticket = new TicketDataBean();
		ticket.setUser((UserBean) sessionMap.get(Constants.USER));
		ticket.setSchedule(schedule);
		ticket.setPrice(schedule.getPrice());
		ticket.setBoardingTime(schedule.getDepartureDate());
		// Default is economy, user can further select the class at while doing payment
		ticket.setChosenClass("Economy");
		paymentManager.storeTicketInfo(ticket);
		
		return "confirm";
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
	
	
}
