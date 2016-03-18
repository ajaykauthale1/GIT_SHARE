/**
 * Interface which contains method signatures for web crawling
 */
package com.my.webcrawler;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.List;

/**
 * @author kauthale.a
 *
 * @version 1.0
 */
public interface CrawlerInterface 
{
	/**
	 * Method which returns list of urls on the given page
	 * 
	 * @param crawler: the crawler
	 * @return ist<URL>: list of URL's
	 * @throws IOException: throws exception when error occurs while reading the page
	 */
	public List<URL> listOfUrl(Crawler crawler)  throws IOException ;
	
	/**
	 * Method which returns the number of key phrase entries in the given page
	 * 
	 * @param crawler: the crawler
	 * @return int: count of key phrase entries
	 * @throws IOException: throws exception when error occurs while reading the page
	 */
	public int getNoOfKeyPhraseEntries(Crawler crawler) throws IOException ;
	
	/**
	 * Method to check if url is restricted or not
	 * 
	 * @param seed: the page to be crawled
	 * @return boolean: true if url is restricted 
	 * <p> 
	 * Url is restricted in following cases
	 *  If url is not starting with "http://en.wikipedia.org/wiki/". <br>
	 *  If url is wiki main page "http://en.wikipedia.org/wiki/Main_Page". <br>
	 *  If url contains ':' in url link between "https://en.wikipedia.org/w/index.php?title=Special:UserLogin&returnto=Main+Page&type=signup". <br>
	 */
	public boolean isRetrictedUrl(String seed);
	
	/**
	 * Method for crawling through web
	 * 
	 * @param crawler: the crawler 
	 * @param keyPhrase: key phrase for crawling
	 * @param pageInfo: the current page information which is being crawled
	 * @return CrawledPages: crawled pages
	 * @throws MalformedURLException: throws exception when error occurs while forming the url
	 */
	public CrawledPages crawlThroughWeb(Crawler crawler, String keyPhrase, CrawledPages pageInfo) throws MalformedURLException;
	
}
