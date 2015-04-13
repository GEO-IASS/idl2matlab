; $Id: cw_form.pro,v 1.1 1995/01/28 18:10:14 dave Exp $
; Copyright (c) 1995, Research Systems, Inc.  All rights reserved.
;	Unauthorized reproduction prohibited.
;+
; NAME:
;	CW_FORM
;
; PURPOSE:
;	CW_FORM is a compound widget that simplifies creating
;	forms which contain text, numeric fields, buttons, 
;	and droplists.  Event handling is also simplified.
;
; CATEGORY:
;	Compound widgets.
;
; CALLING SEQUENCE:
;	widget = CW_FORM([Parent,] Desc)
;
; INPUTS:
;       Parent:	The ID of the parent widget.  Omitted for a top level 
;		modal widget.

; Desc: A string array describing the form.  Each element of the
;	string array contains two or more comma delimited fields.  The
;	character '\' may be used to escape commas that appear within fields.
;	To include the backslash character, escape it with a second
;	backslash.
;
;	The fields are defined as follows:
;
; Field 1: Depth: the digit 0, 1, 2, or 3.  0 continues the current
;	level, 1 begins a new level, 2 denotes the last element of the
;	current level, and 3 both begins a new level and is the last entry of
;	the current level.  Nesting is used primarily with row or column 
;	bases for layout.  See the example below.
; Field 2: Item type: BASE, BUTTON, DROPLIST, FLOAT, INTEGER, LABEL, or TEXT.
;	The items return the following value types:
;	BUTTON - For single buttons, 0 if clear, 1 if set.
;		For multiple buttons, also called button groups, that are
;		exclusive the index of the set button is returned.  For
;		non-exclusive button groups, the value is an array
;		an element for each button containing 1
;		if the button is set, 0 otherwise.
;	DROPLIST - a 0 based index indicating which item is selected.
;	FLOAT, INTEGER, TEXT - return their respective data type.
;
; Field 3: Initial value.  Omitted for bases.
;	For BUTTON and DROPLIST items, the value field contains one
;		or more item names, delimited by the | character.
;	For FLOAT, INTEGER, LABEL, and TEXT items the value field contains the
;		initial value of the field.
;
; Fields 4 and following: Keywords or Keyword=value pairs that specify
;	optional attributes or options.  Possibilities include:
;
;	COLUMN	If present, specifies column layout.
;	EXCLUSIVE  If present makes an exclusive set of buttons.  The
;		default is nonexclusive.
;	FONT=<font name>  If present, the font for the item is specified.
;	FRAME:	If present, a frame is drawn around the item.
;	LABEL_LEFT=<label>  annotate a button or button group with a label
;		placed to the left of the buttons.  Valid with BUTTON,
;		DROPLIST, FLOAT, INTEGER and TEXT items.
;	LABEL_TOP=<label> annotate a button or button group with a label
;		placed at the top of the buttons.  Valid with BUTTON,
;		DROPLIST, FLOAT, INTEGER and TEXT items.
;	LEFT, CENTER, or RIGHT   Specifies alignment of label items.
;	QUIT	If present, when the user activiates this entry when it
;		is activated as a modal widget, the form is destroyed
;		and its value returned as the result of CW_FORM.  For non-
;		modal form widgets, events generated by changing this item
;		have their QUIT field set to 1.
;	ROW	If present, specifies row layout.
;	SET_VALUE  Sets the initial value of button groups.
;	TAG=<name>   the tag name  of this element.  The widget's value
;		is a structure corresponding to the form.  Each form item
;		has a corresponding tag-value pair in the widget's value.
;		Default = TAGnnn, where nnn is the index of the item
;		in the Desc array.
;	WIDTH=n Specifies the width, in characters, of a TEXT, INTEGER,
;		or FLOAT item.
;	
; KEYWORD PARAMETERS:
;	COLUMN:		  If set the main orientation is vertical, otherwise
;			  horizontal.
;	IDS:		  A named variable into which the widget id of
;				each widget corresponding to an element
;				in desc is stored.
;	TITLE:		  The title of the top level base.  Not used
;			  if a parent widget is supplied.
;	UVALUE:		  The user value to be associated with the widget.
;
; OUTPUTS:
;       If Parent is supplied, the result is the ID of the base containing
;	the form.  If Parent is omitted, the form is realized as a modal
;	top level widget. The function result is then a structure containing
;	the value of each field in the form when the user finishes.
;
;	This widget has a value that is a structure with a tag/value pair
;	for each field in the form.  WIDGET_CONTROL, id, GET_VALUE=v may
;	be used to read the current value of the form.  WIDGET_CONTROL, id,
;	SET_VALUE={ Tagname: value, ..., Tagname: value} sets the values
;	of one or more tags.
;
; SIDE EFFECTS:
;	Widgets are created.
;
; RESTRICTIONS:
;	
; EXAMPLES:

;	**** Define a form, with a label, followed by two vertical button
;	groups one non-exclusive and the other exclusive, followed by a text
;	field, and an integer field, followed lastly by OK and Done buttons.
;	If either the OK or Done buttons are pressed, the form is exited.
;	
;
;		; String array describing the form
;	desc = [ $
;	    '0, LABEL, Centered Label, CENTER', $
;		; Define a row base on a new depth.  All elements until a depth
;		; of two are included in the row.
; 	    '1, BASE,, ROW, FRAME', $
; 	    '0, BUTTON, B1|B2|B3, LABEL_TOP=Nonexclusive:, COLUMN, TAG=bg1', $
;		; This element terminates the row.
; 	    '2, BUTTON, E1|E2|E2, EXCLUSIVE,LABEL_TOP=Exclusive,COLUMN,TAG=bg2', $
; 	    '0, TEXT, , LABEL_LEFT=Enter File name:, WIDTH=12, TAG=fname', $
;	    '0, INTEGER, 0, LABEL_LEFT=File size:, WIDTH=6, TAG=fsize', $
;	    '1, BASE,, ROW', $
;	    '0, BUTTON, OK, QUIT,FONT=*helvetica-medium-r-*-180-*,TAG=OK', $
;	    '2, BUTTON, Cancel, QUIT']
;
;    To use the form in a modal manner:
;	  a = CW_FORM(desc, /COLUMN)
;	  help, /st,a
;    When the form is exited, (when the user presses the OK or Cancel buttons), 
;	the following structure is returned as the function's value:
;		BG1             INT       Array(3)  (Set buttons = 1, else 0)
;		BG2             INT              1  (Exclusive: a single index)
;		FNAME           STRING    'test.dat' (text field)
;		FSIZE           LONG               120 (integer field)
;		OK              LONG                 1 (this button was pressed)
;		TAG8            LONG                 0 (this button wasn't)
;	Note that if the Cancel button is pressed, the widget is exited with
;	the OK field set to 0.
;
;  *****************
;
;    To use CW_FORM inside another widget:
;	    a = widget_base(title='Testing')
;	    b = cw_form(a, desc, /COLUMN)
;	    WIDGET_CONTROL, a, /real
;	    xmanager, 'Test', a
;	In this example, an event is generated each time the value of
;	the form is changed.  The event has the following structure:
;	   ID              LONG                <id of CW_FORM widget>
;	   TOP             LONG                <id of top-level widget>
;	   HANDLER         LONG                <internal use>
;	   TAG             STRING    'xxx'	; name of field that changed
;	   VALUE           INT       xxx	; new value of changed field
;	   QUIT            INT              0	; quit flag
;    The event handling procedure (in this example, called TEST_EVENT), may use
;	the TAG field of the event structure to determine which field
;	changed and perform any data validation or special actions required.
;	It can also get and set the value of the widget by calling
;	WIDGET_CONTROL.
;    A simple event procedure might be written to monitor the QUIT field
;	of events from the forms widget, and if set, read and save the
;	widget's value, and finally destroy the widget.
;
;    To set or change a field within the form from a program, use a the
;	WIDGET_CONTROL procedure:
;	   	WIDGET_CONTROL, b, SET_VALUE={FNAME: 'junk.dat'}
;	This statement sets the file name field of this example.
;
; MODIFICATION HISTORY:
;	January, 1995.  DMS, Written.
;-
;


function CW_FORM_PARSE, Extra, Name, Value, Index=Index
; Given the extra fields in the string array Extra,
;	determine if one field starts with Name.
; If so, return TRUE, otherwise FALSE.
; If the field contains the character '=' after Name, return the contents
; of the field following the equal sign.
; Return the index of the found element in Index.
;

found = where(strpos(extra, name) eq 0, count)
if count eq 0 then return, 0
if count gt 1 then message,'Ambiguous field name: '+name, /CONTINUE

index = found(0)
item = extra(index)
nlen = strlen(name)
value = ''			;Assume no value
equal = strpos(item,'=',nlen) ;Find = character
if equal ge 0 then value = strmid(item, equal+1, 1000) ;Extract following
extra(index)=''			;clean it out...
return, 1
end


pro CW_FORM_APPEND, extra, e, keyword, USE_VALUE=use_value, ACTUAL_KEYWORD=akw
if CW_FORM_PARSE(e, keyword, value) then begin
    if n_elements(akw) le 0 then akw = keyword
    if KEYWORD_SET(use_value) eq 0 then value = 1
    if n_elements(extra) eq 0 then extra = create_struct(akw, value) $
    else extra = create_struct(extra, akw, value)
endif
end



pro CW_FORM_LABEL, parent, nparent, e, frame
;Put LABEL_LEFT and/or LABEL_RIGHT on a base.

nparent = parent
    
if CW_FORM_PARSE(e, 'LABEL_LEFT', value) then begin
	nparent = WIDGET_BASE(nparent, /ROW, FRAME=frame)
	frame = 0
	junk1 = WIDGET_LABEL(nparent, VALUE=value)
	endif
if CW_FORM_PARSE(e, 'LABEL_TOP', value) then begin
	nparent = WIDGET_BASE(nparent, /COLUMN, FRAME=frame)
	frame = 0
	junk1 = WIDGET_LABEL(nparent, VALUE=value)
	endif
end



pro CW_FORM_BUILD, parent, desc, cur, ids, lasttag
; Recursive routine that builds the form hierarchy described in DESC.
; Returns the ID of each button in ids.

; Format of a field descriptor:
; Field 0,  Flags: 
; Field 1, Type of item.  BASE, LABEL, INTEGER, FLOAT, DROPLIST,
;	EXCLUSIVE_BUTTONS, TEXT
; Field 2, Value of item...
; Fields >= 3, optional flags
;
;
; Type id = 0 for bgroup, 1 for droplist, 2 for button,
;	3 for integer, 4 for float, 5 for text.
;
  n = n_elements(desc)

  while cur lt n do begin
    a = str_sep(desc(cur), ',', /TRIM, ESC='\')
    if n_elements(a) lt 2 then $
	message,'Form element '+strtrim(cur,2)+'is missing a field separator'
    extra=0			;Clear extra keywords by making it undefined
    junk = temporary(extra)	;Clear common param list
    type = -1			;Assume type == no events.
    quit = 0
    frame = 0
    if n_elements(a) gt 3 then begin	;Addt'l common params?
	e = a(3:*)		;Remove leading/trailing blanks
	quit = CW_FORM_PARSE(e, 'QUIT')
	frame = CW_FORM_PARSE(e, 'FRAME')
	CW_FORM_APPEND, extra, e, 'FONT', /USE_VALUE
	CW_FORM_APPEND, extra, e, 'COLUMN'
	CW_FORM_APPEND, extra, e, 'ROW'
	CW_FORM_APPEND, extra, e, 'LEFT', ACTUAL='ALIGN_LEFT'
	CW_FORM_APPEND, extra, e, 'CENTER', ACTUAL='ALIGN_CENTER'
	CW_FORM_APPEND, extra, e, 'RIGHT', ACTUAL='ALIGN_RIGHT'
    endif else e = ''

    case a(1) of		;Which widget type?
'BASE': BEGIN
    new = WIDGET_BASE(parent, FRAME=frame, _EXTRA=extra)
    ENDCASE
'BUTTON': BEGIN
    CW_FORM_APPEND, extra, e, 'LABEL_LEFT', /USE_VALUE
    CW_FORM_APPEND, extra, e, 'LABEL_TOP', /USE_VALUE
    CW_FORM_APPEND, extra, e, 'SET_VALUE', /USE_VALUE
    exclusive = CW_FORM_PARSE(e,'EXCLUSIVE')
    values = str_sep(a(2),'|', ESC='\')
    if n_elements(values) ge 2 then begin
        type = 0
        new = CW_BGROUP(parent, str_sep(a(2),'|'),  $
		        EXCLUSIVE = exclusive, NONEXCLUSIVE = 1-exclusive, $
		        FRAME=frame, _EXTRA=extra)
        WIDGET_CONTROL, new, GET_VALUE=value
    endif else begin
        type = 2
	new = WIDGET_BUTTON(parent, value=values(0), FRAME=frame, _EXTRA=extra)
	value = 0L
    endelse
    uextra = { value: value }
    ENDCASE
'DROPLIST': BEGIN
    CW_FORM_LABEL, parent, nparent, e, frame
    new = WIDGET_DROPLIST(nparent, VALUE = str_sep(a(2), '|'), $
		FRAME=frame, UVALUE=ids(n), _EXTRA=extra)
    uextra = { VALUE: 0L }
    type = 1
    ENDCASE
'INTEGER': BEGIN
    type = 3
    value = 0L
process_integer:
    uextra = { VALUE: value }    
    CW_FORM_LABEL, parent, nparent, e, frame
    if CW_FORM_PARSE(e, 'WIDTH', temp) then width = fix(temp) else width=6
    new = WIDGET_TEXT(nparent, /ALL_EVENTS, /EDITABLE, YSIZE=1, $
		XSIZE=width, UVALUE=ids(n))
    if n_elements(a) ge 3 then BEGIN		;Save value
	WIDGET_CONTROL, new, SET_VALUE=a(2)
	uextra.value = a(2)
	endif
   ENDCASE
'FLOAT': BEGIN
    type = 4
    value = 0.0
    goto, process_integer
    ENDCASE
'LABEL': BEGIN
    new = WIDGET_LABEL(parent, value=a(2), FRAME=frame, _EXTRA=extra)
    ENDCASE
'TEXT': BEGIN
    type=5
    value = ''
    goto, process_integer
    ENDCASE
else: BEGIN
	MESSAGE,'Illegal form element type: ' + a(1), /CONTINUE
	new = WIDGET_BASE(parent)
    ENDCASE
ENDCASE

    ids(cur) = new
    if type ge 0 then begin
	if CW_FORM_PARSE(e, 'TAG', value) then value = STRUPCASE(value) $
	else value='TAG'+strtrim(cur,2)	  ;default name = TAGnnn.
        u = CREATE_STRUCT( $
		{ type: type, base: ids(n+1), tag:value, next: 0L, quit:quit}, $
		uextra)
	widget_control, new, SET_UVALUE= u
		;First tag?  If so, set child uvalue -> important widget ids.
	if lasttag eq 0 then begin
	    WIDGET_CONTROL, ids(n), GET_UVALUE=tmp, /NO_COPY
	    tmp.head = new
	    WIDGET_CONTROL, ids(n), SET_UVALUE=tmp, /NO_COPY
	endif else begin		;Otherwise, update chain.
	    WIDGET_CONTROL, lasttag, GET_UVALUE=u, /NO_COPY
	    u.next = new
	    WIDGET_CONTROL, lasttag, SET_UVALUE=u, /NO_COPY
	    endelse
	lasttag = new
	endif			;Type

    i = where(strlen(e) gt 0, count)
    if count gt 0 then begin	;Unrecognized fields?
	Message, /CONTINUE, 'Descriptor: '+ desc(cur)
	for j=0, count-1 do message, /CONTINUE, 'Unrecognized field: '+ e(i(j))
	endif

    cur = cur + 1
    dflags = fix(a(0))		;Level flags
    if dflags and 1 then CW_FORM_BUILD, new, desc, cur, ids, lasttag  ;Begin new
    if (dflags and 2) ne 0 then return	;End current
  endwhile
end				;CW_FORM_BUILD



Function CW_FORM_EVENT, ev		;Event handler for CW_FORM
widget_control,   ev.id, GET_UVALUE=u, /NO_COPY  ;What kind of widget?

if u.type eq 1 then begin	;Droplist?  (can't get value)
    v = ev.index
    u.value = v
endif else if u.type eq 2 then begin
    v = ev.select
    u.value=v
endif else begin		;Other types of widgets
    WIDGET_CONTROL, ev.id, GET_VALUE=v
    if u.type ge 3 then begin  ;Toss selection events from text widgets
	v = v(0)
        ret = 0
	if ev.type eq 3 then goto, toss
	endif
    on_ioerror, invalid
    u.value = v			;Does an implicit conversion
    v = u.value
    goto, back_in

; We come here if we get an invalid number.  
invalid: WIDGET_CONTROL, ev.id, SET_VALUE=''  ;Blank it out
    v = ''
    u.value = ''
endelse			;u.type

back_in: ret= { id: u.base, top: ev.top, handler: 0L, $
		tag: u.tag, value: v, quit: u.quit} ;Our value
toss: widget_control, ev.id, SET_UVALUE=u, /NO_COPY	;Save new value...
return, ret
end			;CW_FORM_EVENT


Pro CW_FORM_SETV, id, value	;In this case, value = { Tagname : value, ... }
x = WIDGET_INFO(id, /CHILD)	;Get head of list
WIDGET_CONTROL, x, GET_UVALUE=u
head = u.head
tags = tag_names(value)
n = n_elements(tags)

while head ne 0 do begin
    WIDGET_CONTROL, head, GET_UVALUE=u, /NO_COPY
    w = where(u.tag eq tags, count)
    if count ne 0 then begin
	u.value = value.(w(0))	;Set the value
	if u.type ne 2 then WIDGET_CONTROL, head, $
			SET_VALUE=value.(w(0)) ;Change the widget
	n = n - 1
	endif
    next = u.next
    WIDGET_CONTROL, head, SET_UVALUE=u, /NO_COPY
    if n le 0 then return		;Done...
    head = next
endwhile
end


Function CW_FORM_GETV, id	;Return value of a CW_FORM widget.

x = WIDGET_INFO(id, /CHILD)	;Get head of list
WIDGET_CONTROL, x, GET_UVALUE=u
head = u.head

while head ne 0 do begin
    WIDGET_CONTROL, head, GET_UVALUE=u, /NO_COPY
    if n_elements(ret) le 0 then ret = CREATE_STRUCT(u.tag, u.value) $
    else ret = CREATE_STRUCT(ret, u.tag, u.value)
    next = u.next
    WIDGET_CONTROL, head, SET_UVALUE=u, /NO_COPY
    head = next
endwhile
return, ret
end


pro cw_form_modal_event, ev
if ev.quit ne 0 then begin
    child = WIDGET_INFO(ev.id, /CHILD)
    WIDGET_CONTROL, child, GET_UVALUE=u  ;Get handle
    WIDGET_CONTROL, ev.id, GET_VALUE=v  ;The widget's value
    WIDGET_CONTROL, ev.top, /DESTROY
    HANDLE_VALUE, u.handle, v, /SET
    endif
end

FUNCTION CW_FORM, parent, desc, $
	COLUMN = column, IDS=ids, TITLE=title, UVALUE=uvalue

;  ON_ERROR, 2						;return to caller
  ; Set default values for the keywords
  If KEYWORD_SET(column) then row = 0 else begin row = 1 & column = 0 & end

  p = parent
  handle = 0L
  if n_params() eq 1 then begin
	desc = parent
	if n_elements(title) le 0 then title='FORM Widget'
	p = WIDGET_BASE(TITLE=title, Column = column, row=row)
	handle = handle_create()
  endif
  Base = WIDGET_BASE(p, Column = column, row=Row)

  if n_elements(uvalue) gt 0 then WIDGET_CONTROL, base, SET_UVALUE=uvalue
  n = n_elements(desc)
  ids = lonarr(n+2)		;Element n is ^ to child, n+1 ^ to base
  child = WIDGET_BASE(base)	;Widget to contain info...
  ids(n) = child
  ids(n+1) = base
  lasttag = 0
  WIDGET_CONTROL, child, SET_UVALUE={ head: 0L, base: base, handle: handle}

  CW_FORM_BUILD, base, desc, 0, ids, lasttag
  widget_control, base, EVENT_FUNC='CW_FORM_EVENT', $
	FUNC_GET_VALUE='CW_FORM_GETV', PRO_SET_VALUE='CW_FORM_SETV'

  if n_params() eq 1 then begin		;Modal?
	WIDGET_CONTROL, p, /realize
	XMANAGER, 'CW_FORM', p, EVENT_HANDLER='CW_FORM_MODAL_EVENT', /MODAL
	HANDLE_VALUE, handle, v, /NO_COPY
	HANDLE_FREE, handle
	return, v
	endif
  return, base
END

