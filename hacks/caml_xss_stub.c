/* Copyright for xscreensaver: (c) 1999-2018 Jamie Zawinski <jwz@jwz.org>
 * Copyright for caml_xss: (c) 2024 Florent Monnier
 * This file tryes to provide xss's entry points as ocaml stubs.
 *
 * BSD License for the XScreenSaver API:
 *
 * Permission to use, copy, modify, distribute, and sell this software and its
 * documentation for any purpose is hereby granted without fee, provided that
 * the above copyright notice appear in all copies and that both that
 * copyright notice and this permission notice appear in supporting
 * documentation.  No representations are made about the suitability of this
 * software for any purpose.  It is provided "as is" without express or 
 * implied warranty.
 *
 * License for caml_xss: To the extent permitted by law, you can use, modify,
 * and redistribute this software, and the associated elements.
 */

#include <caml/mlvalues.h>
#include <caml/callback.h>
#include <caml/memory.h>
#include <caml/alloc.h>

#include "screenhack.h"

#include <stdio.h>

/* Exchanging Display */

/* creating an ocaml value encapsulating a pointer to the Display */
static value Val_of_display(Display *d)
{
  value v = caml_alloc(1, Abstract_tag);
  *((Display **) Data_abstract_val(v)) = d;
  return v;
}

/* extract the pointer to the Display, encapsulated in a given value */
static Display * Display_of_val(value v)
{
  return *((Display **) Data_abstract_val(v));
}


/* Exchanging Window */

static value Val_of_window(Window *w)
{
  value v = caml_alloc(1, Abstract_tag);
  *((Window **) Data_abstract_val(v)) = w;
  return v;
}

static Window * Window_of_val(value v)
{
  return *((Window **) Data_abstract_val(v));
}

/* Exchanging GC */

static value Val_of_gc(GC *gc)
{
  value v = caml_alloc(1, Abstract_tag);
  *((GC **) Data_abstract_val(v)) = gc;
  return v;
}

static GC * Gc_of_val(value v)
{
  return *((GC **) Data_abstract_val(v));
}

/* State struct */

struct state {
  Display *display;
  Window window;
  GC gc;
  int num_screens;
  int delay;
  int w;
  int h;
  value caml_xss_elems;
  value caml_xss_state;
};

#if 0

static value Val_state(struct state *st)
{
  value v = caml_alloc(1, Abstract_tag);
  *((struct state **) Data_abstract_val(v)) = st;
  return v;
}

#define State_val(v) \
  *((struct state **) Data_abstract_val(v))

#endif


/* Exchanging X elements */

static value Val_x_elems(struct state *st)
{
  CAMLparam0();
  CAMLlocal1(elms);

  elms = caml_alloc(5, 0);

  Store_field(elms, 0, Val_of_display(st->display) );
  Store_field(elms, 1, Val_of_window(&(st->window)) );
  Store_field(elms, 2, Val_of_gc(&(st->gc)) );
  Store_field(elms, 3, Val_int(st->w) );
  Store_field(elms, 4, Val_int(st->h) );

  CAMLreturn(elms);
}

/* Colormap */

CAMLprim value
caml_xdefaultcolormap(value x_elems);

#define Colormap_val(cv) \
  ((Colormap) Nativeint_val(cv))

CAMLprim value
caml_xdefaultcolormap(value x_elems)
{
  Display *display = Display_of_val(Field(x_elems, 0));
  int screen_number = 0;
  Colormap colormap = XDefaultColormap(display, screen_number);
  return caml_copy_nativeint(colormap);
}

#if 0
Status XAllocColor(display, colormap, screen_in_out)
      Display *display;
      Colormap colormap;
      XColor *screen_in_out;

typedef struct {
	unsigned long pixel;			/* pixel value */
	unsigned short red, green, blue;	/* rgb values */
	char flags;				/* DoRed, DoGreen, DoBlue */
	char pad;
} XColor;

XFreeColors(display, colormap, pixels, npixels, planes)
      Display *display;
      Colormap colormap;
      unsigned long pixels[];
      int npixels;
      unsigned long planes;
#endif

CAMLprim value
caml_xalloccolor(value x_elems, value caml_colormap, value c);

CAMLprim value
caml_xsetforeground(value x_elems, value caml_pixel);

CAMLprim value
caml_xfreecolors(value x_elems, value caml_colormap, value caml_pixel);

CAMLprim value
caml_xalloccolor(value x_elems, value caml_colormap, value c)
{
  Display *display = Display_of_val(Field(x_elems, 0));
  XColor color;
  color.red   = Int_val(Field(c,0));
  color.green = Int_val(Field(c,1));
  color.blue  = Int_val(Field(c,2));
  Colormap colormap = Colormap_val(caml_colormap);
  Status status = XAllocColor(display, colormap, &color);
  return caml_copy_nativeint(color.pixel);
}

CAMLprim value
caml_xsetforeground(value x_elems, value caml_pixel)
{
  Display *display = Display_of_val(Field(x_elems, 0));
  GC *gc = Gc_of_val(Field(x_elems, 2));
  XSetForeground(display, *gc, Nativeint_val(caml_pixel));
  return Val_unit;
}

CAMLprim value
caml_xfreecolors(value x_elems, value caml_colormap, value caml_pixel)
{
  Display *display = Display_of_val(Field(x_elems, 0));
  Colormap colormap = Colormap_val(caml_colormap);
  int npixels = 1;
  unsigned long pixels[1];
  unsigned long planes = 0L;
  pixels[0] = Nativeint_val(caml_pixel);
  XFreeColors(display, colormap, pixels, npixels, planes);
  return Val_unit;
}


/* Prototypes */

void init_closure(struct state *st);
int draw_closure(struct state *st);
void free_closure(struct state *st);
void event_closure(struct state *st);
void reshape_closure(struct state *st, unsigned int w, unsigned int h);

CAMLprim value
caml_xdrawpoint(value x_elems, value p);

CAMLprim value
caml_xdrawrectangle(value x_elems, value r);

CAMLprim value
caml_xdrawline(value x_elems, value l);

CAMLprim value
caml_xdrawarc(value x_elems, value a);

CAMLprim value
caml_xfillrectangle(value x_elems, value r);

CAMLprim value
caml_xfillarc(value x_elems, value a);

CAMLprim value
caml_xfillpolygon(value x_elems, value ps);

/* Callbacks */

void init_closure(struct state *st)
{
  static const value * closure_f = NULL;
  if (closure_f == NULL) {
    closure_f = caml_named_value("init-callback");
  }
  caml_callback(*closure_f, Val_x_elems(st));
}

int draw_closure(struct state *st)
{
  static const value * closure_f = NULL;
  value delay;
  if (closure_f == NULL) {
    closure_f = caml_named_value("draw-callback");
  }
  delay = caml_callback(*closure_f, Val_x_elems(st));
  return Int_val(delay);
}

void event_closure(struct state *st)
{
  static const value * closure_f = NULL;
  if (closure_f == NULL) {
    closure_f = caml_named_value("event-callback");
  }
  caml_callback(*closure_f, Val_unit);
}

void reshape_closure(struct state *st, unsigned int w, unsigned int h)
{
  static const value * closure_f = NULL;
  if (closure_f == NULL) {
    closure_f = caml_named_value("reshape-callback");
  }
  caml_callback2(*closure_f, Val_int(w), Val_int(h));
}

void free_closure(struct state *st)
{
  static const value * closure_f = NULL;
  if (closure_f == NULL) {
    closure_f = caml_named_value("free-callback");
  }
  caml_callback(*closure_f, Val_unit);
}

/* X-lib bindings */

CAMLprim value
caml_xdrawpoint(value x_elems, value p)
{
  Display *display = Display_of_val( Field(x_elems, 0) );
  Window  *window  = Window_of_val(  Field(x_elems, 1) );
  GC      *gc      = Gc_of_val(      Field(x_elems, 2) );

  XDrawPoint(display, *window, *gc,
    Int_val(Field(p, 0)),
    Int_val(Field(p, 1)));

  return Val_unit;
}

CAMLprim value
caml_xdrawrectangle(value x_elems, value r)
{
  Display *display = Display_of_val( Field(x_elems, 0) );
  Window  *window  = Window_of_val(  Field(x_elems, 1) );
  GC      *gc      = Gc_of_val(      Field(x_elems, 2) );

  XDrawRectangle(display, *window, *gc,
    Int_val(Field(r, 0)),
    Int_val(Field(r, 1)),
    Int_val(Field(r, 2)),
    Int_val(Field(r, 3)));

  return Val_unit;
}

CAMLprim value
caml_xfillrectangle(value x_elems, value r)
{
  Display *display = Display_of_val( Field(x_elems, 0) );
  Window  *window  = Window_of_val(  Field(x_elems, 1) );
  GC      *gc      = Gc_of_val(      Field(x_elems, 2) );

  XFillRectangle(display, *window, *gc,
    Int_val(Field(r, 0)),
    Int_val(Field(r, 1)),
    Int_val(Field(r, 2)),
    Int_val(Field(r, 3)));

  return Val_unit;
}

CAMLprim value
caml_xdrawline(value x_elems, value l)
{
  Display *display = Display_of_val( Field(x_elems, 0) );
  Window  *window  = Window_of_val(  Field(x_elems, 1) );
  GC      *gc      = Gc_of_val(      Field(x_elems, 2) );

  XDrawLine(display, *window, *gc,
    Int_val(Field(l, 0)),
    Int_val(Field(l, 1)),
    Int_val(Field(l, 2)),
    Int_val(Field(l, 3)));

  return Val_unit;
}

CAMLprim value
caml_xdrawarc(value x_elems, value a)
{
  Display *display = Display_of_val( Field(x_elems, 0) );
  Window  *window  = Window_of_val(  Field(x_elems, 1) );
  GC      *gc      = Gc_of_val(      Field(x_elems, 2) );

  XDrawArc(display, *window, *gc,
    Int_val(Field(a, 0)),
    Int_val(Field(a, 1)),
    Int_val(Field(a, 2)),
    Int_val(Field(a, 3)),
    Int_val(Field(a, 4)),
    Int_val(Field(a, 5)));

  return Val_unit;
}

CAMLprim value
caml_xfillarc(value x_elems, value a)
{
  Display *display = Display_of_val( Field(x_elems, 0) );
  Window  *window  = Window_of_val(  Field(x_elems, 1) );
  GC      *gc      = Gc_of_val(      Field(x_elems, 2) );

  XFillArc(display, *window, *gc,
    Int_val(Field(a, 0)),
    Int_val(Field(a, 1)),
    Int_val(Field(a, 2)),
    Int_val(Field(a, 3)),
    Int_val(Field(a, 4)),
    Int_val(Field(a, 5)));

  return Val_unit;
}

CAMLprim value
caml_xfillpolygon(value x_elems, value ps)
{
  Display *display = Display_of_val( Field(x_elems, 0) );
  Window  *window  = Window_of_val(  Field(x_elems, 1) );
  GC      *gc      = Gc_of_val(      Field(x_elems, 2) );

  XPoint *points;
  int npoints;
  int shape;
  int mode;
  int i;

  shape = Complex;
  mode = CoordModePrevious;
  //mode = CoordModeOrigin;

  npoints = Wosize_val(ps);
  points = calloc(npoints, sizeof(XPoint));

  for (i=0; i < npoints; i++)
  {
    value p = Field(ps, i);
    points[i].x = Int_val(Field(p, 0));
    points[i].y = Int_val(Field(p, 1));
  }

  XFillPolygon(display, *window, *gc,
    points, npoints, shape, mode);

  free(points);
  return Val_unit;
}

/* Entry Points */

static void *
caml_xss_init (Display *display, Window window)
{
  struct state *st = (struct state *) calloc (1, sizeof(*st));
  //XGCValues gcv;

  st->display = display;
  st->window = window;
  st->gc = None;
  st->delay = 100000;

  int num_screens = XScreenCount(display);
  st->num_screens = num_screens;

  int screen_number = 0;
  st->gc = XDefaultGC(display, screen_number);

  int default_screen = 0;
  unsigned long fg = XWhitePixel(display, default_screen);

  XSetForeground(display, st->gc, fg);

  {
    XWindowAttributes xwa;
    XGetWindowAttributes(display, window, &xwa);
    st->w = xwa.width;
    st->h = xwa.height;
  }

  char *caml_argv[] = { "caml_xss", NULL };
  caml_main(caml_argv);

  init_closure(st);

  return st;
}

static unsigned long
caml_xss_draw (Display *display, Window window, void *closure)
{
  struct state *st = (struct state *) closure;

  st->delay = draw_closure(st);

  return st->delay;
}

static void
caml_xss_reshape (Display *display, Window window, void *closure, 
                   unsigned int w, unsigned int h)
{
  struct state *st = (struct state *) closure;
  st->w = w;
  st->h = h;
  reshape_closure(st, w, h);
}

static Bool
caml_xss_event (Display *display, Window window, void *closure, XEvent *event)
{
  struct state *st = (struct state *) closure;
  event_closure(st);
  return False;
}

static void
caml_xss_free (Display *display, Window window, void *closure)
{
  struct state *st = (struct state *) closure;

  free_closure(st);
  free(st);
}

static const char *caml_xss_defaults [] = {
  0
};

static XrmOptionDescRec caml_xss_options [] = {
  { 0, 0, 0, 0 }
};

XSCREENSAVER_MODULE ("caml_xss", caml_xss)
