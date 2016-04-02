/**
 * 
 */
package com.easyair.model.beans;

import java.io.Serializable;
import java.util.Date;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.OneToOne;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * @author Ajay
 *
 */
@Entity
@Table(name = "orders")
public class OrderDataBean implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	/** */
	private Long orderId;
	/** */
	private String orderNumber;
	/** */
	private Long ticket;
	/** */
	private Date lastUpdatedOn;
	/**
	 * @return the orderId
	 */
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "order_id")
	public Long getOrderId() {
		return orderId;
	}
	/**
	 * @param orderId the orderId to set
	 */
	public void setOrderId(Long orderId) {
		this.orderId = orderId;
	}
	/**
	 * @return the orderNumber
	 */
	@Column(name = "order_number", unique = true, nullable = false)
	public String getOrderNumber() {
		return orderNumber;
	}
	/**
	 * @param orderNumber the orderNumber to set
	 */
	public void setOrderNumber(String orderNumber) {
		this.orderNumber = orderNumber;
	}
	
	/**
	 * @return the ticket
	 */
	@Column(name = "ticket_id", unique = true, nullable = false)
	public Long getTicket() {
		return ticket;
	}
	/**
	 * @param ticket the ticket to set
	 */
	public void setTicket(Long ticket) {
		this.ticket = ticket;
	}
	/**
	 * @return the lastUpdatedOn
	 */
	@Temporal(TemporalType.DATE)
	@Column(name = "last_updated", nullable = false)
	public Date getLastUpdatedOn() {
		return lastUpdatedOn;
	}
	/**
	 * @param lastUpdatedOn the lastUpdatedOn to set
	 */
	public void setLastUpdatedOn(Date lastUpdatedOn) {
		this.lastUpdatedOn = lastUpdatedOn;
	}
}
