/**
 * Interface for global constants
 */
package com.my.webcrawler;

/**
 * @author kauthale.a
 *
 * @version 1.0
 */
public interface CrawlerConstants 
{
	/** Constant for checking the whether seed page is wiki page or not */
	public static String SEED_PREFIX = "https://en.wikipedia.org/wiki/";
	/** Constant for checking the whether seed page is relative wiki page or not */
	public static String RELATIVE_SEED_PREFIX = "/wiki/";
	/** Constant for avoiding the wiki main page */
	public static String SEED_AVOID = "https://en.wikipedia.org/Main_Page";
	/** Constant for avoiding the relative wiki main page */
	public static String RELATIVE_SEED_AVOID = "/wiki/Main_Page";
	/** Constant for maximum crawling depth */
	public static int MAX_CRAWLING_DEPTH = 5;
	/** Constant for maximum no of pages to be crawled */
	public static int MAX_CRAWLING_URL = 1000;
	/** Constant for starting seed page */
	public static String SEED_START = "https://en.wikipedia.org/wiki/Hugh_of_Saint-Cher";
	/** Constant for delay in between two url requests */
	public static int REQUEST_DELAY = 1000;
}
