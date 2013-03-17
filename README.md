fhttp v0.5
==========

Intro
----------

fhttp is an HTTP/HTTPS client built over Flash(AS3) Sockets. The purpose of this project is mainly educational and
maybe won't be suited for real-world projects for a time. Current project's state supports these features:
	
* OPTIONS, HEAD, GET, POST;
* HTTPS over SecureSocket API;
* redirection;
* persistent connection;
* pipeline;
* chunked;
* gzip;
* native MIME implementation(text, application, miltipart etc) - to be extended.

Features to be tested:
	
* PUT, DELETE, TRACE - currently these verb aren't available;
* Caching is working by default, supports Expires, Etag, Last-Modified, Cache-Control, only GET responses;
* proxy.
	
Features in progress:
	
* Strict specification compliance;
* CONNECT, PATCH;
* HTTP cookies contol;
* HTTP Auth;
* AIR support.
	
Details
----------

	
Examples
----------

Setup

	var 
	http:HTTPClient = new HTTPClient;
	http.addEventListener(HTTPClientEvent.COMPLETE, httpEventHandler, false, 0, false);
	http.addEventListener(HTTPClientEvent.ERROR,    httpEventHandler, false, 0, false);
	http.addEventListener(HTTPClientEvent.REDIRECT, httpEventHandler, false, 0, false);
	http.addEventListener(HTTPClientEvent.RETRY,    httpEventHandler, false, 0, false);
	
	private function httpEventHandler(event:HTTPClientEvent):void 
	{
		switch (event.type)
		{
			case HTTPClientEvent.COMPLETE:
			{
				var data:* = event.data.response.data;
				//var data:IMIMEObject = event.data.response.data;
				break;
			}
			
			case HTTPClientEvent.ERROR:
			{
				break;
			}
			
			case HTTPClientEvent.REDIRECT:
			{
				event.data.redirect();
				break;
			}
			
			case HTTPClientEvent.RETRY:
			{
				//event.data.retry();
				break;
			}
		}
	}

GET

	http.get('http://www.domain.com', 
	{
		    accept: 'text/html',
		user-agent: x-user-agent
	});
	
POST

	http.post('http://www.domain.com', null, 'some-date-string-or-bynary-data');
	
POST MIME

	http.post('http://www.domain.com', null, new MIMEText('plain', 'plain-text-here', 'utf-8'));

POST MIME multipart/*

	var 
	multipart:MIMEMultipart = new MIMEMultipart;	//default mixed
	multipart.add(new MIMEText('plain', 'plain-text-here', 'utf-8'));
	multipart.add(new MIMEText('html',  'plain-text-here', 'utf-8'));
	
	http.post('http://www.domain.com', null, multipart);
	

POST MIME multipart/form-data

	var 
	mformdata:MIMEMultipartFormData = new MIMEMultipartFormData;
	mformdata.add(new MIMEText('plain', 'field_name_value', 'utf-8'), { name: 'field_name' });
	mformdata.add(new MIMEText('plain', 'field_file_value', 'utf-8'), { name: 'field_file', filename: 'filename.txt' });
	// passing multipart to form data will interpreted as list of files in a single field.
	mformdata.add(multipart, { name: 'files', filenames: [ 'file1', 'file2' ] });
	
	http.post('http://www.domain.com', null, mformdata);