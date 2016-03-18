/**
 * 
 */
package com.easyair.model.beans;

import java.io.Serializable;
import java.util.HashSet;
import java.util.Set;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.Table;

/**
 * @author Ajay
 *
 */
@Entity
@Table(name = "flight")
public class FlightDataBean implements Serializable {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	/** */
	private Long flightId;
	/** */
	private String flightNumber;
	/** */
	private int seatingCapacity;
	/** */
	private String source;
	/** */
	private String destination;
	/** */
	private Set<ScheduleDataBean> schedules = new HashSet<ScheduleDataBean>(0);
	/** */
	private AirlineDataBean airline;
	
	
	/**
	 * @return the flightId
	 */
	@Id
	@GeneratedValue
	@Column(name = "flight_id")
	public Long getFlightId() {
		return flightId;
	}
	/**
	 * @param flightId the flightId to set
	 */
	public void setFlightId(Long flightId) {
		this.flightId = flightId;
	}
	/**
	 * @return the flightNumber
	 */
	@Column(name = "flight_number", unique = true, nullable = false)
	public String getFlightNumber() {
		return flightNumber;
	}
	/**
	 * @param flightNumber the flightNumber to set
	 */
	public void setFlightNumber(String flightNumber) {
		this.flightNumber = flightNumber;
	}
	/**
	 * @return the seatingCapacity
	 */
	@Column(name = "seating_capacity")
	public int getSeatingCapacity() {
		return seatingCapacity;
	}
	/**
	 * @param seatingCapacity the seatingCapacity to set
	 */
	public void setSeatingCapacity(int seatingCapacity) {
		this.seatingCapacity = seatingCapacity;
	}
	/**
	 * @return the source
	 */
	@Column(name = "source", nullable = false)
	public String getSource() {
		return source;
	}
	/**
	 * @param source the source to set
	 */
	public void setSource(String source) {
		this.source = source;
	}
	/**
	 * @return the destination
	 */
	@Column(name = "destination", nullable = false)
	public String getDestination() {
		return destination;
	}
	/**
	 * @param destination the destination to set
	 */
	public void setDestination(String destination) {
		this.destination = destination;
	}
	/**
	 * @return the schedules
	 */
	@OneToMany(fetch = FetchType.EAGER, mappedBy = "flight")
	public Set<ScheduleDataBean> getSchedules() {
		return schedules;
	}
	/**
	 * @param schedules the schedules to set
	 */
	public void setSchedules(Set<ScheduleDataBean> schedules) {
		this.schedules = schedules;
	}
	/**
	 * @return the airline
	 */
	@JoinColumn(name = "airline_id")
    @ManyToOne(cascade = CascadeType.ALL,fetch = FetchType.LAZY)
	public AirlineDataBean getAirline() {
		return airline;
	}
	/**
	 * @param airline the airline to set
	 */
	public void setAirline(AirlineDataBean airline) {
		this.airline = airline;
	}
}
