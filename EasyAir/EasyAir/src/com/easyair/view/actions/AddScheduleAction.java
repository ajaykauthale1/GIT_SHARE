/**
 * 
 */
package com.easyair.view.actions;

import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.apache.struts2.interceptor.SessionAware;

import com.easyair.controller.ScheduleManager;
import com.easyair.model.beans.ScheduleDataBean;
import com.opensymphony.xwork2.ActionSupport;

/**
 * @author Ajay
 *
 */
public class AddScheduleAction extends ActionSupport implements SessionAware {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	/** session map for user */
	private Map<String, Object> sessionMap;
	/** */
	private ScheduleDataBean schedule =  new ScheduleDataBean();
	/** */
	private Map<Long, String> airlines;
	/** */
	ScheduleManager mgr = new ScheduleManager();
	/** */
	private double arrivalTime;
	
	public AddScheduleAction() {
		airlines = mgr.getAirlinesMap();
	}

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
		return "success";
	}
	
	public String addSchedule() {
		String result = mgr.addSchedule(schedule);
		if (StringUtils.equals("success", result)) {
			addActionMessage(getText("schedule.add.success"));
		} else {
			addActionMessage(getText("schedule.add.error"));
		}
		schedule = new ScheduleDataBean();
		return "success";
	}

	/**
	 * @return the schedule
	 */
	public ScheduleDataBean getSchedule() {
		airlines = mgr.getAirlinesMap();
		return schedule;
	}

	/**
	 * @param schedule the schedule to set
	 */
	public void setSchedule(ScheduleDataBean schedule) {
		this.schedule = schedule;
	}

	/**
	 * @return the airlines
	 */
	public Map<Long, String> getAirlines() {
		return airlines;
	}

	/**
	 * @param airlines the airlines to set
	 */
	public void setAirlines(Map<Long, String> airlines) {
		this.airlines = airlines;
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
}
