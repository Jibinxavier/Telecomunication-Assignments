import socket, sys,select
from thread import *
import threading
import email.utils as eut
import os
import Tkinter
from BaseHTTPServer import BaseHTTPRequestHandler
from StringIO import StringIO
import datetime 
listeningPort = 8081
CRLF = "\r\n"
max_conn = 200
buffer_size = 16384

blocked_list=[]  

 

class BlockingConsole(Tkinter.Tk):

    def __init__(self, parent):
        Tkinter.Tk.__init__(self, parent)
        self.parent = parent
        self.initialize()


    def initialize(self):
        self.grid()
        self.entryVariable = Tkinter.StringVar()
        self.entry = Tkinter.Entry(self,textvariable=self.entryVariable)
        self.entry.grid(column=0,row=0,sticky='EW')
       
        button = Tkinter.Button(self,text=u"Block ",
                                command=self.OnButtonClick)
        button.grid(column=1,row=0)

        label = Tkinter.Label(self,
                              anchor="w",fg="white",bg="green")
        label.grid(column=0,row=1,columnspan=2,sticky='EW')

        self.grid_columnconfigure(0,weight=1)

        self.resizable(True,False)
    def OnButtonClick(self):
        inputw=self.entryVariable.get()
        blocked_list.append( self.entryVariable.get())
        print "Blocked ",inputw










# this class is used to parse the data
class HTTPRequest(BaseHTTPRequestHandler):
    def __init__(self, request_text):
        self.rfile = StringIO(request_text)
        self.raw_requestline = self.rfile.readline()
        
        self.parse_request()

class Cache: 
    ''' It stores the date and path which is the key to the cacheline.
        The ordered keys, are used to keep track of the cacheline, and  evict the oldest one  
    '''
    def __init__(self,cache_size):
        
        self.cache_line={}
        self.ordered_keys=[]
        self.cache_size=cache_size
    def intialise_cacheline(self,path):
        self.cache_line[path]=[]
        
    def least_recently_us( self ):
        self.remove(0)
 
    def insert(self,path,data,date): 
        
        if path not in self.cache_line.keys():
            self.intialise_cacheline(path)
            self.ordered_keys.append([path,date])
        self.cache_line[path].append(data) 
        
       

        if self.cache_size<len(self.cache_line):
			self.least_recently_us()
    def remove(self,i):
        to_rm_path=self.ordered_keys.pop(i)
        del self.cache_line[to_rm_path[0]]

    def fetch(self,path): 
        
        if path  in self.cache_line.keys():
            for i in range(len(self.ordered_keys)):

                if self.ordered_keys[i][0]==path:

                    
                    if self.ordered_keys[i][1]<datetime.datetime.now(): # if the cache is outdated 
                        print " outdated "
                        self.remove(i)
                        return False
                    else:  
                        data=self.ordered_keys.pop(i) ## reordering so that it does  LRU
                        self.cache_line[path].append(data)  
                        return self.cache_line[path]
        else: 
            return False


        

 

class Proxy():
    def __init__(self, conn,addr,cache):
        self.cache=cache
        self.conn=conn
        self.start()

    def start(self):
        ''' Parses the requests. The connect and other method ate dealt with are differently . It also checks if a website is blocked'''
       
        self.request=''
        try:
            while self.request=='':
                self.request+=self.conn.recv(buffer_size)  # there might be empty requests
                 

            self.command,self.host,self.protocol,self.path,self.rest=self.parse_header() 
            print "Request ",self.command,self.host,self.path
            
            self.find_path() 
            self.parse_port()
            
            cached_data= self.cache.fetch(self.host+self.path)
            if self.is_blocked(self.host):
                self.conn.send('<h1> Site blocked<h1>')
                print " Website blocked ",self.host,self.path
            else:

                if cached_data:
                    print "###########   Cache Hit ###########"
                    self.send_to_client(cached_data)
                else: 
                    if self.command=="CONNECT":
                        self.connect_command()
                    else: 

                        self.other_commands() 
               

        except socket.error, (value, message):
            print "************"
            print "socket error", value, message
            print "************"
            self.conn.close()
            sys.exit()
        self.conn.close()
    
    def send_to_client(self,data):
        data=data[0]
        for item in data: 
            self.conn.send(item)
    def is_blocked(self,url):# naive implementation to check if a site is blocked
        print blocked_list
        i = url.find(':')
        if i!=-1:   
            url = url[:i]   #removing port number

        www_pos=url.find('www.') #extracting everything except www.
       
        if www_pos!=-1:
            url=url[www_pos+1:]
            #print url
        for blocked_url in blocked_list:
            if blocked_url in url:
                return True 
       
       
        return False
         

    def parse_header(self):
        request = HTTPRequest(self.request)
        path=None 
        if hasattr(request, 'path'):
            path=request.path  
       
        data='\n'.join(self.request.split('\n') [1:]) #removing the request
        return (request.command,request.headers['host'],request.request_version,path,data)
       
    def parse_port(self):
        i = self.host.find(':')
        if i!=-1:
            self.port = int(self.host[i+1:])
            self.host = self.host[:i]
        else:
            self.port = 80 #default     
        
    def connect_to(self):
        
        self.server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.server.connect((self.host,self.port))   
         
    def read_write(self):
        time_out_max = 20
        socs = [self.conn,self.server]
        count = 0
        date=""
        buffer1=[]
        while True:
            count += 1
            (input_ready, _, error) = select.select(socs, [], socs, 3)
            if error:
                break
            
            for in_ in input_ready:
                data = in_.recv(buffer_size)
                if in_ is self.conn:
                    out = self.server
                else:
                    out = self.conn
               
                if len(data)!=0: 
                    if self.command=="GET" and out ==self.conn:
                        buffer1.append(data)
                        
                    out.send(data)
   
                    count = 0
                else:
                    if self.command=="GET" and len(buffer1)!=0:
                       
                        date=self.parse_expiry_date(buffer1[0])
                        self.cache.insert(self.host+self.path,buffer1,date)

                    
                    break

            if count == time_out_max:
                break
        self.server.close()
     
    def find_path(self):
        self.path = self.path[7:]   #removing http:// 
        i = self.path.find('/') 
        self.path = self.path[i:]

         
    def other_commands(self):
        '''Deals with GET ,POST..It connects to the server and sends the request    '''
       
        self.connect_to()  
        self.server.send(self.command+" "+self.path+" "+self.protocol+"\n"+self.rest)
         
        self.request = ''
        self.read_write()

    def connect_command(self):
        '''Deals with https, CONNECT.It connects to the server.Then it sends a coonection established message to the client and 
        allows interation between them that is validating certificates '''
        self.connect_to()
        self.conn.send('HTTP/1.1 200 Connection established\n'+ '\n') 

        self.request = ''
        self.read_write()      

    def parse_expiry_date(self,response):
        header_data, _, body = response.partition(CRLF + CRLF)
            
        
        header=header_data.split(CRLF) 
        
        expiry_date=''
        cache_control=''
        for h in header:
            if "Expires" in h:
                i=h.find(":")
                expiry_date= h[i+2:]
                break


        if expiry_date=='':
            return datetime.datetime.now()
        else:
            return datetime.datetime(*eut.parsedate(expiry_date)[:6])   
          
        



 
def start():
    cache=Cache(10)
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.bind(('', listeningPort))
        s.listen(max_conn)
        print "server started successfully"
    except Exception, e: 
        print e
        sys.exit(2)

    while True:
        try:
            conn, addr = s.accept()   # incoming sockets 
             
            start_new_thread(Proxy, (conn, addr,cache,))
        except KeyboardInterrupt:
            s.close()
            print "server shutting down"
            sys.exit(1)

    s.close()



if __name__ == '__main__': # tkinker has to run in the main thread 
    app = BlockingConsole(None)
    app.title('Blocking  Console')
    th = threading.Thread(target=start)# while proxy 
    th.daemon = True
    th.start()

   
    app.mainloop()