
pro testaxis

t=indgen(10,10)
r=findgen(50)
r=r+10

window,1
PLOT,r, TITLE='Plot1'
AXIS,10,10,0,XAX=0
AXIS,10,10,10,XAX=1
AXIS,20,20,15,YAX=0
AXIS,30,10,15,YAX=1
AXIS,30,30,15,ZAX=1

window,2
PLOT,r, TITLE='Plot2'
AXIS,10,10,10,XAX=1
AXIS,10,20,XAX=0
AXIS,10,XAX=1
AXIS,XAX=1

window,3
;PLOT,r, TITLE='Plot3'
surface,t
AXIS,10,10,10,XAX=1
AXIS,10,10,10,YAX=1
AXIS,10,10,10,ZAX=1
AXIS,20,20,20,XAX=0
AXIS,20,20,20,YAX=0
AXIS,20,20,20,ZAX=0

window,4
PLOT,r, TITLE='Plot4'
AXIS,YAX=1

window,5
PLOT,r, TITLE='Plot5'
AXIS,10,10,10,XAX=1, /YLOG

window,6
surface,t
AXIS,10,10,10,ZAX=1
AXIS,5,5,ZAX=1
AXIS,3,ZAX=1
AXIS,ZAX=1

window,7
AXIS
end
