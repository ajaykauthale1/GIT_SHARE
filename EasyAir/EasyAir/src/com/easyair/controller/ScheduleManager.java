/**
 * 
 */
package com.easyair.controller;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.classic.Session;

import com.easyair.dto.ScheduleDto;
import com.easyair.mapper.ScheduleMapper;
import com.easyair.model.beans.AirlineDataBean;
import com.easyair.model.beans.FlightDataBean;
import com.easyair.model.beans.OrderDataBean;
import com.easyair.model.beans.ScheduleDataBean;
import com.easyair.model.beans.TicketDataBean;
import com.easyair.model.beans.UserBean;
import com.easyair.utils.HibernateUtil;

/**
 * @author Ajay
 *
 */
@SuppressWarnings("deprecation")
public class ScheduleManager extends HibernateUtil {

	/**
	 * 
	 * @return
	 */
	public Map<Long, String> getAirlinesMap() {
		Map<Long, String> airlines = new HashMap<Long, String>();
		Session session = HibernateUtil.getSessionFactory().getCurrentSession();
		session.beginTransaction();
		List<AirlineDataBean> airlineList = null;
		try {

			airlineList = (List<AirlineDataBean>) session.createQuery("from AirlineDataBean").list();

		} catch (HibernateException e) {
			e.printStackTrace();
			session.getTransaction().rollback();
		}
		session.getTransaction().commit();

		for (AirlineDataBean airline : airlineList) {
			airlines.put(airline.getAirlineId(), airline.getName());
		}
		return airlines;
	}

	/**
	 * 
	 * @return
	 */
	public List<FlightDataBean> getFlights() {

		Session session = HibernateUtil.getSessionFactory().getCurrentSession();
		session.beginTransaction();
		List<FlightDataBean> flights = null;
		try {

			flights = (List<FlightDataBean>) session.createQuery("from FlightDataBean").list();

		} catch (HibernateException e) {
			e.printStackTrace();
			session.getTransaction().rollback();
		}
		session.getTransaction().commit();
		return flights;
	}

	/**
	 * 
	 * @return
	 */
	public List<FlightDataBean> getFlights(String source, String destination) {

		Session session = HibernateUtil.getSessionFactory().getCurrentSession();
		session.beginTransaction();
		List<FlightDataBean> flights = null;
		try {
			String queryString = "from FlightDataBean where source = :source and destination = :destination";
			Query query = session.createQuery(queryString);
			query.setString("source", source);
			query.setString("destination", destination);
			flights = (List<FlightDataBean>) query.list();
		} catch (HibernateException e) {
			e.printStackTrace();
			session.getTransaction().rollback();
		}
		session.getTransaction().commit();
		return flights;
	}

	/**
	 * 
	 * @param flightId
	 * @return
	 */
	public Set<ScheduleDataBean> getFlightSchedules(Long flightId) {
		Set<ScheduleDataBean> schedules = new HashSet<>();
		Session session = HibernateUtil.getSessionFactory().getCurrentSession();
		session.beginTransaction();
		FlightDataBean flight = null;
		try {
			String queryString = "from FlightDataBean where flightId = :id";
			Query query = session.createQuery(queryString);
			query.setLong("id", flightId);
			flight = (FlightDataBean) query.uniqueResult();
		} catch (HibernateException e) {
			e.printStackTrace();
			session.getTransaction().rollback();
		}
		session.getTransaction().commit();
		return flight.getSchedules();
	}

	/**
	 * 
	 * @param flightId
	 * @return
	 */
	public FlightDataBean getFlight(Long flightId) {
		Session session = HibernateUtil.getSessionFactory().getCurrentSession();
		session.beginTransaction();
		FlightDataBean flight = null;
		try {
			String queryString = "from FlightDataBean where flightId = :id";
			Query query = session.createQuery(queryString);
			query.setLong("id", flightId);
			flight = (FlightDataBean) query.uniqueResult();
		} catch (HibernateException e) {
			e.printStackTrace();
			session.getTransaction().rollback();
		}
		session.getTransaction().commit();
		return flight;
	}

	/**
	 * 
	 * @param flightId
	 * @param source
	 * @param destination
	 * @return
	 */
	public FlightDataBean getFlight(Long airlineId, String source, String destination) {
		Session session = HibernateUtil.getSessionFactory().getCurrentSession();
		session.beginTransaction();
		FlightDataBean flight = null;
		try {
			String queryString = "from FlightDataBean where airline.airlineId = :airlineId and source = :source and "
					+ "destination = :destination";
			Query query = session.createQuery(queryString);
			query.setLong("airlineId", airlineId);
			query.setString("source", source);
			query.setString("destination", destination);
			flight = (FlightDataBean) query.uniqueResult();
		} catch (HibernateException e) {
			e.printStackTrace();
			session.getTransaction().rollback();
		}
		session.getTransaction().commit();
		return flight;
	}

	/**
	 * 
	 * @param airlineId
	 * @return
	 */
	public AirlineDataBean getAirline(Long airlineId) {
		Session session = HibernateUtil.getSessionFactory().getCurrentSession();
		session.beginTransaction();
		AirlineDataBean airline = null;
		try {
			String queryString = "from AirlineDataBean where airlineId = :id";
			Query query = session.createQuery(queryString);
			query.setLong("id", airlineId);
			airline = (AirlineDataBean) query.uniqueResult();
		} catch (HibernateException e) {
			e.printStackTrace();
			session.getTransaction().rollback();
		}
		session.getTransaction().commit();
		return airline;
	}

	/**
	 * 
	 * @param airlineId
	 * @return
	 */
	public String getAirlineName(Long airlineId) {
		Session session = HibernateUtil.getSessionFactory().getCurrentSession();
		session.beginTransaction();
		String airlineName = null;
		try {
			String queryString = "from AirlineDataBean where airlineId = :id";
			Query query = session.createQuery(queryString);
			query.setLong("id", airlineId);
			airlineName = ((AirlineDataBean) query.uniqueResult()).getName();
		} catch (HibernateException e) {
			e.printStackTrace();
			session.getTransaction().rollback();
		}
		session.getTransaction().commit();
		return airlineName;
	}

	/**
	 * 
	 * @param source
	 * @param destination
	 * @return
	 */
	public List<ScheduleDto> getSchedules(String source, String destination, Date departureDate) {
		ScheduleMapper mapper = new ScheduleMapper();
		return mapper.getScheduleDtoList(source, destination, departureDate);
	}

	/**
	 * 
	 * @param code
	 * @return
	 */
	public String getAirport(String code) {
		String airport = null;
		Session session = HibernateUtil.getSessionFactory().getCurrentSession();
		session.beginTransaction();
		Connection con = session.connection();
		try {
			PreparedStatement stmt = con.prepareStatement("select airport from airports where code=?");
			stmt.setString(1, code);

			ResultSet rs = stmt.executeQuery();
			if (rs.next()) {
				airport = code + " - " + rs.getString(1);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			session.getTransaction().commit();
		}
		return airport;
	}

	/**
	 * 
	 * @param scheduleId
	 * @return
	 */
	public ScheduleDataBean getSchedule(Long scheduleId) {
		Session session = HibernateUtil.getSessionFactory().getCurrentSession();
		ScheduleDataBean schedule = null;
		session.beginTransaction();
		session.flush();
		try {
			String queryString = "from ScheduleDataBean where scheduleId = :id";
			Query query = session.createQuery(queryString);
			query.setLong("id", scheduleId);
			schedule = (ScheduleDataBean) query.uniqueResult();
		} catch (Exception e) {
			e.printStackTrace();
			session.getTransaction().rollback();
		}
		session.getTransaction().commit();
		return schedule;
	}

	/**
	 * 
	 * @return
	 */
	public Long getNextFlightId() {
		Session session = HibernateUtil.getSessionFactory().getCurrentSession();
		Long id = new Long(1);
		session.beginTransaction();
		Connection con = session.connection();
		try {
			PreparedStatement stmt = con.prepareStatement("select max(flight_id) from flight");

			ResultSet rs = stmt.executeQuery();
			if (rs.next()) {
				Long max = rs.getLong(1);
				if (max != 0) {
					id = max + 1;
				}
			}

		} catch (Exception e) {
			e.printStackTrace();
			session.getTransaction().rollback();
		} finally {
			session.getTransaction().commit();
		}

		return id;
	}

	/**
	 * 
	 * @param dto
	 * @return
	 */
	public void saveFlight(FlightDataBean bean) {
		HibernateUtil.persist(bean);
	}

	/**
	 * 
	 * @param dto
	 * @return
	 */
	public String updateSchedule(ScheduleDto dto) {
		ScheduleDataBean bean = new ScheduleDataBean();
		bean = ScheduleMapper.mapDtoToBean(dto, bean);
		HibernateUtil.update(bean);
		return "success";
	}

	/**
	 * 
	 * @param dto
	 * @return
	 */
	public Set<UserBean> deleteSchedule(ScheduleDto dto) {
		PaymentManager mgr = new PaymentManager();
		Set<UserBean> users = new HashSet<UserBean>();
		ScheduleDataBean bean = getSchedule(dto.getScheduleId());
		if (bean == null) {
			return null;
		}
		for (TicketDataBean t : bean.getTickets()) {
			OrderDataBean order = mgr.getOrderForTicket(t.getTicketId());
			if (order != null) {
				HibernateUtil.delete(order);
			}
		}
		for (TicketDataBean t : bean.getTickets()) {
			users.add(t.getUser());
			HibernateUtil.delete(t);
		}
		HibernateUtil.delete(bean);
		return users;
	}

	/**
	 * 
	 * @param bean
	 * @return
	 */
	public String addSchedule(ScheduleDataBean bean) {
		String source = bean.getFlight().getSource();
		source = source.substring(source.indexOf("-")+2);
		String destination = bean.getFlight().getDestination();
		destination = destination.substring(destination.indexOf("-")+2);
		FlightDataBean flight = getFlight(bean.getFlight().getAirline().getAirlineId(), source, destination);
		if (flight == null) {
			flight = new FlightDataBean();
			AirlineDataBean airline = getAirline(bean.getFlight().getAirline().getAirlineId());
			flight.setSource(source);
			flight.setDestination(destination);
			Long flightId = getNextFlightId();
			flight.setFlightNumber(airline.getName().substring(0, 3).toUpperCase() + flightId);
			flight.setAirline(airline);
			flight.setSeatingCapacity(200);
			
			HibernateUtil.persist(flight);
			flight = getFlight(flightId);
		}
		
		bean.setFlight(flight);
		
		HibernateUtil.persist(bean);
		
		return "success";
	}
}
