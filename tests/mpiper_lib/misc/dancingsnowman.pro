pro dancingSnowmanExit,event
;called from the pull down menu
widget_control,event.top,/destroy
return
end

;{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|

pro dancingSnowmanCleanup, base
;called no matter how the GUI is destroyed
widget_control,base,get_uvalue=object
obj_destroy,object
return
end

;{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|

pro dancingSnowman_event,event
;event handler for the top base
widget_control,event.top, get_uvalue=object
eventType = tag_names(event, /struct) ;find out what it is
case eventType of
 ;resize events go here and keep the window square
 'WIDGET_BASE' : object->resize, newSize = (event.x + event.y)/2
 'WIDGET_TIMER': object->boogie
else:
end

return
end

;{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|

pro dancingSnowman::resize, newSize=newSize
;resizes the draw widget and redraws the view

widget_control,self.drawId,draw_xsize=newSize,draw_ysize=newSize
self.oWindow->Draw, self.oView

return
end

;{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|

pro dancingSnowman::boogie
;makes the snowman dance via the double pendulum algorithm

M = self.m1 + self.m2
x1 = self.l1 * cos(self.theta1) & x2 = self.l2*cos(self.theta2)
y1 = self.l1 * sin(self.theta1) & y2 = self.l2*sin(self.theta2)
temp0 = y1*x2 - y2*x1
temp1 = self.m2*self.omega2^2*temp0 + M*self.grav*y1
temp2 = -self.m2*self.omega1^2*temp0 + self.m2*self.grav*y2
temp5 = (x1*x2 + y1*y2)/self.l1/self.l2
temp3 = temp5/self.l1/self.l2
temp4 = (M-self.m2*temp5^2)

self.omega1 = self.omega1 - self.dt*(temp1/self.l1^2. - temp3*temp2)/temp4
self.omega2 = self.omega2 - self.dt*(-temp1*temp3 + temp2*M/self.m2/self.l2^2.)/temp4
self.omega1 = self.omega1*self.damp
self.omega2 = self.omega2*self.damp
self.theta1 = self.theta1 + self.dt*self.omega1
self.theta2 = self.theta2 + self.dt*self.omega2
self.oBellyModel->rotate,[0,0,1],(self.oldTheta1 - self.theta1)/!dtor
self.oHeadModel->rotate,[0,0,1],(self.oldTheta2 - self.theta2)/!dtor
self.oldTheta1 = self.theta1
self.oldTheta2 = self.theta2
self.oWindow->Draw, self.oView

widget_control, self.base, timer=self.timer
return
end

;{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|

function dancingSnowman::init, m1=m1,m2=m2,l1=l1,l2=l2,grav=grav, $
							   timer=timer, theta1=theta1, theta2=theta2, $
							   damp=damp, dt=dt
;initialization routine for the dancing snowman

;Experiment with the mass (m1,m2),length(l1,l2), and gravity parameters
;to get different behaviors of the snowman.
;Theta1 and Theta2 are the starting angles of the double pendulum
;Damp controls how quickly the oscillations damp out and dt is the time interval for
;the swing on the pendulum. Timer is how often IDL calls the boogie routine,make this
;smaller to speed up the dance.

if not keyword_set(timer) then timer = 0.1 & self.timer = timer
if not keyword_set(grav) then grav = 98.0 & self.grav = grav
if not keyword_set(m1) then m1 = 80.0 & self.m1 = m1
if not keyword_set(m2) then m2 = 80.0 & self.m2 = m2
if not keyword_set(l1) then l1 = 80.0 & self.l1 = l1
if not keyword_set(l2) then l2 = 80.0 & self.l2 = l2
if not keyword_set(theta1) then theta1 = 90 & self.theta1 = theta1*!dtor
if not keyword_set(theta2) then theta2 = -45 & self.theta2 = theta2*!dtor
if not keyword_set(damp) then damp = 0.990 & self.damp = damp
if not keyword_set(dt) then dt = 0.3 & self.dt = dt
self.oldTheta1 = self.theta1
self.oldTheta2 = self.theta2

;initialize the super class
if (self->IDLgrModel::init(_extra=extra) ne 1) then return, 0

;Get the screen size.
device, get_screen_size = screenSize
xdim = screenSize[0]*.50 ;about 50 percent of the screen size
ydim=xdim  ;keep isotropic

base=widget_base(title='Dancing Snowman',column=1,/tlb_size_events,mbar=barBase)
;pull down menu next
fileId = widget_button(barBase, value='File', /menu)
void = widget_button(fileId, /separator, value='Exit', $
           event_pro='dancingSnowmanExit')
self.drawId=widget_draw(base, xsize=xdim, ysize=ydim, $
                    graphics_level=2, retain=0, /expose_events)

widget_control, base, /realize
widget_control, hourglass=1
widget_control, self.drawId, get_value=oWindow
self.oWindow=oWindow

;create view object.
self.oView = obj_new('IDLgrView', projection=1, eye=1.1, $
        color=[0,0,0], view=[-1,-1,2,2], zclip=[1,-1])
self.oBaseModel = obj_new('IDLgrModel') ;need a model for the base
self.oBellyModel = obj_new('IDLgrModel') ;need a model for the belly
self.oHeadModel = obj_new('IDLgrModel') ;need a model for the head
;base ball first
oBase = obj_new('orb', POS=[0,0,0], RADIUS=0.2,color=[255,255,255])
;belly next
oBelly = obj_new('orb', POS=[0,0.0,0], RADIUS=0.14,color=[255,255,255])
oBellyButton1 = obj_new('orb',pos=[0,+0.14*sin(40*!dtor),0.14*cos(40*!dtor)],radius=.025,color=[0,0,0])
oBellyButton2 = obj_new('orb',pos=[0,+0.14*sin(0*!dtor),0.14*cos(0*!dtor)],radius=.025,color=[0,0,0])
self.oBellyModel->translate,0,0.25,0 ;translate to the middle position
;head last
oHead = obj_new('orb', POS=[0,0,0], RADIUS=0.09,color=[255,255,255])
oNose = obj_new('orb',pos=[0,+0.09*sin(0*!dtor),0.09*cos(0*!dtor)],radius=.015,color=[255,0,0])
oLeftEye= obj_new('orb',pos=[-0.09*sin(25*!dtor),+0.09*sin(25*!dtor),0.09*cos(40*!dtor)],radius=.015,color=[0,0,0])
oRightEye= obj_new('orb',pos=[+0.09*sin(25*!dtor),+0.09*sin(25*!dtor),0.09*cos(40*!dtor)],radius=.015,color=[0,0,0])
mouthX = [0.1*sin(115*!dtor)*sin(-30*!dtor),0, 0.1*sin(115*!dtor)*sin(30*!dtor)]
mouthY = [0.1*cos(115*!dtor), 0.1*cos(130*!dtor), 0.1*cos(115*!dtor)]
mouthZ = [0.1*sin(115*!dtor)*cos(-30*!dtor), 0.1*sin(115*!dtor),0.1*sin(115*!dtor)*cos(30*!dtor)]
oMouth= obj_new('IDLgrPolyline',mouthX,mouthY,mouthZ,color=[0,0,0],thick=3)
self.oHeadModel->translate,0,0.2,0 ;translate to the top of the other two balls
;add the objects to the model
self.oBaseModel->add, oBase
self.oBellyModel->add, oBelly
self.oBellyModel->add, oBellyButton1
self.oBellyModel->add, oBellyButton2
self.oHeadModel->add, oHead
self.oHeadModel->add, oNose
self.oHeadModel->add, oRightEye
self.oHeadModel->add, oLeftEye
self.oHeadModel->add, oMouth
;add the models together
self.oBaseModel->add,self.oBellyModel
self.oBellyModel->add,self.oHeadModel

;add the models to the view
self.oView -> add, self.oBaseModel

;don't want light sources to rotate so give them a separate model
oLightModel = obj_new('IDLgrModel')
oLight1 = obj_new('IDLgrLight',direction=[0,0,0],location=[0,0,1],type=2, $
                  color=[255,255,255],hide=0)
oLight2 = obj_new('IDLgrLight', direction=[1,0,0],location=[-1,1,0],type=1, $
                  color=[255,255,255],intensity=0.5)
oLightModel->add,oLight1
oLightModel->add,oLight2
;add some text that will not move
;displayText = ['M','E','R','R','Y',' ','C','H','R','I','S','T','M','A','S','!']
displayText = ['MERRY CHRISTMAS!','From Kling Research and Software, inc']
oFont = obj_new('IDLgrFont','Times*Bold*italic',size=20)
oText = obj_new('IDLgrText',string=displayText,location=transpose([[0.0,0.0],[-0.5,-0.6],[0.5,0.5]]), $
                color=[255,0,0],font = oFont, align=0.5)
oLightModel->add,oText
self.oView-> add, oLightModel
;rotate the snowman to the starting position
self.oBellyModel->rotate,[0,0,1],(-self.theta1)/!dtor
self.oHeadModel->rotate,[0,0,1],(-self.theta2)/!dtor
self.oWindow->Draw, self.oView

;store objects for cleanup
self.oContainer = obj_new('IDL_Container')
self.oContainer -> add, oBase
self.oContainer -> add, oBelly
self.oContainer-> add,oLight1
self.oContainer-> add,oLight2
self.oContainer-> add,oText
self.oContainer-> add,oFont
self.oContainer-> add, oLightModel
;store the object reference in the base
self.base = base
widget_control, base,set_uvalue=self
widget_control,base,timer=0.010 ;timer for the dance

xmanager,'dancingSnowman',base,/no_block,cleanup='dancingSnowmanCleanup'
return,1
end

;{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|

pro dancingSnowman::cleanup
;cleanup routine for the dancing snowman object
if obj_valid(self.oContainer) then obj_destroy,self.oContainer
if ptr_valid(self.oLightArrayPtr) then begin
  obj_destroy,*self.oLightArrayPtr
  ptr_free,self.oLightArrayPtr
endif
if obj_valid(self.oWindow) then obj_destroy,self.oWindow
if obj_valid(self.oView) then obj_destroy,self.oView
if obj_valid(self.oBaseModel) then obj_destroy, self.oBaseModel
if obj_valid(self.oBellyModel) then obj_destroy, self.oBellyModel
if obj_valid(self.oHeadModel) then obj_destroy, self.oHeadModel

return
end

;{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|

pro dancingSnowman__define

;defintion routine for the dancing snowman object
void = {dancingSnowman, $
        inherits IDLgrmodel, $
        base : 0L, $
        timer : 0.0, $
        omega1 : 0.0, $
        omega2 : 0.0, $
        theta1 : 0.0, theta2: 0.0, $
        oldTheta1 : 0.0 , oldTheta2 : 0.0, $
        grav : 0.0, $
        m1 : 0.0, m2 : 0.0, $
        l1 : 0.0, l2 : 0.0, $
        dt : 0.0, damp: 0.0, $
        oLightArrayPtr : ptr_new(), $
        nLights : 0, $
        drawId : 0L, $
        oBaseModel : obj_new(), $
        oBellyModel : obj_new(), $
        oHeadModel : obj_new(), $
        oWindow : obj_new(), $
        oView : obj_new(), $
        oContainer : obj_new()}

return
end

;{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|{{:|

pro dancingSnowman,  m1=m1,m2=m2,l1=l1,l2=l2,grav=grav, $
				     timer=timer, theta1=theta1, theta2=theta2, $
					 damp=damp, dt=dt
;driver program for the dancing snowman object

oMan = obj_new('dancingSnowman',m1=m1,m2=m2,l1=l1,l2=l2,grav=grav, $
   				        timer=timer, theta1=theta1, theta2=theta2, $
					    damp=damp, dt=dt)

return
end