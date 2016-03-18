/**
 * Class for storing crawling information
 */
package com.my.webcrawler;

import java.util.HashMap;
import java.util.Map;

/**
 * @author AjayBaban
 *
 * @version 1.0
 */
public class CrawledPages 
{
	/** list for storing traversed web pages */
	private Map<String, Integer> listOfTraversedURL = new HashMap<String, Integer>();
	/** list for storing web pages which needs to be traversed */
	private Map<String, Integer> listOfURLNeedToTraverse = new HashMap<String, Integer>();
	/** depth reached by the crawler */
	private int depth;

	// //////////////// Constructors ////////////////////////////////
	/**
	 * Default constructor
	 */
	public CrawledPages() {
		super();
		this.depth = 1;
	}

	// //////////////// Setter and Getter methods ///////////////////
	/**
	 * @return the listOfTraversedURL
	 */
	public Map<String, Integer> getListOfTraversedURL() {
		return listOfTraversedURL;
	}

	/**
	 * @param listOfTraversedURL
	 *            the listOfTraversedURL to set
	 */
	public void setListOfTraversedURL(Map<String, Integer> listOfTraversedURL) {
		this.listOfTraversedURL = listOfTraversedURL;
	}

	/**
	 * @return the listOfURLNeedToTraverse
	 */
	public Map<String, Integer> getListOfURLNeedToTraverse() {
		return listOfURLNeedToTraverse;
	}

	/**
	 * @param listOfURLNeedToTraverse
	 *            the listOfURLNeedToTraverse to set
	 */
	public void setListOfURLNeedToTraverse(Map<String, Integer> listOfURLNeedToTraverse) {
		this.listOfURLNeedToTraverse = listOfURLNeedToTraverse;
	}

	/**
	 * @return the depth
	 */
	public int getDepth() {
		return depth;
	}

	/**
	 * @param depth
	 *            the depth to set
	 */
	public void setDepth(int depth) {
		this.depth = depth;
	}

}
