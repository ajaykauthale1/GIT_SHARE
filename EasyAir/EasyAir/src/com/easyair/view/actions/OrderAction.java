package com.easyair.view.actions;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.struts2.interceptor.SessionAware;

import com.easyair.controller.PaymentManager;
import com.easyair.controller.ScheduleManager;
import com.easyair.model.beans.OrderDataBean;
import com.easyair.model.beans.ScheduleDataBean;
import com.easyair.model.beans.TicketDataBean;
import com.easyair.model.beans.UserBean;
import com.easyair.utils.Constants;
import com.opensymphony.xwork2.ActionSupport;

public class OrderAction extends ActionSupport implements SessionAware {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	/** session map for user */
	private Map<String, Object> sessionMap;
	/** */
	private PaymentManager mgr = new PaymentManager();
	/** */
	private List<OrderDataBean> orders = new ArrayList<OrderDataBean>();
	/** */
	private Long selectedOrderId;	
	/** */
	private Long selectedTicketId;
	/** */
	private ScheduleDataBean schedule;
	/** */
	private UserBean user;
	/** */
	private TicketDataBean ticket;

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
		UserBean user = (UserBean) sessionMap.get(Constants.USER);
		if (user != null) {
			List<TicketDataBean> tickets = mgr.getTickets(user.getUserId());
			Set<Long> ticketIds = new HashSet<>();
			for (TicketDataBean ticket : tickets) {
				ticketIds.add(ticket.getTicketId());
			}
			if (!ticketIds.isEmpty()) {
				this.orders = mgr.getOrders(ticketIds);
			}
		}
		return "success";
	}
	
	/**
	 * 
	 * @return
	 */
	public String schedule() {
		return "schedule";
	}
	
	/**
	 * 
	 * @return
	 */
	public String orderUpdate() {
		sessionMap.put(Constants.ORDER_TO_UPDATE, this.selectedOrderId);
		return "orderUpdate";
	}
	
	/**
	 * 
	 * @return
	 */
	public String printTicket() {
		PaymentManager paymentManager = new PaymentManager();
		ScheduleManager scheduleManager = new ScheduleManager();
		ticket = paymentManager.getTicket(selectedTicketId);
		user = (UserBean) sessionMap.get(Constants.USER);
		if (ticket == null || user == null) {
			return "success";
		}
		schedule = scheduleManager.getSchedule(ticket.getSchedule().getScheduleId());
		return "printTicket";
	}

	/**
	 * @return the mgr
	 */
	public PaymentManager getMgr() {
		return mgr;
	}

	/**
	 * @param mgr the mgr to set
	 */
	public void setMgr(PaymentManager mgr) {
		this.mgr = mgr;
	}

	/**
	 * @return the orders
	 */
	public List<OrderDataBean> getOrders() {
		return orders;
	}

	/**
	 * @param orders the orders to set
	 */
	public void setOrders(List<OrderDataBean> orders) {
		this.orders = orders;
	}

	/**
	 * @return the selectedOrderId
	 */
	public Long getSelectedOrderId() {
		return selectedOrderId;
	}

	/**
	 * @param selectedOrderId the selectedOrderId to set
	 */
	public void setSelectedOrderId(Long selectedOrderId) {
		this.selectedOrderId = selectedOrderId;
	}

	/**
	 * @return the selectedTicketId
	 */
	public Long getSelectedTicketId() {
		return selectedTicketId;
	}

	/**
	 * @param selectedTicketId the selectedTicketId to set
	 */
	public void setSelectedTicketId(Long selectedTicketId) {
		this.selectedTicketId = selectedTicketId;
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
