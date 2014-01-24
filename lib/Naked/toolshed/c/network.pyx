#!/usr/bin/env python
# encoding: utf-8
# cython: profile=True

import sys
import requests
from Naked.settings import debug as DEBUG_FLAG

#------------------------------------------------------------------------------
#[ HTTP class]
#  handle HTTP requests
#  Uses the requests external library to handle HTTP requests and response object (available on PyPI)
#------------------------------------------------------------------------------
class HTTP():
    def __init__(self, url="", request_timeout=10):
        self.url = url
        self.request_timeout = request_timeout
        #------------------------------------------------------------------------------
        # HTTP response properties (assignment occurs with the HTTP request methods)
        #------------------------------------------------------------------------------
        self.res = None # assigned with the requests external library response object after a HTTP method call

    #------------------------------------------------------------------------------
    # [ get method ] (string) -
    #   HTTP GET request - returns text string
    #   returns data stream read from the URL (string)
    #   Default timeout = 10 s from class constructor
    #------------------------------------------------------------------------------
    def get(self):
        try:
            response = requests.get(self.url, timeout=self.request_timeout)
            self.res = response # assign the response object from requests to a property on the instance of HTTP class
            return response.text
        except Exception as e:
            if DEBUG_FLAG:
                sys.stderr.write("Naked Framework Error: Unable to perform GET request with the URL " + self.url + " using the get() method (Naked.toolshed.network.py)")
            raise e

    #------------------------------------------------------------------------------
    # [ get_data method ] (binary data)
    #   HTTP GET request, return binary data
    #   returns data stream with raw binary data
    #------------------------------------------------------------------------------
    def get_data(self):
        try:
            response = requests.get(self.url, timeout=self.request_timeout)
            self.res = response # assign the response object from requests to a property on the instance
            return response.content # return binary data instead of text (get() returns text)
        except Exception as e:
            if DEBUG_FLAG:
                sys.stderr.write("Naked Framework Error: Unable to perform GET request with the URL " + self.url + " using the get_data() method (Naked.toolshed.network.py)")
            raise e

    #------------------------------------------------------------------------------
    # [ get_bin_write_file method ] (boolean)
    #   open HTTP data stream with GET request, make file with the returned binary data
    #   file path is passed to the method by the developer
    #   set suppress_output to True if you want to suppress the d/l status information that is printed to the standard output stream
    #   return True on successful pull and write to disk
    #------------------------------------------------------------------------------
    def get_bin_write_file(self, filepath="", suppress_output = False, overwrite_existing = False):
        try:
            import os # used for os.fsync() method in the write
            # Confirm that the file does not exist and prevent overwrite if it does (unless developer indicates otherwise)
            if not overwrite_existing:
                from Naked.toolshed.system import file_exists
                if file_exists(filepath):
                    if not suppress_output:
                        print("Download aborted.  A local file with the requested filename exists on the path.")
                    return False
            if (filepath == "" and len(self.url) > 1):
                filepath = self.url.split('/')[-1] # use the filename from URL and working directory as default if not specified
            if not suppress_output:
                sys.stdout.write("Downloading file from " + self.url + "...")
                sys.stdout.flush()
            response = requests.get(self.url, timeout=self.request_timeout, stream=True)
            self.res = response
            with open(filepath, 'wb') as f: # write as binary data
                for chunk in response.iter_content(chunk_size=2048):
                    f.write(chunk)
                    f.flush()
                    os.fsync(f.fileno()) # flush all internal buffers to disk
            if not suppress_output:
                print(" ")
                print("Dowload complete.")
            return True # return True if successful write
        except Exception as e:
            if DEBUG_FLAG:
                sys.stderr.write("Naked Framework Error: Unable to perform GET request and write file with the URL " + self.url + " using the get_bin_write_file() method (Naked.toolshed.network.py)")
            raise e

    #------------------------------------------------------------------------------
    # [ get_txt_write_file method ] (boolean)
    #   open HTTP data stream with GET request, write file with utf-8 encoded text using returned text data
    #   file path is passed to the method by the developer (default is the base filename in the URL if not specified)
    #   return True on successful pull and write to disk
    #------------------------------------------------------------------------------
    def get_txt_write_file(self, filepath=""):
        try:
            import os # used for os.fsync() method in the write
            if (filepath == "" and len(self.url) > 1):
                filepath = self.url.split('/')[-1] # use the filename from URL and working directory as default if not specified
            response = requests.get(self.url, timeout=self.request_timeout, stream=True)
            self.res = response
            import codecs
            with codecs.open(filepath, mode='w', encoding="utf-8") as f: #write as text
                for chunk in response.iter_content(chunk_size=1024):
                    f.write(chunk)
                    f.flush()
                    os.fsync(f.fileno()) # flush all internal buffers to disk
            return True # return True if successful write
        except Exception as e:
            if DEBUG_FLAG:
                sys.stderr.write("Naked Framework Error: Unable to perform GET request and write file with the URL " + self.url + " using the get_data_write_txt() method (Naked.toolshed.network.py)")
            raise e

    #------------------------------------------------------------------------------
    # [ head method ] (dictionary of strings)
    #   HTTP HEAD request
    #   returns a dictionary of the header strings
    #   test for a specific header on either the response dictionary or the instance res property
    #   Usage example:
    #      content_type = instance.res['content-type']
    #------------------------------------------------------------------------------
    def head(self):
        try:
            response = requests.head(self.url, timeout=self.request_timeout)
            self.res = response # assign the response object from requests to a property on the instance of HTTP class
            return response.headers
        except Exception as e:
            if DEBUG_FLAG:
                sys.stderr.write("Naked Framework Error: Unable to perform a HEAD request with the head() method (Naked.toolshed.network.py).")
            raise e


    #------------------------------------------------------------------------------
    # [ post method ] (string)
    #  HTTP POST request for text
    #  returns text from the URL as a string
    #------------------------------------------------------------------------------
    def post(self):
        try:
            response = requests.post(self.url, timeout=self.request_timeout)
            self.res = response # assign the response object from requests to a property on the instance of HTTP class
            return response.text
        except Exception as e:
            if DEBUG_FLAG:
                sys.stderr.exit("Naked Framework Error: Unable to perform a POST request with the post() method (Naked.toolshed.network.py).")
            raise e

    #------------------------------------------------------------------------------
    # [ post_data method ] (binary data)
    #  HTTP POST request for binary data
    #  returns binary data from the URL
    #------------------------------------------------------------------------------
    def post_data(self):
        try:
            response = requests.post(self.url, timeout=self.request_timeout)
            self.res = response # assign the response object from requests to a property on the instance of HTTP class
            return response.content
        except Exception as e:
            raise e

    #------------------------------------------------------------------------------
    # [ post_bin_write_file method ] (boolean = success of write)
    #  HTTP POST request, write binary file with the response data
    #  default filepath is the basename of the URL file, may be set by passing an argument to the method
    #  returns a boolean that indicates the success of the file write
    #------------------------------------------------------------------------------
    def post_bin_write_file(self, filepath=""):
        try:
            import os # used for os.fsync() method in the write
            if (filepath == "" and len(self.url) > 1):
                filepath = self.url.split('/')[-1] # use the filename from URL and working directory as default if not specified
            response = requests.post(self.url, timeout=self.request_timeout, stream=True)
            self.res = response
            with open(filepath, 'wb') as f: # write as binary data
                for chunk in response.iter_content(chunk_size=1024):
                    f.write(chunk)
                    f.flush()
                    os.fsync(f.fileno()) # flush all internal buffers to disk
            return True # return True if successful write
        except Exception as e:
            if DEBUG_FLAG:
                sys.stderr.write("Naked Framework Error: Unable to perform POST request and write file with the URL " + self.url + " using the post_data_write_bin() method (Naked.toolshed.network.py)")
            raise e

    #------------------------------------------------------------------------------
    # [ post_txt_write_file method ] (boolean = success of file write)
    #   HTTP POST request, write utf-8 encoded text file with the response data
    #   default filepath is the basename of the URL file, may be set by passing an argument to the method
    #   returns a boolean that indicates the success of the file write
    #------------------------------------------------------------------------------
    def post_txt_write_file(self, filepath=""):
        try:
            import os # used for os.fsync() method in the write
            if (filepath == "" and len(self.url) > 1):
                filepath = self.url.split('/')[-1] # use the filename from URL and working directory as default if not specified
            response = requests.post(self.url, timeout=self.request_timeout, stream=True)
            self.res = response
            import codecs
            with codecs.open(filepath, mode='w', encoding="utf-8") as f: # write as binary data
                for chunk in response.iter_content(chunk_size=1024):
                    f.write(chunk)
                    f.flush()
                    os.fsync(f.fileno()) # flush all internal buffers to disk
            return True # return True if successful write
        except Exception as e:
            if DEBUG_FLAG:
                sys.stderr.write("Naked Framework Error: Unable to perform POST request and write file with the URL " + self.url + " using the post_data_write_bin() method (Naked.toolshed.network.py)")
            raise e

    #------------------------------------------------------------------------------
    # [ response method ]
    #   getter method for the requests library object that is assigned as a property
    #   on the HTTP class after a HTTP request method is run (e.g. get())
    #   Note: must run one of the HTTP request verbs to assign this property before use of getter (=None by default)
    #------------------------------------------------------------------------------
    def response(self):
        try:
            return self.res
        except Exception as e:
            if DEBUG_FLAG:
                sys.stderr.write("Naked Framework Error: Unable to return the response from your HTTP request with the response() method (Naked.toolshed.network.py).")
            raise e

    #------------------------------------------------------------------------------
    # [ status_ok method ] (boolean)
    #   return boolean whether HTTP response was in 200 status code range
    #   Note: must run HTTP request (e.g. GET with the get() method) before using this method
    #------------------------------------------------------------------------------
    def status_ok(self):
        try:
            if self.res and self.res.status_code:
                return (self.res.status_code == requests.codes.ok)
            else:
                return False
        except Exception as e:
            if DEBUG_FLAG:
                sys.stderr.write("Naked Framework Error: Unable to obtain the HTTP status with the status_ok() method (Naked.toolshed.network.py).")
            raise e

if __name__ == '__main__':
    pass
    #------------------------------------------------------------------------------
    # HTTP GET 1
    #------------------------------------------------------------------------------
    # http = HTTP("http://www.google.com")
    # data = http.get()
    # print(data)
    # from Naked.toolshed.file import FileWriter
    # w = FileWriter("testfile.txt")
    # w.write_utf8(data)
    #------------------------------------------------------------------------------
    # HTTP GET 2
    #------------------------------------------------------------------------------
    # http = HTTP()
    # http.url = "http://www.google.com"
    # print(http.get())
    #------------------------------------------------------------------------------
    # RESPONSE TEST
    #------------------------------------------------------------------------------
    # http = HTTP("http://www.aosjdpasdjf.com")
    # http.get()
    # print(http.status_ok())

