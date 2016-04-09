/**
 * 
 */
package com.easyair.view.actions;

import java.util.Map;

import org.apache.struts2.interceptor.SessionAware;

import com.easyair.model.beans.FlightDataBean;
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
	ScheduleDataBean schedule =  new ScheduleDataBean();

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
	
}
