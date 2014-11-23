#SkyScraper

SkyScraper is an advanced web scraping library for iOS written in Objective-C.  It is specifically designed to allow HTML document parsing and conversion into JSON model representation (and then further into the application objects).  The mapping of the specific parts of HTML document to JSON model representation is defined by the end user in XSLT 1.0 langugage.

The library is an [XSLT](https://en.wikipedia.org/wiki/XSLT) 1.0 processor based on [libxslt](http://xmlsoft.org/libxslt/) (primarily by Daniel Veillard) with some built-in [EXSLT](http://exslt.org) extensions - shipping within [libexslt](http://www.xmlsoft.org/XSLT/EXSLT/index.html) as part of libxslt, and an external [regexp extension](http://exslt.org/regexp/index.html) by Joel W. Reed.


## GENERAL IDEA

The idea of web scraping is to acquire data from HTML documents that are hosted on the web.  It can be done in various ways - most of which are based on  (SAX, DOM) parsing of HTML and then extracting the needed data from HTML elements for corresponding fields of application-specific data models.
For iOS usually it is done within the application code - thus hardcoding the parsing logic and mixing it into the application logic.
The classical approach makes it hard to modify the parsing logic independently and hard to automate and generalize conversion into the application data models.
Instead SkyScraper abstracts the HTML-parsing and data-extraction logic by use of XSLT files that are separate from the application code, and define the conversion of HTML into JSON, which contains the extracted pieces of data to be then easily deserialized into application-specific data objects (using such frameworks as f.e. [Mantle](https://github.com/Mantle/Mantle))

So the basic scheme is like this:  HTML -> SkyXSLTransformation -> JSON -> ModelDeserializationFramework -> Model

(TODO: add a section on Rationale which justifies and supports this overall approach, although I think most advantages are obvious).

## HOW TO START

**1)** Prior to integrating into your own project - it is recommended to checkout and study the Tests project and Examples/CLSkyScraper project contained within this repository.  After cloning please cd into Tests and Examples/CLSkyScraper and run 

	pod install
	
within those directories, since the Pods are not under git for the Tests and Examples.  After the pods are installed open respectively:
	
	Tests.xcworkspace
	
and 
	
	CLSkyScraper.xcworkspace


**2)** The recommended way of integration into your own project is by using the [CocoaPods](http://cocoapods.org).  The Podspec is for now contained within this repository, so please add this into the Podfile:

	pod 'SkyScraper', :git => "git@github.com:justadreamer/SkyScraper.git"

This includes the additions for the AFNetworking and Mantle frameworks.  If you don't use/want those, please use:

	pod 'SkyScraper/Base', :git => "git@github.com:justadreamer/SkyScraper.git"

This includes only the SkyXSLTransformation class. 

The spec will be moved into the main Specs repository eventually, but for now the library is in a very early development stage.

**3)**  To learn/train yourself in XSLT - again please study the Tests and Examples/CLSkyScraper projects - there are XSLT transformations defined within the application resources.  There are some useful tricks to be learned from these examples - f.e. modularization by utilizing XIncludes, text data sanitization to be used within JSON, URL concatenation, etc.  There are also quite a lot of resources on XSLT 1.0 on the web:

[https://en.wikipedia.org/wiki/XSLT](https://en.wikipedia.org/wiki/XSLT)

[http://www.w3.org/TR/xslt](http://www.w3.org/TR/xslt)

[http://www.w3schools.com/xsl/default.asp](http://www.w3schools.com/xsl/default.asp)


##Example of direct usage

Below is an example boilerplace code needed to apply an XSLT transformation and get a JSON from an HTML data.  We assume that you have got an HTML document represented with ```NSData *html``` object and have an XSLT transformation ```scraping.xsl``` in the application resources:

	NSBundle *bundle = [NSBundle bundleForClass:self.class];
	NSURL *XSLURL = [bundle URLForResource:@"scraping" withExtension:@"xsl"];
    SkyXSLTransformation *transformation = [[SkyXSLTransformation alloc] initWithXSLTURL:XSLURL];
    
	id result = [transformation JSONObjectFromHTMLData:html withParams:nil error:&error];
	NSLog(@"%@",result);
	


##Example usage with AFNetworking '~> 2'

Below is an example boilerplate code you need to download the HTML document and acquire the JSON representation of your application data models.  It is assumed that you have defined an ```NSURL *URL``` object pointing at target HTML document on the web.  It is also assumed that somewhere in the application resource bundle you have ```scraping.xsl``` file with the XSLT transformation to convert HTML into JSON.

		#import <SkyScraper/SkyScraper.h>
		//...
		
	    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
	    
	    NSURL *localXSLURL = [[NSBundle mainBundle] URLForResource:@"scraping" withExtension:@"xsl"];
	    
	    SkyXSLTransformation *transformation = [[SkyXSLTransformation alloc] initWithXSLTURL:localXSLURL];
	    
	    SkyHTMLResponseSerializer *serializer = [SkyHTMLResponseSerializer serializerWithXSLTransformation:transformation params:nil modelAdapter:nil];
	    
	    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	    operation.responseSerializer = serializer;

	    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
	        NSLog(@"%@",responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        	NSLog(@"%@",error);
        }];
    	
    	[operation start];
    	
    	
Here the transformation object has been utilized within the response serializer object, used by AFHTTPRequestOperation to deserialize the response.


##Example usage with AFNetworking '~> 2' and Mantle

The basic setup is all the same as in the previous example, the difference is only in that we instantiate and initialize a Mantle model adapter and pass it to the response serializer factory method.  The response serializer the will use the model adapter to deserialize the parsed JSON object into the application data object - an instance of Model.class.

		SkyMantleModelAdapter *modelAdapter = [[SkyMantleModelAdapter alloc] initWithModelClass:Model.class];
	    SkyHTMLResponseSerializer *serializer = [SkyHTMLResponseSerializer serializerWithXSLTransformation:transformation params:nil modelAdapter:modelAdapter];


##Library features

###1. Pluggability
The library has been designed with general goals of simplicity and extensibility in mind, yet with an emphasis of its highly specialized task - limited to a niche of converting HTML -> JSON -> model objects.  
Extensibility primarily deals with the ability to create model adapters that would work for different model frameworks - Mantle is just an example, but it is possible and easy to create adapters for Nimbus or JSONModel frameworks as well.
Also SkyXSLTransformation class does not care about your networking stack - you are not limited to using AFNetworking - it can be any other network framework. Thus the simple SkyXSLTransformation component is designed to be easily **pluggable** into any networking and/or model framework.

###2. Thread-safety
Instances of SkyXSLTransformation are immutable objects, they do not store any state during execution of the transform:... method and since they encapsulate only a runtime-compiled XSLT stylesheet, which in turn stays immutable - it guarantees thread safety.  

###3. Transformation reusability
This plays well together with thread-safety, however just to emphasize the feature once again: the same instance of SkyXSLTransformation once initialized can be used over and over again for processing the according HTML documents.  The parameters passed are specific for each use occasion - so every time you call -[SkyXSLTransformation transform:params:modelAdapter:] - you can pass different params dictionary.

###4. XSLT modularity support
The library supports both XInclude and <xsl:import>.  Please refer to the online documentation to understand the difference, as this gives a developer a great flexibility for extracting the reusable code into separate xslt documents.

###5. Independent XSLT development workflow
For developing and testing an XSLT against the HTML to be scraped - you don't have to create an iOS app.  The very same functionality that is contained within the SkyXSLTransformation is supported by ```xsltproc/xsltproc```(both binary and source are provided), which is compiled against the very same instance of ```libxslt``` and the same plugins (only regexp plugin for now).  Also to check that your XSLT transforms into a valid JSON (and also to pretty-print the output) - it is recommended to use jsonlint (can be installed using ```brew install jsonlint```).  So let's assume you have downloaded an html document.  The command you should employ to test how your XSLT doc applied to it works is this:

		$ xsltproc/xsltproc --html --xincludestyle --param param_name "'string_value'" stylesheet.xsl document.html | jsonlint

This uses the compiled version of xsltproc shipping within this repository, for the description of options execute
		
		xsltproc/xsltproc

So this workflow makes it possible to develop XSLT independently and then just use it within your app.  More importantly this makes it possible to create scraping unit-tests without the need to run them in simulator or even on the Mac.  You can just use xsltproc compiled for another OS and test the JSON obtained from a scraped HTML f.e. with Python nose test framework, or any other JUnit-like framework.  

This also separates the data layer from the iOS code and makes it reusable in the web-server or other mobile/desktop OS environment.  Read you can create the same XSLT to run on both iOS and Android (although for Android you'll need a different XSLT processor).

###6. Support for XSLT extensions
Currently there is a number of EXSLT extensions supported: including regexps extensions, which is compiled in separately from an opensource plugin implementation.  Here is a full list of modules supported:

		$ xsltproc/xsltproc --dumpextensions
		
		Registered XSLT Extensions
		
		Registered Extension Functions:
		{http://exslt.org/regular-expressions}replace
		{http://exslt.org/math}lowest
		{http://exslt.org/math}power
		{http://exslt.org/math}tan
		{http://exslt.org/math}atan
		{http://exslt.org/sets}has-same-node
		{http://exslt.org/strings}encode-uri
		{http://exslt.org/strings}decode-uri
		{http://exslt.org/strings}align
		{http://exslt.org/dates-and-times}duration
		{http://exslt.org/dates-and-times}week-in-month
		{http://exslt.org/math}max
		{http://exslt.org/math}sin
		{http://exslt.org/math}acos
		{http://exslt.org/sets}difference
		{http://exslt.org/sets}leading
		{http://exslt.org/dates-and-times}day-abbreviation
		{http://exslt.org/dates-and-times}difference
		{http://exslt.org/dates-and-times}second-in-minute
		{http://exslt.org/dates-and-times}seconds
		{http://exslt.org/math}abs
		{http://exslt.org/math}log
		{http://exslt.org/sets}distinct
		{http://exslt.org/dates-and-times}day-of-week-in-month
		{http://exslt.org/dates-and-times}month-name
		{http://exslt.org/dates-and-times}sum
		{http://exslt.org/dates-and-times}year
		{http://icl.com/saxon}line-number
		{http://exslt.org/math}random
		{http://exslt.org/dates-and-times}day-in-year
		{http://exslt.org/dates-and-times}day-name
		{http://exslt.org/dynamic}map
		{http://exslt.org/regular-expressions}match
		{http://exslt.org/math}cos
		{http://exslt.org/sets}intersection
		{http://exslt.org/strings}concat
		{http://exslt.org/dates-and-times}day-in-week
		{http://exslt.org/dates-and-times}hour-in-day
		{http://exslt.org/common}node-set
		{http://exslt.org/math}asin
		{http://exslt.org/sets}trailing
		{http://exslt.org/strings}split
		{http://exslt.org/dates-and-times}leap-year
		{http://icl.com/saxon}eval
		{http://icl.com/saxon}evaluate
		{http://icl.com/saxon}systemId
		{http://exslt.org/strings}replace
		{http://exslt.org/dates-and-times}add-duration
		{http://exslt.org/dates-and-times}time
		{http://icl.com/saxon}expression
		{http://exslt.org/regular-expressions}test
		{http://exslt.org/math}constant
		{http://exslt.org/math}sqrt
		{http://exslt.org/math}atan2
		{http://exslt.org/math}exp
		{http://exslt.org/strings}tokenize
		{http://exslt.org/dates-and-times}day-in-month
		{http://exslt.org/dates-and-times}minute-in-hour
		{http://exslt.org/dates-and-times}week-in-year
		{http://xmlsoft.org/XSLT/}test
		{http://exslt.org/dates-and-times}date
		{http://exslt.org/dates-and-times}month-in-year
		{http://exslt.org/common}object-type
		{http://exslt.org/math}min
		{http://exslt.org/math}highest
		{http://exslt.org/strings}padding
		{http://exslt.org/dates-and-times}add
		{http://exslt.org/dates-and-times}date-time
		{http://exslt.org/dates-and-times}month-abbreviation
		{http://exslt.org/dynamic}evaluate
		
		Registered Extension Elements:
		{http://exslt.org/functions}result
		{http://exslt.org/common}document
		{http://xmlsoft.org/XSLT/}test
		
		Registered Extension Modules:
		http://exslt.org/functions
		http://xmlsoft.org/XSLT/
		http://icl.com/saxon







