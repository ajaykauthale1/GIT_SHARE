package com.easyair.mapper;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Set;

import com.easyair.controller.ScheduleManager;
import com.easyair.dto.ScheduleDto;
import com.easyair.model.beans.AirlineDataBean;
import com.easyair.model.beans.FlightDataBean;
import com.easyair.model.beans.ScheduleDataBean;

public class scheduleMapper {

	/**
	 * 
	 * @param source
	 * @param destination
	 * @return
	 */
	public List<ScheduleDto> getScheduleDtoList(String source, String destination, Date departureDate) {
		List<ScheduleDto> schedules = new ArrayList<ScheduleDto>();
		ScheduleManager manager = new ScheduleManager();
		
	    List<FlightDataBean> flights = manager.getFlights(source, destination);
		
		for (FlightDataBean flight : flights) {
			
			Set<ScheduleDataBean> schedulesSet = manager.getFlightSchedules(flight.getFlightId());
			
			for (ScheduleDataBean schedule : schedulesSet) {
				if (departureDate.equals(schedule.getDepartureDate())) {
					ScheduleDto dto = new ScheduleDto();
					dto.setToDestination(manager.getAirport(destination));
					dto.setFromSource(manager.getAirport(source));
					dto.setFlightId(flight.getFlightId());
					dto.setPrice(schedule.getPrice());
					dto.setScheduleId(schedule.getScheduleId());
					dto.setTripHours(schedule.getTripHours());
					Long airlineId = flight.getAirline().getAirlineId();
					dto.setAirlineId(airlineId);
					dto.setAirlineName(manager.getAirlineName(airlineId));
					schedules.add(dto);
				}
			}
		}
		
		return schedules;
	}
	
	/**
	 * 
	 * @param dto
	 * @param bean
	 * @return
	 */
	public static ScheduleDataBean mapDtoToBean(ScheduleDto dto, ScheduleDataBean bean) {
		ScheduleManager mgr = new ScheduleManager();
		FlightDataBean flight = mgr.getFlight(dto.getFlightId());
		AirlineDataBean airline = mgr.getAirline(dto.getAirlineId());
		bean = mgr.getSchedule(dto.getScheduleId());
		
		flight.setSource(dto.getFromSource());
		flight.setDestination(dto.getToDestination());
		flight.setAirline(airline);
		bean.setFlight(flight);
		bean.setPrice(dto.getPrice());
		double prevTripHours = (bean.getArrivalTime() - bean.getDepartureTime());
		if (prevTripHours != dto.getTripHours()) {
			double diff = bean.getDepartureTime() + dto.getTripHours();
			if (diff >= 24) {
				if (diff % 24 != 0)
				{
					diff = diff % 24;
				} else {
					diff = 0;
				}
				
			}
			bean.setArrivalTime(diff);
		}
		bean.setTripHours(dto.getTripHours());
		return bean;
	}
}
