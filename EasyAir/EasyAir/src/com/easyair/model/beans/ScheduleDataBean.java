/**
 * 
 */
package com.easyair.model.beans;

import java.io.Serializable;
import java.util.Date;
import java.util.Set;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * @author Ajay
 *
 */

@Entity
@Table(name = "schedule")
public class ScheduleDataBean implements Serializable {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/** */
	private Long scheduleId;
	/** */
	private Date departureDate;
	/** */
	private double departureTime;
	/** */
	private Date arrivalDate;
	/** */
	private double arrivalTime;
	/** */
	private double tripHours;
	/** */
	private double price;
	/** */
	private FlightDataBean flight;
	/** Tickets */
	private Set<TicketDataBean> tickets;

	/**
	 * @return the scheduleId
	 */
	@Id
	@GeneratedValue
	@Column(name = "schedule_id")
	public Long getScheduleId() {
		return scheduleId;
	}

	/**
	 * @param scheduleId
	 *            the scheduleId to set
	 */
	public void setScheduleId(Long scheduleId) {
		this.scheduleId = scheduleId;
	}

	/**
	 * @return the departureDate
	 */
	@Temporal(TemporalType.DATE)
	@Column(name = "departure_date")
	public Date getDepartureDate() {
		return departureDate;
	}

	/**
	 * @param departureDate
	 *            the departureDate to set
	 */
	public void setDepartureDate(Date departureDate) {
		this.departureDate = departureDate;
	}

	/**
	 * @return the departureTime
	 */
	@Column(name = "departure_time")
	public double getDepartureTime() {
		return departureTime;
	}

	/**
	 * @param departureTime
	 *            the departureTime to set
	 */
	public void setDepartureTime(double departureTime) {
		this.departureTime = departureTime;
	}

	/**
	 * @return the arrivalDate
	 */
	@Temporal(TemporalType.DATE)
	@Column(name = "arrival_date")
	public Date getArrivalDate() {
		return arrivalDate;
	}

	/**
	 * @param arrivalDate
	 *            the arrivalDate to set
	 */
	public void setArrivalDate(Date arrivalDate) {
		this.arrivalDate = arrivalDate;
	}

	/**
	 * @return the arrivalTime
	 */
	@Column(name = "arrival_time")
	public double getArrivalTime() {
		return arrivalTime;
	}

	/**
	 * @param arrivalTime
	 *            the arrivalTime to set
	 */
	public void setArrivalTime(double arrivalTime) {
		this.arrivalTime = arrivalTime;
	}

	/**
	 * @return the tripHours
	 */
	@Column(name = "trip_hours")
	public double getTripHours() {
		return tripHours;
	}

	/**
	 * @param tripHours
	 *            the tripHours to set
	 */
	public void setTripHours(double tripHours) {
		this.tripHours = tripHours;
	}

	/**
	 * @return the flight
	 */
	@ManyToOne(fetch = FetchType.EAGER)
	@JoinColumn(name = "flight_id")
	public FlightDataBean getFlight() {
		return flight;
	}

	/**
	 * @param flight
	 *            the flight to set
	 */
	public void setFlight(FlightDataBean flight) {
		this.flight = flight;
	}

	/**
	 * @return the price
	 */
	@Column(name = "price")
	public double getPrice() {
		return price;
	}

	/**
	 * @param price
	 *            the price to set
	 */
	public void setPrice(double price) {
		this.price = price;
	}

	/**
	 * @return the tickets
	 */
	@OneToMany(fetch = FetchType.LAZY, mappedBy = "schedule")
	public Set<TicketDataBean> getTickets() {
		return tickets;
	}

	/**
	 * @param tickets
	 *            the tickets to set
	 */
	public void setTickets(Set<TicketDataBean> tickets) {
		this.tickets = tickets;
	}
}
