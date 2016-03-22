/**
 * 
 */
package com.easyair.view.actions;

import java.util.Map;

import org.apache.struts2.interceptor.SessionAware;

import com.easyair.controller.ScheduleManager;
import com.easyair.model.beans.ScheduleDataBean;
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
