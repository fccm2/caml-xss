type display
type window
type gc
type colormap
type pixel

type x_elems = {
  display: display;
  window: window;
  gc: gc;
  w: int;
  h: int;
}

module X : sig
  (* bindings elements *)
  val draw_point : x_elems -> int * int -> unit
  val draw_line : x_elems -> int * int * int * int -> unit
  val draw_rectangle : x_elems -> int * int * int * int -> unit
  val draw_arc : x_elems -> int * int * int * int * int * int -> unit
  val fill_rectangle : x_elems -> int * int * int * int -> unit
  val fill_arc : x_elems -> int * int * int * int * int * int -> unit
  val fill_polygon : x_elems -> (int * int) array -> unit
  val default_colormap : x_elems -> colormap
  val alloc_color : x_elems -> colormap -> int * int * int -> pixel
  val set_foreground : x_elems -> pixel -> unit
  val free_colors : x_elems -> colormap -> pixel -> unit
end

type user_calls = {
  user_draw : x_elems -> int;
  user_init : x_elems -> unit;
  user_reshape : int -> int -> unit;
}

val ref_user_calls : user_calls -> unit

val default_calls : user_calls

