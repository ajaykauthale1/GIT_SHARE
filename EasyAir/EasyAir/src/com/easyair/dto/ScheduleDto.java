/**
 * 
 */
package com.easyair.dto;

/**
 * @author Ajay
 *
 */
public class ScheduleDto {
	private Long scheduleId;
	private Long flightId;
	private Long airlineId;
	private String airlineName;
	private String fromSource;
	private String toDestination;
	private double tripHours;
	private double price;
	/**
	 * @return the scheduleId
	 */
	public Long getScheduleId() {
		return scheduleId;
	}
	/**
	 * @param scheduleId the scheduleId to set
	 */
	public void setScheduleId(Long scheduleId) {
		this.scheduleId = scheduleId;
	}
	/**
	 * @return the flightId
	 */
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
	 * @return the airlineId
	 */
	public Long getAirlineId() {
		return airlineId;
	}
	/**
	 * @param airlineId the airlineId to set
	 */
	public void setAirlineId(Long airlineId) {
		this.airlineId = airlineId;
	}
	/**
	 * @return the airlineName
	 */
	public String getAirlineName() {
		return airlineName;
	}
	/**
	 * @param airlineName the airlineName to set
	 */
	public void setAirlineName(String airlineName) {
		this.airlineName = airlineName;
	}
	/**
	 * @return the fromSource
	 */
	public String getFromSource() {
		return fromSource;
	}
	/**
	 * @param fromSource the fromSource to set
	 */
	public void setFromSource(String fromSource) {
		this.fromSource = fromSource;
	}
	/**
	 * @return the toDestination
	 */
	public String getToDestination() {
		return toDestination;
	}
	/**
	 * @param toDestination the toDestination to set
	 */
	public void setToDestination(String toDestination) {
		this.toDestination = toDestination;
	}
	/**
	 * @return the tripHours
	 */
	public double getTripHours() {
		return tripHours;
	}
	/**
	 * @param tripHours the tripHours to set
	 */
	public void setTripHours(double tripHours) {
		this.tripHours = tripHours;
	}
	/**
	 * @return the price
	 */
	public double getPrice() {
		return price;
	}
	/**
	 * @param price the price to set
	 */
	public void setPrice(double price) {
		this.price = price;
	}
}
