/**
 * Class for invoking the web crawling by providing seed page and key phrase
 */
package com.my.webcrawler;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Iterator;
import java.util.Map;

/**
 * @author kauthale.a
 *
 * @version 1.0
 */
public class CrawlerInvoker {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		File result = new File("resources\\results\\Result.txt");
		FileOutputStream output = null;

		BufferedWriter writer = null;

		try {

			URL oracle = new URL(CrawlerConstants.SEED_START);
			//TODO need to add logger, but because of time limit added syso
			System.out.println("Crawling Started....");
			Crawler cw = new Crawler(oracle, "concordance");
			CrawledPages pageInfo = new CrawledPages();
			// crawl the seed page first
			cw.crawl();
			pageInfo.setDepth(1);
			pageInfo.getListOfTraversedURL().putAll(cw.getListOfTraversedURL());
			pageInfo.getListOfURLNeedToTraverse().putAll(cw.getListOfURLNeedToTraverse());
			// crawl remaining pages
			CrawlerInterface ci = new CrawlerImpl();
			pageInfo = ci.crawlThroughWeb(cw, "concordance", pageInfo);
			
			System.out.println("Crawling Finished....");
			// write the crawled web pages into the result.txt file
			result = new File("resources\\results\\Result.txt");

			if (output == null) {
				output = new FileOutputStream(result);
			}

			writer = new BufferedWriter(new OutputStreamWriter(output));
			writer.write("-----------------------------------------------------------------------------------------------------------------------------");
			writer.newLine();
			writer.write("VISITED URL: No of Entries of Key Phrase");
			writer.newLine();
			writer.write("-----------------------------------------------------------------------------------------------------------------------------");
			writer.newLine();
			
			Iterator it = pageInfo.getListOfTraversedURL().entrySet().iterator();
			while (it.hasNext()) {
				Map.Entry<String, Integer> urlEntry = (Map.Entry<String, Integer>) it.next();
				writer.write(urlEntry.getKey() + ": " + urlEntry.getValue());
				writer.newLine();
			}
			
			writer.write("-----------------------------------------------------------------------------------------------------------------------------");
			writer.close();
		} catch (MalformedURLException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

}
