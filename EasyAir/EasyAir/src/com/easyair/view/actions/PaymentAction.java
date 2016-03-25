/**
 * 
 */
package com.easyair.view.actions;

import java.util.Map;

import org.apache.struts2.interceptor.SessionAware;

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
	UserBean user = null;
	/** */
	
	@Override
	/**
	 * set session map
	 */
	public void setSession(Map sessionMap) {
		this.sessionMap = sessionMap;
	}
	
	public String init() {
		user = (UserBean) sessionMap.get(Constants.USER);
		return "success";
	}

	public String purchase() {
		
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
}
