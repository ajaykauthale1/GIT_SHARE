/**
 * 
 */
package com.easyair.view.actions;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.apache.struts2.interceptor.SessionAware;

import com.easyair.controller.PaymentManager;
import com.easyair.controller.ScheduleManager;
import com.easyair.model.beans.BaggageDataBean;
import com.easyair.model.beans.OrderDataBean;
import com.easyair.model.beans.ScheduleDataBean;
import com.easyair.model.beans.TicketDataBean;
import com.easyair.utils.Constants;
import com.opensymphony.xwork2.ActionSupport;

/**
 * @author Ajay
 *
 */
public class OrderUpdateAction extends ActionSupport implements SessionAware {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	/** session map for user */
	private Map<String, Object> sessionMap;
	/** */
	private OrderDataBean order;
	/** */
	private TicketDataBean ticket;
	/** */
	private ScheduleDataBean schedule;
	/** */
	private List<BaggageDataBean> baggages = new ArrayList<BaggageDataBean>();
	/** */
	private PaymentManager mgr = new PaymentManager();
	/** */
	private ScheduleManager scheduleManager = new ScheduleManager();

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
		Long orderId = (Long) sessionMap.get(Constants.ORDER_TO_UPDATE);
		if (orderId == null) {
			return "success";
		}
		this.order = mgr.getOrder(orderId);
		if (this.order != null) {
			this.ticket = mgr.getTicket(order.getTicket());
			this.schedule = scheduleManager.getSchedule(ticket.getSchedule().getScheduleId());
			this.baggages.addAll(ticket.getBaggages());
		}
		if (this.baggages.isEmpty() || this.baggages.size() == 0) {
			BaggageDataBean baggage = new BaggageDataBean("40cm x 50cm x 25cm", "23kg/51lb", "cabin");
			this.baggages.add(baggage);
			baggage = new BaggageDataBean("80cm x 50cm x 40cm", "68kg/150lb", "luggage");
			this.baggages.add(baggage);
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
	public String update() {
		return "success";
	}

	/**
	 * 
	 * @return
	 */
	public String cancel() {
		Long orderId = (Long) sessionMap.get(Constants.ORDER_TO_UPDATE);
		String result = mgr.cancelOrder(orderId);
		if (StringUtils.equals("success", result)) {
			addActionMessage(getText("order.cancel.success"));
		} else {
			addActionError(getText("order.cancel.error"));
		}
		return init();
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
	 * @return the order
	 */
	public OrderDataBean getOrder() {
		return order;
	}

	/**
	 * @param order
	 *            the order to set
	 */
	public void setOrder(OrderDataBean order) {
		this.order = order;
	}

	/**
	 * @return the baggages
	 */
	public List<BaggageDataBean> getBaggages() {
		return baggages;
	}

	/**
	 * @param baggages
	 *            the baggages to set
	 */
	public void setBaggages(List<BaggageDataBean> baggages) {
		this.baggages = baggages;
	}
}
