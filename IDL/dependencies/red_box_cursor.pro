pro red_box_cursor, x0, y0, nx, ny, INIT = init, FIXED_SIZE = fixed_size, $
                    MESSAGE = message, monochrom = mc, use_plot_coord = plr, mark = mark, $
                    aspect = asp, verbose = verbose, limits = lim
;+
; NAME:
;       BOX_CURSOR
;
; PURPOSE:
;       Emulate the operation of a variable-sized box cursor (also
;       known as a "marquee" selector).
;
; CATEGORY:
;       Interactive graphics.
;
; CALLING SEQUENCE:
;       BOX_CURSOR, x0, y0, nx, ny [, KEYWORDS]
;
; INPUTS:
;       No required input parameters.
;
; OPTIONAL INPUT PARAMETERS:
;       x0, y0, nx, and ny give the initial location (x0, y0) and size
;       (nx, ny) of the box if the keyword INIT is set.  Otherwise,
;       the box is initially drawn in the center of the screen.
;
; KEYWORD PARAMETERS:
;       INIT      : (Flag) If this keyword is set, supplied values of
;                   x0, y0, nx, and ny are taken as the initial
;                   parameters for the box. By default, the box starts
;                   in the center of the alowed range with a size of
;                   1/8 of the full size.
;
;       FIXED_SIZE: (Flag) If this keyword is set, nx and ny contain
;                   the initial size of the box.  This size may not be
;                   changed by the user.
;
;       MESSAGE   : (Flag) If this keyword is set, print a short message
;                   describing operation of the cursor.
;
;       MONOCHROME: (Flag)  On monochrome displays, the drawing color
;                   must be set to 0, or the box will be
;                   invisible. This is done if this keyword is set.
;
;   USE_PLOT_COORD: (Flag) By Default, the coordinates are given in
;                   device units. If you want to locate a box in a
;                   previous drawn plot, these device coordinates are
;                   transformed to the displayed plotrange when this
;                   keyword is set.
;
;       MARK      : (Flag) Draw a box around the chosen field before quitting
;
;       ASPECT    : (Flag) if unequal zero, resizing of the box is
;                   only allowed with keeping the original aspect
;                   ratio nx:ny. 
;
;       VERBOSE   : (Flag) Print selected values to the Terminal
;                   before exiting. 
;
;       LIMITS    : (input, vector) Set limits for the edges of the
;                   box. Can be a scalar, a two or fourelement
;                   vector. If scalar, a square region of size LIMITS
;                   is used, for a 2-el vector a region of LIMITS(0) x
;                   LIMITS(1) starting at (0,0). A 4-el vector must
;                   contain the positions of lower left and upper
;                   right corner of the range: [llx,lly,urx,ury].
;                   Default range is the whole window.
;
; OUTPUTS:
;       x0:  X value of lower left corner of box.
;       y0:  Y value of lower left corner of box.
;       nx:  width of box
;       ny:  height of box
;
;       Values are given in pixels (default) or plot coordinates
;       (keyword USE_PLOT_COORD)
;       The box is also constrained to lie entirely within the window
;       or the given limits, resp.
;
; COMMON BLOCKS:
;       None.
;
; SIDE EFFECTS:
;       A box is drawn in the currently active window.  It is erased
;       on exit unless MARK is set.
;
; RESTRICTIONS:
;       Works only with window system drivers.
;
; PROCEDURE:
;       The graphics function is set to 10 for Invert.  This
;       allows the box to be drawn and erased without disturbing the
;       contents of the window.
;
;       Operation is as follows:
;       Left mouse button:   Move the box by dragging.
;       Middle mouse button: Resize the box by dragging.  The corner
;                            nearest the initial mouse position is moved.
;       Right mouse button:  Exit this procedure, returning the 
;                            current box parameters.
;
; MODIFICATION HISTORY:
;       DMS, April, 1990.
;       DMS, April, 1992.  Made dragging more intutitive.
;       PS,  Okt,   1992.  Add MONOCHROME keyword to allow use on
;                          B&W displays; possibility of transforming to
;                          plotrange coordinates.
;       PS,  Aug,   1993.  Allow rescaling with constant aspect ratio.
;       PS,  Jun,   1995.  Clean out error in resizing (fails when
;                          resizing over the window boundaries). Added
;                          LIMITS keyword. Reformating of sourcecode.
;       PS,  Aug,   1995.  Made limits more safe and comfortable.
;-

on_error, 2

device, get_graphics = old, set_graphics = 10 ;Set invert

limits = [0, 0, !D.x_size-1, !D.y_size-1]

IF keyword_set(lim) THEN BEGIN
    CASE n_elements(lim) OF
        1: BEGIN
            message, 'Assuming square region at (0,0)', /info
            limits = [0, 0, [lim, lim] < limits(2:3)]
        END
        2: BEGIN
            message, 'Assuming lower left at (0,0)', /info
            limits = [0, 0, lim]
        END
        4: limits = [lim(0:1) > 0, lim(2:3) < limits(2:3)]
        ELSE: message, 'Wrong format for limits, ignoring it', /info
    ENDCASE
ENDIF
    
limits = [limits, limits(2)-limits(0), limits(3)-limits(1)]

IF !D.n_colors EQ 2 THEN $
  col = 0 $
ELSE $
  col = !D.n_colors -1

IF keyword_set(mc) THEN col = 0

IF keyword_set(message) THEN BEGIN
    print, "Drag Left button to move box."
    print, "Drag Middle button near a corner to resize box."
    print, "Right button when done."
ENDIF

IF NOT keyword_set(init) THEN BEGIN ;Supply default values for box:
    IF NOT keyword_set(fixed_size) THEN BEGIN
        nx = (limits(4))/8
        ny = (limits(5))/8
    ENDIF
    x0 = limits(0)+(limits(4))/2 - nx/2
    y0 = limits(1)+(limits(5))/2 - ny/2
ENDIF

IF keyword_set(asp) THEN asp_rat = float(ny)/nx

button = 0
GOTO, middle

WHILE 1 DO BEGIN
    old_button = button
    cursor, x, y, 2, /dev       ;Wait for a button
    button = !Err
    IF (old_button EQ 0) AND (button NE 0) THEN BEGIN
        mx0 = x                 ;For dragging, mouse locn...
        my0 = y         
        x00 = x0                ;Orig start of ll corner
        y00 = y0
    ENDIF
    IF !Err EQ 1 THEN BEGIN     ;Drag entire box?
        x0 = x00 + x - mx0
        y0 = y00 + y - my0
    ENDIF
     ;;; New size?
    IF (!Err EQ 2) AND (NOT keyword_set(fixed_size)) THEN BEGIN
        IF NOT keyword_set(asp) THEN BEGIN
            IF old_button EQ 0 THEN BEGIN ;Find closest corner
                mind = 1e6
                FOR i = 0, 3 DO BEGIN
                    d = float(px(i)-x)^2 + float(py(i)-y)^2
                    IF d LT mind THEN BEGIN
                        mind = d
                        corner = i
                    ENDIF
                ENDFOR
                nx0 = nx        ;Save sizes.
                ny0 = ny
            ENDIF
            dx = x - mx0 & dy = y - my0 ;Distance dragged...
            CASE corner OF
                0: BEGIN 
                    x0 = x00 + dx
                    y0 = y00 + dy
                    nx = (nx0 - dx) > 1 < limits(4)
                    ny = (ny0 - dy) > 1 < limits(5)
                END
                1: BEGIN 
                    y0 = y00 + dy
                    nx = (nx0 + dx) > 1 < limits(4)
                    ny = (ny0 - dy) > 1 < limits(5)
                END
                2: BEGIN 
                    nx = (nx0 + dx) > 1 < limits(4)
                    ny = (ny0 + dy) > 1 < limits(5)
                END
                3: BEGIN 
                    x0 = x00 + dx
                    nx = (nx0 - dx) > 1 < limits(4)
                    ny = (ny0 + dy) > 1 < limits(5)
                END
            ENDCASE
        ENDIF ELSE BEGIN
            IF old_button EQ 0 THEN BEGIN ;Find closest corner
                mind = 1e6
                FOR i = 0, 3 DO BEGIN
                    d = float(px(i)-x)^2 + float(py(i)-y)^2
                    IF d LT mind THEN BEGIN
                        mind = d
                        corner = i
                    ENDIF
                ENDFOR
                nx0 = nx        ;Save sizes.
                ny0 = ny
            ENDIF
            
;               dx = x - mx0 & dy = y - my0     ;Distance dragged...
            dx = x - mx0 & dy = fix((nx+dx)*asp_rat+.5) - ny
            CASE corner OF
                0: BEGIN 
                    x0 = x00 + dx
                    y0 = y00 + dy
                    nx = (nx0 - dx) > 1 < limits(4) 
                    ny = (ny0 - dy) > 1 < limits(5) 
                END
                1: BEGIN 
                    y0 = y00 - dy
                    nx = (nx0 + dx) > 1 < limits(4) 
                    ny = (ny0 + dy) > 1 < limits(5) 
                END
                2: BEGIN 
                    nx = (nx0 + dx) > 1 < limits(4)
                    ny = (ny0 + dy) > 1 < limits(5)
                END
                3: BEGIN 
                    x0 = x00 + dx
                    nx = (nx0 - dx) > 1 < limits(4)
                    ny = (ny0 - dy) > 1 < limits(5)
                END
            ENDCASE
        ENDELSE
    ENDIF
     ;;; Erase previous box
    plots, px, py, col = col, /dev, thick = 1, lines = 0
    empty                       ;Decwindow bug
    IF !Err EQ 4 THEN BEGIN     ;Quitting?
        device, set_graphics = old
        IF keyword_set(plr) THEN BEGIN
            x0 = (float(x0)/!D.x_size-!X.window(0)) * $
              (!X.crange(1)-!X.crange(0))/(!X.window(1)-!X.window(0))
            y0 = (float(y0)/!D.y_size-!Y.window(0)) * $
              (!Y.crange(1)-!Y.crange(0))/(!Y.window(1)-!Y.window(0))
            nx = float(nx)/!D.x_size * $
              (!X.crange(1)-!X.crange(0))/(!X.window(1)-!X.window(0))
            ny = float(ny)/!D.y_size * $
              (!Y.crange(1)-!Y.crange(0))/(!Y.window(1)-!Y.window(0))
        ENDIF
        IF keyword_set(mark) THEN plots, px, py, /dev
        IF keyword_set(verbose) THEN print, x0, y0, nx, ny
        return
    ENDIF
Middle:
    x0 = x0 > limits(0)
    y0 = y0 > limits(1)
    x0 = x0 < (limits(2) - nx) ;Never outside window
    y0 = y0 < (limits(3) - ny)
    
    px = [x0, x0 + nx, x0 + nx, x0, x0] ;X points
    py = [y0, y0, y0 + ny, y0 + ny, y0] ;Y values
    
    plots, px, py, col = col, /dev, thick = 1, lines = 0 ;Draw the box
    wait, .1                    ;Dont hog it all
    
;;    IF keyword_set(verbose) THEN print, x0, y0, nx, ny
ENDWHILE
END



