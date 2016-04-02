/**
 * 
 */
package com.easyair.view.actions;

import java.util.Map;

import org.apache.struts2.interceptor.SessionAware;

import com.easyair.controller.PaymentManager;
import com.easyair.model.beans.PaymentDataBean;
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
	PaymentDataBean payment = null;
	/** */
	PaymentManager paymentManager = null;
	
	/**
	 * 
	 */
	public PaymentAction() {
		payment = new PaymentDataBean();
		paymentManager = new PaymentManager();
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
		payment.setUser((UserBean) sessionMap.get(Constants.USER));
		paymentManager.storePaymentInfo(payment);
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
}
